import React, { useEffect, useState } from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { onAuthStateChanged } from 'firebase/auth'
import { Toaster } from 'react-hot-toast'
import { auth } from './services/firebase'
import Layout from './components/Layout'
import LoginPage from './pages/LoginPage'
import Dashboard from './pages/Dashboard'
import QuestionsPage from './pages/QuestionsPage'
import QuizzesPage from './pages/QuizzesPage'
import SubjectsPage from './pages/SubjectsPage'
import UsersPage from './pages/UsersPage'
import AnalyticsPage from './pages/AnalyticsPage'
import CustomizationPage from './pages/CustomizationPage'
import NoticesPage from './pages/NoticesPage'
import BulkUploadPage from './pages/BulkUploadPage'

function App() {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user)
      setLoading(false)
    })
    return () => unsubscribe()
  }, [])

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>
    )
  }

  return (
    <BrowserRouter>
      <Toaster position="top-right" />
      <Routes>
        <Route path="/login" element={!user ? <LoginPage /> : <Navigate to="/" />} />
        <Route
          path="/"
          element={user ? <Layout /> : <Navigate to="/login" />}
        >
          <Route index element={<Dashboard />} />
          <Route path="questions" element={<QuestionsPage />} />
          <Route path="quizzes" element={<QuizzesPage />} />
          <Route path="subjects" element={<SubjectsPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="analytics" element={<AnalyticsPage />} />
          <Route path="customization" element={<CustomizationPage />} />
          <Route path="notices" element={<NoticesPage />} />
          <Route path="bulk-upload" element={<BulkUploadPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}

export default App
