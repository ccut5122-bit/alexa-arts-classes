import React, { useState } from 'react'
import { addDoc, collection, serverTimestamp, getDoc, doc } from 'firebase/firestore'
import { db } from '../services/firebase'
import toast from 'react-hot-toast'
import { FiSend, FiZap } from 'react-icons/fi'

const triggerGithubWorker = async () => {
  try {
    const snap = await getDoc(doc(db, 'config', 'github'))
    if (!snap.exists()) return 'GitHub worker token config not set'
    const cfg = snap.data()
    const res = await fetch(
      `https://api.github.com/repos/${cfg.owner}/${cfg.repo}/actions/workflows/push-worker.yml/dispatches`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${cfg.githubToken}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ ref: 'main' }),
      }
    )
    if (!res.ok) return `Trigger failed (${res.status})`
    return null
  } catch (e) {
    return e.message
  }
}

export default function SendNotificationPage() {
  const [form, setForm] = useState({
    title: '',
    body: '',
    target: 'all',
    notificationType: 'general',
    link: '',
  })
  const [sending, setSending] = useState(false)

  const handleSend = async (e) => {
    e.preventDefault()
    setSending(true)
    try {
      await addDoc(collection(db, 'notifications'), {
        title: form.title,
        body: form.body,
        target: form.target,
        notificationType: form.notificationType,
        link: form.link || null,
        status: 'published',
        pushSent: false,
        createdAt: serverTimestamp(),
      })
      toast.success('Notification saved! Sending now...')
      const err = await triggerGithubWorker()
      if (err) {
        toast.error('Saved but push trigger failed: ' + err)
      } else {
        toast.success('Push sent instantly!')
      }
      setForm({ title: '', body: '', target: 'all', notificationType: 'general', link: '' })
    } catch (error) {
      toast.error('Failed to send: ' + error.message)
    } finally {
      setSending(false)
    }
  }

  return (
    <div className="p-8 max-w-2xl">
      <h1 className="text-2xl font-bold mb-2">Send Notification</h1>
      <p className="text-gray-500 text-sm mb-6">
        Send a push notification / banner to all app users instantly (seconds).
      </p>

      <form onSubmit={handleSend} className="card p-6 space-y-4">
        <div>
          <label className="label">Title *</label>
          <input
            className="input-field"
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            placeholder="e.g. New Notes Available!"
            required
          />
        </div>
        <div>
          <label className="label">Message *</label>
          <textarea
            className="input-field"
            rows="3"
            value={form.body}
            onChange={(e) => setForm({ ...form, body: e.target.value })}
            placeholder="e.g. History Chapter 3 notes uploaded."
            required
          />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="label">Target</label>
            <select
              className="input-field"
              value={form.target}
              onChange={(e) => setForm({ ...form, target: e.target.value })}
            >
              <option value="all">All Users</option>
              <option value="premium">Premium Only</option>
            </select>
          </div>
          <div>
            <label className="label">Type</label>
            <select
              className="input-field"
              value={form.notificationType}
              onChange={(e) => setForm({ ...form, notificationType: e.target.value })}
            >
              <option value="general">General</option>
              <option value="notice">Notice</option>
              <option value="exam">Exam Update</option>
            </select>
          </div>
        </div>
        <div>
          <label className="label">Link (optional)</label>
          <input
            className="input-field"
            value={form.link}
            onChange={(e) => setForm({ ...form, link: e.target.value })}
            placeholder="e.g. /chapter-list or https://..."
          />
        </div>
        <div className="flex justify-end pt-4 border-t">
          <button type="submit" disabled={sending} className="btn-primary flex items-center gap-2 disabled:opacity-50">
            {sending ? <FiZap className="w-4 h-4" /> : <FiSend className="w-4 h-4" />}
            {sending ? 'Sending...' : 'Send Now'}
          </button>
        </div>
      </form>
    </div>
  )
}