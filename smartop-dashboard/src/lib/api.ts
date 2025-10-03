import axios, { AxiosInstance, AxiosRequestConfig } from 'axios'

class ApiClient {
  private client: AxiosInstance
  private baseURL: string
  private token: string | null = null

  constructor() {
    this.baseURL = process.env.NEXT_PUBLIC_API_URL || 'http://127.0.0.1:8001/api'

    this.client = axios.create({
      baseURL: this.baseURL,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      timeout: 30000,
    })

    // Load token from localStorage on initialization
    this.loadTokenFromStorage()

    // Request interceptor
    this.client.interceptors.request.use(
      (config) => {
        if (this.token) {
          config.headers.Authorization = `Bearer ${this.token}`
        }
        return config
      },
      (error) => {
        return Promise.reject(error)
      }
    )

    // Response interceptor
    this.client.interceptors.response.use(
      (response) => {
        return response
      },
      async (error) => {
        if (error.response?.status === 401) {
          // Token expired or invalid
          this.clearToken()
          // Redirect to login
          if (typeof window !== 'undefined') {
            window.location.href = '/login'
          }
        }
        return Promise.reject(error)
      }
    )
  }

  setToken(token: string) {
    this.token = token
    if (typeof window !== 'undefined') {
      localStorage.setItem('smartop_token', token)
    }
  }

  clearToken() {
    this.token = null
    if (typeof window !== 'undefined') {
      localStorage.removeItem('smartop_token')
    }
  }

  loadTokenFromStorage() {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('smartop_token')
      if (token) {
        this.token = token
      }
    }
  }

  // Auth endpoints
  async login(email: string, password: string) {
    const response = await this.client.post('/login', { email, password })
    return response.data
  }

  async register(userData: any) {
    const response = await this.client.post('/register', userData)
    return response.data
  }

  async logout() {
    try {
      await this.client.post('/logout')
    } finally {
      this.clearToken()
    }
  }

  async getCurrentUser() {
    const response = await this.client.get('/user')
    return response.data
  }

  // Dashboard endpoints
  async getDashboardStats() {
    const response = await this.client.get('/dashboard')
    return response.data
  }

  async getReports(params?: any) {
    const response = await this.client.get('/reports', { params })
    return response.data
  }

  // Companies endpoints
  async getCompanies(params?: any) {
    const response = await this.client.get('/companies', { params })
    return response.data
  }

  async getCompany(id: string) {
    const response = await this.client.get(`/companies/${id}`)
    return response.data
  }

  async createCompany(data: any) {
    const response = await this.client.post('/companies', data)
    return response.data
  }

  async updateCompany(id: string, data: any) {
    const response = await this.client.put(`/companies/${id}`, data)
    return response.data
  }

  async deleteCompany(id: string) {
    const response = await this.client.delete(`/companies/${id}`)
    return response.data
  }

  // Users endpoints
  async getUsers(params?: any) {
    const response = await this.client.get('/admin/users', { params })
    return response.data
  }

  async getUser(id: string) {
    const response = await this.client.get(`/admin/users/${id}`)
    return response.data
  }

  async createUser(data: any) {
    const response = await this.client.post('/admin/users', data)
    return response.data
  }

  async updateUser(id: string, data: any) {
    const response = await this.client.put(`/admin/users/${id}`, data)
    return response.data
  }

  async deleteUser(id: string) {
    const response = await this.client.delete(`/admin/users/${id}`)
    return response.data
  }

  // Machines endpoints
  async getMachines(params?: any) {
    const response = await this.client.get('/machines', { params })
    return response.data
  }

  async getMachine(id: string) {
    const response = await this.client.get(`/machines/${id}`)
    return response.data
  }

  async createMachine(data: any) {
    const response = await this.client.post('/machines', data)
    return response.data
  }

  async updateMachine(id: string, data: any) {
    const response = await this.client.put(`/machines/${id}`, data)
    return response.data
  }

  async deleteMachine(id: string) {
    const response = await this.client.delete(`/machines/${id}`)
    return response.data
  }

  async generateQrCode(id: string) {
    const response = await this.client.post(`/machines/${id}/qr-code`)
    return response.data
  }

  async assignOperatorToMachine(machineId: string, data: any) {
    const response = await this.client.post(`/machines/${machineId}/assign-operator`, data)
    return response.data
  }

  // Control Lists endpoints
  async getControlLists(params?: any) {
    const response = await this.client.get('/control-lists', { params })
    return response.data
  }

  async getControlList(id: string) {
    const response = await this.client.get(`/control-lists/${id}`)
    return response.data
  }

  async createControlList(data: any) {
    const response = await this.client.post('/control-lists', data)
    return response.data
  }

  async updateControlList(id: string, data: any) {
    const response = await this.client.put(`/control-lists/${id}`, data)
    return response.data
  }

  async deleteControlList(id: string) {
    const response = await this.client.delete(`/control-lists/${id}`)
    return response.data
  }

  async approveControlList(id: string, data?: any) {
    const response = await this.client.post(`/control-lists/${id}/approve`, data)
    return response.data
  }

  async rejectControlList(id: string, data?: any) {
    const response = await this.client.post(`/control-lists/${id}/reject`, data)
    return response.data
  }

  async revertControlList(id: string) {
    const response = await this.client.post(`/control-lists/${id}/revert`)
    return response.data
  }

  // Control Templates endpoints
  async getControlTemplates(params?: any) {
    const response = await this.client.get('/control-templates', { params })
    return response.data
  }

  async getControlTemplate(id: string) {
    const response = await this.client.get(`/control-templates/${id}`)
    return response.data
  }

  async createControlTemplate(data: any) {
    const response = await this.client.post('/control-templates', data)
    return response.data
  }

  async updateControlTemplate(id: string, data: any) {
    const response = await this.client.put(`/control-templates/${id}`, data)
    return response.data
  }

  async deleteControlTemplate(id: string) {
    const response = await this.client.delete(`/control-templates/${id}`)
    return response.data
  }

  async duplicateControlTemplate(id: string) {
    const response = await this.client.post(`/control-templates/${id}/duplicate`)
    return response.data
  }

  async createControlListFromTemplate(templateId: string, data: any) {
    const response = await this.client.post(`/control-templates/${templateId}/create-control-list`, data)
    return response.data
  }

  // Profile endpoints
  async updateProfile(data: any) {
    const response = await this.client.put('/profile', data)
    return response.data
  }

  // Work Sessions endpoints
  async getWorkSessions(params?: any) {
    const response = await this.client.get('/work-sessions', { params })
    return response.data
  }

  async approveWorkSession(id: string, notes?: string) {
    const response = await this.client.post(`/work-sessions/${id}/approve`, { notes })
    return response.data
  }

  async rejectWorkSession(id: string, notes?: string) {
    const response = await this.client.post(`/work-sessions/${id}/reject`, { notes })
    return response.data
  }

  // Reports endpoints
  async generateReport(data: any) {
    const response = await this.client.post('/reports/generate', data)
    return response.data
  }

  async getReports(params?: any) {
    const response = await this.client.get('/reports', { params })
    return response.data
  }

  // Health check
  async healthCheck() {
    const response = await this.client.get('/health')
    return response.data
  }
}

