import React, { useState, useRef } from 'react'
import { collection, doc, writeBatch } from 'firebase/firestore'
import { db } from '../services/firebase'
import toast from 'react-hot-toast'
import Papa from 'papaparse'
import { FiUpload, FiDownload, FiCheckCircle, FiXCircle, FiFileText } from 'react-icons/fi'

const REQUIRED_HEADERS = [
  'subjectId', 'questionText', 'option_a', 'option_b',
  'option_c', 'option_d', 'correctOption', 'explanation',
]

export default function BulkUploadPage() {
  const [selectedFile, setSelectedFile] = useState(null)
  const [previewData, setPreviewData] = useState([])
  const [error, setError] = useState(null)
  const [uploading, setUploading] = useState(false)
  const fileInputRef = useRef(null)

  const downloadTemplate = () => {
    const template = [
      REQUIRED_HEADERS,
      [
        'History', 'Which battle established British rule in India?',
        'Battle of Buxar', 'Battle of Plassey', 'Battle of Panipat', 'Battle of Haldighati',
        'b', 'The Battle of Plassey in 1757 established British dominance.',
      ],
      [
        'Political Science', 'What is the supreme law of India?',
        'The Constitution', 'The Parliament', 'The President', 'The Supreme Court',
        'a', 'The Constitution of India is the supreme law of the land.',
      ],
    ]

    const csv = Papa.unparse(template)
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'alexa_mcq_template.csv'
    a.click()
    URL.revokeObjectURL(url)
    toast.success('Template downloaded!')
  }

  const handleFileSelect = (e) => {
    const file = e.target.files[0]
    if (!file) return
    setSelectedFile(file)
    setError(null)

    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      complete: (results) => {
        if (results.errors.length > 0) {
          setError('Error parsing file: ' + results.errors[0].message)
          setPreviewData([])
          return
        }

        const data = results.data
        if (data.length === 0) {
          setError('File is empty')
          setPreviewData([])
          return
        }

        // Validate headers
        const headers = Object.keys(data[0])
        const missingHeaders = REQUIRED_HEADERS.filter((h) => !headers.includes(h))
        if (missingHeaders.length > 0) {
          setError(`Missing required columns: ${missingHeaders.join(', ')}`)
          setPreviewData([])
          return
        }

        setPreviewData(data.slice(0, 5))
        toast.success(`Parsed ${results.data.length} questions!`)
      },
    })
  }

  const validateAndTransform = (data) => {
    const questions = []
    const errors = []

    data.forEach((row, index) => {
      try {
        if (!row.questionText) {
          errors.push(`Row ${index + 2}: Missing question text`)
          return
        }

        const options = [
          { id: 'a', text: (row.option_a || '').trim() },
          { id: 'b', text: (row.option_b || '').trim() },
          { id: 'c', text: (row.option_c || '').trim() },
          { id: 'd', text: (row.option_d || '').trim() },
        ].filter((o) => o.text)

        if (options.length < 2) {
          errors.push(`Row ${index + 2}: Need at least 2 options`)
          return
        }

        const correctOption = (row.correctOption || '').toLowerCase().trim()
        if (!['a', 'b', 'c', 'd'].includes(correctOption)) {
          errors.push(`Row ${index + 2}: Invalid correctOption "${correctOption}"`)
          return
        }

        questions.push({
          subjectId: (row.subjectId || '').trim(),
          chapterId: (row.chapterId || '').trim(),
          type: row.type || 'mcq',
          questionText: row.questionText.trim(),
          questionTextHindi: (row.questionTextHindi || '').trim(),
          questionImageUrl: (row.questionImageUrl || '').trim(),
          options: [
            { id: 'a', text: (row.option_a || '').trim() },
            { id: 'b', text: (row.option_b || '').trim() },
            { id: 'c', text: (row.option_c || '').trim() },
            { id: 'd', text: (row.option_d || '').trim() },
          ],
          correctOption,
          explanation: (row.explanation || '').trim(),
          explanationHindi: (row.explanationHindi || '').trim(),
          difficulty: (row.difficulty || 'medium').toLowerCase(),
          tags: (row.tags || '').split(',').map((t) => t.trim()).filter(Boolean),
          source: (row.source || 'Custom').trim(),
          year: row.year ? parseInt(row.year) : null,
          marks: row.marks ? parseInt(row.marks) : 1,
          negativeMarks: row.negativeMarks ? parseFloat(row.negativeMarks) : 0.25,
        })
      } catch (err) {
        errors.push(`Row ${index + 2}: ${err.message}`)
      }
    })

    return { questions, errors }
  }

  const handleUpload = async () => {
    if (!selectedFile) return
    setUploading(true)

    Papa.parse(selectedFile, {
      header: true,
      skipEmptyLines: true,
      complete: async (results) => {
        const { questions, errors } = validateAndTransform(results.data)

        if (errors.length > 0) {
          setError(`Validation errors:\n${errors.slice(0, 5).join('\n')}`)
          toast.error(`Found ${errors.length} rows with issues`)
          setUploading(false)
          return
        }

        if (questions.length === 0) {
          setError('No valid questions to upload')
          toast.error('No valid questions found')
          setUploading(false)
          return
        }

        try {
          // Upload in batches of 400
          for (let i = 0; i < questions.length; i += 400) {
            const batch = questions.slice(i, i + 400)
            const writeBatchRef = writeBatch(db)
            batch.forEach((q) => {
              const ref = collection(db, 'questions')
              // Use addDoc style via batch
              const docRef = doc(collection(db, 'questions'))
              writeBatchRef.set(docRef, q)
            })
            await writeBatchRef.commit()
          }

          toast.success(`Successfully uploaded ${questions.length} questions!`)
          setSelectedFile(null)
          setPreviewData([])
          if (fileInputRef.current) fileInputRef.current.value = ''
        } catch (err) {
          setError('Upload failed: ' + err.message)
          toast.error('Upload failed')
        } finally {
          setUploading(false)
        }
      },
    })
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Bulk MCQ Upload</h1>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card p-8 text-center">
          <div className="w-20 h-20 bg-indigo-50 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <FiFileText className="w-10 h-10 text-indigo-600" />
          </div>
          <h2 className="text-lg font-bold mb-2">Upload Excel / CSV</h2>
          <p className="text-sm text-gray-500 mb-6">
            Upload a CSV file with your questions. Download the template to see the required format.
          </p>

          <div className="flex flex-col gap-4">
            <button onClick={downloadTemplate} className="btn-secondary flex items-center justify-center gap-2">
              <FiDownload className="w-4 h-4" /> Download Template
            </button>

            <label className="btn-primary flex items-center justify-center gap-2 cursor-pointer">
              <FiUpload className="w-4 h-4" />
              {selectedFile ? selectedFile.name : 'Choose CSV File'}
              <input
                ref={fileInputRef}
                type="file"
                accept=".csv,.xlsx,.xls"
                onChange={handleFileSelect}
                className="hidden"
              />
            </label>

            {previewData.length > 0 && (
              <div className="mt-4 text-left bg-green-50 p-4 rounded-lg">
                <p className="text-sm text-green-700 font-medium flex items-center gap-2 mb-2">
                  <FiCheckCircle /> File parsed successfully!
                </p>
                <p className="text-xs text-green-600">
                  Preview of first {previewData.length} rows:
                </p>
              </div>
            )}

            {error && (
              <div className="mt-4 text-left bg-red-50 p-4 rounded-lg">
                <p className="text-sm text-red-700 font-medium flex items-center gap-2">
                  <FiXCircle /> {error}
                </p>
              </div>
            )}

            {previewData.length > 0 && (
              <button
                onClick={handleUpload}
                disabled={uploading}
                className="btn-primary flex items-center justify-center gap-2 disabled:opacity-50"
              >
                {uploading ? 'Uploading...' : 'Upload All Questions'}
              </button>
            )}
          </div>
        </div>

        <div>
          <h2 className="text-lg font-bold mb-4">Template Format</h2>
          <div className="card p-6">
            <h3 className="font-semibold text-sm mb-3">Required Columns:</h3>
            <div className="flex flex-wrap gap-2 mb-6">
              {REQUIRED_HEADERS.map((h) => (
                <span key={h} className="px-3 py-1 bg-gray-100 rounded-full text-xs font-mono">
                  {h}
                </span>
              ))}
            </div>

            <h3 className="font-semibold text-sm mb-3">Optional Columns:</h3>
            <div className="flex flex-wrap gap-2 mb-6">
              {['questionTextHindi', 'chapterId', 'type', 'difficulty', 'source', 'year', 'marks', 'negativeMarks', 'tags', 'questionImageUrl', 'explanationHindi'].map((h) => (
                <span key={h} className="px-3 py-1 bg-gray-50 rounded-full text-xs font-mono">
                  {h}
                </span>
              ))}
            </div>

            <div className="bg-gray-50 p-4 rounded-lg mb-4">
              <h3 className="font-semibold text-sm mb-2">Supported Subjects (subjectId):</h3>
              <p className="text-xs text-gray-600 font-mono">
                History, Political Science, Economics, Geography, Sociology, Psychology
              </p>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="font-semibold text-sm mb-2">Supported Sources:</h3>
              <p className="text-xs text-gray-600 font-mono">JAC PYQ, NCERT, Custom</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}