import React, { useEffect, useState } from 'react'
import {
  collection, getDocs, addDoc, updateDoc, deleteDoc, doc,
} from 'firebase/firestore'
import { db } from '../services/firebase'
import toast from 'react-hot-toast'
import { FiPlus, FiEdit, FiTrash2, FiX, FiEye } from 'react-icons/fi'

export default function QuizzesPage() {
  const [quizzes, setQuizzes] = useState([])
  const [showModal, setShowModal] = useState(false)
  const [editing, setEditing] = useState(null)
  const [form, setForm] = useState({
    title: '',
    type: 'chapter',
    subjectId: '',
    chapterIds: [],
    questionIds: [],
    totalQuestions: 10,
    timeLimit: 15,
    negativeMarking: true,
    negativeMarksPerWrong: 0.25,
    isLive: false,
  })

  useEffect(() => {
    loadQuizzes()
  }, [])

  const loadQuizzes = async () => {
    try {
      const snap = await getDocs(collection(db, 'quizzes'))
      setQuizzes(snap.docs.map((doc) => ({ id: doc.id, ...doc.data() })))
    } catch (error) {
      toast.error('Failed to load quizzes')
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      if (editing) {
        await updateDoc(doc(db, 'quizzes', editing.id), form)
        toast.success('Quiz updated')
      } else {
        await addDoc(collection(db, 'quizzes'), form)
        toast.success('Quiz created')
      }
      setShowModal(false)
      loadQuizzes()
    } catch (error) {
      toast.error('Failed to save quiz')
    }
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this quiz?')) return
    await deleteDoc(doc(db, 'quizzes', id))
    toast.success('Quiz deleted')
    loadQuizzes()
  }

  const toggleLive = async (quiz) => {
    await updateDoc(doc(db, 'quizzes', quiz.id), { isLive: !quiz.isLive })
    loadQuizzes()
  }

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Quizzes</h1>
          <p className="text-gray-500 text-sm mt-1">{quizzes.length} quizzes</p>
        </div>
        <button onClick={() => { setEditing(null); setForm({ title: '', type: 'chapter', subjectId: '', chapterIds: [], questionIds: [], totalQuestions: 10, timeLimit: 15, negativeMarking: true, negativeMarksPerWrong: 0.25, isLive: false }); setShowModal(true) }} className="btn-primary flex items-center gap-2">
          <FiPlus className="w-4 h-4" /> Create Quiz
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {quizzes.map((quiz) => (
          <div key={quiz.id} className="card p-6">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="font-bold text-lg">{quiz.title}</h3>
                <p className="text-sm text-gray-500">
                  {quiz.type} • {quiz.subjectId || 'All subjects'}
                </p>
              </div>
              <button
                onClick={() => toggleLive(quiz)}
                className={`px-3 py-1 rounded-full text-xs font-bold ${
                  quiz.isLive
                    ? 'bg-green-100 text-green-700'
                    : 'bg-gray-100 text-gray-500'
                }`}
              >
                {quiz.isLive ? 'LIVE' : 'DRAFT'}
              </button>
            </div>

            <div className="flex gap-4 text-sm text-gray-600 mb-4">
              <span>{quiz.totalQuestions} questions</span>
              <span>{quiz.timeLimit} min</span>
              <span>{quiz.negativeMarking ? 'Negative marking' : 'No negative'}</span>
            </div>

            <div className="flex justify-end gap-2">
              <button
                onClick={() => { setEditing(quiz); setForm(quiz); setShowModal(true) }}
                className="p-2 rounded-lg text-indigo-600 hover:bg-indigo-50"
              >
                <FiEdit />
              </button>
              <button
                onClick={() => handleDelete(quiz.id)}
                className="p-2 rounded-lg text-red-600 hover:bg-red-50"
              >
                <FiTrash2 />
              </button>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-xl max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center p-6 border-b">
              <h2 className="text-lg font-bold">{editing ? 'Edit Quiz' : 'Create Quiz'}</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-gray-100 rounded-lg">
                <FiX />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="label">Quiz Title *</label>
                <input
                  className="input-field"
                  value={form.title}
                  onChange={(e) => setForm({ ...form, title: e.target.value })}
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Type</label>
                  <select
                    className="input-field"
                    value={form.type}
                    onChange={(e) => setForm({ ...form, type: e.target.value })}
                  >
                    <option value="chapter">Chapter</option>
                    <option value="monthly">Monthly</option>
                    <option value="revision">Revision</option>
                    <option value="custom">Custom</option>
                  </select>
                </div>
                <div>
                  <label className="label">Subject</label>
                  <input
                    className="input-field"
                    value={form.subjectId}
                    onChange={(e) => setForm({ ...form, subjectId: e.target.value })}
                    placeholder="Subject name"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Total Questions</label>
                  <input
                    type="number"
                    className="input-field"
                    value={form.totalQuestions}
                    onChange={(e) => setForm({ ...form, totalQuestions: parseInt(e.target.value) })}
                  />
                </div>
                <div>
                  <label className="label">Time Limit (minutes)</label>
                  <input
                    type="number"
                    className="input-field"
                    value={form.timeLimit}
                    onChange={(e) => setForm({ ...form, timeLimit: parseInt(e.target.value) })}
                  />
                </div>
              </div>
              <div className="flex gap-6">
                <label className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={form.negativeMarking}
                    onChange={(e) => setForm({ ...form, negativeMarking: e.target.checked })}
                    className="w-4 h-4 text-indigo-600"
                  />
                  Negative Marking
                </label>
                {form.negativeMarking && (
                  <label className="flex items-center gap-2">
                    Marks per wrong:
                    <input
                      type="number"
                      step="0.25"
                      className="input-field w-20"
                      value={form.negativeMarksPerWrong}
                      onChange={(e) => setForm({ ...form, negativeMarksPerWrong: parseFloat(e.target.value) })}
                    />
                  </label>
                )}
              </div>
              <div className="flex justify-end gap-3 pt-4 border-t">
                <button type="button" onClick={() => setShowModal(false)} className="btn-secondary">Cancel</button>
                <button type="submit" className="btn-primary">{editing ? 'Update' : 'Create'}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}