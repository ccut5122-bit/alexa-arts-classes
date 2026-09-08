import React, { useEffect, useState } from 'react'
import {
  collection, getDocs, query, where, orderBy, limit, Timestamp,
} from 'firebase/firestore'
import { db } from '../services/firebase'
import {
  ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid,
  Tooltip, BarChart, Bar, PieChart, Pie, Cell, Legend,
} from 'recharts'

export default function AnalyticsPage() {
  const [activeUsers, setActiveUsers] = useState([])
  const [quizPerformance, setQuizPerformance] = useState([])
  const [subjectStats, setSubjectStats] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => { loadAllAnalytics() }, [])

  const loadAllAnalytics = async () => {
    setLoading(true)
    try {
      await Promise.all([loadActiveUsers(), loadSubjectAnalytics()])
    } catch (error) {
      console.error(error)
    } finally {
      setLoading(false)
    }
  }

  const loadActiveUsers = async () => {
    const usersSnap = await getDocs(collection(db, 'users'))
    const users = usersSnap.docs.map((d) => ({
      id: d.id,
      lastActive: d.data().lastActive?.toDate?.() || new Date(),
      gamification: d.data().gamification || {},
      district: d.data().district || 'Unknown',
    }))

    // Last 7 days activity
    const days = []
    for (let i = 6; i >= 0; i--) {
      const day = new Date()
      day.setHours(0, 0, 0, 0)
      day.setDate(day.getDate() - i)
      const nextDay = new Date(day)
      nextDay.setDate(nextDay.getDate() + 1)
      const count = users.filter((u) => {
        const time = u.lastActive
        return time >= day && time < nextDay
      }).length
      days.push({
        name: day.toLocaleDateString('en-US', { weekday: 'short' }),
        users: count,
      })
    }
    setActiveUsers(days)
  }

  const loadSubjectAnalytics = async () => {
    const [questionsSnap, usersSnap] = await Promise.all([
      getDocs(query(collection(db, 'questions'), where('source', '==', 'JAC PYQ'))),
      getDocs(collection(db, 'users')),
    ])

    // Questions per subject
    const subjectCount = {}
    questionsSnap.docs.forEach((d) => {
      const subject = d.data().subjectId || 'Unknown'
      subjectCount[subject] = (subjectCount[subject] || 0) + 1
    })
    setSubjectStats(Object.entries(subjectCount).map(([name, count]) => ({ name, count })))

    // Quiz performance distribution
    const districts = {}
    usersSnap.docs.forEach((d) => {
      const district = d.data().district || 'Unknown'
      const coins = d.data().gamification?.coins || 0
      if (!districts[district]) districts[district] = { users: 0, totalCoins: 0 }
      districts[district].users++
      districts[district].totalCoins += coins
    })
    setQuizPerformance(
      Object.entries(districts).map(([name, data]) => ({
        name,
        users: data.users,
        coins: data.totalCoins,
      }))
    )
  }

  const COLORS = ['#6366f1', '#a855f7', '#ec4899', '#f59e0b', '#10b981', '#3b82f6']

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>
    )
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Advanced Analytics</h1>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div className="card p-6">
          <h2 className="text-lg font-semibold mb-4">Active Users (Last 7 Days)</h2>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={activeUsers}>
              <defs>
                <linearGradient id="userGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#6366f1" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Area type="monotone" dataKey="users" stroke="#6366f1" fill="url(#userGrad)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="card p-6">
          <h2 className="text-lg font-semibold mb-4">PYQ Questions per Subject</h2>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={subjectStats}
                dataKey="count"
                nameKey="name"
                cx="50%"
                cy="50%"
                label
              >
                {subjectStats.map((_, index) => (
                  <Cell key={index} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="card p-6">
        <h2 className="text-lg font-semibold mb-4">District-wise Performance</h2>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={quizPerformance}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis allowDecimals={false} />
            <Tooltip />
            <Legend />
            <Bar dataKey="users" fill="#6366f1" name="Users" />
            <Bar dataKey="coins" fill="#f59e0b" name="Total Coins" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}