import React, { useEffect, useState } from 'react'
import {
  collection, getDocs, addDoc, updateDoc, deleteDoc, doc,
} from 'firebase/firestore'
import { db } from '../services/firebase'
import toast from 'react-hot-toast'
import { FiPlus, FiEdit, FiTrash2, FiX } from 'react-icons/fi'

export default function SubjectsPage() {
  const [subjects, setSubjects] = useState([])
  const [chapters, setChapters] = useState([])
  const [showModal, setShowModal] = useState(false)
  const [editing, setEditing] = useState(null)
  const [form, setForm] = useState({
    name: '', nameHindi: '', icon: 'book', color: '#4CAF50',
    order: 0, totalChapters: 0, isFeatured: false,
    description: '', descriptionHindi: '',
  })

  useEffect(() => { loadAll() }, [])

  const loadAll = async () => {
    try {
      const [subjectsSnap, chaptersSnap] = await Promise.all([
        getDocs(collection(db, 'subjects')),
        getDocs(collection(db, 'chapters')),
      ])
      setSubjects(subjectsSnap.docs.map((d) => ({ id: d.id, ...d.data() })))
      setChapters(chaptersSnap.docs.map((d) => ({ id: d.id, ...d.data() })))
    } catch (error) {
      toast.error('Failed to load subjects')
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      if (editing) {
        await updateDoc(doc(db, 'subjects', editing.id), form)
        toast.success('Subject updated')
      } else {
        await addDoc(collection(db, 'subjects'), form)
        toast.success('Subject added')
      }
      setShowModal(false)
      loadAll()
    } catch (error) {
      toast.error('Failed to save subject')
    }
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this subject and its chapters?')) return
    try {
      const chaptersToDelete = chapters.filter((c) => c.subjectId === id)
      for (const ch of chaptersToDelete) {
        await deleteDoc(doc(db, 'chapters', ch.id))
      }
      await deleteDoc(doc(db, 'subjects', id))
      toast.success('Subject deleted')
      loadAll()
    } catch (error) {
      toast.error('Failed to delete subject')
    }
  }

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Subjects & Chapters</h1>
          <p className="text-gray-500 text-sm mt-1">{subjects.length} subjects</p>
        </div>
        <button
          onClick={() => {
            setEditing(null)
            setForm({ name: '', nameHindi: '', icon: 'book', color: '#4CAF50', order: subjects.length, totalChapters: 0, isFeatured: false, description: '', descriptionHindi: '' })
            setShowModal(true)
          }}
          className="btn-primary flex items-center gap-2"
        >
          <FiPlus className="w-4 h-4" /> Add Subject
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {subjects.map((subject, index) => {
          const subjectChapters = chapters.filter((c) => c.subjectId === subject.name)
          return (
            <div key={subject.id} className="card p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div
                    className="w-12 h-12 rounded-xl flex items-center justify-center text-white font-bold text-xl"
                    style={{ backgroundColor: subject.color || '#4CAF50' }}
                  >
                    {subject.name.charAt(0)}
                  </div>
                  <div>
                    <h3 className="font-bold">{subject.name}</h3>
                    <p className="text-xs text-gray-500">{subject.nameHindi}</p>
                  </div>
                </div>
                <div className="flex gap-1">
                  <button
                    onClick={() => { setEditing(subject); setForm(subject); setShowModal(true) }}
                    className="p-2 rounded-lg text-indigo-600 hover:bg-indigo-50"
                  >
                    <FiEdit className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(subject.id)}
                    className="p-2 rounded-lg text-red-600 hover:bg-red-50"
                  >
                    <FiTrash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {subject.isFeatured && (
                <span className="inline-block px-2 py-0.5 rounded-full bg-amber-100 text-amber-700 text-xs font-bold mb-2">
                  ⭐ Featured
                </span>
              )}

              <p className="text-sm text-gray-600 mb-3 line-clamp-2">{subject.description}</p>

              <div className="flex items-center justify-between text-sm text-gray-500 border-t pt-3">
                <span>{subjectChapters.length} chapters</span>
                <span>Order: {subject.order + 1}</span>
              </div>
            </div>
          )
        })}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center p-6 border-b">
              <h2 className="text-lg font-bold">{editing ? 'Edit Subject' : 'Add Subject'}</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-gray-100 rounded-lg">
                <FiX />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Name *</label>
                  <input className="input-field" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
                </div>
                <div>
                  <label className="label">Hindi Name</label>
                  <input className="input-field" value={form.nameHindi} onChange={(e) => setForm({ ...form, nameHindi: e.target.value })} />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Icon</label>
                  <select className="input-field" value={form.icon} onChange={(e) => setForm({ ...form, icon: e.target.value })}>
                    <option value="book">Book</option>
                    <option value="history">History</option>
                    <option value="gavel">Gavel (Pol Science)</option>
                    <option value="trending">Trending (Economics)</option>
                    <option value="public">Globe (Geography)</option>
                    <option value="people">People (Sociology)</option>
                    <option value="psychology">Brain (Psychology)</option>
                  </select>
                </div>
                <div>
                  <label className="label">Color</label>
                  <input type="color" className="input-field h-10 p-1" value={form.color} onChange={(e) => setForm({ ...form, color: e.target.value })} />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Order</label>
                  <input type="number" className="input-field" value={form.order} onChange={(e) => setForm({ ...form, order: parseInt(e.target.value) || 0 })} />
                </div>
                <div>
                  <label className="label">Featured</label>
                  <label className="flex items-center gap-2 mt-2">
                    <input type="checkbox" checked={form.isFeatured} onChange={(e) => setForm({ ...form, isFeatured: e.target.checked })} className="w-4 h-4 text-indigo-600" />
                    Show on Homepage
                  </label>
                </div>
              </div>
              <div>
                <label className="label">Description</label>
                <textarea className="input-field" rows="2" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} />
              </div>
              <div>
                <label className="label">Description (Hindi)</label>
                <textarea className="input-field" rows="2" value={form.descriptionHindi} onChange={(e) => setForm({ ...form, descriptionHindi: e.target.value })} />
              </div>
              <div className="flex justify-end gap-3 pt-4 border-t">
                <button type="button" onClick={() => setShowModal(false)} className="btn-secondary">Cancel</button>
                <button type="submit" className="btn-primary">{editing ? 'Update' : 'Add'}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}