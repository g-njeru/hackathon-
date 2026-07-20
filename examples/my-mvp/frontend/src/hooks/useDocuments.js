import { useState, useEffect } from 'react'
import { fetchDocuments } from '../api/documents'

export default function useDocuments() {
  const [documents, setDocuments] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchDocuments()
      .then(setDocuments)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [])

  return { documents, loading, error }
}
