'use client'

import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Label } from '@/components/ui/label'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { QRCodeModal } from '@/components/ui/qr-code-modal'
import { apiClient, Machine } from '@/lib/api'
import {
  Plus,
  Search,
  Cog,
  QrCode,
  Building2,
  Calendar,
  Wrench,
  CheckCircle,
  AlertTriangle,
  Edit,
  Trash2,
  Eye,
  Database,
  UserPlus,
  ArrowRight,
  Users,
  X,
  ClipboardList,
  MoreVertical
} from 'lucide-react'

interface MachinePool {
  id: number
  manufacturer: string
  model: string
  type: string
  specifications: any
  created_at: string
}

interface CompanyMachine {
  id: number
  poolMachine: MachinePool
  name: string
  serial_number: string
  status: 'active' | 'maintenance' | 'inactive'
  year?: number
  company_id: number
  assigned_operators: {
    id: number
    name: string
    email: string
    role: string
    shift?: 'morning' | 'afternoon' | 'night'
    is_primary?: boolean
  }[]
  created_at: string
}

export default function MachinesPage() {
  const [machinePool, setMachinePool] = useState<MachinePool[]>([])
  const [companyMachines, setCompanyMachines] = useState<CompanyMachine[]>([])
  const [operators, setOperators] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [modelSearchTerm, setModelSearchTerm] = useState('')
  const [activeTab, setActiveTab] = useState('company-machines')
  const [isAddMachineDialogOpen, setIsAddMachineDialogOpen] = useState(false)
  const [isAssignOperatorDialogOpen, setIsAssignOperatorDialogOpen] = useState(false)
  const [selectedMachine, setSelectedMachine] = useState<CompanyMachine | null>(null)
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('list')
  const [isControlListDialogOpen, setIsControlListDialogOpen] = useState(false)
  const [isQRCodeModalOpen, setIsQRCodeModalOpen] = useState(false)
  const [qrMachine, setQrMachine] = useState<CompanyMachine | null>(null)
  const [userRole, setUserRole] = useState<string>('operator')
  const [isMachineDetailDialogOpen, setIsMachineDetailDialogOpen] = useState(false)
  const [detailMachine, setDetailMachine] = useState<CompanyMachine | null>(null)
  const [machineControlLists, setMachineControlLists] = useState<any[]>([])
  const [machineFormData, setMachineFormData] = useState({
    manufacturer: '',
    model: '',
    type: '',
    name: '',
    serial_number: '',
    year: '',
    specifications: {}
  })

  useEffect(() => {
    // Load user role from localStorage
    if (typeof window !== 'undefined') {
      const userData = localStorage.getItem('user')
      if (userData) {
        const parsedUser = JSON.parse(userData)
        const role = parsedUser.roles?.[0]?.name || 'operator'
        setUserRole(role)
      }
    }

    const fetchData = async () => {
      try {
        // Fetch machines from API
        const machinesResponse = await apiClient.getMachines()
        const machinesData = machinesResponse.data || machinesResponse

        // Convert API response to CompanyMachine format
        const formattedMachines: CompanyMachine[] = Array.isArray(machinesData)
          ? machinesData.map((machine: any) => ({
              id: machine.id,
              poolMachine: {
                id: machine.id,
                manufacturer: machine.manufacturer || 'N/A',
                model: machine.model || machine.name,
                type: machine.machine_type || 'Genel',
                specifications: machine.specifications || {},
                created_at: machine.created_at
              },
              name: machine.name || machine.machine_code,
              serial_number: machine.serial_number || machine.machine_code || 'N/A',
              status: machine.status,
              year: machine.installation_date ? new Date(machine.installation_date).getFullYear() : undefined,
              company_id: machine.company_id,
              assigned_operators: [],
              created_at: machine.created_at
            }))
          : []

        setCompanyMachines(formattedMachines)

        // Fetch operators for assignment
        try {
          const usersResponse = await apiClient.getUsers()
          const usersData = usersResponse.data?.users || usersResponse.data || usersResponse
          const operatorsData = Array.isArray(usersData)
            ? usersData.filter((user: any) => user.role === 'operator')
            : []
          setOperators(operatorsData)
        } catch (err) {
          console.error('Failed to fetch operators:', err)
          setOperators([])
        }

      } catch (error) {
        console.error('Data fetch error:', error)
        setCompanyMachines([])
        setOperators([])
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  const filteredCompanyMachines = companyMachines.filter(machine =>
    machine.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    machine.serial_number.toLowerCase().includes(searchTerm.toLowerCase()) ||
    machine.poolMachine.manufacturer.toLowerCase().includes(searchTerm.toLowerCase()) ||
    machine.poolMachine.model.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const filteredMachinePool = machinePool.filter(machine =>
    machine.manufacturer.toLowerCase().includes(modelSearchTerm.toLowerCase()) ||
    machine.model.toLowerCase().includes(modelSearchTerm.toLowerCase()) ||
    machine.type.toLowerCase().includes(modelSearchTerm.toLowerCase())
  )

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'active':
        return { label: 'Aktif', className: 'bg-green-100 text-green-800', icon: CheckCircle }
      case 'maintenance':
        return { label: 'Bakımda', className: 'bg-yellow-100 text-yellow-800', icon: Wrench }
      case 'inactive':
        return { label: 'Pasif', className: 'bg-red-100 text-red-800', icon: AlertTriangle }
      default:
        return { label: status, className: 'bg-gray-100 text-gray-800', icon: AlertTriangle }
    }
  }

  const handleCreateControlList = (machine: CompanyMachine) => {
    setSelectedMachine(machine)
    setIsControlListDialogOpen(true)
    console.log('Kontrol listesi oluşturma:', machine)
  }

  const handleViewMachineDetails = async (machine: CompanyMachine) => {
    setDetailMachine(machine)
    setIsMachineDetailDialogOpen(true)

    // Fetch control lists for this machine
    try {
      const response = await apiClient.getControlLists({ machine_id: machine.id })
      const listsData = Array.isArray(response)
        ? response
        : Array.isArray(response.data)
          ? response.data
          : []
      setMachineControlLists(listsData)
    } catch (error) {
      console.error('Kontrol listeleri yüklenirken hata:', error)
      setMachineControlLists([])
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
            <h1 className="text-2xl font-bold text-gray-900">
              {userRole === 'operator' ? 'Atanan Makineler' : 'Makine Yönetimi'}
            </h1>
            <p className="text-gray-600">
              {userRole === 'operator'
                ? 'Size atanan makineleri görebilirsiniz'
                : 'Endüstriyel makineleri görüntüleyin ve yönetin'}
            </p>
          </div>
          {userRole !== 'operator' && (
            <Dialog>
              <DialogTrigger asChild>
                <Button className="flex items-center gap-2">
                  <Plus className="h-4 w-4" />
                  Makine Ekle/Ara
                </Button>
              </DialogTrigger>
              <AddMachineDialog
                machinePool={machinePool}
                companyMachines={companyMachines}
                setCompanyMachines={setCompanyMachines}
                setMachinePool={setMachinePool}
              />
            </Dialog>
          )}
        </div>

        {/* Statistics - Hidden for operators */}
        {userRole !== 'operator' && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center space-x-2">
                  <Database className="h-8 w-8 text-purple-600" />
                  <div>
                    <p className="text-2xl font-bold">{machinePool.length}</p>
                    <p className="text-sm text-gray-600">Makine Havuzu</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center space-x-2">
                  <Cog className="h-8 w-8 text-blue-600" />
                  <div>
                    <p className="text-2xl font-bold">{companyMachines.length}</p>
                    <p className="text-sm text-gray-600">Şirket Makineleri</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center space-x-2">
                  <CheckCircle className="h-8 w-8 text-green-600" />
                  <div>
                    <p className="text-2xl font-bold">{companyMachines.filter(m => m.status === 'active').length}</p>
                    <p className="text-sm text-gray-600">Aktif Makine</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center space-x-2">
                  <Users className="h-8 w-8 text-orange-600" />
                  <div>
                    <p className="text-2xl font-bold">{companyMachines.filter(m => m.assigned_operators.length > 0).length}</p>
                    <p className="text-sm text-gray-600">Operatör Atanmış</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Operator View - Card Grid Only */}
        {userRole === 'operator' ? (
          <div className="space-y-6">
            {/* Search for Operators */}
            <Card>
              <CardContent className="pt-6">
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                  <Input
                    placeholder="Makine adı, seri no, model ile ara..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </CardContent>
            </Card>

            {/* Machines Grid for Operators */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredCompanyMachines.length > 0 ? (
                filteredCompanyMachines.map((machine) => {
                  const statusBadge = getStatusBadge(machine.status)
                  const StatusIcon = statusBadge.icon
                  return (
                    <Card key={machine.id} className="hover:shadow-lg transition-shadow">
                      <CardHeader>
                        <div className="flex justify-between items-start">
                          <div>
                            <CardTitle>{machine.name}</CardTitle>
                            <CardDescription>SN: {machine.serial_number}</CardDescription>
                          </div>
                          <Badge className={statusBadge.className}>
                            <StatusIcon className="h-3 w-3 mr-1" />
                            {statusBadge.label}
                          </Badge>
                        </div>
                      </CardHeader>
                      <CardContent>
                        <div className="space-y-2 text-sm">
                          <div className="flex items-center gap-2">
                            <Building2 className="h-4 w-4 text-gray-500" />
                            <span>{machine.poolMachine.manufacturer}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <Cog className="h-4 w-4 text-gray-500" />
                            <span>{machine.poolMachine.model}</span>
                          </div>
                        </div>
                        <div className="flex gap-2 mt-4">
                          <Button
                            size="sm"
                            variant="outline"
                            title="Detaylar"
                            onClick={() => handleViewMachineDetails(machine)}
                          >
                            <Eye className="h-4 w-4 mr-1" />
                            Detaylar
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            title="QR Kodu Göster"
                            onClick={() => {
                              setQrMachine(machine)
                              setIsQRCodeModalOpen(true)
                            }}
                          >
                            <QrCode className="h-4 w-4 mr-1" />
                            QR
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            className="bg-purple-50 hover:bg-purple-100 text-purple-700 border-purple-200"
                            onClick={() => handleCreateControlList(machine)}
                            title="Kontrol Listesi"
                          >
                            <ClipboardList className="h-4 w-4 mr-1" />
                            Kontrol
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  )
                })
              ) : (
                <div className="col-span-full text-center py-12">
                  <Cog className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">Makine bulunamadı</h3>
                  <p className="text-gray-600">Size henüz makine atanmamış veya arama kriterlerinize uygun makine yok.</p>
                </div>
              )}
            </div>
          </div>
        ) : (
          /* Admin/Manager View - Tabs and Table */
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="company-machines" className="flex items-center gap-2">
                <Cog className="h-4 w-4" />
                Şirket Makineleri
              </TabsTrigger>
              <TabsTrigger value="machine-pool" className="flex items-center gap-2">
                <Database className="h-4 w-4" />
                Makine Havuzu
              </TabsTrigger>
            </TabsList>

            <TabsContent value="company-machines" className="space-y-6">
              {/* Search for Company Machines */}
              <Card>
                <CardContent className="pt-6">
                  <div className="flex gap-4">
                    <div className="flex-1 relative">
                      <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                      <Input
                        placeholder="Makine adı, seri no, model ile ara..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="pl-10"
                      />
                    </div>
                    <Dialog>
                      <DialogTrigger asChild>
                        <Button className="flex items-center gap-2">
                          <Plus className="h-4 w-4" />
                          Makine Ekle/Ara
                        </Button>
                      </DialogTrigger>
                      <AddMachineDialog
                        machinePool={machinePool}
                        companyMachines={companyMachines}
                        setCompanyMachines={setCompanyMachines}
                        setMachinePool={setMachinePool}
                      />
                    </Dialog>
                  </div>
                </CardContent>
              </Card>

              {/* Company Machines List */}
              <Card>
                <CardContent className="p-0">
                  {filteredCompanyMachines.length > 0 ? (
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Makine</TableHead>
                          <TableHead>Model</TableHead>
                          <TableHead>Durum</TableHead>
                          <TableHead>Operatörler</TableHead>
                          <TableHead>Yıl</TableHead>
                          <TableHead className="text-right">İşlemler</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {filteredCompanyMachines.map((machine) => {
                          const statusBadge = getStatusBadge(machine.status)
                          const StatusIcon = statusBadge.icon
                          return (
                            <TableRow key={machine.id} className="hover:bg-gray-50">
                              <TableCell>
                                <div>
                                  <div className="font-medium">{machine.name}</div>
                                  <div className="text-sm text-gray-500 font-mono">{machine.serial_number}</div>
                                </div>
                              </TableCell>
                              <TableCell>
                                <div>
                                  <div className="font-medium">{machine.poolMachine.manufacturer} {machine.poolMachine.model}</div>
                                  <div className="text-sm text-gray-500">{machine.poolMachine.type}</div>
                                </div>
                              </TableCell>
                              <TableCell>
                                <Badge className={statusBadge.className}>
                                  <StatusIcon className="h-3 w-3 mr-1" />
                                  {statusBadge.label}
                                </Badge>
                              </TableCell>
                              <TableCell>
                                {machine.assigned_operators.length > 0 ? (
                                  <div className="space-y-1">
                                    <div className="flex items-center text-sm font-medium text-green-600">
                                      <Users className="h-4 w-4 mr-1" />
                                      {machine.assigned_operators.length} Operatör
                                    </div>
                                    <div className="text-xs text-gray-600">
                                      {machine.assigned_operators.slice(0, 2).map((op) => (
                                        <div key={op.id} className="flex items-center gap-1">
                                          {op.is_primary && <span className="w-1.5 h-1.5 bg-blue-500 rounded-full"></span>}
                                          <span>{op.name}</span>
                                          {op.shift && (
                                            <span className="text-xs bg-gray-100 px-1 rounded">
                                              {op.shift === 'morning' ? 'S' : op.shift === 'afternoon' ? 'Ö' : 'G'}
                                            </span>
                                          )}
                                        </div>
                                      ))}
                                      {machine.assigned_operators.length > 2 && (
                                        <div className="text-xs text-gray-400">+{machine.assigned_operators.length - 2} diğer</div>
                                      )}
                                    </div>
                                  </div>
                                ) : (
                                  <div className="flex items-center text-sm text-red-600">
                                    <Users className="h-4 w-4 mr-1" />
                                    <span className="text-xs">Atanmamış</span>
                                  </div>
                                )}
                              </TableCell>
                              <TableCell>
                                {machine.year || '-'}
                              </TableCell>
                              <TableCell className="text-right">
                                <div className="flex items-center justify-end gap-2">
                                  <Button
                                    variant="outline"
                                    size="sm"
                                    onClick={() => {
                                      setSelectedMachine(machine)
                                      setIsAssignOperatorDialogOpen(true)
                                    }}
                                    title="Operatör Yönetimi"
                                  >
                                    <UserPlus className="h-4 w-4" />
                                  </Button>
                                  <Button
                                    variant="outline"
                                    size="sm"
                                    className="bg-purple-50 hover:bg-purple-100 text-purple-700 border-purple-200"
                                    onClick={() => handleCreateControlList(machine)}
                                    title="Kontrol Listesi Oluştur"
                                  >
                                    <ClipboardList className="h-4 w-4" />
                                  </Button>
                                  <Button
                                    variant="outline"
                                    size="sm"
                                    title="Detaylar"
                                    onClick={() => handleViewMachineDetails(machine)}
                                  >
                                    <Eye className="h-4 w-4" />
                                  </Button>
                                  <Button
                                    variant="outline"
                                    size="sm"
                                    title="QR Kod"
                                    onClick={() => {
                                      setQrMachine(machine)
                                      setIsQRCodeModalOpen(true)
                                    }}
                                  >
                                    <QrCode className="h-4 w-4" />
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
                      <Cog className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                      <h3 className="text-lg font-medium text-gray-900 mb-2">Makine bulunamadı</h3>
                      <p className="text-gray-600 mb-4">Şirketinize henüz makine eklenmemiş.</p>
                      <Dialog>
                        <DialogTrigger asChild>
                          <Button>
                            <Plus className="h-4 w-4 mr-2" />
                            İlk Makineyi Ekle
                          </Button>
                        </DialogTrigger>
                        <AddMachineDialog
                          machinePool={machinePool}
                          companyMachines={companyMachines}
                          setCompanyMachines={setCompanyMachines}
                          setMachinePool={setMachinePool}
                        />
                      </Dialog>
                  </div>
                )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="machine-pool" className="space-y-6">
              {/* Search for Machine Pool */}
              <Card>
                <CardContent className="pt-6">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                    <Input
                      placeholder="Marka, model, tip ile ara..."
                      value={modelSearchTerm}
                      onChange={(e) => setModelSearchTerm(e.target.value)}
                      className="pl-10"
                    />
                  </div>
                </CardContent>
              </Card>

              {/* Machine Pool Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredMachinePool.length > 0 ? (
                  filteredMachinePool.map((machine) => (
                    <Card key={machine.id} className="hover:shadow-lg transition-shadow">
                      <CardHeader>
                        <div className="flex items-center justify-between">
                          <CardTitle className="text-lg">{machine.manufacturer}</CardTitle>
                          <Badge variant="secondary" className="bg-purple-100 text-purple-800">
                            <Database className="h-3 w-3 mr-1" />
                            Havuz
                          </Badge>
                        </div>
                        <CardDescription>
                          <span className="font-semibold">{machine.model}</span>
                        </CardDescription>
                      </CardHeader>
                      <CardContent>
                        <div className="space-y-3">
                          <div className="flex items-center text-sm text-gray-600">
                            <Cog className="h-4 w-4 mr-2" />
                            {machine.type}
                          </div>
                          <div className="flex items-center text-sm text-gray-600">
                            <Calendar className="h-4 w-4 mr-2" />
                            Havuza eklendi: {new Date(machine.created_at).toLocaleDateString('tr-TR')}
                          </div>
                          {machine.specifications && Object.keys(machine.specifications).length > 0 && (
                            <div className="text-sm text-gray-600">
                              <p className="font-medium mb-1">Özellikler:</p>
                              {Object.entries(machine.specifications).map(([key, value]) => (
                                <p key={key} className="text-xs">• {key}: {value}</p>
                              ))}
                            </div>
                          )}
                        </div>

                        <div className="flex items-center gap-2 mt-4 pt-4 border-t">
                          <Button
                            className="flex-1 bg-blue-600 hover:bg-blue-700"
                            onClick={() => handleAssignToCompany(machine, companyMachines, setCompanyMachines)}
                          >
                            <ArrowRight className="h-4 w-4 mr-1" />
                            Şirketime Ekle
                          </Button>
                          <Button variant="outline" size="sm">
                            <Eye className="h-4 w-4" />
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))
                ) : (
                  <div className="col-span-full text-center py-12">
                    <Database className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <h3 className="text-lg font-medium text-gray-900 mb-2">Makine bulunamadı</h3>
                    <p className="text-gray-600 mb-4">Arama kriterlerinize uygun makine bulunamadı.</p>
                  </div>
                )}
              </div>
            </TabsContent>
          </Tabs>
        )}

        {/* Assign Operator Dialog */}
        <Dialog open={isAssignOperatorDialogOpen} onOpenChange={setIsAssignOperatorDialogOpen}>
          <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Operatör Yönetimi</DialogTitle>
              <DialogDescription>
                {selectedMachine?.name} makinesindeki operatörleri yönetin
              </DialogDescription>
            </DialogHeader>
            <OperatorManagementContent
              selectedMachine={selectedMachine}
              operators={operators}
              companyMachines={companyMachines}
              setCompanyMachines={setCompanyMachines}
              setIsAssignOperatorDialogOpen={setIsAssignOperatorDialogOpen}
            />
          </DialogContent>
        </Dialog>

        {/* Control List Creation Dialog */}
        <Dialog open={isControlListDialogOpen} onOpenChange={setIsControlListDialogOpen}>
          <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Kontrol Listesi Oluştur</DialogTitle>
              <DialogDescription>
                {selectedMachine?.name} makinesi için kontrol listesi oluşturun
              </DialogDescription>
            </DialogHeader>
            <ControlListCreationContent
              selectedMachine={selectedMachine}
              setIsControlListDialogOpen={setIsControlListDialogOpen}
            />
          </DialogContent>
        </Dialog>

        {/* Machine Detail Dialog */}
        <Dialog open={isMachineDetailDialogOpen} onOpenChange={setIsMachineDetailDialogOpen}>
          <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Makine Detayları - {detailMachine?.name}</DialogTitle>
              <DialogDescription>
                Makine bilgileri ve kontrol listesi durumları
              </DialogDescription>
            </DialogHeader>

            {detailMachine && (
              <div className="space-y-6">
                {/* Machine Info */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg">Makine Bilgileri</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm text-gray-600">Model</p>
                        <p className="font-medium">{detailMachine.poolMachine?.model || 'N/A'}</p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Seri No</p>
                        <p className="font-medium">{detailMachine.serial_number}</p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Üretici</p>
                        <p className="font-medium">{detailMachine.poolMachine?.manufacturer || 'N/A'}</p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Durum</p>
                        <Badge className={getStatusBadge(detailMachine.status).className}>
                          {getStatusBadge(detailMachine.status).label}
                        </Badge>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                {/* Control Lists */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg">Kontrol Listeleri</CardTitle>
                  </CardHeader>
                  <CardContent>
                    {machineControlLists.length === 0 ? (
                      <p className="text-gray-500 text-center py-4">Bu makine için kontrol listesi bulunmuyor</p>
                    ) : (
                      <div className="space-y-3">
                        {machineControlLists.map((list: any) => (
                          <div
                            key={list.id}
                            className="border rounded-lg p-4 hover:bg-gray-50 transition-colors"
                          >
                            <div className="flex items-start justify-between">
                              <div className="flex-1">
                                <h4 className="font-medium">{list.title}</h4>
                                {list.description && (
                                  <p className="text-sm text-gray-600 mt-1">{list.description}</p>
                                )}
                                <div className="flex gap-2 mt-2">
                                  <Badge
                                    className={
                                      list.status === 'approved'
                                        ? 'bg-green-100 text-green-800'
                                        : list.status === 'rejected'
                                        ? 'bg-red-100 text-red-800'
                                        : list.status === 'pending'
                                        ? 'bg-yellow-100 text-yellow-800'
                                        : 'bg-blue-100 text-blue-800'
                                    }
                                  >
                                    {list.status === 'approved'
                                      ? 'Onaylandı'
                                      : list.status === 'rejected'
                                      ? 'Reddedildi'
                                      : list.status === 'pending'
                                      ? 'Bekliyor'
                                      : 'Tamamlandı'}
                                  </Badge>
                                  <Badge variant="outline">
                                    {list.priority === 'high'
                                      ? 'Yüksek Öncelik'
                                      : list.priority === 'medium'
                                      ? 'Orta Öncelik'
                                      : 'Düşük Öncelik'}
                                  </Badge>
                                </div>
                              </div>
                              <div className="text-sm text-gray-500">
                                {new Date(list.created_at).toLocaleDateString('tr-TR')}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </CardContent>
                </Card>
              </div>
            )}

            <DialogFooter>
              <Button
                variant="outline"
                onClick={() => setIsMachineDetailDialogOpen(false)}
              >
                Kapat
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* QR Code Modal */}
        {qrMachine && (
          <QRCodeModal
            isOpen={isQRCodeModalOpen}
            onClose={() => setIsQRCodeModalOpen(false)}
            machine={qrMachine}
          />
        )}
      </div>
    </AdminLayout>
  )
}

// Helper functions
const handleAssignToCompany = (poolMachine: MachinePool, companyMachines: CompanyMachine[], setCompanyMachines: React.Dispatch<React.SetStateAction<CompanyMachine[]>>) => {
  // Havuzdan şirkete makine ekleme
  const newMachine: CompanyMachine = {
    id: Date.now(), // Geçici ID
    poolMachine: poolMachine,
    name: `${poolMachine.manufacturer.substring(0,3).toUpperCase()}-${String(companyMachines.length + 1).padStart(3, '0')}`,
    serial_number: `SN${Date.now().toString().slice(-8)}`,
    status: 'active',
    company_id: 1, // Current company
    assigned_operators: [],
    created_at: new Date().toISOString()
  }

  setCompanyMachines(prev => [...prev, newMachine])
  alert(`${poolMachine.manufacturer} ${poolMachine.model} makinesi şirketinize eklendi!`)
  console.log('Şirkete makine eklendi:', newMachine)
}

const handleAssignOperator = (machineId: number | undefined, operatorId: number, shift: 'morning' | 'afternoon' | 'night', isPrimary: boolean, companyMachines: CompanyMachine[], setCompanyMachines: React.Dispatch<React.SetStateAction<CompanyMachine[]>>, operators: any[]) => {
  if (!machineId) return

  const operator = operators.find(op => op.id === operatorId)
  if (!operator) return

  setCompanyMachines(prev => prev.map(machine => {
    if (machine.id === machineId) {
      // Eğer primary operator olarak atanıyorsa, diğer operatörlerin primary flagini kaldır
      let updatedOperators = machine.assigned_operators
      if (isPrimary) {
        updatedOperators = updatedOperators.map(op => ({ ...op, is_primary: false }))
      }

      // Operatörün zaten atanmış olup olmadığını kontrol et
      const existingOperatorIndex = updatedOperators.findIndex(op => op.id === operatorId)

      if (existingOperatorIndex !== -1) {
        // Mevcut operatörü güncelle
        updatedOperators[existingOperatorIndex] = {
          ...updatedOperators[existingOperatorIndex],
          shift,
          is_primary: isPrimary
        }
      } else {
        // Yeni operatör ekle
        updatedOperators.push({
          id: operator.id,
          name: operator.name,
          email: operator.email,
          role: operator.role,
          shift,
          is_primary: isPrimary
        })
      }

      return { ...machine, assigned_operators: updatedOperators }
    }
    return machine
  }))

  console.log('Operatör atandı/güncellendi:', { machineId, operatorId, shift, isPrimary })
}

const handleRemoveOperator = (machineId: number | undefined, operatorId: number, companyMachines: CompanyMachine[], setCompanyMachines: React.Dispatch<React.SetStateAction<CompanyMachine[]>>) => {
  if (!machineId) return

  setCompanyMachines(prev => prev.map(machine => {
    if (machine.id === machineId) {
      const updatedOperators = machine.assigned_operators.filter(op => op.id !== operatorId)
      return { ...machine, assigned_operators: updatedOperators }
    }
    return machine
  }))

  console.log('Operatör kaldırıldı:', { machineId, operatorId })
}

// Add Machine Dialog Component
function AddMachineDialog({
  machinePool,
  companyMachines,
  setCompanyMachines,
  setMachinePool
}: {
  machinePool: MachinePool[]
  companyMachines: CompanyMachine[]
  setCompanyMachines: React.Dispatch<React.SetStateAction<CompanyMachine[]>>
  setMachinePool: React.Dispatch<React.SetStateAction<MachinePool[]>>
}) {
  const [step, setStep] = useState<'search' | 'add'>('search')
  const [searchModel, setSearchModel] = useState('')
  const [foundMachines, setFoundMachines] = useState<MachinePool[]>([])
  const [isLoading, setIsLoading] = useState(false)

  const handleSearch = async () => {
    setIsLoading(true)
    // Simulate API search delay
    setTimeout(() => {
      // Search in actual machine pool
      const results = machinePool.filter(m =>
        m.manufacturer.toLowerCase().includes(searchModel.toLowerCase()) ||
        m.model.toLowerCase().includes(searchModel.toLowerCase()) ||
        m.type.toLowerCase().includes(searchModel.toLowerCase())
      )

      setFoundMachines(results)

      if (results.length === 0) {
        setStep('add')
      }
      setIsLoading(false)
    }, 500)
  }

  return (
    <DialogContent className="max-w-2xl">
      <DialogHeader>
        <DialogTitle>
          {step === 'search' ? 'Makine Ara' : 'Yeni Makine Ekle'}
        </DialogTitle>
        <DialogDescription>
          {step === 'search'
            ? 'Önce makine havuzunda bu model var mı kontrol edelim'
            : 'Bu model havuzda yok, yeni makine olarak ekleyelim'
          }
        </DialogDescription>
      </DialogHeader>

      {step === 'search' ? (
        <div className="space-y-4">
          <div className="space-y-2">
            <Label>Makine Modeli</Label>
            <div className="flex gap-2">
              <Input
                placeholder="Örn: Siemens SINUMERIK 840D"
                value={searchModel}
                onChange={(e) => setSearchModel(e.target.value)}
              />
              <Button onClick={handleSearch} disabled={!searchModel || isLoading}>
                {isLoading ? 'Arıyor...' : 'Ara'}
              </Button>
            </div>
          </div>

          {foundMachines.length > 0 && (
            <div className="space-y-3">
              <Label>Bulunan Makineler</Label>
              {foundMachines.map((machine) => (
                <div key={machine.id} className="p-4 border rounded-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className="font-medium">{machine.manufacturer} {machine.model}</h4>
                      <p className="text-sm text-gray-600">{machine.type}</p>
                    </div>
                    <Button onClick={() => {
                      handleAssignToCompany(machine, companyMachines, setCompanyMachines)
                      setStep('search')
                      setSearchModel('')
                      setFoundMachines([])
                    }}>
                      Şirketime Ekle
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      ) : (
        <NewMachineForm
          onSuccess={() => setStep('search')}
          machinePool={machinePool}
          setMachinePool={setMachinePool}
          companyMachines={companyMachines}
          setCompanyMachines={setCompanyMachines}
        />
      )}

      <DialogFooter>
        {step === 'add' && (
          <Button variant="outline" onClick={() => setStep('search')}>
            Geri Dön
          </Button>
        )}
      </DialogFooter>
    </DialogContent>
  )
}

// Control List Creation Content Component
function ControlListCreationContent({
  selectedMachine,
  setIsControlListDialogOpen
}: {
  selectedMachine: CompanyMachine | null
  setIsControlListDialogOpen: React.Dispatch<React.SetStateAction<boolean>>
}) {
  const [controlListTitle, setControlListTitle] = useState('')
  const [controlItems, setControlItems] = useState<{
    id: number
    title: string
    description: string
    priority: 'low' | 'medium' | 'high'
    category: string
  }[]>([])
  const [newItem, setNewItem] = useState({
    title: '',
    description: '',
    priority: 'medium' as 'low' | 'medium' | 'high',
    category: 'Güvenlik'
  })

  const categories = ['Güvenlik', 'Bakım', 'Performans', 'Kalite', 'Çevre']
  const priorities = [
    { value: 'low', label: 'Düşük', color: 'bg-gray-100 text-gray-800' },
    { value: 'medium', label: 'Orta', color: 'bg-yellow-100 text-yellow-800' },
    { value: 'high', label: 'Yüksek', color: 'bg-red-100 text-red-800' }
  ]

  // Örnek kontrol maddelerini otomatik ekle
  const addSampleItems = () => {
    const sampleItems = [
      {
        id: Date.now() + 1,
        title: 'Güvenlik donanımları kontrolü',
        description: 'Acil durdurma butonları, güvenlik bariyerleri ve uyarı işaretlerinin çalışır durumda olduğunu kontrol edin',
        priority: 'high' as const,
        category: 'Güvenlik'
      },
      {
        id: Date.now() + 2,
        title: 'Yağlama seviyesi kontrolü',
        description: 'Makine yağ seviyelerini kontrol edin ve gerekirse ilave yapın',
        priority: 'medium' as const,
        category: 'Bakım'
      },
      {
        id: Date.now() + 3,
        title: 'Titreşim ve ses kontrolü',
        description: 'Normalin dışında titreşim veya ses olup olmadığını kontrol edin',
        priority: 'medium' as const,
        category: 'Performans'
      },
      {
        id: Date.now() + 4,
        title: 'Üretilen parça kalite kontrolü',
        description: 'İlk üretilen parçaların tolerans değerlerini ölçün ve kaydedin',
        priority: 'high' as const,
        category: 'Kalite'
      }
    ]
    setControlItems(sampleItems)
  }

  const addControlItem = () => {
    if (!newItem.title.trim()) return

    const item = {
      id: Date.now(),
      ...newItem
    }
    setControlItems(prev => [...prev, item])
    setNewItem({
      title: '',
      description: '',
      priority: 'medium',
      category: 'Güvenlik'
    })
  }

  const removeControlItem = (id: number) => {
    setControlItems(prev => prev.filter(item => item.id !== id))
  }

  const handleCreateControlList = async () => {
    if (!controlListTitle.trim() || controlItems.length === 0) {
      alert('Lütfen kontrol listesi başlığı girin ve en az bir kontrol maddesi ekleyin.')
      return
    }

    try {
      const controlListData = {
        machine_id: selectedMachine?.id,
        title: controlListTitle,
        description: `${selectedMachine?.name} makinesi için kontrol listesi`,
        control_items: controlItems.map((item, index) => ({
          title: item.title,
          description: item.description,
          type: 'checkbox',
          required: item.priority === 'high',
          order: index + 1
        })),
        priority: controlItems.some(item => item.priority === 'high') ? 'high' : 'medium',
        scheduled_date: new Date().toISOString().split('T')[0],
        notes: `Kategoriler: ${[...new Set(controlItems.map(item => item.category))].join(', ')}`
      }

      console.log('Kontrol listesi gönderiliyor:', controlListData)
      const response = await apiClient.createControlList(controlListData)
      console.log('API yanıtı:', response)

      alert(`${selectedMachine?.name} makinesi için "${controlListTitle}" kontrol listesi başarıyla oluşturuldu!`)
      setIsControlListDialogOpen(false)

      // Reset form
      setControlListTitle('')
      setControlItems([])
    } catch (error: any) {
      console.error('Kontrol listesi oluşturma hatası:', error)
      alert(error.response?.data?.message || 'Kontrol listesi oluşturulurken bir hata oluştu')
    }
  }

  const getPriorityBadgeColor = (priority: string) => {
    return priorities.find(p => p.value === priority)?.color || 'bg-gray-100 text-gray-800'
  }

  const getPriorityLabel = (priority: string) => {
    return priorities.find(p => p.value === priority)?.label || priority
  }

  return (
    <div className="space-y-6">
      {/* Makine Bilgileri */}
      <div className="bg-blue-50 p-4 rounded-lg">
        <h3 className="font-semibold text-blue-900">Seçilen Makine</h3>
        <p className="text-blue-700">{selectedMachine?.name} - {selectedMachine?.poolMachine.manufacturer} {selectedMachine?.poolMachine.model}</p>
        <p className="text-sm text-blue-600">{selectedMachine?.poolMachine.type}</p>
      </div>

      {/* Kontrol Listesi Başlığı */}
      <div className="space-y-2">
        <Label className="text-base font-semibold">Kontrol Listesi Başlığı</Label>
        <Input
          placeholder="Örn: Günlük Operasyon Öncesi Kontrol Listesi"
          value={controlListTitle}
          onChange={(e) => setControlListTitle(e.target.value)}
        />
      </div>

      {/* Hızlı Başlangıç */}
      {controlItems.length === 0 && (
        <div className="border-2 border-dashed border-gray-200 rounded-lg p-6 text-center">
          <ClipboardList className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Kontrol Listesi Oluşturun</h3>
          <p className="text-gray-600 mb-4">Örnek kontrol maddeleri ile başlayabilir veya kendi maddelerinizi ekleyebilirsiniz.</p>
          <Button type="button" onClick={addSampleItems} variant="outline">
            Örnek Maddeler ile Başla
          </Button>
        </div>
      )}

      {/* Kontrol Maddeleri Listesi */}
      {controlItems.length > 0 && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <Label className="text-base font-semibold">Kontrol Maddeleri ({controlItems.length})</Label>
            <Button type="button" onClick={() => setControlItems([])} variant="outline" size="sm">
              Tümünü Temizle
            </Button>
          </div>

          <div className="space-y-3 max-h-60 overflow-y-auto">
            {controlItems.map((item, index) => (
              <div key={item.id} className="p-4 border rounded-lg bg-gray-50">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-sm font-medium text-gray-500">#{index + 1}</span>
                      <Badge className={getPriorityBadgeColor(item.priority)}>
                        {getPriorityLabel(item.priority)}
                      </Badge>
                      <Badge variant="outline">{item.category}</Badge>
                    </div>
                    <h4 className="font-medium text-gray-900 mb-1">{item.title}</h4>
                    <p className="text-sm text-gray-600">{item.description}</p>
                  </div>
                  <Button
                    type="button"
                    variant="destructive"
                    size="sm"
                    onClick={() => removeControlItem(item.id)}
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Yeni Kontrol Maddesi Ekleme */}
      <div className="space-y-4 border-t pt-4">
        <Label className="text-base font-semibold">Yeni Kontrol Maddesi Ekle</Label>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label>Kategori</Label>
            <select
              className="w-full p-2 border rounded-md"
              value={newItem.category}
              onChange={(e) => setNewItem(prev => ({ ...prev, category: e.target.value }))}
            >
              {categories.map(cat => (
                <option key={cat} value={cat}>{cat}</option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <Label>Öncelik</Label>
            <select
              className="w-full p-2 border rounded-md"
              value={newItem.priority}
              onChange={(e) => setNewItem(prev => ({ ...prev, priority: e.target.value as 'low' | 'medium' | 'high' }))}
            >
              {priorities.map(priority => (
                <option key={priority.value} value={priority.value}>{priority.label}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="space-y-2">
          <Label>Kontrol Başlığı</Label>
          <Input
            placeholder="Örn: Motor sıcaklığı kontrolü"
            value={newItem.title}
            onChange={(e) => setNewItem(prev => ({ ...prev, title: e.target.value }))}
          />
        </div>

        <div className="space-y-2">
          <Label>Açıklama</Label>
          <textarea
            className="w-full p-2 border rounded-md h-20 resize-none"
            placeholder="Detaylı açıklama..."
            value={newItem.description}
            onChange={(e) => setNewItem(prev => ({ ...prev, description: e.target.value }))}
          />
        </div>

        <Button type="button" onClick={addControlItem} className="w-full" disabled={!newItem.title.trim()}>
          <Plus className="h-4 w-4 mr-2" />
          Kontrol Maddesi Ekle
        </Button>
      </div>

      {/* Dialog Footer */}
      <div className="flex justify-end space-x-2 pt-4 border-t">
        <Button
          type="button"
          variant="outline"
          onClick={() => setIsControlListDialogOpen(false)}
        >
          İptal
        </Button>
        <Button
          type="button"
          onClick={handleCreateControlList}
          disabled={!controlListTitle.trim() || controlItems.length === 0}
          className="bg-purple-600 hover:bg-purple-700"
        >
          <ClipboardList className="h-4 w-4 mr-2" />
          Kontrol Listesi Oluştur
        </Button>
      </div>
    </div>
  )
}

// Operator Management Content Component
function OperatorManagementContent({
  selectedMachine,
  operators,
  companyMachines,
  setCompanyMachines,
  setIsAssignOperatorDialogOpen
}: {
  selectedMachine: CompanyMachine | null
  operators: any[]
  companyMachines: CompanyMachine[]
  setCompanyMachines: React.Dispatch<React.SetStateAction<CompanyMachine[]>>
  setIsAssignOperatorDialogOpen: React.Dispatch<React.SetStateAction<boolean>>
}) {
  const [selectedOperatorId, setSelectedOperatorId] = useState<number | null>(null)
  const [selectedShift, setSelectedShift] = useState<'morning' | 'afternoon' | 'night'>('morning')
  const [isPrimary, setIsPrimary] = useState(false)

  const handleAddOperator = () => {
    if (!selectedOperatorId || !selectedMachine) return

    handleAssignOperator(
      selectedMachine.id,
      selectedOperatorId,
      selectedShift,
      isPrimary,
      companyMachines,
      setCompanyMachines,
      operators
    )

    // Reset form
    setSelectedOperatorId(null)
    setSelectedShift('morning')
    setIsPrimary(false)
  }

  const getShiftBadgeColor = (shift: string) => {
    switch (shift) {
      case 'morning': return 'bg-yellow-100 text-yellow-800'
      case 'afternoon': return 'bg-orange-100 text-orange-800'
      case 'night': return 'bg-blue-100 text-blue-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getShiftLabel = (shift: string) => {
    switch (shift) {
      case 'morning': return 'Sabah'
      case 'afternoon': return 'Öğle'
      case 'night': return 'Gece'
      default: return shift
    }
  }

  const availableOperators = operators.filter(op =>
    op.role === 'operator' &&
    !selectedMachine?.assigned_operators.some(assignedOp => assignedOp.id === op.id)
  )

  return (
    <div className="space-y-6">
      {/* Mevcut Operatörler */}
      <div className="space-y-4">
        <Label className="text-base font-semibold">Atanmış Operatörler ({selectedMachine?.assigned_operators.length || 0})</Label>
        {selectedMachine?.assigned_operators && selectedMachine.assigned_operators.length > 0 ? (
          <div className="space-y-3">
            {selectedMachine.assigned_operators.map((operator) => (
              <div key={operator.id} className="p-4 border rounded-lg bg-green-50">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <div>
                      <div className="flex items-center gap-2">
                        <p className="font-medium text-green-800">{operator.name}</p>
                        {operator.is_primary && (
                          <Badge className="bg-blue-600 text-white text-xs">
                            Ana Operatör
                          </Badge>
                        )}
                      </div>
                      <p className="text-sm text-green-600">{operator.email}</p>
                    </div>
                    {operator.shift && (
                      <Badge className={getShiftBadgeColor(operator.shift)}>
                        {getShiftLabel(operator.shift)} Vardiyası
                      </Badge>
                    )}
                  </div>
                  <Button
                    type="button"
                    variant="destructive"
                    size="sm"
                    onClick={() => {
                      handleRemoveOperator(selectedMachine?.id, operator.id, companyMachines, setCompanyMachines)
                    }}
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="p-6 text-center border-2 border-dashed border-gray-200 rounded-lg">
            <Users className="h-8 w-8 text-gray-400 mx-auto mb-2" />
            <p className="text-gray-500">Henüz operatör atanmamış</p>
          </div>
        )}
      </div>

      {/* Yeni Operatör Ekleme Formu */}
      {availableOperators.length > 0 && (
        <div className="space-y-4 border-t pt-4">
          <Label className="text-base font-semibold">Yeni Operatör Ekle</Label>

          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Operatör Seç</Label>
              <div className="grid gap-2">
                {availableOperators.map((operator) => (
                  <div
                    key={operator.id}
                    className={`p-3 border rounded-lg cursor-pointer transition-colors ${
                      selectedOperatorId === operator.id
                        ? 'border-blue-500 bg-blue-50'
                        : 'border-gray-200 hover:bg-gray-50'
                    }`}
                    onClick={() => setSelectedOperatorId(operator.id)}
                  >
                    <p className="font-medium">{operator.name}</p>
                    <p className="text-sm text-gray-600">{operator.email}</p>
                  </div>
                ))}
              </div>
            </div>

            {selectedOperatorId && (
              <>
                <div className="space-y-2">
                  <Label>Vardiya</Label>
                  <div className="flex gap-2">
                    {(['morning', 'afternoon', 'night'] as const).map((shift) => (
                      <Button
                        key={shift}
                        type="button"
                        variant={selectedShift === shift ? 'default' : 'outline'}
                        size="sm"
                        onClick={() => setSelectedShift(shift)}
                        className={selectedShift === shift ? getShiftBadgeColor(shift) : ''}
                      >
                        {getShiftLabel(shift)}
                      </Button>
                    ))}
                  </div>
                </div>

                <div className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    id="isPrimary"
                    checked={isPrimary}
                    onChange={(e) => setIsPrimary(e.target.checked)}
                    className="rounded"
                  />
                  <Label htmlFor="isPrimary" className="text-sm">
                    Ana operatör olarak ata
                  </Label>
                </div>

                <Button type="button" onClick={handleAddOperator} className="w-full">
                  <UserPlus className="h-4 w-4 mr-2" />
                  Operatörü Ekle
                </Button>
              </>
            )}
          </div>
        </div>
      )}

      {/* Dialog Footer */}
      <div className="flex justify-end space-x-2 pt-4 border-t">
        <Button
          type="button"
          variant="outline"
          onClick={() => setIsAssignOperatorDialogOpen(false)}
        >
          Kapat
        </Button>
      </div>
    </div>
  )
}

// New Machine Form Component
function NewMachineForm({
  onSuccess,
  machinePool,
  setMachinePool,
  companyMachines,
  setCompanyMachines
}: {
  onSuccess: () => void
  machinePool: MachinePool[]
  setMachinePool: React.Dispatch<React.SetStateAction<MachinePool[]>>
  companyMachines: CompanyMachine[]
  setCompanyMachines: React.Dispatch<React.SetStateAction<CompanyMachine[]>>
}) {
  const [formData, setFormData] = useState({
    manufacturer: '',
    model: '',
    type: '',
    name: '',
    serial_number: '',
    year: '',
    specifications: {
      max_speed: '',
      power: '',
      dimensions: '',
      weight: ''
    }
  })

  const handleInputChange = (field: string, value: string) => {
    if (field.startsWith('specifications.')) {
      const specField = field.replace('specifications.', '')
      setFormData(prev => ({
        ...prev,
        specifications: {
          ...prev.specifications,
          [specField]: value
        }
      }))
    } else {
      setFormData(prev => ({ ...prev, [field]: value }))
    }
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()

    // Yeni makine havuza ekle
    const newPoolMachine: MachinePool = {
      id: Date.now(),
      manufacturer: formData.manufacturer,
      model: formData.model,
      type: formData.type,
      specifications: Object.fromEntries(
        Object.entries(formData.specifications).filter(([_, value]) => value.trim() !== '')
      ),
      created_at: new Date().toISOString()
    }

    setMachinePool(prev => [...prev, newPoolMachine])

    // Yeni makineyi şirkete de ekle
    const newCompanyMachine: CompanyMachine = {
      id: Date.now() + 1,
      poolMachine: newPoolMachine,
      name: formData.name,
      serial_number: formData.serial_number,
      status: 'active',
      year: formData.year ? parseInt(formData.year) : undefined,
      company_id: 1,
      assigned_operators: [],
      created_at: new Date().toISOString()
    }

    setCompanyMachines(prev => [...prev, newCompanyMachine])

    console.log('Yeni makine eklendi:', { newPoolMachine, newCompanyMachine })
    alert(`${formData.manufacturer} ${formData.model} makinesi hem havuza hem de şirketinize eklendi!`)
    onSuccess()
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Üretici *</Label>
          <Input
            placeholder="Örn: Siemens"
            value={formData.manufacturer}
            onChange={(e) => handleInputChange('manufacturer', e.target.value)}
            required
          />
        </div>
        <div className="space-y-2">
          <Label>Model *</Label>
          <Input
            placeholder="Örn: SINUMERIK 840D sl"
            value={formData.model}
            onChange={(e) => handleInputChange('model', e.target.value)}
            required
          />
        </div>
      </div>

      <div className="space-y-2">
        <Label>Tip *</Label>
        <Input
          placeholder="Örn: CNC Torna, CNC Freze"
          value={formData.type}
          onChange={(e) => handleInputChange('type', e.target.value)}
          required
        />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Makine Adı *</Label>
          <Input
            placeholder="Örn: CNC-003"
            value={formData.name}
            onChange={(e) => handleInputChange('name', e.target.value)}
            required
          />
        </div>
        <div className="space-y-2">
          <Label>Seri Numarası *</Label>
          <Input
            placeholder="Örn: SN123456789"
            value={formData.serial_number}
            onChange={(e) => handleInputChange('serial_number', e.target.value)}
            required
          />
        </div>
      </div>

      <div className="space-y-2">
        <Label>Üretim Yılı</Label>
        <Input
          type="number"
          placeholder="2024"
          value={formData.year}
          onChange={(e) => handleInputChange('year', e.target.value)}
        />
      </div>

      <div className="space-y-3">
        <Label>Teknik Özellikler</Label>
        <div className="grid grid-cols-2 gap-4">
          <Input
            placeholder="Maksimum Hız (rpm)"
            value={formData.specifications.max_speed}
            onChange={(e) => handleInputChange('specifications.max_speed', e.target.value)}
          />
          <Input
            placeholder="Güç (kW)"
            value={formData.specifications.power}
            onChange={(e) => handleInputChange('specifications.power', e.target.value)}
          />
          <Input
            placeholder="Boyutlar (mm)"
            value={formData.specifications.dimensions}
            onChange={(e) => handleInputChange('specifications.dimensions', e.target.value)}
          />
          <Input
            placeholder="Ağırlık (kg)"
            value={formData.specifications.weight}
            onChange={(e) => handleInputChange('specifications.weight', e.target.value)}
          />
        </div>
      </div>

      <DialogFooter>
        <Button type="submit" className="bg-blue-600 hover:bg-blue-700">
          Makineyi Ekle (Havuz + Şirket)
        </Button>
      </DialogFooter>
    </form>
  )
}