// Export singleton instance
export const apiClient = new ApiClient()

// Types
export interface User {
  id: number
  name: string
  email: string
  role: string
  company_id?: number
  company?: Company
  status: 'active' | 'inactive'
  created_at: string
  updated_at: string
}

export interface Company {
  id: number
  name: string
  email?: string
  phone?: string
  address?: string
  logo?: string
  status: 'active' | 'inactive'
  subscription_plan?: string
  subscription_status?: string
  created_at: string
  updated_at: string
}

export interface Machine {
  id: number
  name: string
  type: string
  model?: string
  serial_number: string
  manufacturer?: string
  year?: number
  status: 'active' | 'inactive' | 'maintenance'
  company_id: number
  company?: Company
  qr_code?: string
  created_at: string
  updated_at: string
}

export interface ControlList {
  id: number
  title: string
  description?: string
  machine_id: number
  machine?: Machine
  operator_id: number
  operator?: User
  manager_id?: number
  manager?: User
  status: 'pending' | 'approved' | 'rejected' | 'completed'
  items: ControlItem[]
  photos?: string[]
  notes?: string
  approved_at?: string
  rejected_at?: string
  created_at: string
  updated_at: string
}

export interface ControlItem {
  id: number
  title: string
  description?: string
  type: 'checkbox' | 'text' | 'number' | 'photo'
  required: boolean
  value?: any
  checked?: boolean
  photo_url?: string
  order: number
}

export interface ControlTemplate {
  id: number
  name: string
  description?: string
  machine_types: string[]
  items: ControlTemplateItem[]
  company_id?: number
  is_public: boolean
  created_at: string
  updated_at: string
}

export interface ControlTemplateItem {
  id: number
  title: string
  description?: string
  type: 'checkbox' | 'text' | 'number' | 'photo'
  required: boolean
  options?: string[]
  order: number
}

export interface DashboardStats {
  total_companies: number
  total_users: number
  active_users: number
  total_machines: number
  active_machines: number
  maintenance_machines: number
  total_control_lists: number
  pending_control_lists: number
  approved_control_lists: number
  recent_activities: Activity[]
}

export interface Activity {
  id: number
  type: string
  message: string
  user: string
  created_at: string
}

export default apiClient