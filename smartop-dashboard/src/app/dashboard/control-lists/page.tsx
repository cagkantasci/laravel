'use client'

import { useState, useEffect } from 'react'
import AuthWrapper from '@/components/auth/auth-wrapper'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { apiClient } from '@/lib/api'
import {
  ClipboardList,
  Plus,
  Search,
  CheckCircle,
  Clock,
  XCircle,
  AlertTriangle,
  Eye,
  Edit,
  Truck
} from 'lucide-react'

const statusLabels = {
  'in_progress': 'Devam Ediyor',
  'pending': 'Onay Bekliyor',
  'approved': 'Onaylandı',
  'rejected': 'Reddedildi'
}

const priorityLabels = {
  'low': 'Düşük',
  'medium': 'Orta',
  'high': 'Yüksek'
}

export default function ControlListsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState('all')
  const [selectedPriority, setSelectedPriority] = useState('all')
  const [controlLists, setControlLists] = useState<any[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const fetchControlLists = async () => {
      try {
        const response = await apiClient.getControlLists()
        setControlLists(response.data || response || [])
      } catch (error) {
        console.error('Control lists fetch error:', error)
        setControlLists([])
      } finally {
        setIsLoading(false)
      }
    }

    fetchControlLists()
  }, [])

  const filteredLists = controlLists.filter(list => {
    const matchesSearch = list.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         list.machine_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         list.operator.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = selectedStatus === 'all' || list.status === selectedStatus
    const matchesPriority = selectedPriority === 'all' || list.priority === selectedPriority
    return matchesSearch && matchesStatus && matchesPriority
  })

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved': return 'bg-green-100 text-green-800'
      case 'rejected': return 'bg-red-100 text-red-800'
      case 'pending': return 'bg-yellow-100 text-yellow-800'
      case 'in_progress': return 'bg-blue-100 text-blue-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'bg-red-100 text-red-800'
      case 'medium': return 'bg-yellow-100 text-yellow-800'
      case 'low': return 'bg-green-100 text-green-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'approved': return <CheckCircle className="h-4 w-4" />
      case 'rejected': return <XCircle className="h-4 w-4" />
      case 'pending': return <Clock className="h-4 w-4" />
      case 'in_progress': return <AlertTriangle className="h-4 w-4" />
      default: return <Clock className="h-4 w-4" />
    }
  }

  const statusCounts = {
    total: controlLists.length,
    pending: controlLists.filter(l => l.status === 'pending').length,
    approved: controlLists.filter(l => l.status === 'approved').length,
    rejected: controlLists.filter(l => l.status === 'rejected').length,
    in_progress: controlLists.filter(l => l.status === 'in_progress').length
  }

  return (
    <AuthWrapper>
      <div className="space-y-6">
        {/* Page Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-slate-900 flex items-center">
              <ClipboardList className="h-8 w-8 mr-3 text-blue-600" />
              Kontrol Listeleri
            </h1>
            <p className="text-slate-600">Makine kontrol listelerini görüntüleyin ve yönetin</p>
          </div>
          <Button className="bg-blue-600 hover:bg-blue-700">
            <Plus className="h-4 w-4 mr-2" />
            Yeni Liste
          </Button>
        </div>

        {/* Statistics */}
        <div className="grid gap-6 md:grid-cols-5">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Toplam</CardTitle>
              <ClipboardList className="h-4 w-4 text-blue-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{statusCounts.total}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Devam Ediyor</CardTitle>
              <AlertTriangle className="h-4 w-4 text-blue-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{statusCounts.in_progress}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Onay Bekliyor</CardTitle>
              <Clock className="h-4 w-4 text-yellow-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{statusCounts.pending}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Onaylandı</CardTitle>
              <CheckCircle className="h-4 w-4 text-green-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{statusCounts.approved}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Reddedildi</CardTitle>
              <XCircle className="h-4 w-4 text-red-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{statusCounts.rejected}</div>
            </CardContent>
          </Card>
        </div>

        {/* Filters */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col lg:flex-row gap-4">
              <div className="flex-1">
                <Label htmlFor="search">Kontrol Listesi Ara</Label>
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <Input
                    id="search"
                    placeholder="Liste adı, makine veya operatör..."
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
                  <option value="in_progress">Devam Ediyor</option>
                  <option value="pending">Onay Bekliyor</option>
                  <option value="approved">Onaylandı</option>
                  <option value="rejected">Reddedildi</option>
                </select>
              </div>
              <div className="lg:w-48">
                <Label htmlFor="priority">Öncelik</Label>
                <select
                  id="priority"
                  value={selectedPriority}
                  onChange={(e) => setSelectedPriority(e.target.value)}
                  className="w-full h-10 px-3 py-2 text-sm border border-input bg-background rounded-md focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                >
                  <option value="all">Tüm Öncelikler</option>
                  <option value="high">Yüksek</option>
                  <option value="medium">Orta</option>
                  <option value="low">Düşük</option>
                </select>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Control Lists Table */}
        <Card>
          <CardHeader>
            <CardTitle>Kontrol Listeleri ({filteredLists.length})</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {filteredLists.map((list) => (
                <div key={list.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                  <div className="flex items-center space-x-4">
                    <div className="bg-blue-100 p-2 rounded-full">
                      <ClipboardList className="h-5 w-5 text-blue-600" />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <h3 className="font-medium text-slate-900">{list.title}</h3>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium flex items-center space-x-1 ${getStatusColor(list.status)}`}>
                          {getStatusIcon(list.status)}
                          <span>{statusLabels[list.status]}</span>
                        </span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getPriorityColor(list.priority)}`}>
                          {priorityLabels[list.priority]}
                        </span>
                      </div>

                      <div className="flex items-center space-x-4 text-sm text-slate-600">
                        <div className="flex items-center">
                          <Truck className="h-4 w-4 mr-1" />
                          {list.machine_name}
                        </div>
                        <div>
                          Operatör: {list.operator}
                        </div>
                        <div>
                          Oluşturulma: {new Date(list.created_at).toLocaleDateString('tr-TR')}
                        </div>
                        {list.completed_at && (
                          <div>
                            Tamamlanma: {new Date(list.completed_at).toLocaleDateString('tr-TR')}
                          </div>
                        )}
                      </div>

                      <div className="flex items-center space-x-4 mt-2 text-xs text-slate-500">
                        <div>Toplam: {list.items_total}</div>
                        <div>Tamamlanan: {list.items_completed}</div>
                        <div className="text-green-600">Başarılı: {list.items_passed}</div>
                        {list.items_failed > 0 && (
                          <div className="text-red-600">Başarısız: {list.items_failed}</div>
                        )}
                      </div>

                      {list.status === 'rejected' && list.rejection_reason && (
                        <div className="mt-2 text-sm text-red-600 bg-red-50 p-2 rounded">
                          <strong>Red Sebebi:</strong> {list.rejection_reason}
                        </div>
                      )}
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Button variant="ghost" size="sm">
                      <Eye className="h-4 w-4" />
                    </Button>
                    {list.status === 'pending' && (
                      <>
                        <Button size="sm" className="bg-green-600 hover:bg-green-700 text-white">
                          <CheckCircle className="h-4 w-4 mr-1" />
                          Onayla
                        </Button>
                        <Button size="sm" variant="outline" className="text-red-600 hover:text-red-700">
                          <XCircle className="h-4 w-4 mr-1" />
                          Reddet
                        </Button>
                      </>
                    )}
                    <Button variant="ghost" size="sm">
                      <Edit className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {filteredLists.length === 0 && (
          <Card>
            <CardContent className="text-center py-8">
              <ClipboardList className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Kontrol listesi bulunamadı</h3>
              <p className="text-gray-600">Arama kriterlerinize uygun kontrol listesi bulunmamaktadır.</p>
            </CardContent>
          </Card>
        )}
      </div>
    </AuthWrapper>
  )
}