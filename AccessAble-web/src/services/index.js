import api from './api'

// Admin dashboard services
export const adminService = {
  // Get dashboard statistics
  getDashboardStats: async () => {
    const response = await api.get('/admin/dashboard')
    return response.data
  },

  // Get pending approvals
  getPendingApprovals: async () => {
    const response = await api.get('/admin/pending')
    return response.data
  },
}

// User management services
export const userService = {
  // Get all users
  getAllUsers: async (limit = 50, offset = 0) => {
    const response = await api.get(`/users?limit=${limit}&offset=${offset}`)
    return response.data
  },

  // Get pending users
  getPendingUsers: async () => {
    const response = await api.get('/users/pending')
    return response.data
  },

  // Get user statistics
  getUserStats: async () => {
    const response = await api.get('/users/stats')
    return response.data
  },

  // Get user by UID
  getUserByUid: async (uid) => {
    const response = await api.get(`/users/${uid}`)
    return response.data
  },

  // Approve user
  approveUser: async (uid) => {
    const response = await api.patch(`/users/${uid}/approve`)
    return response.data
  },

  // Update user role
  updateUserRole: async (uid, role) => {
    const response = await api.patch(`/users/${uid}/role`, { role })
    return response.data
  },

  // Delete user
  deleteUser: async (uid) => {
    const response = await api.delete(`/users/${uid}`)
    return response.data
  },
}

// Places management services
export const placeService = {
  // Get all places
  getAllPlaces: async (approved = true, limit = 50, offset = 0) => {
    const response = await api.get(`/places?approved=${approved}&limit=${limit}&offset=${offset}`)
    return response.data
  },

  // Get pending places
  getPendingPlaces: async () => {
    const response = await api.get('/places/pending')
    return response.data
  },

  // Get place statistics
  getPlaceStats: async () => {
    const response = await api.get('/places/stats')
    return response.data
  },

  // Get place by ID
  getPlaceById: async (id) => {
    const response = await api.get(`/places/${id}`)
    return response.data
  },

  // Create new place
  createPlace: async (placeData) => {
    const response = await api.post('/places', placeData)
    return response.data
  },

  // Approve place
  approvePlace: async (id) => {
    const response = await api.patch(`/places/${id}/approve`)
    return response.data
  },

  // Update place
  updatePlace: async (id, updateData) => {
    const response = await api.patch(`/places/${id}`, updateData)
    return response.data
  },

  // Delete place
  deletePlace: async (id) => {
    const response = await api.delete(`/places/${id}`)
    return response.data
  },

  // Search places
  searchPlaces: async (query, filters = {}) => {
    const params = new URLSearchParams({ q: query })
    
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        params.append(key, value)
      }
    })

    const response = await api.get(`/places/search?${params}`)
    return response.data
  },

  // Add review to place
  addReview: async (placeId, reviewData) => {
    const response = await api.post(`/places/${placeId}/reviews`, reviewData)
    return response.data
  },
}

// Auth services
export const authService = {
  // Get user profile
  getProfile: async () => {
    const response = await api.get('/auth/profile')
    return response.data
  },

  // Update user profile
  updateProfile: async (updateData) => {
    const response = await api.patch('/auth/profile', updateData)
    return response.data
  },

  // Verify token
  verifyToken: async () => {
    const response = await api.get('/auth/verify')
    return response.data
  },
}