import axios from 'axios'
import { getAuth } from 'firebase/auth'

const API_BASE_URL = import.meta.env.VITE_API_URL

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
})

// Add auth token to requests
api.interceptors.request.use(async (config) => {
  const auth = getAuth()
  const user = auth.currentUser
  
  if (user) {
    const token = await user.getIdToken()
    config.headers.Authorization = `Bearer ${token}`
  }
  
  return config
})

// Handle response errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message)
    return Promise.reject(error)
  }
)

export default api