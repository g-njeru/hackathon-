const API_URL = import.meta.env.VITE_API_URL || ''
const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

import { MOCK_DOCUMENTS } from '../mocks/documents'

function authHeaders() {
  const token = localStorage.getItem('token')
  return token ? { Authorization: `Bearer ${token}` } : {}
}

export async function fetchDocuments() {
  if (USE_MOCK) {
    await new Promise(r => setTimeout(r, 300))
    return MOCK_DOCUMENTS
  }
  const res = await fetch(`${API_URL}/api/documents`, { headers: authHeaders() })
  if (!res.ok) throw new Error('Failed to fetch')
  return res.json()
}

export async function createDocument(data) {
  if (USE_MOCK) {
    await new Promise(r => setTimeout(r, 300))
    return { id: 'mock-' + Date.now(), ...data, created_at: new Date().toISOString(), updated_at: new Date().toISOString() }
  }
  const res = await fetch(`${API_URL}/api/documents`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify(data)
  })
  if (!res.ok) throw new Error('Failed to create')
  return res.json()
}

export async function updateDocument(id, data) {
  if (USE_MOCK) {
    await new Promise(r => setTimeout(r, 300))
    return { id, ...data, updated_at: new Date().toISOString() }
  }
  const res = await fetch(`${API_URL}/api/documents/${id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify(data)
  })
  if (!res.ok) throw new Error('Failed to update')
  return res.json()
}

export async function deleteDocument(id) {
  if (USE_MOCK) {
    await new Promise(r => setTimeout(r, 300))
    return
  }
  const res = await fetch(`${API_URL}/api/documents/${id}`, {
    method: 'DELETE',
    headers: authHeaders()
  })
  if (!res.ok) throw new Error('Failed to delete')
}
