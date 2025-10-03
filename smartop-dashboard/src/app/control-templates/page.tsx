'use client'

import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { apiClient } from '@/lib/api'
import {
  Plus,
  Search,
  FileCheck,
  Edit,
  Trash2,
  Copy,
  Eye,
  CheckCircle,
  XCircle
} from 'lucide-react'

interface ControlTemplate {
  id: number
  name: string  // Backend uses 'name' not 'title'
  description?: string
  category: string
  machine_types?: string[]  // Optional, can be null
  items?: ControlTemplateItem[]  // Optional, can be null
  is_active: boolean
  created_at: string
  company?: {
    id: number
    name: string
  }
}

interface ControlTemplateItem {
  id: number
  title: string
  description?: string
  type: 'checkbox' | 'text' | 'number' | 'photo'
  required: boolean
  order: number
}

export default function ControlTemplatesPage() {
  const [templates, setTemplates] = useState<ControlTemplate[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [selectedTemplate, setSelectedTemplate] = useState<ControlTemplate | null>(null)

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: 'safety',
    machine_types: '',
    items: [] as Partial<ControlTemplateItem>[]
  })

  useEffect(() => {
    fetchTemplates()
  }, [])

  const fetchTemplates = async () => {
    setLoading(true)
    try {
      const response = await apiClient.getControlTemplates()
      setTemplates(response.data || [])
    } catch (error) {
      console.error('Templates fetch error:', error)
      setTemplates([])
    } finally {
      setLoading(false)
    }
  }

  const handleCreate = async () => {
    try {
      const data = {
        name: formData.title, // Backend expects 'name' not 'title'
        description: formData.description,
        category: formData.category,
        machine_types: formData.machine_types.split(',').map(t => t.trim()).filter(t => t),
        template_items: formData.items, // Backend expects 'template_items' not 'items'
        is_active: true
      }

      if (selectedTemplate) {
        // Update existing template
        await apiClient.updateControlTemplate(selectedTemplate.id.toString(), data)
      } else {
        // Create new template
        await apiClient.createControlTemplate(data)
      }

      setIsCreateDialogOpen(false)
      setSelectedTemplate(null)
      setFormData({
        title: '',
        description: '',
        category: 'safety',
        machine_types: '',
        items: []
      })
      fetchTemplates()
    } catch (error) {
      console.error('Create/Update error:', error)
    }
  }

  const handleDuplicate = async (id: number) => {
    try {
      await apiClient.duplicateControlTemplate(id.toString())
      fetchTemplates()
    } catch (error) {
      console.error('Duplicate error:', error)
    }
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Bu şablonu silmek istediğinizden emin misiniz?')) return
    try {
      await apiClient.deleteControlTemplate(id.toString())
      fetchTemplates()
    } catch (error) {
      console.error('Delete error:', error)
    }
  }

  const handleView = (template: ControlTemplate) => {
    setSelectedTemplate(template)
    setIsViewDialogOpen(true)
  }

  const handleEdit = (template: ControlTemplate) => {
    setSelectedTemplate(template)
    setFormData({
      title: template.name,
      description: template.description || '',
      category: template.category,
      machine_types: template.machine_types?.join(', ') || '',
      items: template.items || []
    })
    setIsCreateDialogOpen(true)
  }

  const addTemplateItem = () => {
    setFormData({
      ...formData,
      items: [
        ...formData.items,
        {
          title: '',
          description: '',
          type: 'checkbox',
          required: true,
          order: formData.items.length + 1
        }
      ]
    })
  }

  const filteredTemplates = templates.filter(template =>
    template.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    template.category?.toLowerCase().includes(searchTerm.toLowerCase())
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
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Kontrol Şablonları</h1>
            <p className="text-gray-600">Yeniden kullanılabilir kontrol listesi şablonları oluşturun</p>
          </div>
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button className="flex items-center gap-2">
                <Plus className="h-4 w-4" />
                Yeni Şablon
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle>{selectedTemplate ? 'Kontrol Şablonunu Düzenle' : 'Yeni Kontrol Şablonu'}</DialogTitle>
                <DialogDescription>
                  Makineler için yeniden kullanılabilir bir kontrol şablonu {selectedTemplate ? 'düzenleyin' : 'oluşturun'}
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div>
                  <Label>Şablon Adı</Label>
                  <Input
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    placeholder="Örn: Günlük Bakım Kontrol Listesi"
                  />
                </div>
                <div>
                  <Label>Açıklama</Label>
                  <Textarea
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    placeholder="Şablon hakkında kısa açıklama"
                    rows={3}
                  />
                </div>
                <div>
                  <Label>Kategori</Label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full border border-gray-300 rounded-md px-3 py-2"
                  >
                    <option value="safety">Güvenlik</option>
                    <option value="maintenance">Bakım</option>
                    <option value="quality">Kalite</option>
                    <option value="operational">Operasyonel</option>
                  </select>
                </div>
                <div>
                  <Label>Makine Tipleri (virgülle ayırın)</Label>
                  <Input
                    value={formData.machine_types}
                    onChange={(e) => setFormData({ ...formData, machine_types: e.target.value })}
                    placeholder="Örn: CNC Torna, Freze, Press"
                  />
                </div>
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <Label>Kontrol Maddeleri</Label>
                    <Button type="button" size="sm" onClick={addTemplateItem}>
                      <Plus className="h-4 w-4 mr-1" />
                      Madde Ekle
                    </Button>
                  </div>
                  <div className="space-y-2 max-h-60 overflow-y-auto">
                    {formData.items.map((item, index) => (
                      <div key={index} className="border rounded-lg p-3 space-y-2">
                        <Input
                          placeholder="Madde başlığı"
                          value={item.title || ''}
                          onChange={(e) => {
                            const newItems = [...formData.items]
                            newItems[index] = { ...item, title: e.target.value }
                            setFormData({ ...formData, items: newItems })
                          }}
                        />
                        <select
                          value={item.type || 'checkbox'}
                          onChange={(e) => {
                            const newItems = [...formData.items]
                            newItems[index] = { ...item, type: e.target.value as any }
                            setFormData({ ...formData, items: newItems })
                          }}
                          className="w-full border border-gray-300 rounded-md px-3 py-2"
                        >
                          <option value="checkbox">Onay Kutusu</option>
                          <option value="text">Metin</option>
                          <option value="number">Sayı</option>
                          <option value="photo">Fotoğraf</option>
                        </select>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => {
                  setIsCreateDialogOpen(false)
                  setSelectedTemplate(null)
                  setFormData({
                    title: '',
                    description: '',
                    category: 'safety',
                    machine_types: '',
                    items: []
                  })
                }}>
                  İptal
                </Button>
                <Button onClick={handleCreate}>
                  {selectedTemplate ? 'Güncelle' : 'Oluştur'}
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>

        {/* Search */}
        <Card>
          <CardContent className="pt-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Şablon adı veya kategori ile ara..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </CardContent>
        </Card>

        {/* Templates Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredTemplates.length > 0 ? (
            filteredTemplates.map((template) => (
              <Card key={template.id} className="hover:shadow-lg transition-shadow">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div className="flex items-center space-x-2">
                      <FileCheck className="h-5 w-5 text-blue-600" />
                      <CardTitle className="text-lg">{template.name}</CardTitle>
                    </div>
                    {template.is_active ? (
                      <CheckCircle className="h-5 w-5 text-green-600" />
                    ) : (
                      <XCircle className="h-5 w-5 text-red-600" />
                    )}
                  </div>
                  <CardDescription>
                    {template.description || 'Açıklama yok'}
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    <div>
                      <Badge className="mr-2">{template.category}</Badge>
                      {template.machine_types?.map((type, index) => (
                        <Badge key={index} variant="outline" className="mr-1">
                          {type}
                        </Badge>
                      ))}
                    </div>
                    <div className="text-sm text-gray-600">
                      <span className="font-semibold">{template.items?.length || 0}</span> kontrol maddesi
                    </div>
                    <div className="flex items-center gap-2 pt-3 border-t">
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        className="flex-1"
                        onClick={() => handleView(template)}
                      >
                        <Eye className="h-4 w-4 mr-1" />
                        Görüntüle
                      </Button>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => handleDuplicate(template.id)}
                      >
                        <Copy className="h-4 w-4" />
                      </Button>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => handleEdit(template)}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => handleDelete(template.id)}
                      >
                        <Trash2 className="h-4 w-4 text-red-600" />
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))
          ) : (
            <div className="col-span-full text-center py-12">
              <FileCheck className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Şablon bulunamadı</h3>
              <p className="text-gray-600 mb-4">Henüz hiç kontrol şablonu oluşturulmamış.</p>
              <Button onClick={() => setIsCreateDialogOpen(true)}>
                <Plus className="h-4 w-4 mr-2" />
                İlk Şablonu Oluştur
              </Button>
            </div>
          )}
        </div>

        {/* View Template Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Şablon Detayları</DialogTitle>
              <DialogDescription>
                Kontrol şablonu bilgileri ve maddeleri
              </DialogDescription>
            </DialogHeader>
            {selectedTemplate && (
              <div className="space-y-4">
                <div>
                  <Label className="text-gray-700 font-semibold">Şablon Adı</Label>
                  <p className="text-gray-900 mt-1">{selectedTemplate.name}</p>
                </div>
                <div>
                  <Label className="text-gray-700 font-semibold">Açıklama</Label>
                  <p className="text-gray-900 mt-1">{selectedTemplate.description || 'Açıklama yok'}</p>
                </div>
                <div>
                  <Label className="text-gray-700 font-semibold">Kategori</Label>
                  <div className="mt-1">
                    <Badge>{selectedTemplate.category}</Badge>
                  </div>
                </div>
                <div>
                  <Label className="text-gray-700 font-semibold">Makine Tipleri</Label>
                  <div className="mt-1 flex flex-wrap gap-1">
                    {selectedTemplate.machine_types?.length ? (
                      selectedTemplate.machine_types.map((type, index) => (
                        <Badge key={index} variant="outline">{type}</Badge>
                      ))
                    ) : (
                      <p className="text-gray-500 text-sm">Belirtilmemiş</p>
                    )}
                  </div>
                </div>
                <div>
                  <Label className="text-gray-700 font-semibold">Kontrol Maddeleri ({selectedTemplate.items?.length || 0})</Label>
                  <div className="mt-2 space-y-2">
                    {selectedTemplate.items?.length ? (
                      selectedTemplate.items.map((item, index) => (
                        <div key={index} className="border rounded-lg p-3 bg-gray-50">
                          <div className="flex items-center justify-between">
                            <span className="font-medium">{index + 1}. {item.title}</span>
                            <div className="flex items-center gap-2">
                              <Badge variant="outline" className="text-xs">
                                {item.type === 'checkbox' ? 'Onay Kutusu' :
                                 item.type === 'text' ? 'Metin' :
                                 item.type === 'number' ? 'Sayı' :
                                 item.type === 'photo' ? 'Fotoğraf' : item.type}
                              </Badge>
                              {item.required && (
                                <Badge variant="destructive" className="text-xs">Zorunlu</Badge>
                              )}
                            </div>
                          </div>
                          {item.description && (
                            <p className="text-sm text-gray-600 mt-1">{item.description}</p>
                          )}
                        </div>
                      ))
                    ) : (
                      <p className="text-gray-500 text-sm">Kontrol maddesi bulunmuyor</p>
                    )}
                  </div>
                </div>
                <div>
                  <Label className="text-gray-700 font-semibold">Durum</Label>
                  <div className="mt-1">
                    {selectedTemplate.is_active ? (
                      <Badge className="bg-green-500">Aktif</Badge>
                    ) : (
                      <Badge variant="destructive">Pasif</Badge>
                    )}
                  </div>
                </div>
              </div>
            )}
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => {
                setIsViewDialogOpen(false)
                setSelectedTemplate(null)
              }}>
                Kapat
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  )
}
