import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { apiClient } from '@/lib/api'

// Dashboard hooks
export function useDashboardStats() {
  return useQuery({
    queryKey: ['dashboard', 'stats'],
    queryFn: () => apiClient.getDashboardStats(),
  })
}

export function useReports() {
  return useQuery({
    queryKey: ['reports'],
    queryFn: () => apiClient.getReports(),
  })
}

// Companies hooks
export function useCompanies(params?: any) {
  return useQuery({
    queryKey: ['companies', params],
    queryFn: () => apiClient.getCompanies(params),
  })
}

export function useCompany(id: string) {
  return useQuery({
    queryKey: ['companies', id],
    queryFn: () => apiClient.getCompany(id),
    enabled: !!id,
  })
}

export function useCreateCompany() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: any) => apiClient.createCompany(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['companies'] })
    },
  })
}

export function useUpdateCompany() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      apiClient.updateCompany(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['companies'] })
      queryClient.invalidateQueries({ queryKey: ['companies', id] })
    },
  })
}

export function useDeleteCompany() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: string) => apiClient.deleteCompany(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['companies'] })
    },
  })
}

// Users hooks
export function useUsers(params?: any) {
  return useQuery({
    queryKey: ['users', params],
    queryFn: () => apiClient.getUsers(params),
  })
}

export function useUser(id: string) {
  return useQuery({
    queryKey: ['users', id],
    queryFn: () => apiClient.getUser(id),
    enabled: !!id,
  })
}

export function useCreateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: any) => apiClient.createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })
}

export function useUpdateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      apiClient.updateUser(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
      queryClient.invalidateQueries({ queryKey: ['users', id] })
    },
  })
}

export function useDeleteUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: string) => apiClient.deleteUser(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })
}

// Machines hooks
export function useMachines(params?: any) {
  return useQuery({
    queryKey: ['machines', params],
    queryFn: () => apiClient.getMachines(params),
  })
}

export function useMachine(id: string) {
  return useQuery({
    queryKey: ['machines', id],
    queryFn: () => apiClient.getMachine(id),
    enabled: !!id,
  })
}

export function useCreateMachine() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: any) => apiClient.createMachine(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['machines'] })
    },
  })
}

export function useUpdateMachine() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      apiClient.updateMachine(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['machines'] })
      queryClient.invalidateQueries({ queryKey: ['machines', id] })
    },
  })
}

export function useDeleteMachine() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: string) => apiClient.deleteMachine(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['machines'] })
    },
  })
}

export function useGenerateQrCode() {
  return useMutation({
    mutationFn: (id: string) => apiClient.generateQrCode(id),
  })
}

// Control Lists hooks
export function useControlLists(params?: any) {
  return useQuery({
    queryKey: ['control-lists', params],
    queryFn: () => apiClient.getControlLists(params),
  })
}

export function useControlList(id: string) {
  return useQuery({
    queryKey: ['control-lists', id],
    queryFn: () => apiClient.getControlList(id),
    enabled: !!id,
  })
}

export function useCreateControlList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: any) => apiClient.createControlList(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['control-lists'] })
    },
  })
}

export function useUpdateControlList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      apiClient.updateControlList(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['control-lists'] })
      queryClient.invalidateQueries({ queryKey: ['control-lists', id] })
    },
  })
}

export function useDeleteControlList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: string) => apiClient.deleteControlList(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['control-lists'] })
    },
  })
}

export function useApproveControlList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data?: any }) =>
      apiClient.approveControlList(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['control-lists'] })
      queryClient.invalidateQueries({ queryKey: ['control-lists', id] })
      queryClient.invalidateQueries({ queryKey: ['dashboard'] })
    },
  })
}

export function useRejectControlList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data?: any }) =>
      apiClient.rejectControlList(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['control-lists'] })
      queryClient.invalidateQueries({ queryKey: ['control-lists', id] })
      queryClient.invalidateQueries({ queryKey: ['dashboard'] })
    },
  })
}

// Control Templates hooks
export function useControlTemplates(params?: any) {
  return useQuery({
    queryKey: ['control-templates', params],
    queryFn: () => apiClient.getControlTemplates(params),
  })
}

export function useControlTemplate(id: string) {
  return useQuery({
    queryKey: ['control-templates', id],
    queryFn: () => apiClient.getControlTemplate(id),
    enabled: !!id,
  })
}

export function useCreateControlTemplate() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: any) => apiClient.createControlTemplate(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['control-templates'] })
    },
  })
}

export function useUpdateControlTemplate() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      apiClient.updateControlTemplate(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['control-templates'] })
      queryClient.invalidateQueries({ queryKey: ['control-templates', id] })
    },
  })
}

export function useDeleteControlTemplate() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: string) => apiClient.deleteControlTemplate(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['control-templates'] })
    },
  })
}

export function useDuplicateControlTemplate() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: string) => apiClient.duplicateControlTemplate(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['control-templates'] })
    },
  })
}

// Auth hooks
export function useCurrentUser() {
  return useQuery({
    queryKey: ['user', 'current'],
    queryFn: () => apiClient.getCurrentUser(),
    retry: false,
  })
}

export function useLogin() {
  return useMutation({
    mutationFn: ({ email, password }: { email: string; password: string }) =>
      apiClient.login(email, password),
    onSuccess: (data) => {
      // Handle the correct response structure: data.data.token
      if (data.success && data.data?.token) {
        apiClient.setToken(data.data.token)
      }
    },
  })
}

export function useRegister() {
  return useMutation({
    mutationFn: (userData: any) => apiClient.register(userData),
  })
}

export function useLogout() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: () => apiClient.logout(),
    onSuccess: () => {
      queryClient.clear()
    },
  })
}

// Health check hook
export function useHealthCheck() {
  return useQuery({
    queryKey: ['health'],
    queryFn: () => apiClient.healthCheck(),
    refetchInterval: 5 * 60 * 1000, // 5 minutes
  })
}