import React, { useEffect, useState } from 'react'
import {
  collection, getDocs, updateDoc, doc, query, where,
} from 'firebase/firestore'
import { db } from '../services/firebase'
import toast from 'react-hot-toast'
import { FiUserX, FiUserCheck, FiSearch, FiDownload, FiShield } from 'react-icons/fi'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

export default function UsersPage() {
  const [users, setUsers] = useState([])
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState('all')

  useEffect(() => { loadUsers() }, [])

  const loadUsers = async () => {
    setLoading(true)
    try {
      const snap = await getDocs(collection(db, 'users'))
      setUsers(snap.docs.map((d) => ({ id: d.id, ...d.data() })))
    } catch (error) {
      toast.error('Failed to load users')
    } finally {
      setLoading(false)
    }
  }

  const toggleBan = async (user) => {
    try {
      await updateDoc(doc(db, 'users', user.id), { isBanned: !user.isBanned })
      toast.success(user.isBanned ? 'User unbanned' : 'User banned')
      loadUsers()
    } catch (error) {
      toast.error('Failed to update user')
    }
  }

  const togglePremium = async (user) => {
    try {
      await updateDoc(doc(db, 'users', user.id), { isPremium: !user.isPremium })
      toast.success(user.isPremium ? 'Premium removed' : 'Premium granted')
      loadUsers()
    } catch (error) {
      toast.error('Failed to update user')
    }
  }

  const exportUsers = () => {
    const ws = XLSX.utils.json_to_sheet(users)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Users')
    const wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
    saveAs(new Blob([wbout], { type: 'application/octet-stream' }), 'users.xlsx')
    toast.success('Exported to Excel')
  }

  const filteredUsers = users.filter((user) => {
    const matchesSearch =
      search === '' ||
      user.displayName?.toLowerCase().includes(search.toLowerCase()) ||
      user.email?.toLowerCase().includes(search.toLowerCase()) ||
      user.district?.toLowerCase().includes(search.toLowerCase())
    const matchesFilter =
      filter === 'all' ||
      (filter === 'banned' && user.isBanned) ||
      (filter === 'premium' && user.isPremium) ||
      (filter === 'admin' && user.role === 'admin')
    return matchesSearch && matchesFilter
  })

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Users Management</h1>
          <p className="text-gray-500 text-sm mt-1">{filteredUsers.length} users</p>
        </div>
        <button onClick={exportUsers} className="btn-secondary flex items-center gap-2">
          <FiDownload className="w-4 h-4" /> Export Excel
        </button>
      </div>

      <div className="flex gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search by name, email, or district..."
            className="input-field pl-10"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select className="input-field w-40" value={filter} onChange={(e) => setFilter(e.target.value)}>
          <option value="all">All Users</option>
          <option value="premium">Premium</option>
          <option value="banned">Banned</option>
          <option value="admin">Admins</option>
        </select>
      </div>

      {loading ? (
        <div className="flex justify-center py-20"><div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div></div>
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">User</th>
                <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">District</th>
                <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Coins</th>
                <th className="text-left px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Status</th>
                <th className="text-center px-6 py-3 text-xs font-semibold text-gray-600 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filteredUsers.map((user) => (
                <tr key={user.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-indigo-50 flex items-center justify-center">
                        <span className="font-bold text-indigo-600">{(user.displayName || 'U')[0].toUpperCase()}</span>
                      </div>
                      <div>
                        <p className="font-medium text-gray-800">{user.displayName || 'No name'}</p>
                        <p className="text-xs text-gray-500">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-600">{user.district || '—'}</td>
                  <td className="px-6 py-4">
                    <span className="font-bold text-amber-600">🪙 {user.gamification?.coins ?? 0}</span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="space-y-1">
                      {user.isBanned && (
                        <span className="px-2 py-1 rounded-full bg-red-50 text-red-700 text-xs font-medium">Banned</span>
                      )}
                      {user.isPremium && (
                        <span className="px-2 py-1 rounded-full bg-purple-50 text-purple-700 text-xs font-medium">Premium</span>
                      )}
                      {user.role === 'admin' && (
                        <span className="px-2 py-1 rounded-full bg-blue-50 text-blue-700 text-xs font-medium">Admin</span>
                      )}
                      {!user.isBanned && !user.isPremium && user.role !== 'admin' && (
                        <span className="px-2 py-1 rounded-full bg-gray-50 text-gray-500 text-xs font-medium">Active</span>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex justify-center gap-2">
                      <button
                        onClick={() => togglePremium(user)}
                        className="px-3 py-1.5 rounded-lg text-xs font-medium bg-purple-50 text-purple-700 hover:bg-purple-100"
                      >
                        {user.isPremium ? 'Remove Premium' : 'Make Premium'}
                      </button>
                      <button
                        onClick={() => toggleBan(user)}
                        className={`px-3 py-1.5 rounded-lg text-xs font-medium ${
                          user.isBanned
                            ? 'bg-green-50 text-green-700 hover:bg-green-100'
                            : 'bg-red-50 text-red-700 hover:bg-red-100'
                        }`}
                      >
                        {user.isBanned ? <span className="flex items-center gap-1"><FiUserCheck /> Unban</span> : <span className="flex items-center gap-1"><FiUserX /> Ban</span>}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {filteredUsers.length === 0 && (
                <tr>
                  <td colSpan="5" className="px-6 py-16 text-center">
                    <p className="text-gray-500 font-medium">No users found</p>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}