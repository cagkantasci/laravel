'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { apiClient } from '@/lib/api'
import {
  Building2,
  ArrowLeft,
  Cog,
  Users,
  Mail,
  Phone,
  MapPin,
  Calendar,
  UserPlus,
  ClipboardList,
  CheckCircle,
  AlertTriangle,
  Plus,
  Trash2,
  Edit,
  QrCode
} from 'lucide-react'

interface Machine {
  id: number
  name: string
  machine_code: string
  machine_type: string
  status: 'active' | 'maintenance' | 'inactive'
  serial_number?: string
  manufacturer?: string
  model?: string
  created_at: string
  assigned_operators?: any[]
}

interface Operator {
  id: number
  name: string
  email: string
  phone?: string
  status: string
  role: string
}

interface Company {
  id: number
  name: string
  email?: string
  phone?: string
  address?: string
  city?: string
  district?: string
  status: string
  subscription_plan?: string
  subscription_status?: string
  created_at: string
}

export default function CompanyDetailPage() {
  const params = useParams()
  const router = useRouter()
  const companyId = params.id as string

  const [company, setCompany] = useState<Company | null>(null)
  const [machines, setMachines] = useState<Machine[]>([])
  const [operators, setOperators] = useState<Operator[]>([])
  const [allOperators, setAllOperators] = useState<Operator[]>([])
  const [controlTemplates, setControlTemplates] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  const [isAssignOperatorOpen, setIsAssignOperatorOpen] = useState(false)
  const [isAssignControlListOpen, setIsAssignControlListOpen] = useState(false)
  const [selectedMachine, setSelectedMachine] = useState<Machine | null>(null)
  const [selectedOperatorId, setSelectedOperatorId] = useState('')
  const [selectedTemplateId, setSelectedTemplateId] = useState('')

  useEffect(() => {
    fetchCompanyData()
  }, [companyId])

  const fetchCompanyData = async () => {
    setLoading(true)
    try {
      // Fetch company details
      const companyResponse = await apiClient.getCompany(companyId)
      setCompany(companyResponse.data || companyResponse)

      // Fetch machines for this company
      const machinesResponse = await apiClient.getMachines({ company_id: companyId })
      const machinesData = machinesResponse.data || machinesResponse
      setMachines(Array.isArray(machinesData) ? machinesData : [])

      // Fetch all users (filter operators for this company)
      const usersResponse = await apiClient.getUsers()
      const usersData = usersResponse.data?.users || usersResponse.data || usersResponse

      if (Array.isArray(usersData)) {
        const allOps = usersData.filter((user: any) => user.role === 'operator')
        setAllOperators(allOps)

        // Filter operators for this company
        const companyOps = allOps.filter((user: any) => user.company?.id === parseInt(companyId))
        setOperators(companyOps)
      }

      // Fetch control templates
      const templatesResponse = await apiClient.getControlTemplates()
      const templatesData = templatesResponse.data || templatesResponse
      setControlTemplates(Array.isArray(templatesData) ? templatesData : [])

    } catch (error) {
      console.error('Error fetching company data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAssignOperator = async () => {
    if (!selectedMachine || !selectedOperatorId) {
      alert('Lütfen operatör seçin')
      return
    }

    try {
      // Call API to assign operator to machine
      await apiClient.assignOperatorToMachine(selectedMachine.id.toString(), {
        operator_id: selectedOperatorId
      })

      alert('Operatör başarıyla atandı!')
      setIsAssignOperatorOpen(false)
      setSelectedOperatorId('')
      fetchCompanyData()
    } catch (error: any) {
      console.error('Error assigning operator:', error)
      alert('Operatör atanamadı: ' + (error.response?.data?.message || error.message))
    }
  }

  const handleAssignControlList = async () => {
    if (!selectedMachine || !selectedTemplateId) {
      alert('Lütfen kontrol listesi şablonu seçin')
      return
    }

    try {
      // Call API to create control list from template
      await apiClient.createControlListFromTemplate(selectedTemplateId, {
        machine_id: selectedMachine.id
      })

      alert('Kontrol listesi başarıyla oluşturuldu!')
      setIsAssignControlListOpen(false)
      setSelectedTemplateId('')
      fetchCompanyData()
    } catch (error: any) {
      console.error('Error creating control list:', error)
      alert('Kontrol listesi oluşturulamadı: ' + (error.response?.data?.message || error.message))
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

  if (!company) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center h-64">
          <div className="text-lg text-red-600">Şirket bulunamadı</div>
        </div>
      </AdminLayout>
    )
  }

  const getMachineStatusBadge = (status: string) => {
    switch (status) {
      case 'active':
        return <Badge className="bg-green-100 text-green-800">Aktif</Badge>
      case 'maintenance':
        return <Badge className="bg-yellow-100 text-yellow-800">Bakımda</Badge>
      case 'inactive':
        return <Badge className="bg-gray-100 text-gray-800">Pasif</Badge>
      default:
        return <Badge>{status}</Badge>
    }
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Button
              variant="outline"
              size="sm"
              onClick={() => router.back()}
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Geri
            </Button>
            <div>
              <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                <Building2 className="h-8 w-8 text-blue-600" />
                {company.name}
              </h1>
              <p className="text-gray-600 mt-1">Şirket Detayları ve Yönetim</p>
            </div>
          </div>
          <Badge
            variant={company.status === 'active' ? 'default' : 'secondary'}
            className={company.status === 'active' ? 'bg-green-100 text-green-800 text-lg px-4 py-2' : 'text-lg px-4 py-2'}
          >
            {company.status === 'active' ? 'Aktif' : 'Pasif'}
          </Badge>
        </div>

        {/* Company Info */}
        <Card>
          <CardHeader>
            <CardTitle>Şirket Bilgileri</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {company.email && (
                <div className="flex items-center gap-2">
                  <Mail className="h-5 w-5 text-gray-400" />
                  <div>
                    <p className="text-sm text-gray-500">E-posta</p>
                    <p className="font-medium">{company.email}</p>
                  </div>
                </div>
              )}
              {company.phone && (
                <div className="flex items-center gap-2">
                  <Phone className="h-5 w-5 text-gray-400" />
                  <div>
                    <p className="text-sm text-gray-500">Telefon</p>
                    <p className="font-medium">{company.phone}</p>
                  </div>
                </div>
              )}
              {company.address && (
                <div className="flex items-center gap-2">
                  <MapPin className="h-5 w-5 text-gray-400" />
                  <div>
                    <p className="text-sm text-gray-500">Adres</p>
                    <p className="font-medium">{company.address}</p>
                  </div>
                </div>
              )}
              <div className="flex items-center gap-2">
                <Calendar className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Kayıt Tarihi</p>
                  <p className="font-medium">
                    {new Date(company.created_at).toLocaleDateString('tr-TR')}
                  </p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-3">
                <div className="p-3 bg-blue-100 rounded-lg">
                  <Cog className="h-6 w-6 text-blue-600" />
                </div>
                <div>
                  <p className="text-2xl font-bold">{machines.length}</p>
                  <p className="text-sm text-gray-600">Toplam Makine</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-3">
                <div className="p-3 bg-green-100 rounded-lg">
                  <Users className="h-6 w-6 text-green-600" />
                </div>
                <div>
                  <p className="text-2xl font-bold">{operators.length}</p>
                  <p className="text-sm text-gray-600">Operatör Sayısı</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-3">
                <div className="p-3 bg-orange-100 rounded-lg">
                  <CheckCircle className="h-6 w-6 text-orange-600" />
                </div>
                <div>
                  <p className="text-2xl font-bold">
                    {machines.filter(m => m.status === 'active').length}
                  </p>
                  <p className="text-sm text-gray-600">Aktif Makine</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Tabs */}
        <Tabs defaultValue="machines" className="space-y-6">
          <TabsList>
            <TabsTrigger value="machines">
              <Cog className="h-4 w-4 mr-2" />
              Makineler
            </TabsTrigger>
            <TabsTrigger value="operators">
              <Users className="h-4 w-4 mr-2" />
              Operatörler
            </TabsTrigger>
          </TabsList>

          {/* Machines Tab */}
          <TabsContent value="machines">
            <Card>
              <CardHeader>
                <CardTitle>Makineler</CardTitle>
                <CardDescription>Şirkete ait tüm makineler</CardDescription>
              </CardHeader>
              <CardContent>
                {machines.length > 0 ? (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Makine Adı</TableHead>
                        <TableHead>Kod</TableHead>
                        <TableHead>Tip</TableHead>
                        <TableHead>Durum</TableHead>
                        <TableHead>İşlemler</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {machines.map((machine) => (
                        <TableRow key={machine.id}>
                          <TableCell className="font-medium">{machine.name}</TableCell>
                          <TableCell>{machine.machine_code}</TableCell>
                          <TableCell>{machine.machine_type}</TableCell>
                          <TableCell>{getMachineStatusBadge(machine.status)}</TableCell>
                          <TableCell>
                            <div className="flex gap-2">
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => {
                                  setSelectedMachine(machine)
                                  setIsAssignOperatorOpen(true)
                                }}
                              >
                                <UserPlus className="h-4 w-4 mr-1" />
                                Operatör Ata
                              </Button>
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => {
                                  setSelectedMachine(machine)
                                  setIsAssignControlListOpen(true)
                                }}
                              >
                                <ClipboardList className="h-4 w-4 mr-1" />
                                Kontrol Listesi
                              </Button>
                            </div>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <div className="text-center py-12">
                    <Cog className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-gray-600">Henüz makine eklenmemiş</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Operators Tab */}
          <TabsContent value="operators">
            <Card>
              <CardHeader>
                <CardTitle>Operatörler</CardTitle>
                <CardDescription>Şirkete ait operatör listesi</CardDescription>
              </CardHeader>
              <CardContent>
                {operators.length > 0 ? (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Adı</TableHead>
                        <TableHead>E-posta</TableHead>
                        <TableHead>Telefon</TableHead>
                        <TableHead>Durum</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {operators.map((operator) => (
                        <TableRow key={operator.id}>
                          <TableCell className="font-medium">{operator.name}</TableCell>
                          <TableCell>{operator.email}</TableCell>
                          <TableCell>{operator.phone || '-'}</TableCell>
                          <TableCell>
                            <Badge
                              className={
                                operator.status === 'active'
                                  ? 'bg-green-100 text-green-800'
                                  : 'bg-gray-100 text-gray-800'
                              }
                            >
                              {operator.status === 'active' ? 'Aktif' : 'Pasif'}
                            </Badge>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <div className="text-center py-12">
                    <Users className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-gray-600">Henüz operatör eklenmemiş</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        {/* Assign Operator Dialog */}
        <Dialog open={isAssignOperatorOpen} onOpenChange={setIsAssignOperatorOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Operatör Ata</DialogTitle>
              <DialogDescription>
                {selectedMachine?.name} makinesine operatör atayın
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="operator">Operatör Seç</Label>
                <select
                  id="operator"
                  value={selectedOperatorId}
                  onChange={(e) => setSelectedOperatorId(e.target.value)}
                  className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">Operatör seçin...</option>
                  {allOperators.map((operator) => (
                    <option key={operator.id} value={operator.id}>
                      {operator.name} ({operator.email})
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsAssignOperatorOpen(false)}>
                İptal
              </Button>
              <Button onClick={handleAssignOperator}>Ata</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Assign Control List Dialog */}
        <Dialog open={isAssignControlListOpen} onOpenChange={setIsAssignControlListOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Kontrol Listesi Oluştur</DialogTitle>
              <DialogDescription>
                {selectedMachine?.name} makinesi için kontrol listesi oluşturun
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="template">Kontrol Listesi Şablonu</Label>
                <select
                  id="template"
                  value={selectedTemplateId}
                  onChange={(e) => setSelectedTemplateId(e.target.value)}
                  className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">Şablon seçin...</option>
                  {controlTemplates.map((template) => (
                    <option key={template.id} value={template.id}>
                      {template.title}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsAssignControlListOpen(false)}>
                İptal
              </Button>
              <Button onClick={handleAssignControlList}>Oluştur</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  )
}
