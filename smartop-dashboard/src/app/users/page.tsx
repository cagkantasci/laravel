'use client'

import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Label } from '@/components/ui/label'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { apiClient, User } from '@/lib/api'
import {
  Plus,
  Search,
  Users,
  Shield,
  UserCheck,
  Building2,
  Mail,
  Phone,
  Calendar,
  Edit,
  Trash2,
  Eye,
  Filter,
  Upload,
  Camera,
  X
} from 'lucide-react'

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [roleFilter, setRoleFilter] = useState<string>('all')
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    company: '',
    role: 'operator',
    photo: null as File | null,
    password: '',
    password_confirmation: ''
  })
  const [photoPreview, setPhotoPreview] = useState<string | null>(null)
  const [currentUserRole, setCurrentUserRole] = useState<string>('admin') // This will come from auth context
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)

  useEffect(() => {
    // Get current user role from localStorage or auth context
    if (typeof window !== 'undefined') {
      const userData = localStorage.getItem('user')
      if (userData) {
        const parsedUser = JSON.parse(userData)
        const role = parsedUser.roles?.[0]?.name || 'admin'
        setCurrentUserRole(role)
      }
    }
  }, [])

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const response = await apiClient.getUsers()
        console.log('Users API response:', response)

        // Handle different response formats
        let usersData = []
        if (Array.isArray(response)) {
          usersData = response
        } else if (Array.isArray(response.data)) {
          usersData = response.data
        } else if (response.data?.users && Array.isArray(response.data.users)) {
          usersData = response.data.users
        }

        console.log('Parsed users data:', usersData)
        setUsers(usersData)
      } catch (error) {
        console.error('Users fetch error:', error)
        setUsers([])
      } finally {
        setLoading(false)
      }
    }

    fetchUsers()
  }, [])

  // Role-based filtering function
  const getViewableUsers = () => {
    let viewableUsers = users

    // Role-based filtering: Admin sees all, Manager sees only operators
    if (currentUserRole === 'manager') {
      viewableUsers = users.filter(user => user.role === 'operator')
    } else if (currentUserRole === 'operator') {
      // Operators typically shouldn't see user management, but if they do, only themselves
      viewableUsers = users.filter(user => user.role === 'operator')
    }
    // Admin sees all users by default

    return viewableUsers
  }

  const filteredUsers = getViewableUsers().filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.phone.includes(searchTerm)
    const matchesRole = roleFilter === 'all' || user.role === roleFilter
    return matchesSearch && matchesRole
  })

  // Get available roles for filter dropdown based on current user role
  const getAvailableRoles = () => {
    if (currentUserRole === 'admin') {
      return [
        { value: 'all', label: 'Tüm Roller' },
        { value: 'admin', label: 'Yönetici' },
        { value: 'manager', label: 'Müdür' },
        { value: 'operator', label: 'Operatör' }
      ]
    } else if (currentUserRole === 'manager') {
      return [
        { value: 'all', label: 'Tüm Operatörler' },
        { value: 'operator', label: 'Operatör' }
      ]
    } else {
      return [
        { value: 'all', label: 'Operatörler' },
        { value: 'operator', label: 'Operatör' }
      ]
    }
  }

  const getRoleBadge = (role: string) => {
    switch (role) {
      case 'admin':
        return { label: 'Yönetici', className: 'bg-red-100 text-red-800' }
      case 'manager':
        return { label: 'Müdür', className: 'bg-blue-100 text-blue-800' }
      case 'operator':
        return { label: 'Operatör', className: 'bg-green-100 text-green-800' }
      default:
        return { label: role, className: 'bg-gray-100 text-gray-800' }
    }
  }

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center h-64">
          <div className="text-lg">Yükleniyor...</div>
        </div>
      </AdminLayout>
    )
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Kullanıcı Yönetimi</h1>
            <p className="text-gray-600">Sistem kullanıcılarını görüntüleyin ve yönetin</p>
          </div>
          <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
            <DialogTrigger asChild>
              <Button className="flex items-center gap-2">
                <Plus className="h-4 w-4" />
                Yeni Kullanıcı
              </Button>
            </DialogTrigger>
            <AddUserDialog
              formData={formData}
              setFormData={setFormData}
              photoPreview={photoPreview}
              setPhotoPreview={setPhotoPreview}
              onClose={() => setIsAddDialogOpen(false)}
              onUserAdded={(user) => {
                setUsers(prevUsers => [user, ...prevUsers])
                // Refresh the full list
                apiClient.getUsers().then(response => {
                  const usersData = response.data?.users || response.data || response
                  setUsers(Array.isArray(usersData) ? usersData : [])
                }).catch(err => console.error('Failed to refresh users:', err))
              }}
            />
          </Dialog>
        </div>

        {/* Search and Filters */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                <Input
                  placeholder="Kullanıcı adı veya email ile ara..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
              <div className="flex items-center space-x-2">
                <Filter className="h-4 w-4 text-gray-500" />
                <select
                  value={roleFilter}
                  onChange={(e) => setRoleFilter(e.target.value)}
                  className="border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  {getAvailableRoles().map(role => (
                    <option key={role.value} value={role.value}>{role.label}</option>
                  ))}
                </select>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Users className="h-8 w-8 text-blue-600" />
                <div>
                  <p className="text-2xl font-bold">{getViewableUsers().length}</p>
                  <p className="text-sm text-gray-600">
                    {currentUserRole === 'admin' ? 'Toplam Kullanıcı' :
                     currentUserRole === 'manager' ? 'Toplam Operatör' : 'Operatör Sayısı'}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <UserCheck className="h-8 w-8 text-green-600" />
                <div>
                  <p className="text-2xl font-bold">{getViewableUsers().filter(u => u.status === 'active').length}</p>
                  <p className="text-sm text-gray-600">Aktif Kullanıcı</p>
                </div>
              </div>
            </CardContent>
          </Card>
          {currentUserRole === 'admin' && (
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center space-x-2">
                  <Shield className="h-8 w-8 text-red-600" />
                  <div>
                    <p className="text-2xl font-bold">{users.filter(u => u.role === 'admin').length}</p>
                    <p className="text-sm text-gray-600">Yönetici</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
          {currentUserRole === 'admin' && (
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center space-x-2">
                  <Building2 className="h-8 w-8 text-orange-600" />
                  <div>
                    <p className="text-2xl font-bold">{users.filter(u => u.role === 'manager').length}</p>
                    <p className="text-sm text-gray-600">Müdür</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
          {currentUserRole !== 'admin' && (
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center space-x-2">
                  <Phone className="h-8 w-8 text-purple-600" />
                  <div>
                    <p className="text-2xl font-bold">{getViewableUsers().filter(u => u.phone && u.phone.length === 10).length}</p>
                    <p className="text-sm text-gray-600">Kayıtlı Telefon</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
          {currentUserRole !== 'admin' && (
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center space-x-2">
                  <Calendar className="h-8 w-8 text-indigo-600" />
                  <div>
                    <p className="text-2xl font-bold">
                      {getViewableUsers().filter(u => {
                        const createdDate = new Date(u.created_at)
                        const thirtyDaysAgo = new Date()
                        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
                        return createdDate > thirtyDaysAgo
                      }).length}
                    </p>
                    <p className="text-sm text-gray-600">Son 30 Gün</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Users Table */}
        <Card>
          <CardHeader>
            <CardTitle>Kullanıcı Listesi</CardTitle>
            <CardDescription>
              {currentUserRole === 'admin' ? 'Tüm sistem kullanıcıları' :
               currentUserRole === 'manager' ? 'Yönetiminizdeki operatörler' : 'Operatör listesi'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {filteredUsers.length > 0 ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Kullanıcı</TableHead>
                    <TableHead>E-posta</TableHead>
                    <TableHead>Telefon</TableHead>
                    <TableHead>Rol</TableHead>
                    <TableHead>Şirket</TableHead>
                    <TableHead>Durum</TableHead>
                    <TableHead>Kayıt Tarihi</TableHead>
                    <TableHead className="text-right">İşlemler</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredUsers.map((user) => {
                    const roleBadge = getRoleBadge(user.role)
                    return (
                      <TableRow key={user.id}>
                        <TableCell className="font-medium">
                          <div className="flex items-center space-x-3">
                            <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
                              <span className="text-blue-600 font-semibold text-sm">
                                {user.name.split(' ').map(n => n[0]).join('').toUpperCase()}
                              </span>
                            </div>
                            <span>{user.name}</span>
                          </div>
                        </TableCell>
                        <TableCell>{user.email}</TableCell>
                        <TableCell>
                          <div className="flex items-center">
                            <Phone className="h-4 w-4 mr-2 text-gray-400" />
                            {user.phone || 'Girilmemiş'}
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant="secondary"
                            className={roleBadge.className}
                          >
                            {roleBadge.label}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          {user.company ? (
                            <div className="flex items-center">
                              <Building2 className="h-4 w-4 mr-2 text-gray-400" />
                              {user.company.name}
                            </div>
                          ) : (
                            <span className="text-gray-400">-</span>
                          )}
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={user.status === 'active' ? 'default' : 'secondary'}
                            className={user.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}
                          >
                            {user.status === 'active' ? 'Aktif' : 'Pasif'}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center">
                            <Calendar className="h-4 w-4 mr-2 text-gray-400" />
                            {new Date(user.created_at).toLocaleDateString('tr-TR')}
                          </div>
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex items-center gap-2 justify-end">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => {
                                setSelectedUser(user)
                                setIsViewDialogOpen(true)
                              }}
                            >
                              <Eye className="h-4 w-4" />
                            </Button>
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => {
                                setSelectedUser(user)
                                setFormData({
                                  name: user.name,
                                  email: user.email,
                                  phone: user.phone || '',
                                  company: user.company?.name || '',
                                  role: user.role,
                                  photo: null
                                })
                                setIsEditDialogOpen(true)
                              }}
                            >
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button
                              variant="outline"
                              size="sm"
                              className="text-red-600 hover:text-red-700"
                              onClick={() => {
                                setSelectedUser(user)
                                setIsDeleteDialogOpen(true)
                              }}
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    )
                  })}
                </TableBody>
              </Table>
            ) : (
              <div className="text-center py-12">
                <Users className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">Kullanıcı bulunamadı</h3>
                <p className="text-gray-600 mb-4">Arama kriterlerinize uygun kullanıcı bulunamadı.</p>
                <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
                  <DialogTrigger asChild>
                    <Button>
                      <Plus className="h-4 w-4 mr-2" />
                      İlk Kullanıcıyı Ekle
                    </Button>
                  </DialogTrigger>
                  <AddUserDialog
                    formData={formData}
                    setFormData={setFormData}
                    photoPreview={photoPreview}
                    setPhotoPreview={setPhotoPreview}
                    onClose={() => setIsAddDialogOpen(false)}
                    onUserAdded={(user) => {
                      setUsers(prevUsers => [user, ...prevUsers])
                      // Refresh the full list
                      apiClient.getUsers().then(response => {
                        const usersData = response.data?.users || response.data || response
                        setUsers(Array.isArray(usersData) ? usersData : [])
                      }).catch(err => console.error('Failed to refresh users:', err))
                    }}
                  />
                </Dialog>
              </div>
            )}
          </CardContent>
        </Card>

        {/* View User Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Kullanıcı Detayları</DialogTitle>
              <DialogDescription>
                {selectedUser?.name} kullanıcısının detay bilgileri
              </DialogDescription>
            </DialogHeader>
            {selectedUser && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div>
                    <Label className="text-sm font-medium text-gray-500">Ad Soyad</Label>
                    <p className="text-lg font-semibold">{selectedUser.name}</p>
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-500">E-posta</Label>
                    <p className="text-lg">{selectedUser.email}</p>
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-500">Telefon</Label>
                    <p className="text-lg">{selectedUser.phone || 'Girilmemiş'}</p>
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-500">Rol</Label>
                    <Badge className={getRoleBadge(selectedUser.role).className}>
                      {getRoleBadge(selectedUser.role).label}
                    </Badge>
                  </div>
                </div>
                <div className="space-y-4">
                  <div>
                    <Label className="text-sm font-medium text-gray-500">Şirket</Label>
                    <p className="text-lg">{selectedUser.company?.name || 'Belirtilmemiş'}</p>
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-500">Durum</Label>
                    <Badge className={selectedUser.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}>
                      {selectedUser.status === 'active' ? 'Aktif' : 'Pasif'}
                    </Badge>
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-500">Kayıt Tarihi</Label>
                    <p className="text-lg">{new Date(selectedUser.created_at).toLocaleDateString('tr-TR')}</p>
                  </div>
                </div>
              </div>
            )}
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsViewDialogOpen(false)}>
                Kapat
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Edit User Dialog */}
        <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
          <EditUserDialog
            user={selectedUser}
            formData={formData}
            setFormData={setFormData}
            photoPreview={photoPreview}
            setPhotoPreview={setPhotoPreview}
            onClose={() => setIsEditDialogOpen(false)}
            onSave={(updatedUser) => {
              setUsers(prevUsers =>
                prevUsers.map(u => u.id === selectedUser?.id ? {...u, ...updatedUser} : u)
              )
              setIsEditDialogOpen(false)
            }}
          />
        </Dialog>

        {/* Delete Confirmation Dialog */}
        <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Kullanıcıyı Sil</DialogTitle>
              <DialogDescription>
                {selectedUser?.name} kullanıcısını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.
              </DialogDescription>
            </DialogHeader>
            <DialogFooter className="flex gap-3">
              <Button
                variant="outline"
                onClick={() => setIsDeleteDialogOpen(false)}
              >
                İptal
              </Button>
              <Button
                variant="destructive"
                onClick={async () => {
                  if (selectedUser) {
                    try {
                      await apiClient.deleteUser(selectedUser.id.toString())
                      setUsers(prevUsers => prevUsers.filter(u => u.id !== selectedUser.id))
                      setIsDeleteDialogOpen(false)
                      alert(`${selectedUser.name} kullanıcısı başarıyla silindi.`)
                    } catch (error: any) {
                      console.error('Kullanıcı silinirken hata oluştu:', error)
                      let errorMessage = 'Kullanıcı silinirken hata oluştu'

                      if (error.response?.data?.message) {
                        errorMessage = error.response.data.message
                      } else if (error.message) {
                        errorMessage = error.message
                      }

                      alert(errorMessage)
                    }
                  }
                }}
              >
                Sil
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

      </div>
    </AdminLayout>
  )
}

interface AddUserDialogProps {
  formData: {
    name: string
    email: string
    phone: string
    company: string
    role: string
    photo: File | null
  }
  setFormData: React.Dispatch<React.SetStateAction<any>>
  photoPreview: string | null
  setPhotoPreview: React.Dispatch<React.SetStateAction<string | null>>
  onClose: () => void
  onUserAdded: (user: any) => void
}

function AddUserDialog({ formData, setFormData, photoPreview, setPhotoPreview, onClose, onUserAdded }: AddUserDialogProps) {
  const handleInputChange = (field: string, value: string) => {
    setFormData((prev: any) => ({ ...prev, [field]: value }))
  }

  const handlePhotoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setFormData((prev: any) => ({ ...prev, photo: file }))

      // Create preview
      const reader = new FileReader()
      reader.onload = (e) => {
        setPhotoPreview(e.target?.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const removePhoto = () => {
    setFormData((prev: any) => ({ ...prev, photo: null }))
    setPhotoPreview(null)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    // Password validation
    if (!formData.password || formData.password.length < 8) {
      alert('Şifre en az 8 karakter olmalıdır')
      return
    }

    if (formData.password !== formData.password_confirmation) {
      alert('Şifreler eşleşmiyor')
      return
    }

    try {
      console.log('Kullanıcı ekleme verisi:', formData)

      const response = await apiClient.createUser({
        name: formData.name,
        email: formData.email,
        phone: formData.phone,
        role: formData.role,
        password: formData.password,
        password_confirmation: formData.password_confirmation
      })

      console.log('Kullanıcı eklendi:', response)

      // Call onUserAdded callback with new user
      if (response.data?.user) {
        onUserAdded(response.data.user)
      }

      // Reset form
      setFormData({
        name: '',
        email: '',
        phone: '',
        company: '',
        role: 'operator',
        photo: null,
        password: '',
        password_confirmation: ''
      })
      setPhotoPreview(null)
      onClose()

      alert('Kullanıcı başarıyla eklendi!')
    } catch (error: any) {
      console.error('Kullanıcı eklenirken hata oluştu:', error)
      console.error('Error response:', error.response)
      console.error('Error response data:', error.response?.data)
      console.error('ERRORS OBJECT:', error.response?.data?.errors)

      // Extract error message
      let errorMessage = 'Kullanıcı eklenirken hata oluştu'

      if (error.response?.data?.errors) {
        // Validation errors
        const errors = error.response.data.errors
        const errorMessages = Object.entries(errors).map(([field, messages]: [string, any]) => {
          return `${field}: ${Array.isArray(messages) ? messages.join(', ') : messages}`
        })
        errorMessage = errorMessages.join('\n')
      } else if (error.response?.data?.message) {
        errorMessage = error.response.data.message
      } else if (error.message) {
        errorMessage = error.message
      }

      alert(errorMessage)
    }
  }

  return (
    <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
      <DialogHeader>
        <DialogTitle>Yeni Kullanıcı Ekle</DialogTitle>
        <DialogDescription>
          Yeni bir kullanıcı hesabı oluşturun. Tüm gerekli bilgileri doldurun.
        </DialogDescription>
      </DialogHeader>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Photo Upload Section */}
        <div className="space-y-4">
          <Label>Profil Fotoğrafı</Label>
          <div className="flex items-center space-x-4">
            {photoPreview ? (
              <div className="relative">
                <img
                  src={photoPreview}
                  alt="Profil önizleme"
                  className="w-20 h-20 rounded-full object-cover border-2 border-gray-300"
                />
                <button
                  type="button"
                  onClick={removePhoto}
                  className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
                >
                  <X className="h-3 w-3" />
                </button>
              </div>
            ) : (
              <div className="w-20 h-20 rounded-full bg-gray-200 flex items-center justify-center border-2 border-dashed border-gray-300">
                <Camera className="h-8 w-8 text-gray-400" />
              </div>
            )}

            <div className="flex-1">
              <Label htmlFor="photo" className="cursor-pointer">
                <div className="flex items-center gap-2 px-4 py-2 bg-blue-50 text-blue-600 rounded-lg border border-blue-200 hover:bg-blue-100 transition-colors">
                  <Upload className="h-4 w-4" />
                  Fotoğraf Seç
                </div>
              </Label>
              <Input
                id="photo"
                type="file"
                accept="image/*"
                onChange={handlePhotoChange}
                className="hidden"
              />
              <p className="text-xs text-gray-500 mt-1">
                JPG, PNG veya GIF formatında, maksimum 5MB
              </p>
            </div>
          </div>
        </div>

        {/* Personal Information */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="name">Ad Soyad *</Label>
            <Input
              id="name"
              placeholder="Örn: Ahmet Yılmaz"
              value={formData.name}
              onChange={(e) => handleInputChange('name', e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="email">E-posta *</Label>
            <Input
              id="email"
              type="email"
              placeholder="Örn: ahmet@smartop.com"
              value={formData.email}
              onChange={(e) => handleInputChange('email', e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="phone">Telefon Numarası</Label>
            <Input
              id="phone"
              type="tel"
              placeholder="Örn: 5321234567 (10 haneli)"
              value={formData.phone}
              onChange={(e) => {
                // Sadece sayıları kabul et ve 10 haneli olacak şekilde sınırla
                const value = e.target.value.replace(/\D/g, '').slice(0, 10)
                handleInputChange('phone', value)
              }}
              maxLength={10}
              pattern="[0-9]{10}"
            />
            <p className="text-xs text-gray-500">
              10 haneli mobil numara (opsiyonel)
            </p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="password">Şifre *</Label>
            <Input
              id="password"
              type="password"
              placeholder="En az 8 karakter"
              value={formData.password}
              onChange={(e) => handleInputChange('password', e.target.value)}
              required
              minLength={8}
            />
          </div>
        </div>

        {/* Password Confirmation */}
        <div className="space-y-2">
          <Label htmlFor="password_confirmation">Şifre Onayı *</Label>
          <Input
            id="password_confirmation"
            type="password"
            placeholder="Şifreyi tekrar girin"
            value={formData.password_confirmation}
            onChange={(e) => handleInputChange('password_confirmation', e.target.value)}
            required
            minLength={8}
          />
          <p className="text-xs text-gray-500">
            Şifrenizi onaylamak için tekrar girin
          </p>
        </div>

        {/* Role Selection */}
        <div className="space-y-2">
          <Label htmlFor="role">Kullanıcı Rolü *</Label>
          <select
            id="role"
            value={formData.role}
            onChange={(e) => handleInputChange('role', e.target.value)}
            className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            required
          >
            <option value="operator">Operatör - Makine kontrolü ve raporlama</option>
            <option value="manager">Manager - Şirket yönetimi ve onaylar</option>
            <option value="admin">Admin - Sistem yönetimi (sadece süper admin)</option>
          </select>
          <p className="text-xs text-gray-500">
            Rol seçimi kullanıcının sistem içindeki yetkilerini belirler
          </p>
        </div>

        <DialogFooter className="flex gap-3">
          <Button
            type="button"
            variant="outline"
            onClick={onClose}
          >
            İptal
          </Button>
          <Button
            type="submit"
            className="bg-blue-600 hover:bg-blue-700"
          >
            Kullanıcı Ekle
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  )
}

interface EditUserDialogProps {
  user: any
  formData: {
    name: string
    email: string
    phone: string
    company: string
    role: string
    photo: File | null
  }
  setFormData: React.Dispatch<React.SetStateAction<any>>
  photoPreview: string | null
  setPhotoPreview: React.Dispatch<React.SetStateAction<string | null>>
  onClose: () => void
  onSave: (updatedUser: any) => void
}

function EditUserDialog({ user, formData, setFormData, photoPreview, setPhotoPreview, onClose, onSave }: EditUserDialogProps) {
  const [isLoading, setIsLoading] = useState(false)

  // Initialize form with user data when dialog opens
  useEffect(() => {
    if (user) {
      setFormData({
        name: user.name || '',
        email: user.email || '',
        phone: user.phone || '',
        company: user.company?.name || '',
        role: user.role || 'operator',
        photo: null
      })
      // If user has a photo, you could set the preview here
      setPhotoPreview(user.photo || null)
    }
  }, [user, setFormData, setPhotoPreview])

  const handleInputChange = (field: string, value: string) => {
    setFormData((prev: any) => ({ ...prev, [field]: value }))
  }

  const handlePhotoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setFormData((prev: any) => ({ ...prev, photo: file }))

      // Create preview
      const reader = new FileReader()
      reader.onload = (e) => {
        setPhotoPreview(e.target?.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const removePhoto = () => {
    setFormData((prev: any) => ({ ...prev, photo: null }))
    setPhotoPreview(null)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)

    // Telefon numarası validasyonu (opsiyonel)
    if (formData.phone && formData.phone.length > 0) {
      if (formData.phone.length !== 10) {
        alert('Telefon numarası 10 haneli olmalıdır (başında 0 olmadan)')
        setIsLoading(false)
        return
      }

      if (!formData.phone.startsWith('5')) {
        alert('Telefon numarası 5 ile başlamalıdır (mobil numara)')
        setIsLoading(false)
        return
      }
    }

    try {
      console.log('Kullanıcı güncelleme verisi:', formData)

      const updateData: any = {
        name: formData.name,
        email: formData.email,
        phone: formData.phone || null,
        role: formData.role
      }

      const response = await apiClient.updateUser(user.id.toString(), updateData)
      console.log('Kullanıcı güncellendi:', response)

      // Call the onSave callback to update the user in the parent component
      if (response.data?.user) {
        onSave(response.data.user)
      } else {
        onSave(updateData)
      }

      // Reset form
      setFormData({
        name: '',
        email: '',
        phone: '',
        company: '',
        role: 'operator',
        photo: null
      })
      setPhotoPreview(null)
      onClose()

      alert('Kullanıcı başarıyla güncellendi!')
    } catch (error: any) {
      console.error('Kullanıcı güncellenirken hata oluştu:', error)
      console.error('Error response:', error.response)

      let errorMessage = 'Kullanıcı güncellenirken hata oluştu'

      if (error.response?.data?.errors) {
        const errors = error.response.data.errors
        const errorMessages = Object.entries(errors).map(([field, messages]: [string, any]) => {
          return `${field}: ${Array.isArray(messages) ? messages.join(', ') : messages}`
        })
        errorMessage = errorMessages.join('\n')
      } else if (error.response?.data?.message) {
        errorMessage = error.response.data.message
      } else if (error.message) {
        errorMessage = error.message
      }

      alert(errorMessage)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
      <DialogHeader>
        <DialogTitle>Kullanıcı Düzenle</DialogTitle>
        <DialogDescription>
          {user?.name} kullanıcısının bilgilerini güncelleyin.
        </DialogDescription>
      </DialogHeader>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Photo Upload Section */}
        <div className="space-y-4">
          <Label>Profil Fotoğrafı</Label>
          <div className="flex items-center space-x-4">
            {photoPreview ? (
              <div className="relative">
                <img
                  src={photoPreview}
                  alt="Profil önizleme"
                  className="w-20 h-20 rounded-full object-cover border-2 border-gray-300"
                />
                <button
                  type="button"
                  onClick={removePhoto}
                  className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
                >
                  <X className="h-3 w-3" />
                </button>
              </div>
            ) : (
              <div className="w-20 h-20 rounded-full bg-gray-200 flex items-center justify-center border-2 border-dashed border-gray-300">
                <Camera className="h-8 w-8 text-gray-400" />
              </div>
            )}

            <div className="flex-1">
              <Label htmlFor="edit-photo" className="cursor-pointer">
                <div className="flex items-center gap-2 px-4 py-2 bg-blue-50 text-blue-600 rounded-lg border border-blue-200 hover:bg-blue-100 transition-colors">
                  <Upload className="h-4 w-4" />
                  Fotoğraf Değiştir
                </div>
              </Label>
              <Input
                id="edit-photo"
                type="file"
                accept="image/*"
                onChange={handlePhotoChange}
                className="hidden"
              />
              <p className="text-xs text-gray-500 mt-1">
                JPG, PNG veya GIF formatında, maksimum 5MB
              </p>
            </div>
          </div>
        </div>

        {/* Personal Information */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="edit-name">Ad Soyad *</Label>
            <Input
              id="edit-name"
              placeholder="Örn: Ahmet Yılmaz"
              value={formData.name}
              onChange={(e) => handleInputChange('name', e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="edit-email">E-posta *</Label>
            <Input
              id="edit-email"
              type="email"
              placeholder="Örn: ahmet@smartop.com"
              value={formData.email}
              onChange={(e) => handleInputChange('email', e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="edit-phone">Telefon Numarası *</Label>
            <Input
              id="edit-phone"
              type="tel"
              placeholder="Örn: 5321234567 (10 haneli)"
              value={formData.phone}
              onChange={(e) => {
                // Sadece sayıları kabul et ve 10 haneli olacak şekilde sınırla
                const value = e.target.value.replace(/\D/g, '').slice(0, 10)
                handleInputChange('phone', value)
              }}
              maxLength={10}
              pattern="[0-9]{10}"
              required
            />
            <p className="text-xs text-gray-500">
              10 haneli mobil numara (5 ile başlayan): 5321234567. Bu numara giriş için kullanılacak.
            </p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="edit-company">Şirket</Label>
            <Input
              id="edit-company"
              placeholder="Örn: SmartOp A.Ş."
              value={formData.company}
              onChange={(e) => handleInputChange('company', e.target.value)}
            />
          </div>
        </div>

        {/* Role Selection */}
        <div className="space-y-2">
          <Label htmlFor="edit-role">Kullanıcı Rolü *</Label>
          <select
            id="edit-role"
            value={formData.role}
            onChange={(e) => handleInputChange('role', e.target.value)}
            className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            required
          >
            <option value="operator">Operatör - Makine kontrolü ve raporlama</option>
            <option value="manager">Manager - Şirket yönetimi ve onaylar</option>
            <option value="admin">Admin - Sistem yönetimi (sadece süper admin)</option>
          </select>
          <p className="text-xs text-gray-500">
            Rol seçimi kullanıcının sistem içindeki yetkilerini belirler
          </p>
        </div>

        <DialogFooter className="flex gap-3">
          <Button
            type="button"
            variant="outline"
            onClick={onClose}
            disabled={isLoading}
          >
            İptal
          </Button>
          <Button
            type="submit"
            className="bg-blue-600 hover:bg-blue-700"
            disabled={isLoading}
          >
            {isLoading ? 'Güncelleniyor...' : 'Kullanıcıyı Güncelle'}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  )
}