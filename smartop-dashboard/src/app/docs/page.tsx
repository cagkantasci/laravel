'use client'

import { useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
  Search,
  BookOpen,
  FileText,
  Video,
  Download,
  ExternalLink,
  Play,
  Star,
  Clock,
  Users,
  Smartphone,
  Monitor,
  Settings,
  Shield,
  BarChart3,
  HelpCircle,
  MessageSquare,
  Phone
} from 'lucide-react'

interface DocCategory {
  id: string
  title: string
  description: string
  icon: any
  docs: DocItem[]
}

interface DocItem {
  id: string
  title: string
  description: string
  type: 'guide' | 'video' | 'api' | 'faq'
  duration?: string
  difficulty: 'beginner' | 'intermediate' | 'advanced'
  popular?: boolean
  url?: string
}

export default function DocsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedCategory, setSelectedCategory] = useState<string>('all')

  const categories: DocCategory[] = [
    {
      id: 'getting-started',
      title: 'Başlangıç',
      description: 'SmartOp ile ilk adımlarınızı atın',
      icon: Play,
      docs: [
        {
          id: 'quick-start',
          title: 'Hızlı Başlangıç Kılavuzu',
          description: 'SmartOp\'u 5 dakikada kurmaya başlayın',
          type: 'guide',
          difficulty: 'beginner',
          popular: true,
          duration: '5 dk'
        },
        {
          id: 'first-machine',
          title: 'İlk Makinenizi Ekleyin',
          description: 'Sisteme ilk makinenizi nasıl ekleyeceğinizi öğrenin',
          type: 'video',
          difficulty: 'beginner',
          duration: '3 dk'
        },
        {
          id: 'user-setup',
          title: 'Kullanıcı ve Roller',
          description: 'Ekip üyelerinizi sisteme davet edin ve roller atayın',
          type: 'guide',
          difficulty: 'beginner',
          duration: '8 dk'
        }
      ]
    },
    {
      id: 'mobile-app',
      title: 'Mobil Uygulama',
      description: 'Android ve iOS uygulamaları',
      icon: Smartphone,
      docs: [
        {
          id: 'mobile-install',
          title: 'Mobil Uygulama Kurulumu',
          description: 'Android ve iOS uygulamalarını indirin ve kurun',
          type: 'guide',
          difficulty: 'beginner',
          duration: '2 dk'
        },
        {
          id: 'qr-scanning',
          title: 'QR Kod Tarama',
          description: 'Makineleri QR kod ile nasıl tarayacağınızı öğrenin',
          type: 'video',
          difficulty: 'beginner',
          duration: '4 dk'
        },
        {
          id: 'offline-mode',
          title: 'Çevrimdışı Kullanım',
          description: 'İnternet bağlantısı olmadığında nasıl çalışır',
          type: 'guide',
          difficulty: 'intermediate',
          duration: '6 dk'
        }
      ]
    },
    {
      id: 'web-dashboard',
      title: 'Web Dashboard',
      description: 'Yönetim paneli kullanımı',
      icon: Monitor,
      docs: [
        {
          id: 'dashboard-overview',
          title: 'Dashboard Genel Bakış',
          description: 'Ana ekran ve istatistikleri anlayın',
          type: 'guide',
          difficulty: 'beginner',
          popular: true,
          duration: '7 dk'
        },
        {
          id: 'company-management',
          title: 'Şirket Yönetimi',
          description: 'Şirket bilgilerini nasıl düzenleyeceğinizi öğrenin',
          type: 'guide',
          difficulty: 'intermediate',
          duration: '10 dk'
        },
        {
          id: 'reports-analytics',
          title: 'Raporlar ve Analitik',
          description: 'Detaylı raporları nasıl oluşturacağınızı keşfedin',
          type: 'video',
          difficulty: 'intermediate',
          duration: '12 dk'
        }
      ]
    },
    {
      id: 'advanced',
      title: 'Gelişmiş Özellikler',
      description: 'Uzman kullanıcılar için',
      icon: Settings,
      docs: [
        {
          id: 'api-integration',
          title: 'API Entegrasyonu',
          description: 'SmartOp API\'sini kendi sistemlerinizle entegre edin',
          type: 'api',
          difficulty: 'advanced',
          duration: '30 dk'
        },
        {
          id: 'custom-fields',
          title: 'Özel Alanlar',
          description: 'Kontrol listelerine özel alanlar ekleyin',
          type: 'guide',
          difficulty: 'intermediate',
          duration: '15 dk'
        },
        {
          id: 'automation',
          title: 'Otomasyon Kuralları',
          description: 'Otomatik bildirimler ve işlemler ayarlayın',
          type: 'guide',
          difficulty: 'advanced',
          duration: '20 dk'
        }
      ]
    },
    {
      id: 'security',
      title: 'Güvenlik',
      description: 'Güvenlik ve uyumluluk',
      icon: Shield,
      docs: [
        {
          id: 'data-security',
          title: 'Veri Güvenliği',
          description: 'Verilerinizin nasıl korunduğunu öğrenin',
          type: 'guide',
          difficulty: 'beginner',
          duration: '5 dk'
        },
        {
          id: 'user-permissions',
          title: 'Kullanıcı İzinleri',
          description: 'Detaylı izin yönetimi ve güvenlik ayarları',
          type: 'guide',
          difficulty: 'intermediate',
          duration: '12 dk'
        },
        {
          id: 'compliance',
          title: 'KVKK Uyumluluğu',
          description: 'KVKK ve veri koruma düzenlemeleri',
          type: 'guide',
          difficulty: 'intermediate',
          duration: '8 dk'
        }
      ]
    }
  ]

  const allDocs = categories.flatMap(category =>
    category.docs.map(doc => ({ ...doc, categoryId: category.id, categoryTitle: category.title }))
  )

  const filteredDocs = allDocs.filter(doc => {
    const matchesSearch = doc.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         doc.description.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesCategory = selectedCategory === 'all' || doc.categoryId === selectedCategory
    return matchesSearch && matchesCategory
  })

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'guide':
        return FileText
      case 'video':
        return Video
      case 'api':
        return Settings
      case 'faq':
        return HelpCircle
      default:
        return BookOpen
    }
  }

  const getTypeLabel = (type: string) => {
    switch (type) {
      case 'guide':
        return 'Kılavuz'
      case 'video':
        return 'Video'
      case 'api':
        return 'API'
      case 'faq':
        return 'SSS'
      default:
        return type
    }
  }

  const getDifficultyBadge = (difficulty: string) => {
    switch (difficulty) {
      case 'beginner':
        return { label: 'Başlangıç', className: 'bg-green-100 text-green-800' }
      case 'intermediate':
        return { label: 'Orta', className: 'bg-yellow-100 text-yellow-800' }
      case 'advanced':
        return { label: 'İleri', className: 'bg-red-100 text-red-800' }
      default:
        return { label: difficulty, className: 'bg-gray-100 text-gray-800' }
    }
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Dokümantasyon</h1>
            <p className="text-gray-600">SmartOp kullanımı için kapsamlı kılavuzlar ve videolar</p>
          </div>
          <div className="flex items-center space-x-3">
            <Button variant="outline">
              <MessageSquare className="h-4 w-4 mr-2" />
              Destek Talebi
            </Button>
            <Button>
              <Phone className="h-4 w-4 mr-2" />
              Canlı Destek
            </Button>
          </div>
        </div>

        {/* Search and Filter */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                <Input
                  placeholder="Dokümanlarda ara..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                className="border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="all">Tüm Kategoriler</option>
                {categories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.title}
                  </option>
                ))}
              </select>
            </div>
          </CardContent>
        </Card>

        {/* Quick Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <BookOpen className="h-8 w-8 text-blue-600" />
                <div>
                  <p className="text-2xl font-bold">{allDocs.length}</p>
                  <p className="text-sm text-gray-600">Toplam Döküman</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Video className="h-8 w-8 text-red-600" />
                <div>
                  <p className="text-2xl font-bold">{allDocs.filter(d => d.type === 'video').length}</p>
                  <p className="text-sm text-gray-600">Video Kılavuz</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Star className="h-8 w-8 text-yellow-600" />
                <div>
                  <p className="text-2xl font-bold">{allDocs.filter(d => d.popular).length}</p>
                  <p className="text-sm text-gray-600">Popüler İçerik</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center space-x-2">
                <Users className="h-8 w-8 text-green-600" />
                <div>
                  <p className="text-2xl font-bold">{allDocs.filter(d => d.difficulty === 'beginner').length}</p>
                  <p className="text-sm text-gray-600">Başlangıç Seviye</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Categories Overview - Only show when no search */}
        {!searchTerm && selectedCategory === 'all' && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {categories.map((category) => {
              const IconComponent = category.icon
              return (
                <Card key={category.id} className="hover:shadow-lg transition-shadow cursor-pointer"
                      onClick={() => setSelectedCategory(category.id)}>
                  <CardHeader>
                    <div className="flex items-center space-x-3">
                      <div className="p-2 bg-blue-100 rounded-lg">
                        <IconComponent className="h-6 w-6 text-blue-600" />
                      </div>
                      <div>
                        <CardTitle className="text-lg">{category.title}</CardTitle>
                        <CardDescription>{category.description}</CardDescription>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="flex items-center justify-between text-sm text-gray-600">
                      <span>{category.docs.length} döküman</span>
                      <ExternalLink className="h-4 w-4" />
                    </div>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        )}

        {/* Documentation List */}
        {(searchTerm || selectedCategory !== 'all') && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                {selectedCategory === 'all' ? 'Arama Sonuçları' : categories.find(c => c.id === selectedCategory)?.title}
              </h2>
              <span className="text-sm text-gray-600">{filteredDocs.length} döküman bulundu</span>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {filteredDocs.map((doc) => {
                const TypeIcon = getTypeIcon(doc.type)
                const difficultyBadge = getDifficultyBadge(doc.difficulty)
                return (
                  <Card key={doc.id} className="hover:shadow-lg transition-shadow">
                    <CardHeader>
                      <div className="flex items-start justify-between">
                        <div className="flex items-start space-x-3">
                          <div className="p-2 bg-gray-100 rounded-lg">
                            <TypeIcon className="h-5 w-5 text-gray-600" />
                          </div>
                          <div>
                            <CardTitle className="text-base flex items-center space-x-2">
                              {doc.title}
                              {doc.popular && <Star className="h-4 w-4 text-yellow-500" />}
                            </CardTitle>
                            <CardDescription>{doc.description}</CardDescription>
                          </div>
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-2">
                          <Badge variant="outline">{getTypeLabel(doc.type)}</Badge>
                          <Badge
                            variant="secondary"
                            className={difficultyBadge.className}
                          >
                            {difficultyBadge.label}
                          </Badge>
                          {doc.duration && (
                            <div className="flex items-center text-sm text-gray-500">
                              <Clock className="h-3 w-3 mr-1" />
                              {doc.duration}
                            </div>
                          )}
                        </div>
                        <div className="flex items-center space-x-2">
                          <Button variant="outline" size="sm">
                            <BookOpen className="h-4 w-4 mr-1" />
                            Oku
                          </Button>
                          {doc.type === 'video' && (
                            <Button variant="outline" size="sm">
                              <Play className="h-4 w-4" />
                            </Button>
                          )}
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                )
              })}
            </div>

            {filteredDocs.length === 0 && (
              <div className="text-center py-12">
                <Search className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">Döküman bulunamadı</h3>
                <p className="text-gray-600">Arama kriterlerinize uygun döküman bulunamadı.</p>
              </div>
            )}
          </div>
        )}

        {/* Help Section */}
        <Card className="bg-blue-50 border-blue-200">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Aradığınızı bulamadınız mı?</h3>
                <p className="text-gray-600">Destek ekibimiz size yardımcı olmak için burada. Herhangi bir sorunuz varsa bizimle iletişime geçin.</p>
              </div>
              <div className="flex space-x-3">
                <Button variant="outline">
                  <MessageSquare className="h-4 w-4 mr-2" />
                  Soru Sor
                </Button>
                <Button>
                  <Phone className="h-4 w-4 mr-2" />
                  Destek Ekibi
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  )
}