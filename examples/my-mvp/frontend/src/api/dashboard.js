const API_URL = import.meta.env.VITE_API_URL || ''
const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

function authHeaders() {
  const token = localStorage.getItem('token')
  return token ? { Authorization: `Bearer ${token}` } : {}
}

export async function fetchStats() {
  if (USE_MOCK) {
    await new Promise(r => setTimeout(r, 200))
    return {
      total_documents: 3,
      with_content: 2,
      empty: 1,
      recent: [
        { id: 'mock-1', title: 'Getting Started', created_at: '2025-07-19T10:00:00Z' },
        { id: 'mock-2', title: 'Project Ideas', created_at: '2025-07-18T14:30:00Z' },
        { id: 'mock-3', title: 'Notes', created_at: '2025-07-17T09:15:00Z' },
      ],
      longest: { id: 'mock-1', title: 'Getting Started', content_length: 482 },
    }
  }
  const res = await fetch(`${API_URL}/api/dashboard/stats`, { headers: authHeaders() })
  if (!res.ok) throw new Error('Failed to fetch stats')
  return res.json()
}
