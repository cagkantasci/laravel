'use client'

import { useState, useEffect } from 'react'
import AuthWrapper from '@/components/auth/auth-wrapper'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { apiClient } from '@/lib/api'
import {
  Truck,
  Plus,
  Search,
  Filter,
  QrCode,
  Settings,
  AlertTriangle,
  CheckCircle,
  Clock,
  Wrench
} from 'lucide-react'

const statusLabels = {
  active: 'Aktif',
  inactive: 'Pasif',
  maintenance: 'Bakımda',
  broken: 'Arızalı'
}

const typeLabels = {
  ekskavatör: 'Ekskavatör',
  buldozer: 'Buldozer',
  kamyon: 'Kamyon',
  forklift: 'Forklift'
}

export default function MachinesPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState('all')
  const [selectedType, setSelectedType] = useState('all')
  const [machines, setMachines] = useState<any[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const fetchMachines = async () => {
      try {
        const response = await apiClient.getMachines()
        setMachines(response.data || response || [])
      } catch (error) {
        console.error('Machines fetch error:', error)
        setMachines([])
      } finally {
        setIsLoading(false)
      }
    }

    fetchMachines()
  }, [])

  const filteredMachines = machines.filter(machine => {
    const matchesSearch = machine.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         machine.serial_number.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = selectedStatus === 'all' || machine.status === selectedStatus
    const matchesType = selectedType === 'all' || machine.type === selectedType
    return matchesSearch && matchesStatus && matchesType
  })

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800'
      case 'inactive': return 'bg-gray-100 text-gray-800'
      case 'maintenance': return 'bg-yellow-100 text-yellow-800'
      case 'broken': return 'bg-red-100 text-red-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'active': return <CheckCircle className="h-4 w-4" />
      case 'maintenance': return <Wrench className="h-4 w-4" />
      case 'broken': return <AlertTriangle className="h-4 w-4" />
      case 'inactive': return <Clock className="h-4 w-4" />
      default: return <Clock className="h-4 w-4" />
    }
  }

  const statusCounts = {
    active: machines.filter(m => m.status === 'active').length,
    maintenance: machines.filter(m => m.status === 'maintenance').length,
    inactive: machines.filter(m => m.status === 'inactive').length,
    broken: machines.filter(m => m.status === 'broken').length
  }

  return (
    <AuthWrapper>
      <div className="space-y-6">
        {/* Page Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-slate-900 flex items-center">
              <Truck className="h-8 w-8 mr-3 text-blue-600" />
              Makine Yönetimi
            </h1>
            <p className="text-slate-600">İş makineleri ve ekipmanları yönetin</p>
          </div>
          <Button className="bg-blue-600 hover:bg-blue-700">
            <Plus className="h-4 w-4 mr-2" />
            Yeni Makine
          </Button>
        </div>

        {/* Statistics */}
        <div className="grid gap-6 md:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Aktif Makineler</CardTitle>
              <CheckCircle className="h-4 w-4 text-green-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{statusCounts.active}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Bakımda</CardTitle>
              <Wrench className="h-4 w-4 text-yellow-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{statusCounts.maintenance}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Pasif</CardTitle>
              <Clock className="h-4 w-4 text-gray-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{statusCounts.inactive}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Toplam</CardTitle>
              <Truck className="h-4 w-4 text-blue-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{machines.length}</div>
            </CardContent>
          </Card>
        </div>

        {/* Filters */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col lg:flex-row gap-4">
              <div className="flex-1">
                <Label htmlFor="search">Makine Ara</Label>
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <Input
                    id="search"
                    placeholder="Makine adı veya seri numarası..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>
              <div className="lg:w-48">
                <Label htmlFor="status">Durum</Label>
                <select
                  id="status"
                  value={selectedStatus}
                  onChange={(e) => setSelectedStatus(e.target.value)}
                  className="w-full h-10 px-3 py-2 text-sm border border-input bg-background rounded-md focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                >
                  <option value="all">Tüm Durumlar</option>
                  <option value="active">Aktif</option>
                  <option value="maintenance">Bakımda</option>
                  <option value="inactive">Pasif</option>
                  <option value="broken">Arızalı</option>
                </select>
              </div>
              <div className="lg:w-48">
                <Label htmlFor="type">Tip</Label>
                <select
                  id="type"
                  value={selectedType}
                  onChange={(e) => setSelectedType(e.target.value)}
                  className="w-full h-10 px-3 py-2 text-sm border border-input bg-background rounded-md focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                >
                  <option value="all">Tüm Tipler</option>
                  <option value="ekskavatör">Ekskavatör</option>
                  <option value="buldozer">Buldozer</option>
                  <option value="kamyon">Kamyon</option>
                  <option value="forklift">Forklift</option>
                </select>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Machines Grid */}
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {filteredMachines.map((machine) => (
            <Card key={machine.id} className="hover:shadow-lg transition-shadow">
              <CardHeader className="pb-3">
                <div className="flex justify-between items-start">
                  <div>
                    <CardTitle className="text-lg">{machine.name}</CardTitle>
                    <p className="text-sm text-slate-600">{machine.model} ({machine.year})</p>
                  </div>
                  <div className={`px-2 py-1 rounded-full text-xs font-medium flex items-center space-x-1 ${getStatusColor(machine.status)}`}>
                    {getStatusIcon(machine.status)}
                    <span>{statusLabels[machine.status]}</span>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-slate-600">Seri No:</span>
                    <span className="font-mono">{machine.serial_number}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-600">Tip:</span>
                    <span>{typeLabels[machine.type]}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-600">Lokasyon:</span>
                    <span>{machine.location}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-600">Son Kontrol:</span>
                    <span>{new Date(machine.last_control).toLocaleDateString('tr-TR')}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-600">Sonraki Bakım:</span>
                    <span>{new Date(machine.next_maintenance).toLocaleDateString('tr-TR')}</span>
                  </div>
                </div>

                <div className="flex space-x-2 pt-3 border-t">
                  <Button size="sm" variant="outline" className="flex-1">
                    <QrCode className="h-4 w-4 mr-1" />
                    QR Kod
                  </Button>
                  <Button size="sm" variant="outline" className="flex-1">
                    <Settings className="h-4 w-4 mr-1" />
                    Düzenle
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {filteredMachines.length === 0 && (
          <Card>
            <CardContent className="text-center py-8">
              <Truck className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Makine bulunamadı</h3>
              <p className="text-gray-600">Arama kriterlerinize uygun makine bulunmamaktadır.</p>
            </CardContent>
          </Card>
        )}
      </div>
    </AuthWrapper>
  )
}