'use client'

import { useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Check,
  Crown,
  Star,
  Zap,
  Users,
  Database,
  Shield,
  Headphones,
  BarChart3,
  Cog,
  Building2,
  Globe
} from 'lucide-react'

interface PricingPlan {
  id: string
  name: string
  description: string
  price: number
  currency: string
  period: string
  popular?: boolean
  features: string[]
  limits: {
    users: number | 'unlimited'
    machines: number | 'unlimited'
    storage: string
    support: string
  }
  icon: any
}

export default function PricingPage() {
  const [billingPeriod, setBillingPeriod] = useState<'monthly' | 'yearly'>('monthly')

  const pricingPlans: PricingPlan[] = [
    {
      id: 'starter',
      name: 'Başlangıç',
      description: 'Küçük işletmeler için ideal',
      price: billingPeriod === 'monthly' ? 299 : 2990,
      currency: '₺',
      period: billingPeriod === 'monthly' ? '/ay' : '/yıl',
      icon: Zap,
      features: [
        'Temel makine yönetimi',
        'Basit kontrol listeleri',
        'Temel raporlama',
        'Email desteği',
        'Mobil uygulama erişimi'
      ],
      limits: {
        users: 5,
        machines: 10,
        storage: '5 GB',
        support: 'Email'
      }
    },
    {
      id: 'professional',
      name: 'Profesyonel',
      description: 'Büyüyen işletmeler için',
      price: billingPeriod === 'monthly' ? 699 : 6990,
      currency: '₺',
      period: billingPeriod === 'monthly' ? '/ay' : '/yıl',
      popular: true,
      icon: Star,
      features: [
        'Gelişmiş makine yönetimi',
        'Özelleştirilebilir kontrol listeleri',
        'Detaylı analitik ve raporlar',
        'QR kod entegrasyonu',
        'Bakım planlaması',
        'Öncelikli email desteği',
        'API erişimi',
        'Çoklu şirket yönetimi'
      ],
      limits: {
        users: 25,
        machines: 100,
        storage: '50 GB',
        support: 'Email & Chat'
      }
    },
    {
      id: 'enterprise',
      name: 'Kurumsal',
      description: 'Büyük organizasyonlar için',
      price: billingPeriod === 'monthly' ? 1499 : 14990,
      currency: '₺',
      period: billingPeriod === 'monthly' ? '/ay' : '/yıl',
      icon: Crown,
      features: [
        'Tüm Profesyonel özellikler',
        'Sınırsız entegrasyonlar',
        'Özel raporlama araçları',
        'Gelişmiş güvenlik özellikleri',
        'Dedicated hesap yöneticisi',
        '7/24 telefon desteği',
        'Özel eğitim ve onboarding',
        'SLA garantisi',
        'Özel özellik geliştirme'
      ],
      limits: {
        users: 'unlimited',
        machines: 'unlimited',
        storage: 'Sınırsız',
        support: '7/24 Phone & Chat'
      }
    }
  ]

  const features = [
    {
      icon: Cog,
      title: 'Makine Yönetimi',
      description: 'Endüstriyel makinelerinizi dijital ortamda yönetin'
    },
    {
      icon: BarChart3,
      title: 'Analitik Dashboard',
      description: 'Performans metrikleri ve detaylı raporlar'
    },
    {
      icon: Shield,
      title: 'Güvenlik',
      description: 'Kurumsal düzeyde güvenlik ve yetkilendirme'
    },
    {
      icon: Users,
      title: 'Ekip Yönetimi',
      description: 'Operatörler, müdürler ve yöneticiler için rol tabanlı erişim'
    },
    {
      icon: Database,
      title: 'Veri Yönetimi',
      description: 'Güvenli veri saklama ve yedekleme'
    },
    {
      icon: Globe,
      title: 'Multi-Platform',
      description: 'Web, mobil ve tablet uygulamaları'
    }
  ]

  return (
    <AdminLayout>
      <div className="space-y-8">
        {/* Header */}
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Fiyatlandırma Planları</h1>
          <p className="text-xl text-gray-600 mb-8">İşletmenize uygun planı seçin ve hemen başlayın</p>

          {/* Billing Toggle */}
          <div className="flex items-center justify-center space-x-4 mb-8">
            <span className={`text-sm ${billingPeriod === 'monthly' ? 'text-gray-900 font-medium' : 'text-gray-500'}`}>
              Aylık
            </span>
            <button
              onClick={() => setBillingPeriod(billingPeriod === 'monthly' ? 'yearly' : 'monthly')}
              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                billingPeriod === 'yearly' ? 'bg-blue-600' : 'bg-gray-200'
              }`}
            >
              <span
                className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                  billingPeriod === 'yearly' ? 'translate-x-6' : 'translate-x-1'
                }`}
              />
            </button>
            <span className={`text-sm ${billingPeriod === 'yearly' ? 'text-gray-900 font-medium' : 'text-gray-500'}`}>
              Yıllık
            </span>
            {billingPeriod === 'yearly' && (
              <Badge className="bg-green-100 text-green-800">%17 İndirim</Badge>
            )}
          </div>
        </div>

        {/* Pricing Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {pricingPlans.map((plan) => {
            const IconComponent = plan.icon
            return (
              <Card key={plan.id} className={`relative ${plan.popular ? 'ring-2 ring-blue-500 shadow-lg' : 'hover:shadow-lg'} transition-shadow`}>
                {plan.popular && (
                  <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                    <Badge className="bg-blue-600 text-white px-4 py-1">En Popüler</Badge>
                  </div>
                )}

                <CardHeader className="text-center pb-4">
                  <div className="flex justify-center mb-4">
                    <div className={`p-3 rounded-full ${plan.popular ? 'bg-blue-100' : 'bg-gray-100'}`}>
                      <IconComponent className={`h-8 w-8 ${plan.popular ? 'text-blue-600' : 'text-gray-600'}`} />
                    </div>
                  </div>
                  <CardTitle className="text-2xl">{plan.name}</CardTitle>
                  <CardDescription className="text-base">{plan.description}</CardDescription>
                  <div className="mt-4">
                    <span className="text-4xl font-bold text-gray-900">{plan.currency}{plan.price.toLocaleString()}</span>
                    <span className="text-gray-600">{plan.period}</span>
                  </div>
                </CardHeader>

                <CardContent className="space-y-6">
                  {/* Limits */}
                  <div className="bg-gray-50 rounded-lg p-4 space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Kullanıcı Sayısı:</span>
                      <span className="font-medium">{typeof plan.limits.users === 'number' ? plan.limits.users : 'Sınırsız'}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Makine Sayısı:</span>
                      <span className="font-medium">{typeof plan.limits.machines === 'number' ? plan.limits.machines : 'Sınırsız'}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Depolama:</span>
                      <span className="font-medium">{plan.limits.storage}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Destek:</span>
                      <span className="font-medium">{plan.limits.support}</span>
                    </div>
                  </div>

                  {/* Features */}
                  <div className="space-y-3">
                    {plan.features.map((feature, index) => (
                      <div key={index} className="flex items-start space-x-3">
                        <Check className="h-5 w-5 text-green-500 flex-shrink-0 mt-0.5" />
                        <span className="text-sm text-gray-700">{feature}</span>
                      </div>
                    ))}
                  </div>

                  <Button
                    className={`w-full ${plan.popular ? 'bg-blue-600 hover:bg-blue-700' : ''}`}
                    variant={plan.popular ? 'default' : 'outline'}
                  >
                    Planı Seç
                  </Button>
                </CardContent>
              </Card>
            )
          })}
        </div>

        {/* Features Section */}
        <div className="mt-16">
          <div className="text-center mb-12">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Tüm Planlarda Dahil</h2>
            <p className="text-gray-600">SmartOp ile işletmenizi dijitalleştirin</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => {
              const IconComponent = feature.icon
              return (
                <Card key={index} className="text-center hover:shadow-md transition-shadow">
                  <CardContent className="pt-6">
                    <div className="flex justify-center mb-4">
                      <div className="p-3 rounded-full bg-blue-100">
                        <IconComponent className="h-6 w-6 text-blue-600" />
                      </div>
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-2">{feature.title}</h3>
                    <p className="text-gray-600 text-sm">{feature.description}</p>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </div>

        {/* FAQ Section */}
        <div className="mt-16">
          <div className="text-center mb-12">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Sıkça Sorulan Sorular</h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <Card>
              <CardContent className="pt-6">
                <h3 className="font-semibold text-gray-900 mb-2">Plan değiştirme nasıl yapılır?</h3>
                <p className="text-gray-600 text-sm">Dilediğiniz zaman planınızı yükseltebilir veya düşürebilirsiniz. Değişiklik anında geçerli olur.</p>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <h3 className="font-semibold text-gray-900 mb-2">Ücretsiz deneme var mı?</h3>
                <p className="text-gray-600 text-sm">Evet, tüm planlar için 14 günlük ücretsiz deneme sunuyoruz. Kredi kartı gerekmez.</p>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <h3 className="font-semibold text-gray-900 mb-2">Veri güvenliği nasıl sağlanıyor?</h3>
                <p className="text-gray-600 text-sm">Tüm verileriniz SSL ile şifrelenir ve düzenli olarak yedeklenir. KVKK uyumlu altyapı kullanıyoruz.</p>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <h3 className="font-semibold text-gray-900 mb-2">Teknik destek nasıl alırım?</h3>
                <p className="text-gray-600 text-sm">Planınıza göre email, chat veya telefon desteği alabilirsiniz. Kurumsal planında 7/24 destek mevcuttur.</p>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* CTA Section */}
        <div className="mt-16 text-center bg-blue-50 rounded-lg p-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Hemen Başlayın</h2>
          <p className="text-gray-600 mb-6">14 günlük ücretsiz deneme ile SmartOp'u keşfedin. Kredi kartı gerekmez.</p>
          <div className="flex justify-center space-x-4">
            <Button size="lg">
              Ücretsiz Deneyin
            </Button>
            <Button variant="outline" size="lg">
              <Headphones className="h-4 w-4 mr-2" />
              Satış Ekibi ile Görüşün
            </Button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}