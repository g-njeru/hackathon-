import { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import { fetchStats } from '../api/dashboard'

export default function Dashboard() {
  const { user, logout } = useAuth()
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchStats()
      .then(setStats)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div className="p-8">Loading...</div>
  if (error) return <div className="p-8 text-red-500">Error: {error}</div>

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-4xl mx-auto px-4 py-3 flex justify-between items-center">
          <h1 className="text-xl font-bold text-gray-900">Dashboard</h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-600">{user?.email}</span>
            <button onClick={logout} className="text-sm text-red-600 hover:underline">Logout</button>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 py-8 space-y-6">
        {/* Stats cards */}
        <div className="grid grid-cols-3 gap-4">
          <div className="bg-white rounded-lg shadow p-6 text-center">
            <div className="text-3xl font-bold text-blue-600">{stats.total_documents}</div>
            <div className="text-sm text-gray-500 mt-1">Total Documents</div>
          </div>
          <div className="bg-white rounded-lg shadow p-6 text-center">
            <div className="text-3xl font-bold text-green-600">{stats.with_content}</div>
            <div className="text-sm text-gray-500 mt-1">With Content</div>
          </div>
          <div className="bg-white rounded-lg shadow p-6 text-center">
            <div className="text-3xl font-bold text-yellow-600">{stats.empty}</div>
            <div className="text-sm text-gray-500 mt-1">Empty</div>
          </div>
        </div>

        {/* Longest document */}
        {stats.longest && (
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-2">Longest Document</h2>
            <p className="text-gray-700">
              <span className="font-medium">{stats.longest.title}</span> — {stats.longest.content_length} characters
            </p>
          </div>
        )}

        {/* Recent documents */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Documents</h2>
          {stats.recent.length === 0 ? (
            <p className="text-gray-500">No documents yet.</p>
          ) : (
            <div className="divide-y">
              {stats.recent.map(doc => (
                <div key={doc.id} className="py-3 flex justify-between items-center">
                  <span className="font-medium text-gray-800">{doc.title}</span>
                  <span className="text-sm text-gray-400">
                    {new Date(doc.created_at).toLocaleDateString()}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        <a href="/" className="block text-center text-blue-600 hover:underline">
          ← Back to Documents
        </a>
      </main>
    </div>
  )
}
