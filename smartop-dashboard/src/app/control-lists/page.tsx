'use client'

import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { apiClient, ControlList } from '@/lib/api'
import {
  Plus,
  Search,
  ClipboardList,
  CheckCircle,
  Clock,
  XCircle,
  AlertTriangle,
  Users,
  Cog,
  Calendar,
  Eye,
  Edit,
  Check,
  X,
  Undo
} from 'lucide-react'

export default function ControlListsPage() {
  const [controlLists, setControlLists] = useState<ControlList[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [selectedControlList, setSelectedControlList] = useState<ControlList | null>(null)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [approvalNotes, setApprovalNotes] = useState('')
  const [editFormData, setEditFormData] = useState({
    title: '',
    description: '',
    priority: 'medium',
    notes: '',
    control_items: [] as any[]
  })
  const [isSaving, setIsSaving] = useState(false)

  useEffect(() => {
    const fetchControlLists = async () => {
      try {
        const response = await apiClient.getControlLists()
        console.log('Control lists API response:', response)

        // Handle different response formats
        let listsData = []
        if (Array.isArray(response)) {
          listsData = response
        } else if (Array.isArray(response.data)) {
          listsData = response.data
        } else if (response.data?.control_lists && Array.isArray(response.data.control_lists)) {
          listsData = response.data.control_lists
        }

        console.log('Parsed control lists:', listsData)
        setControlLists(listsData)
      } catch (error) {
        console.error('Control lists fetch error:', error)
        setControlLists([])
      } finally {
        setLoading(false)
      }
    }

    fetchControlLists()
  }, [])

  const filteredControlLists = controlLists.filter(list => {
    const matchesSearch = list.title.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || list.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const handleView = (controlList: ControlList) => {
    setSelectedControlList(controlList)
    setIsViewDialogOpen(true)
  }

  const handleEdit = (controlList: ControlList) => {
    setSelectedControlList(controlList)
    setEditFormData({
      title: controlList.title || '',
      description: controlList.description || '',
      priority: 'medium',
      notes: controlList.notes || '',
      control_items: (controlList as any).control_items || []
    })
    setIsEditDialogOpen(true)
  }

  const handleSaveEdit = async () => {
    if (!selectedControlList) return

    setIsSaving(true)
    try {
      await apiClient.updateControlList(selectedControlList.id.toString(), editFormData)
      alert('Kontrol listesi başarıyla güncellendi!')

      // Refresh list
      const response = await apiClient.getControlLists()
      let listsData = []
      if (Array.isArray(response)) {
        listsData = response
      } else if (Array.isArray(response.data)) {
        listsData = response.data
      } else if (response.data?.control_lists) {
        listsData = response.data.control_lists
      }
      setControlLists(listsData)
      setIsEditDialogOpen(false)
    } catch (error: any) {
      console.error('Güncelleme hatası:', error)
      alert(error.response?.data?.message || 'Güncelleme sırasında bir hata oluştu')
    } finally {
      setIsSaving(false)
    }
  }

  const handleApprove = async (controlList: ControlList) => {
    if (!confirm(`"${controlList.title}" kontrol listesini onaylamak istediğinizden emin misiniz?`)) {
      return
    }

    try {
      await apiClient.approveControlList(controlList.id.toString(), approvalNotes)
      alert('Kontrol listesi başarıyla onaylandı!')

      // Refresh list
      const response = await apiClient.getControlLists()
      let listsData = []
      if (Array.isArray(response)) {
        listsData = response
      } else if (Array.isArray(response.data)) {
        listsData = response.data
      } else if (response.data?.control_lists) {
        listsData = response.data.control_lists
      }
      setControlLists(listsData)
      setApprovalNotes('')
    } catch (error: any) {
      console.error('Onay hatası:', error)
      alert(error.response?.data?.message || 'Onaylama sırasında bir hata oluştu')
    }
  }

  const handleReject = async (controlList: ControlList) => {
    const reason = prompt(`"${controlList.title}" kontrol listesini reddetme nedeniniz:`)
    if (!reason) return

    try {
      await apiClient.rejectControlList(controlList.id.toString(), reason)
      alert('Kontrol listesi reddedildi!')

      // Refresh list
      const response = await apiClient.getControlLists()
      let listsData = []
      if (Array.isArray(response)) {
        listsData = response
      } else if (Array.isArray(response.data)) {
        listsData = response.data
      } else if (response.data?.control_lists) {
        listsData = response.data.control_lists
      }
      setControlLists(listsData)
    } catch (error: any) {
      console.error('Reddetme hatası:', error)
      alert(error.response?.data?.message || 'Reddetme sırasında bir hata oluştu')
    }
  }

  const handleRevert = async (controlList: ControlList) => {
    if (!confirm(`"${controlList.title}" kontrol listesinin ${controlList.status === 'approved' ? 'onay' : 'red'} işlemini geri almak istediğinizden emin misiniz?`)) {
      return
    }

    try {
      const response = await apiClient.revertControlList(controlList.id.toString())
      alert(response.message || 'İşlem başarıyla geri alındı')

      // Refresh list
      const listsResponse = await apiClient.getControlLists()
      let listsData = []
      if (Array.isArray(listsResponse)) {
        listsData = listsResponse
      } else if (Array.isArray(listsResponse.data)) {
        listsData = listsResponse.data
      } else if (listsResponse.data?.control_lists) {
        listsData = listsResponse.data.control_lists
      }
      setControlLists(listsData)
    } catch (error: any) {
      console.error('Geri alma hatası:', error)
      alert(error.response?.data?.message || 'Geri alma sırasında bir hata oluştu')
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return { label: 'Bekliyor', className: 'bg-yellow-100 text-yellow-800', icon: Clock }
      case 'approved':
        return { label: 'Onaylandı', className: 'bg-green-100 text-green-800', icon: CheckCircle }
      case 'rejected':
        return { label: 'Reddedildi', className: 'bg-red-100 text-red-800', icon: XCircle }
      case 'completed':
        return { label: 'Tamamlandı', className: 'bg-blue-100 text-blue-800', icon: CheckCircle }
      default:
        return { label: status, className: 'bg-gray-100 text-gray-800', icon: AlertTriangle }
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
            <h1 className="text-2xl font-bold text-gray-900">Kontrol Listesi Yönetimi</h1>
            <p className="text-gray-600">Makine kontrol listelerini görüntüleyin ve yönetin</p>
          </div>
          <Button
            type="button"
            className="flex items-center gap-2"
            onClick={() => {
              // Redirect to machines page to create control list
              window.location.href = '/machines'
            }}
          >
            <Plus className="h-4 w-4" />
            Yeni Kontrol Listesi
          </Button>
        </div>

        {/* Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <ClipboardList className="h-8 w-8 text-blue-600" />
                <div>
                  <p className="text-2xl font-bold">{controlLists.length}</p>
                  <p className="text-sm text-gray-600">Toplam Kontrol</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Clock className="h-8 w-8 text-yellow-600" />
                <div>
                  <p className="text-2xl font-bold">{controlLists.filter(c => c.status === 'pending').length}</p>
                  <p className="text-sm text-gray-600">Bekleyen Onay</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <CheckCircle className="h-8 w-8 text-green-600" />
                <div>
                  <p className="text-2xl font-bold">{controlLists.filter(c => c.status === 'approved').length}</p>
                  <p className="text-sm text-gray-600">Onaylandı</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <XCircle className="h-8 w-8 text-red-600" />
                <div>
                  <p className="text-2xl font-bold">{controlLists.filter(c => c.status === 'rejected').length}</p>
                  <p className="text-sm text-gray-600">Reddedildi</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Search and Filters */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                <Input
                  placeholder="Kontrol listesi başlığı ile ara..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="all">Tüm Durumlar</option>
                <option value="pending">Bekleyen</option>
                <option value="approved">Onaylandı</option>
                <option value="rejected">Reddedildi</option>
                <option value="completed">Tamamlandı</option>
              </select>
            </div>
          </CardContent>
        </Card>

        {/* Control Lists */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredControlLists.length > 0 ? (
            filteredControlLists.map((controlList) => {
              const statusBadge = getStatusBadge(controlList.status)
              const StatusIcon = statusBadge.icon
              return (
                <Card key={controlList.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-lg">{controlList.title}</CardTitle>
                      <Badge 
                        variant="secondary"
                        className={statusBadge.className}
                      >
                        <StatusIcon className="h-3 w-3 mr-1" />
                        {statusBadge.label}
                      </Badge>
                    </div>
                    {controlList.description && (
                      <CardDescription>
                        {controlList.description.length > 60 ? 
                          `${controlList.description.substring(0, 60)}...` : 
                          controlList.description}
                      </CardDescription>
                    )}
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {controlList.machine && (
                        <div className="flex items-center text-sm text-gray-600">
                          <Cog className="h-4 w-4 mr-2" />
                          {controlList.machine.name}
                        </div>
                      )}
                      {controlList.operator && (
                        <div className="flex items-center text-sm text-gray-600">
                          <Users className="h-4 w-4 mr-2" />
                          {controlList.operator.name}
                        </div>
                      )}
                      <div className="flex items-center text-sm text-gray-600">
                        <ClipboardList className="h-4 w-4 mr-2" />
                        {controlList.items?.length || 0} madde
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Calendar className="h-4 w-4 mr-2" />
                        {new Date(controlList.created_at).toLocaleDateString('tr-TR')}
                      </div>
                    </div>
                    
                    <div className="flex items-center gap-2 mt-4 pt-4 border-t">
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        className="flex-1"
                        onClick={() => handleView(controlList)}
                      >
                        <Eye className="h-4 w-4 mr-1" />
                        Görüntüle
                      </Button>
                      {controlList.status === 'pending' && (
                        <>
                          <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            className="text-green-600 hover:text-green-700"
                            onClick={() => handleApprove(controlList)}
                          >
                            <Check className="h-4 w-4" />
                          </Button>
                          <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            className="text-red-600 hover:text-red-700"
                            onClick={() => handleReject(controlList)}
                          >
                            <X className="h-4 w-4" />
                          </Button>
                        </>
                      )}
                      {(controlList.status === 'approved' || controlList.status === 'rejected') && (
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          className="text-orange-600 hover:text-orange-700"
                          onClick={() => handleRevert(controlList)}
                        >
                          <Undo className="h-4 w-4" />
                        </Button>
                      )}
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => handleEdit(controlList)}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              )
            })
          ) : (
            <div className="col-span-full text-center py-12">
              <ClipboardList className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Kontrol listesi bulunamadı</h3>
              <p className="text-gray-600 mb-4">Arama kriterlerinize uygun kontrol listesi bulunamadı.</p>
              <Button type="button">
                <Plus className="h-4 w-4 mr-2" />
                İlk Kontrol Listesini Oluştur
              </Button>
            </div>
          )}
        </div>

        {/* View Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle className="text-xl">Kontrol Listesi Detayları</DialogTitle>
              <DialogDescription>
                {selectedControlList?.title}
              </DialogDescription>
            </DialogHeader>
            {selectedControlList ? (
              <div className="space-y-6">
                {/* Genel Bilgiler */}
                <Card className="bg-gradient-to-br from-blue-50 to-indigo-50 border-blue-200">
                  <CardContent className="pt-6">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label className="text-sm font-medium text-gray-600 flex items-center gap-2">
                          <ClipboardList className="h-4 w-4" />
                          Durum
                        </Label>
                        <div className="mt-2">
                          <Badge className={getStatusBadge(selectedControlList.status).className}>
                            {getStatusBadge(selectedControlList.status).label}
                          </Badge>
                        </div>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-gray-600 flex items-center gap-2">
                          <Cog className="h-4 w-4" />
                          Makine
                        </Label>
                        <p className="mt-2 font-medium">{selectedControlList.machine?.name || '-'}</p>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-gray-600 flex items-center gap-2">
                          <Users className="h-4 w-4" />
                          Operatör
                        </Label>
                        <p className="mt-2 font-medium">{selectedControlList.operator?.name || '-'}</p>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-gray-600 flex items-center gap-2">
                          <Calendar className="h-4 w-4" />
                          Oluşturma Tarihi
                        </Label>
                        <p className="mt-2 font-medium">{new Date(selectedControlList.created_at).toLocaleDateString('tr-TR')}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                {/* Açıklama */}
                {selectedControlList.description && (
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-base">Açıklama</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <p className="text-gray-700">{selectedControlList.description}</p>
                    </CardContent>
                  </Card>
                )}

                {/* Kontrol Maddeleri */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-base">
                      Kontrol Maddeleri ({(selectedControlList as any).control_items?.length || 0})
                    </CardTitle>
                    <CardDescription>
                      Bu kontrol listesinde yer alan tüm maddeler
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {(selectedControlList as any).control_items && (selectedControlList as any).control_items.length > 0 ? (
                        (selectedControlList as any).control_items.map((item: any, index: number) => (
                          <div key={index} className="flex items-start gap-3 p-4 bg-gray-50 rounded-lg border border-gray-200 hover:bg-gray-100 transition-colors">
                            <div className="flex-shrink-0 w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center font-semibold">
                              {index + 1}
                            </div>
                            <div className="flex-1">
                              <h4 className="text-sm font-semibold text-gray-900">{item.title}</h4>
                              {item.description && (
                                <p className="text-xs text-gray-600 mt-1">{item.description}</p>
                              )}
                              {item.required && (
                                <div className="mt-2">
                                  <Badge variant="outline" className="text-xs bg-red-50 text-red-700 border-red-200">
                                    Zorunlu
                                  </Badge>
                                </div>
                              )}
                            </div>
                          </div>
                        ))
                      ) : (
                        <div className="text-center py-8 text-gray-500">
                          <ClipboardList className="h-12 w-12 mx-auto mb-2 text-gray-400" />
                          <p>Kontrol maddesi bulunamadı</p>
                        </div>
                      )}
                    </div>
                  </CardContent>
                </Card>

                {/* Notlar */}
                {selectedControlList.notes && (
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-base">Notlar</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <p className="text-gray-700 whitespace-pre-wrap">{selectedControlList.notes}</p>
                    </CardContent>
                  </Card>
                )}

                {/* Onay Bilgileri */}
                {(selectedControlList.status === 'approved' || selectedControlList.status === 'rejected') && (
                  <Card className={selectedControlList.status === 'approved' ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}>
                    <CardHeader>
                      <CardTitle className="text-base flex items-center gap-2">
                        {selectedControlList.status === 'approved' ? (
                          <>
                            <CheckCircle className="h-5 w-5 text-green-600" />
                            <span>Onay Bilgileri</span>
                          </>
                        ) : (
                          <>
                            <XCircle className="h-5 w-5 text-red-600" />
                            <span>Red Bilgileri</span>
                          </>
                        )}
                      </CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-2">
                        {selectedControlList.manager && (
                          <div>
                            <Label className="text-sm font-medium text-gray-600">Yetkili</Label>
                            <p className="mt-1 font-medium">{selectedControlList.manager.name}</p>
                          </div>
                        )}
                        {selectedControlList.approved_at && (
                          <div>
                            <Label className="text-sm font-medium text-gray-600">Tarih</Label>
                            <p className="mt-1">{new Date(selectedControlList.approved_at).toLocaleDateString('tr-TR', {
                              day: '2-digit',
                              month: 'long',
                              year: 'numeric',
                              hour: '2-digit',
                              minute: '2-digit'
                            })}</p>
                          </div>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                )}
              </div>
            ) : (
              <div className="text-center py-12">
                <p className="text-gray-500">Kontrol listesi bilgisi yüklenemedi</p>
              </div>
            )}
          </DialogContent>
        </Dialog>

        {/* Edit Dialog */}
        <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
          <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Kontrol Listesini Düzenle</DialogTitle>
              <DialogDescription>
                {selectedControlList?.title} - Kontrol listesi bilgilerini güncelleyin
              </DialogDescription>
            </DialogHeader>
            {selectedControlList && (
              <div className="space-y-6">
                {/* Makine ve Durum Bilgisi (Read-only) */}
                <Card className="bg-gray-50 border-gray-200">
                  <CardContent className="pt-6">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label className="text-sm font-medium text-gray-600">Makine</Label>
                        <p className="mt-1 font-medium">{selectedControlList.machine?.name || '-'}</p>
                      </div>
                      <div>
                        <Label className="text-sm font-medium text-gray-600">Durum</Label>
                        <div className="mt-1">
                          <Badge className={getStatusBadge(selectedControlList.status).className}>
                            {getStatusBadge(selectedControlList.status).label}
                          </Badge>
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                {/* Edit Form */}
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="edit-title">Başlık *</Label>
                    <Input
                      id="edit-title"
                      value={editFormData.title}
                      onChange={(e) => setEditFormData({ ...editFormData, title: e.target.value })}
                      placeholder="Kontrol listesi başlığı"
                    />
                  </div>

                  <div>
                    <Label htmlFor="edit-description">Açıklama</Label>
                    <Textarea
                      id="edit-description"
                      value={editFormData.description}
                      onChange={(e) => setEditFormData({ ...editFormData, description: e.target.value })}
                      placeholder="Kontrol listesi açıklaması"
                      rows={3}
                    />
                  </div>

                  <div>
                    <Label htmlFor="edit-priority">Öncelik</Label>
                    <select
                      id="edit-priority"
                      value={editFormData.priority}
                      onChange={(e) => setEditFormData({ ...editFormData, priority: e.target.value })}
                      className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                      <option value="low">Düşük</option>
                      <option value="medium">Orta</option>
                      <option value="high">Yüksek</option>
                      <option value="critical">Kritik</option>
                    </select>
                  </div>

                  <div>
                    <Label htmlFor="edit-notes">Notlar</Label>
                    <Textarea
                      id="edit-notes"
                      value={editFormData.notes}
                      onChange={(e) => setEditFormData({ ...editFormData, notes: e.target.value })}
                      placeholder="Ek notlar veya açıklamalar"
                      rows={4}
                    />
                  </div>
                </div>

                {/* Kontrol Maddeleri (Editable) */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-base">Kontrol Maddeleri</CardTitle>
                    <CardDescription>
                      Kontrol maddelerini düzenleyebilirsiniz
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3 max-h-96 overflow-y-auto">
                      {editFormData.control_items.map((item: any, index: number) => (
                        <div key={index} className="border rounded-lg p-3 bg-gray-50">
                          <div className="flex items-start gap-2 mb-2">
                            <span className="font-medium text-gray-600 mt-2">{index + 1}.</span>
                            <div className="flex-1 space-y-2">
                              <Input
                                placeholder="Madde başlığı"
                                value={item.title}
                                onChange={(e) => {
                                  const updatedItems = [...editFormData.control_items]
                                  updatedItems[index].title = e.target.value
                                  setEditFormData({ ...editFormData, control_items: updatedItems })
                                }}
                              />
                              <Textarea
                                placeholder="Açıklama (opsiyonel)"
                                value={item.description || ''}
                                rows={2}
                                onChange={(e) => {
                                  const updatedItems = [...editFormData.control_items]
                                  updatedItems[index].description = e.target.value
                                  setEditFormData({ ...editFormData, control_items: updatedItems })
                                }}
                              />
                              <div className="flex items-center gap-2">
                                <label className="flex items-center gap-2 text-sm">
                                  <input
                                    type="checkbox"
                                    checked={item.required || false}
                                    onChange={(e) => {
                                      const updatedItems = [...editFormData.control_items]
                                      updatedItems[index].required = e.target.checked
                                      setEditFormData({ ...editFormData, control_items: updatedItems })
                                    }}
                                  />
                                  Zorunlu
                                </label>
                              </div>
                            </div>
                            <Button
                              type="button"
                              variant="ghost"
                              size="sm"
                              className="text-red-600 hover:text-red-700 hover:bg-red-50"
                              onClick={() => {
                                const updatedItems = editFormData.control_items.filter((_, i) => i !== index)
                                setEditFormData({ ...editFormData, control_items: updatedItems })
                              }}
                            >
                              <X className="h-4 w-4" />
                            </Button>
                          </div>
                        </div>
                      ))}
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        className="w-full"
                        onClick={() => {
                          setEditFormData({
                            ...editFormData,
                            control_items: [
                              ...editFormData.control_items,
                              { title: '', description: '', type: 'checkbox', required: false, order: editFormData.control_items.length + 1 }
                            ]
                          })
                        }}
                      >
                        <Plus className="h-4 w-4 mr-2" />
                        Yeni Madde Ekle
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </div>
            )}
            <DialogFooter className="gap-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsEditDialogOpen(false)}
                disabled={isSaving}
              >
                İptal
              </Button>
              <Button
                type="button"
                onClick={handleSaveEdit}
                disabled={isSaving || !editFormData.title.trim()}
              >
                {isSaving ? 'Kaydediliyor...' : 'Kaydet'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  )
}