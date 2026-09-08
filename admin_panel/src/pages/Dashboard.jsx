import React, { useEffect, useState } from 'react'
import {
  Users,
  FileQuestion,
  ListChecks,
  Activity,
  TrendingUp,
  Award,
  Target,
  Zap,
  Upload,
  Palette,
  Megaphone,
  BarChart3,
} from 'lucide-react'
import {
  collection,
  getDocs,
  query,
  where,
  orderBy,
  limit,
  Timestamp,
} from 'firebase/firestore'
import { db } from '../services/firebase'

export default function Dashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalQuestions: 0,
    totalQuizzes: 0,
    activeToday: 0,
    premiumUsers: 0,
    totalAttempts: 0,
  })
  const [recentUsers, setRecentUsers] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
    loadRecentUsers()
  }, [])

  const loadStats = async () => {
    try {
      const [
        usersSnap,
        questionsSnap,
        quizzesSnap,
        activeSnap,
        premiumSnap,
      ] = await Promise.all([
        getDocs(collection(db, 'users')),
        getDocs(collection(db, 'questions')),
        getDocs(collection(db, 'quizzes')),
        getDocs(
          query(
            collection(db, 'users'),
            where('lastActive', '>=', Timestamp.fromDate(new Date(Date.now() - 24 * 60 * 60 * 1000)))
          )
        ),
        getDocs(query(collection(db, 'users'), where('isPremium', '==', true))),
      ])

      setStats({
        totalUsers: usersSnap.size,
        totalQuestions: questionsSnap.size,
        totalQuizzes: quizzesSnap.size,
        activeToday: activeSnap.size,
        premiumUsers: premiumSnap.size,
      })
    } catch (error) {
      console.error('Error loading stats:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadRecentUsers = async () => {
    try {
      const snap = await getDocs(
        query(collection(db, 'users'), orderBy('lastActive', 'desc'), limit(5))
      )
      setRecentUsers(snap.docs.map((doc) => ({ id: doc.id, ...doc.data() })))
    } catch (error) {
      console.error('Error loading recent users:', error)
    }
  }

  const cards = [
    { label: 'Total Users', value: stats.totalUsers, icon: Users, color: 'text-indigo-600 bg-indigo-50' },
    { label: 'Questions', value: stats.totalQuestions, icon: FileQuestion, color: 'text-green-600 bg-green-50' },
    { label: 'Quizzes', value: stats.totalQuizzes, icon: ListChecks, color: 'text-amber-600 bg-amber-50' },
    { label: 'Active Today', value: stats.activeToday, icon: Activity, color: 'text-pink-600 bg-pink-50' },
    { label: 'Premium Users', value: stats.premiumUsers, icon: Award, color: 'text-purple-600 bg-purple-50' },
  ]

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1">Overview of your educational platform</p>
        </div>
        <button
          onClick={loadStats}
          className="btn-secondary"
        >
          Refresh
        </button>
      </div>

      {/* Stats cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-6 mb-8">
        {cards.map((card) => (
          <div key={card.label} className="card p-6">
            <div className={`w-12 h-12 rounded-xl flex items-center justify-center mb-4 ${card.color}`}>
              <card.icon className="w-6 h-6" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{loading ? '—' : card.value}</p>
            <p className="text-sm text-gray-500 mt-1">{card.label}</p>
          </div>
        ))}
      </div>

      {/* Quick insights */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <div className="card p-6 col-span-2">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Users</h2>
          {recentUsers.length === 0 ? (
            <p className="text-gray-400 text-sm">No users registered yet</p>
          ) : (
            <div className="space-y-4">
              {recentUsers.map((user) => (
                <div key={user.id} className="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center">
                      <span className="font-semibold text-gray-600">
                        {(user.displayName || 'U')[0].toUpperCase()}
                      </span>
                    </div>
                    <div>
                      <p className="font-medium text-gray-800">{user.displayName || 'No name'}</p>
                      <p className="text-xs text-gray-500">{user.email}</p>
                    </div>
                  </div>
                  <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                    user.isPremium ? 'bg-purple-100 text-purple-700' : 'bg-gray-100 text-gray-600'
                  }`}>
                    {user.isPremium ? 'Premium' : user.role || 'Student'}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="card p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="space-y-3">
            <QuickAction icon={Upload} label="Upload MCQs via Excel" route="/bulk-upload" />
            <QuickAction icon={Palette} label="Customize App Appearance" route="/customization" />
            <QuickAction icon={Megaphone} label="Send Notice" route="/notices" />
            <QuickAction icon={BarChart3} label="View Analytics" route="/analytics" />
          </div>
        </div>
      </div>

      {/* Growth indicators */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <RankCard />
        <WeakSubjectCard />
        <QuizCompletionCard />
      </div>
    </div>
  )
}

function QuickAction({ icon: Icon, label, route }) {
  return (
    <a
      href={route}
      className="flex items-center px-4 py-3 rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors"
    >
      <Icon className="w-4 h-4 mr-3 text-indigo-600" />
      <span className="text-sm font-medium">{label}</span>
    </a>
  )
}

function RankCard() {
  return (
    <div className="card p-6">
      <div className="flex items-center gap-3 mb-3">
        <Target className="w-4 h-4 text-amber-600" />
        <h3 className="font-semibold text-gray-800">Top Performer</h3>
      </div>
      <p className="text-sm text-gray-500">Data loads from leaderboard collection</p>
    </div>
  )
}

function WeakSubjectCard() {
  return (
    <div className="card p-6">
      <div className="flex items-center gap-3 mb-3">
        <TrendingUp className="w-4 h-4 text-red-600" />
        <h3 className="font-semibold text-gray-800">Weak Subjects</h3>
      </div>
      <p className="text-sm text-gray-500">Based on MCQ performance patterns</p>
    </div>
  )
}

function QuizCompletionCard() {
  return (
    <div className="card p-6">
      <div className="flex items-center gap-3 mb-3">
        <Zap className="w-4 h-4 text-green-600" />
        <h3 className="font-semibold text-gray-800">Quiz Completion Rate</h3>
      </div>
      <p className="text-sm text-gray-500">Today: --% (requires attempts data)</p>
    </div>
  )
}
