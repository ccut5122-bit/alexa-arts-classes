import React, { useEffect, useState } from 'react'
import {
  collection,
  getDocs,
  addDoc,
  updateDoc,
  deleteDoc,
  doc,
} from 'firebase/firestore'
import { db } from '../services/firebase'
import toast from 'react-hot-toast'
import { FiEdit, FiTrash2, FiPlus, FiSearch, FiX, FiImage } from 'react-icons/fi'

const emptyQuestion = {
  subjectId: '',
  chapterId: '',
  type: 'mcq',
  questionText: '',
  questionTextHindi: '',
  questionImageUrl: '',
  options: [
    { id: 'a', text: '' },
    { id: 'b', text: '' },
    { id: 'c', text: '' },
    { id: 'd', text: '' },
  ],
  correctOption: 'a',
  explanation: '',
  explanationHindi: '',
  difficulty: 'medium',
  tags: [],
  source: 'Custom',
  year: null,
  marks: 1,
  negativeMarks: 0.25,
}

export default function QuestionsPage() {
  const [questions, setQuestions] = useState([])
  const [subjects, setSubjects] = useState([])
  const [chapters, setChapters] = useState([])
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editing, setEditing] = useState(null)
  const [form, setForm] = useState(emptyQuestion)
  const [filterSubject, setFilterSubject] = useState('')
  const [filterDifficulty, setFilterDifficulty] = useState('')

  useEffect(() => {
    loadAll()
  }, [])

  const loadAll = async () => {
    setLoading(true)
    try {
      const [questionsSnap, subjectsSnap, chaptersSnap] = await Promise.all([
        getDocs(collection(db, 'questions')),
        getDocs(collection(db, 'subjects')),
        getDocs(collection(db, 'chapters')),
      ])

      setQuestions(
        questionsSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }))
      )
      setSubjects(
        subjectsSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }))
      )
      setChapters(
        chaptersSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }))
      )
    } catch (error) {
      toast.error('Failed to load data: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const filteredQuestions = questions.filter((q) => {
    const matchesSearch =
      search === '' ||
      q.questionText?.toLowerCase().includes(search.toLowerCase())
    const matchesSubject =
      filterSubject === '' || q.subjectId === filterSubject
    const matchesDifficulty =
      filterDifficulty === '' || q.difficulty === filterDifficulty
    return matchesSearch && matchesSubject && matchesDifficulty
  })

  const openCreateModal = () => {
    setEditing(null)
    setForm(emptyQuestion)
    setShowModal(true)
  }

  const openEditModal = (question) => {
    setEditing(question)
    setForm({
      ...question,
      options: question.options || emptyQuestion.options,
      tags: question.tags || [],
    })
    setShowModal(true)
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      if (editing) {
        await updateDoc(doc(db, 'questions', editing.id), form)
        toast.success('Question updated successfully')
      } else {
        await addDoc(collection(db, 'questions'), form)
        toast.success('Question added successfully')
      }
      setShowModal(false)
      loadAll()
    } catch (error) {
      toast.error('Failed to save: ' + error.message)
    }
  }

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this question?')) return
    try {
      await deleteDoc(doc(db, 'questions', id))
      toast.success('Question deleted')
      loadAll()
    } catch (error) {
      toast.error('Failed to delete: ' + error.message)
    }
  }

  const updateOption = (index, field, value) => {
    const newOptions = [...form.options]
    newOptions[index] = { ...newOptions[index], [field]: value }
    setForm({ ...form, options: newOptions })
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">MCQ Management</h1>
          <p className="text-gray-500 text-sm mt-1">
            {filteredQuestions.length} questions
          </p>
        </div>
        <button onClick={openCreateModal} className="btn-primary flex items-center gap-2">
          <FiPlus className="w-4 h-4" />
          Add Question
        </button>
      </div>

      {/* Filters */}
      <div className="flex gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search questions..."
            className="input-field pl-10"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select
          className="input-field w-48"
          value={filterSubject}
          onChange={(e) => setFilterSubject(e.target.value)}
        >
          <option value="">All Subjects</option>
          {subjects.map((s) => (
            <option key={s.id} value={s.name}>{s.name}</option>
          ))}
        </select>
        <select
          className="input-field w-40"
          value={filterDifficulty}
          onChange={(e) => setFilterDifficulty(e.target.value)}
        >
          <option value="">All Difficulty</option>
          <option value="easy">Easy</option>
          <option value="medium">Medium</option>
          <option value="hard">Hard</option>
        </select>
      </div>

      {/* Questions list */}
      <div className="card overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Question</th>
              <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Subject</th>
              <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Difficulty</th>
              <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Source</th>
              <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Marks</th>
              <th className="text-center px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {filteredQuestions.map((q) => (
              <tr key={q.id} className="hover:bg-gray-50 transition-colors">
                <td className="px-6 py-4">
                  <p className="text-sm font-medium text-gray-800 line-clamp-2 max-w-md">
                    {q.questionText}
                  </p>
                  <p className="text-xs text-gray-400 mt-1">
                    Correct: {q.options?.find(o => o.id === q.correctOption)?.text || q.correctOption}
                  </p>
                </td>
                <td className="px-6 py-4">
                  <span className="px-2 py-1 rounded-full bg-indigo-50 text-indigo-700 text-xs font-medium">
                    {q.subjectId || '—'}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                    q.difficulty === 'easy'
                      ? 'bg-green-50 text-green-700'
                      : q.difficulty === 'hard'
                      ? 'bg-red-50 text-red-700'
                      : 'bg-amber-50 text-amber-700'
                  }`}>
                    {q.difficulty || 'medium'}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <span className="text-sm text-gray-600">
                    {q.source}{q.year ? ` (${q.year})` : ''}
                  </span>
                </td>
                <td className="px-6 py-4 text-sm text-gray-600">{q.marks ?? 1}</td>
                <td className="px-6 py-4">
                  <div className="flex justify-center space-x-2">
                    <button
                      onClick={() => openEditModal(q)}
                      className="p-2 rounded-lg text-indigo-600 hover:bg-indigo-50"
                    >
                      <FiEdit className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(q.id)}
                      className="p-2 rounded-lg text-red-600 hover:bg-red-50"
                    >
                      <FiTrash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
            {filteredQuestions.length === 0 && (
              <tr>
                <td colSpan="6" className="px-6 py-16 text-center">
                  <FiSearch className="w-12 h-12 mx-auto text-gray-300 mb-4" />
                  <p className="text-gray-500 font-medium">No questions found</p>
                  <p className="text-gray-400 text-sm mt-1">
                    Adjust your filters or add new questions
                  </p>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <h2 className="text-lg font-bold text-gray-900">
                {editing ? 'Edit Question' : 'Add New Question'}
              </h2>
              <button
                onClick={() => setShowModal(false)}
                className="p-2 rounded-lg hover:bg-gray-100"
              >
                <FiX className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-6">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Subject *</label>
                  <select
                    className="input-field"
                    value={form.subjectId}
                    onChange={(e) => setForm({ ...form, subjectId: e.target.value })}
                    required
                  >
                    <option value="">Select subject</option>
                    {subjects.map((s) => (
                      <option key={s.id} value={s.name}>{s.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="label">Chapter</label>
                  <select
                    className="input-field"
                    value={form.chapterId}
                    onChange={(e) => setForm({ ...form, chapterId: e.target.value })}
                  >
                    <option value="">Select chapter (optional)</option>
                    {chapters
                      .filter((c) => c.subjectId === form.subjectId)
                      .map((c) => (
                        <option key={c.id} value={c.id}>
                          {c.chapterNumber}. {c.title}
                        </option>
                      ))}
                  </select>
                </div>
              </div>

              <div>
                <label className="label">Question Text *</label>
                <textarea
                  className="input-field"
                  rows="3"
                  value={form.questionText}
                  onChange={(e) => setForm({ ...form, questionText: e.target.value })}
                  placeholder="Enter the question..."
                  required
                />
              </div>

              <div>
                <label className="label">Question Text (Hindi)</label>
                <textarea
                  className="input-field"
                  rows="2"
                  value={form.questionTextHindi}
                  onChange={(e) => setForm({ ...form, questionTextHindi: e.target.value })}
                  placeholder="प्रश्न हिंदी में..."
                />
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="label">Question Image URL</label>
                  <input
                    className="input-field"
                    value={form.questionImageUrl}
                    onChange={(e) => setForm({ ...form, questionImageUrl: e.target.value })}
                    placeholder="https://..."
                  />
                </div>
                <div>
                  <label className="label">Difficulty</label>
                  <select
                    className="input-field"
                    value={form.difficulty}
                    onChange={(e) => setForm({ ...form, difficulty: e.target.value })}
                  >
                    <option value="easy">Easy</option>
                    <option value="medium">Medium</option>
                    <option value="hard">Hard</option>
                  </select>
                </div>
                <div>
                  <label className="label">Source</label>
                  <input
                    className="input-field"
                    value={form.source}
                    onChange={(e) => setForm({ ...form, source: e.target.value })}
                    placeholder="JAC PYQ / Custom"
                  />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="label">Year (PYQ)</label>
                  <input
                    type="number"
                    className="input-field"
                    value={form.year || ''}
                    onChange={(e) => setForm({ ...form, year: parseInt(e.target.value) || null })}
                    placeholder="2024"
                  />
                </div>
                <div>
                  <label className="label">Marks</label>
                  <input
                    type="number"
                    className="input-field"
                    value={form.marks}
                    onChange={(e) => setForm({ ...form, marks: parseInt(e.target.value) || 1 })}
                    step="1"
                  />
                </div>
                <div>
                  <label className="label">Negative Marks</label>
                  <input
                    type="number"
                    className="input-field"
                    value={form.negativeMarks}
                    onChange={(e) => setForm({ ...form, negativeMarks: parseFloat(e.target.value) || 0 })}
                    step="0.25"
                  />
                </div>
              </div>

              {/* Options */}
              <div>
                <label className="label">Options *</label>
                <div className="space-y-3">
                  {form.options.map((option, index) => (
                    <div key={index} className="flex items-center gap-3">
                      <span className="w-8 h-8 flex items-center justify-center bg-indigo-50 text-indigo-700 font-bold rounded-lg">
                        {option.id.toUpperCase()}
                      </span>
                      <input
                        className="input-field"
                        value={option.text}
                        onChange={(e) => updateOption(index, 'text', e.target.value)}
                        placeholder={`Option ${option.id.toUpperCase()} text`}
                      />
                      <label className="flex items-center gap-2 cursor-pointer">
                        <input
                          type="radio"
                          name="correctOption"
                          checked={form.correctOption === option.id}
                          onChange={() => setForm({ ...form, correctOption: option.id })}
                          className="w-4 h-4 text-indigo-600"
                        />
                        <span className="text-xs text-gray-500">Correct</span>
                      </label>
                      <input
                        className="input-field w-32"
                        value={option.imageUrl || ''}
                        onChange={(e) => updateOption(index, 'imageUrl', e.target.value)}
                        placeholder="Image URL (optional)"
                      />
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <label className="label">Explanation</label>
                <textarea
                  className="input-field"
                  rows="3"
                  value={form.explanation}
                  onChange={(e) => setForm({ ...form, explanation: e.target.value })}
                  placeholder="Explain why this answer is correct..."
                />
              </div>

              <div>
                <label className="label">Tags (comma-separated)</label>
                <input
                  className="input-field"
                  value={form.tags?.join(', ') || ''}
                  onChange={(e) =>
                    setForm({
                      ...form,
                      tags: e.target.value.split(',').map((t) => t.trim()).filter(Boolean),
                    })
                  }
                  placeholder="important, pyq_2024"
                />
              </div>

              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="btn-secondary"
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary">
                  {editing ? 'Update Question' : 'Add Question'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}