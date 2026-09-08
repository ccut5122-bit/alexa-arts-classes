import React, { useEffect, useState } from 'react'
import { doc, getDoc, setDoc } from 'firebase/firestore'
import { db } from '../services/firebase'
import toast from 'react-hot-toast'

export default function CustomizationPage() {
  const [theme, setTheme] = useState({
    primaryColor: '#6C63FF',
    secondaryColor: '#00C9A7',
    accentColor: '#FF6B35',
    darkMode: false,
    appName: 'Alexa Arts Classes',
    logoUrl: '',
  })
  const [banners, setBanners] = useState([])
  const [saving, setSaving] = useState(false)

  useEffect(() => { loadConfig() }, [])

  const loadConfig = async () => {
    try {
      const [themeDoc, bannerDoc] = await Promise.all([
        getDoc(doc(db, 'dynamicConfig', 'themeConfig')),
        getDoc(doc(db, 'dynamicConfig', 'bannerConfig')),
      ])

      if (themeDoc.exists()) setTheme(themeDoc.data())
      if (bannerDoc.exists()) setBanners(bannerDoc.data().banners || [])
    } catch (error) {
      toast.error('Failed to load configuration')
    }
  }

  const saveTheme = async () => {
    setSaving(true)
    try {
      await setDoc(doc(db, 'dynamicConfig', 'themeConfig'), {
        ...theme,
        updatedAt: new Date(),
      })
      toast.success('Theme saved! App will update instantly.')
    } catch (error) {
      toast.error('Failed to save theme')
    } finally {
      setSaving(false)
    }
  }

  const saveBanners = async () => {
    setSaving(true)
    try {
      await setDoc(doc(db, 'dynamicConfig', 'bannerConfig'), {
        banners,
        updatedAt: new Date(),
      })
      toast.success('Banners saved!')
    } catch (error) {
      toast.error('Failed to save banners')
    } finally {
      setSaving(false)
    }
  }

  const addBanner = () => {
    setBanners([...banners, {
      id: Date.now().toString(),
      imageUrl: '',
      title: '',
      linkType: 'subject',
      linkValue: '',
      isActive: true,
      order: banners.length,
    }])
  }

  const updateBanner = (index, field, value) => {
    const newBanners = [...banners]
    newBanners[index] = { ...newBanners[index], [field]: value }
    setBanners(newBanners)
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Dynamic App Customization</h1>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Theme Config */}
        <div className="card p-6">
          <h2 className="text-lg font-semibold mb-4">Theme Configuration</h2>
          <div className="space-y-4">
            <div>
              <label className="label">App Name</label>
              <input
                className="input-field"
                value={theme.appName}
                onChange={(e) => setTheme({ ...theme, appName: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="label">Primary Color</label>
                <input
                  type="color"
                  className="input-field h-10 p-1"
                  value={theme.primaryColor}
                  onChange={(e) => setTheme({ ...theme, primaryColor: e.target.value })}
                />
              </div>
              <div>
                <label className="label">Secondary Color</label>
                <input
                  type="color"
                  className="input-field h-10 p-1"
                  value={theme.secondaryColor}
                  onChange={(e) => setTheme({ ...theme, secondaryColor: e.target.value })}
                />
              </div>
            </div>

            <div>
              <label className="label">Accent Color</label>
              <input
                type="color"
                className="input-field h-10 p-1"
                value={theme.accentColor}
                onChange={(e) => setTheme({ ...theme, accentColor: e.target.value })}
              />
            </div>

            <div>
              <label className="label">Logo URL</label>
              <input
                className="input-field"
                value={theme.logoUrl}
                onChange={(e) => setTheme({ ...theme, logoUrl: e.target.value })}
                placeholder="https://..."
              />
            </div>

            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={theme.darkMode}
                onChange={(e) => setTheme({ ...theme, darkMode: e.target.checked })}
                className="w-4 h-4 text-indigo-600"
              />
              <span className="text-sm font-medium">Default to Dark Mode</span>
            </label>

            <button onClick={saveTheme} disabled={saving} className="btn-primary w-full">
              {saving ? 'Saving...' : 'Save Theme'}
            </button>
          </div>
        </div>

        {/* Banner Manager */}
        <div className="card p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold">Homepage Banners</h2>
            <button onClick={addBanner} className="btn-secondary text-xs px-3 py-1.5">
              + Add Banner
            </button>
          </div>

          <div className="space-y-4">
            {banners.map((banner, index) => (
              <div key={banner.id} className="border rounded-lg p-4 border-gray-200">
                <div className="flex justify-between items-center mb-3">
                  <span className="text-xs font-bold text-gray-500">Banner #{index + 1}</span>
                  <button
                    onClick={() => setBanners(banners.filter((_, i) => i !== index))}
                    className="text-red-500 text-xs hover:text-red-700"
                  >
                    Remove
                  </button>
                </div>

                <div className="space-y-3">
                  <div>
                    <label className="label text-xs">Image URL</label>
                    <input
                      className="input-field"
                      value={banner.imageUrl}
                      onChange={(e) => updateBanner(index, 'imageUrl', e.target.value)}
                      placeholder="https://banner-image.jpg"
                    />
                  </div>
                  <div>
                    <label className="label text-xs">Title</label>
                    <input
                      className="input-field"
                      value={banner.title}
                      onChange={(e) => updateBanner(index, 'title', e.target.value)}
                      placeholder="e.g., JAC Board Admit Card Released!"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="label text-xs">Link Type</label>
                      <select
                        className="input-field"
                        value={banner.linkType}
                        onChange={(e) => updateBanner(index, 'linkType', e.target.value)}
                      >
                        <option value="subject">Subject</option>
                        <option value="quiz">Quiz</option>
                        <option value="notice">Notice</option>
                        <option value="external">External Link</option>
                      </select>
                    </div>
                    <div>
                      <label className="label text-xs">Link Value</label>
                      <input
                        className="input-field"
                        value={banner.linkValue}
                        onChange={(e) => updateBanner(index, 'linkValue', e.target.value)}
                        placeholder="subjectId / URL"
                      />
                    </div>
                  </div>
                  <label className="flex items-center gap-2 text-xs">
                    <input
                      type="checkbox"
                      checked={banner.isActive}
                      onChange={(e) => updateBanner(index, 'isActive', e.target.checked)}
                      className="w-3.5 h-3.5 text-indigo-600"
                    />
                    Active
                  </label>
                </div>
              </div>
            ))}

            {banners.length === 0 && (
              <p className="text-gray-400 text-sm text-center py-8">No banners yet</p>
            )}

            <button
              onClick={saveBanners}
              disabled={saving}
              className="btn-primary w-full"
            >
              {saving ? 'Saving...' : 'Save Banners'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}