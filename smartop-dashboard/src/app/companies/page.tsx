'use client'

import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Label } from '@/components/ui/label'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { apiClient, Company } from '@/lib/api'
import {
  Plus,
  Search,
  Building2,
  Users,
  Calendar,
  Mail,
  Phone,
  MapPin,
  Edit,
  Trash2,
  Eye
} from 'lucide-react'

export default function CompaniesPage() {
  const [companies, setCompanies] = useState<Company[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [showAddModal, setShowAddModal] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    trade_name: '',
    tax_number: '',
    tax_office: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    district: '',
    postal_code: '',
    website: '',
  })

  useEffect(() => {
    const fetchCompanies = async () => {
      try {
        const response = await apiClient.getCompanies()
        setCompanies(response.data || response)
      } catch (error) {
        console.error('Companies fetch error:', error)
        setCompanies([])
      } finally {
        setLoading(false)
      }
    }

    fetchCompanies()
  }, [])

  const handleAddCompany = () => {
    setShowAddModal(true)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setSubmitting(true)

    try {
      const response = await apiClient.createCompany(formData)

      // Add new company to list
      if (response.data) {
        setCompanies([response.data, ...companies])
      }

      // Reset form and close modal
      setFormData({
        name: '',
        trade_name: '',
        tax_number: '',
        tax_office: '',
        email: '',
        phone: '',
        address: '',
        city: '',
        district: '',
        postal_code: '',
        website: '',
      })
      setShowAddModal(false)
      alert('Şirket başarıyla eklendi!')

      // Refresh companies list
      const updatedResponse = await apiClient.getCompanies()
      setCompanies(updatedResponse.data || updatedResponse)
    } catch (error: any) {
      console.error('Error creating company:', error)
      console.error('Error response:', error.response)
      console.error('Error response data:', error.response?.data)
      console.error('ERRORS OBJECT:', error.response?.data?.errors)

      // Extract error message
      let errorMessage = 'Şirket eklenirken hata oluştu'

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
    } finally {
      setSubmitting(false)
    }
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  const handleViewCompany = (company: Company) => {
    console.log('View company:', company)
    alert(`${company.name} detayları görüntüleniyor`)
  }

  const handleEditCompany = (company: Company) => {
    console.log('Edit company:', company)
    alert(`${company.name} düzenleniyor`)
  }

  const handleDeleteCompany = (company: Company) => {
    if (confirm(`${company.name} şirketini silmek istediğinize emin misiniz?`)) {
      console.log('Delete company:', company)
      alert('Şirket silme özelliği yakında eklenecek!')
    }
  }

  const filteredCompanies = companies.filter(company =>
    company.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    company.email?.toLowerCase().includes(searchTerm.toLowerCase())
  )

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
      {/* Add Company Modal */}
      <Dialog open={showAddModal} onOpenChange={setShowAddModal}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Yeni Şirket Ekle</DialogTitle>
            <DialogDescription>
              Sisteme yeni bir şirket eklemek için aşağıdaki formu doldurun.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit}>
            <div className="grid gap-4 py-4">
              {/* Şirket Adı */}
              <div className="grid gap-2">
                <Label htmlFor="name">Şirket Adı *</Label>
                <Input
                  id="name"
                  name="name"
                  value={formData.name}
                  onChange={handleInputChange}
                  required
                  placeholder="Örn: ABC Teknoloji A.Ş."
                />
              </div>

              {/* Ticari Unvan */}
              <div className="grid gap-2">
                <Label htmlFor="trade_name">Ticari Unvan</Label>
                <Input
                  id="trade_name"
                  name="trade_name"
                  value={formData.trade_name}
                  onChange={handleInputChange}
                  placeholder="Örn: ABC Tech"
                />
              </div>

              {/* Vergi Numarası */}
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="tax_number">Vergi Numarası *</Label>
                  <Input
                    id="tax_number"
                    name="tax_number"
                    value={formData.tax_number}
                    onChange={handleInputChange}
                    required
                    placeholder="1234567890"
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="tax_office">Vergi Dairesi</Label>
                  <Input
                    id="tax_office"
                    name="tax_office"
                    value={formData.tax_office}
                    onChange={handleInputChange}
                    placeholder="Örn: Beşiktaş V.D."
                  />
                </div>
              </div>

              {/* İletişim Bilgileri */}
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="email">E-posta</Label>
                  <Input
                    id="email"
                    name="email"
                    type="email"
                    value={formData.email}
                    onChange={handleInputChange}
                    placeholder="info@sirket.com"
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="phone">Telefon</Label>
                  <Input
                    id="phone"
                    name="phone"
                    value={formData.phone}
                    onChange={handleInputChange}
                    placeholder="+90 555 123 45 67"
                  />
                </div>
              </div>

              {/* Adres */}
              <div className="grid gap-2">
                <Label htmlFor="address">Adres</Label>
                <Input
                  id="address"
                  name="address"
                  value={formData.address}
                  onChange={handleInputChange}
                  placeholder="Sokak, Mahalle, No"
                />
              </div>

              {/* Şehir, İlçe, Posta Kodu */}
              <div className="grid grid-cols-3 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="city">Şehir</Label>
                  <Input
                    id="city"
                    name="city"
                    value={formData.city}
                    onChange={handleInputChange}
                    placeholder="İstanbul"
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="district">İlçe</Label>
                  <Input
                    id="district"
                    name="district"
                    value={formData.district}
                    onChange={handleInputChange}
                    placeholder="Beşiktaş"
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="postal_code">Posta Kodu</Label>
                  <Input
                    id="postal_code"
                    name="postal_code"
                    value={formData.postal_code}
                    onChange={handleInputChange}
                    placeholder="34357"
                  />
                </div>
              </div>

              {/* Website */}
              <div className="grid gap-2">
                <Label htmlFor="website">Website</Label>
                <Input
                  id="website"
                  name="website"
                  type="url"
                  value={formData.website}
                  onChange={handleInputChange}
                  placeholder="https://www.sirket.com"
                />
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setShowAddModal(false)}
                disabled={submitting}
              >
                İptal
              </Button>
              <Button type="submit" disabled={submitting}>
                {submitting ? 'Ekleniyor...' : 'Şirket Ekle'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Şirket Yönetimi</h1>
            <p className="text-gray-600">Sistemdeki şirketleri görüntüleyin ve yönetin</p>
          </div>
          <Button onClick={handleAddCompany} className="flex items-center gap-2">
            <Plus className="h-4 w-4" />
            Yeni Şirket
          </Button>
        </div>

        {/* Search and Filters */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center space-x-2">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                <Input
                  placeholder="Şirket adı veya email ile ara..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Building2 className="h-8 w-8 text-blue-600" />
                <div>
                  <p className="text-2xl font-bold">{companies.length}</p>
                  <p className="text-sm text-gray-600">Toplam Şirket</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Users className="h-8 w-8 text-green-600" />
                <div>
                  <p className="text-2xl font-bold">{companies.filter(c => c.status === 'active').length}</p>
                  <p className="text-sm text-gray-600">Aktif Şirket</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Calendar className="h-8 w-8 text-orange-600" />
                <div>
                  <p className="text-2xl font-bold">{companies.filter(c => c.subscription_status === 'active').length}</p>
                  <p className="text-sm text-gray-600">Aktif Abonelik</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Building2 className="h-8 w-8 text-red-600" />
                <div>
                  <p className="text-2xl font-bold">{companies.filter(c => c.status === 'inactive').length}</p>
                  <p className="text-sm text-gray-600">Pasif Şirket</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Companies List */}
        <Card>
          <CardContent className="p-0">
            {filteredCompanies.length > 0 ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Şirket Adı</TableHead>
                    <TableHead>İletişim</TableHead>
                    <TableHead>Adres</TableHead>
                    <TableHead>Durum</TableHead>
                    <TableHead>Kayıt Tarihi</TableHead>
                    <TableHead className="text-right">İşlemler</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredCompanies.map((company) => (
                    <TableRow
                      key={company.id}
                      className="cursor-pointer hover:bg-gray-50"
                      onClick={() => window.location.href = `/companies/${company.id}`}
                    >
                      <TableCell className="font-medium">
                        <div className="flex items-center gap-2">
                          <Building2 className="h-4 w-4 text-gray-400" />
                          {company.name}
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="space-y-1 text-sm">
                          {company.email && (
                            <div className="flex items-center text-gray-600">
                              <Mail className="h-3 w-3 mr-1" />
                              {company.email}
                            </div>
                          )}
                          {company.phone && (
                            <div className="flex items-center text-gray-600">
                              <Phone className="h-3 w-3 mr-1" />
                              {company.phone}
                            </div>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="max-w-xs">
                        {company.address ? (
                          <div className="flex items-start text-sm text-gray-600">
                            <MapPin className="h-3 w-3 mr-1 mt-0.5 flex-shrink-0" />
                            <span className="truncate">{company.address}</span>
                          </div>
                        ) : (
                          <span className="text-gray-400">-</span>
                        )}
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant={company.status === 'active' ? 'default' : 'secondary'}
                          className={company.status === 'active' ? 'bg-green-100 text-green-800' : ''}
                        >
                          {company.status === 'active' ? 'Aktif' : 'Pasif'}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center text-sm text-gray-600">
                          <Calendar className="h-3 w-3 mr-1" />
                          {new Date(company.created_at).toLocaleDateString('tr-TR')}
                        </div>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            onClick={(e) => {
                              e.stopPropagation()
                              window.location.href = `/companies/${company.id}`
                            }}
                            variant="outline"
                            size="sm"
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          <Button
                            onClick={(e) => {
                              e.stopPropagation()
                              handleEditCompany(company)
                            }}
                            variant="outline"
                            size="sm"
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            onClick={(e) => {
                              e.stopPropagation()
                              handleDeleteCompany(company)
                            }}
                            variant="outline"
                            size="sm"
                            className="text-red-600 hover:text-red-700"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            ) : (
              <div className="text-center py-12">
                <Building2 className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">Şirket bulunamadı</h3>
                <p className="text-gray-600 mb-4">Arama kriterlerinize uygun şirket bulunamadı.</p>
                <Button onClick={handleAddCompany}>
                  <Plus className="h-4 w-4 mr-2" />
                  İlk Şirketi Ekle
                </Button>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  )
}