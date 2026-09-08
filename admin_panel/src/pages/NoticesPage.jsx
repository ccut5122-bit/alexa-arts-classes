import React, { useEffect, useState } from 'react'
import { doc, getDoc, setDoc } from 'firebase/firestore'
import { db } from '../services/firebase'
import toast from 'react-hot-toast'
import { FiPlus, FiTrash2, FiX } from 'react-icons/fi'

export default function NoticesPage() {
  const [notices, setNotices] = useState([])
  const [showModal, setShowModal] = useState(false)
  const [form, setForm] = useState({
    title: '', body: '', type: 'info', isPopup: false, isActive: true,
    expiresAt: null, createdAt: new Date(),
  })

  useEffect(() => { loadNotices() }, [])

  const loadNotices = async () => {
    try {
      const noticeDoc = await getDoc(doc(db, 'dynamicConfig', 'noticeBoard'))
      if (noticeDoc.exists()) {
        setNotices(noticeDoc.data().notices || [])
      }
    } catch (error) {
      toast.error('Failed to load notices')
    }
  }

  const saveNotices = async (newNotices) => {
    try {
      await setDoc(doc(db, 'dynamicConfig', 'noticeBoard'), {
        notices: newNotices,
        updatedAt: new Date(),
      })
      setNotices(newNotices)
      toast.success('Notice board updated!')
    } catch (error) {
      toast.error('Failed to save notices')
    }
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    const newNotice = {
      ...form,
      id: Date.now().toString(),
      createdAt: new Date(),
    }
    saveNotices([newNotice, ...notices])
    setShowModal(false)
    setForm({ title: '', body: '', type: 'info', isPopup: false, isActive: true, expiresAt: null, createdAt: new Date() })
  }

  const handleDelete = (id) => {
    if (!confirm('Delete this notice?')) return
    saveNotices(notices.filter((n) => n.id !== id))
  }

  const toggleActive = (id) => {
    saveNotices(notices.map((n) => n.id === id ? { ...n, isActive: !n.isActive } : n))
  }

  const typeColors = {
    info: 'bg-blue-50 text-blue-700',
    warning: 'bg-amber-50 text-amber-700',
    urgent: 'bg-red-50 text-red-700',
  }

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">In-App Notice Board</h1>
          <p className="text-gray-500 text-sm mt-1">
            Flash notifications and popup banners sent instantly to all users
          </p>
        </div>
        <button onClick={() => setShowModal(true)} className="btn-primary flex items-center gap-2">
          <FiPlus className="w-4 h-4" /> New Notice
        </button>
      </div>

      <div className="space-y-4">
        {notices.map((notice) => (
          <div key={notice.id} className="card p-6 flex items-start justify-between">
            <div className="flex-1 mr-4">
              <div className="flex items-center gap-3 mb-2">
                <span className={`px-2 py-0.5 rounded-full text-xs font-bold ${typeColors[notice.type]}`}>
                  {notice.type.toUpperCase()}
                </span>
                {notice.isPopup && (
                  <span className="px-2 py-0.5 rounded-full bg-purple-50 text-purple-700 text-xs font-bold">
                    POPUP
                  </span>
                )}
              </div>
              <h3 className="font-bold text-lg">{notice.title}</h3>
              <p className="text-sm text-gray-600 mt-1">{notice.body}</p>
              <p className="text-xs text-gray-400 mt-2">
                Created: {new Date(notice.createdAt?.toDate?.() || notice.createdAt).toLocaleDateString()}
              </p>
            </div>
            <div className="flex flex-col gap-2">
              <button
                onClick={() => toggleActive(notice.id)}
                className={`px-3 py-1.5 rounded-lg text-xs font-medium ${
                  notice.isActive
                    ? 'bg-green-50 text-green-700 hover:bg-green-100'
                    : 'bg-gray-100 text-gray-500 hover:bg-gray-200'
                }`}
              >
                {notice.isActive ? 'Active' : 'Inactive'}
              </button>
              <button
                onClick={() => handleDelete(notice.id)}
                className="px-3 py-1.5 rounded-lg text-xs font-medium bg-red-50 text-red-700 hover:bg-red-100"
              >
                Delete
              </button>
            </div>
          </div>
        ))}

        {notices.length === 0 && (
          <div className="card p-16 text-center">
            <p className="text-gray-400">No notices yet. Create your first notice!</p>
          </div>
        )}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg">
            <div className="flex justify-between items-center p-6 border-b">
              <h2 className="text-lg font-bold">New Notice</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-gray-100 rounded-lg">
                <FiX />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="label">Title *</label>
                <input
                  className="input-field"
                  value={form.title}
                  onChange={(e) => setForm({ ...form, title: e.target.value })}
                  placeholder="e.g., JAC Board Admit Card Released!"
                  required
                />
              </div>
              <div>
                <label className="label">Body *</label>
                <textarea
                  className="input-field"
                  rows="3"
                  value={form.body}
                  onChange={(e) => setForm({ ...form, body: e.target.value })}
                  placeholder="Notice details..."
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
                    <option value="info">Info</option>
                    <option value="warning">Warning</option>
                    <option value="urgent">Urgent</option>
                  </select>
                </div>
              </div>
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={form.isPopup}
                  onChange={(e) => setForm({ ...form, isPopup: e.target.checked })}
                  className="w-4 h-4 text-indigo-600"
                />
                Show as Popup Dialog
              </label>
              <div className="flex justify-end gap-3 pt-4 border-t">
                <button type="button" onClick={() => setShowModal(false)} className="btn-secondary">Cancel</button>
                <button type="submit" className="btn-primary">Send Notice</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}