'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import {
  CreditCard,
  DollarSign,
  Users,
  Building2,
  Truck,
  CheckCircle,
  Edit,
  Trash2,
  Plus
} from 'lucide-react'

// Mock data - gerçek API'den gelecek
const pricingPlans = [
  {
    id: 1,
    name: 'Starter',
    description: 'Küçük işletmeler için',
    price: 299,
    currency: 'TL',
    period: 'ay',
    features: [
      '10 Makine',
      '2 Manager',
      '20 Operatör',
      'Temel Raporlama',
      'Mobil Uygulama',
      'E-posta Desteği'
    ],
    limits: {
      machines: 10,
      managers: 2,
      operators: 20
    },
    active: true
  },
  {
    id: 2,
    name: 'Professional',
    description: 'Büyüyen işletmeler için',
    price: 799,
    currency: 'TL',
    period: 'ay',
    features: [
      '50 Makine',
      '5 Manager',
      '100 Operatör',
      'Gelişmiş Raporlama',
      'API Entegrasyonu',
      'Öncelikli Destek'
    ],
    limits: {
      machines: 50,
      managers: 5,
      operators: 100
    },
    active: true,
    popular: true
  },
  {
    id: 3,
    name: 'Enterprise',
    description: 'Büyük kurumlar için',
    price: null,
    currency: 'TL',
    period: 'özel',
    features: [
      'Sınırsız Makine',
      'Sınırsız Manager',
      'Sınırsız Operatör',
      'Özel Özellikler',
      '24/7 Destek',
      'Özel Entegrasyon'
    ],
    limits: {
      machines: -1,
      managers: -1,
      operators: -1
    },
    active: true
  }
]

const subscriptionStats = {
  totalRevenue: 125000,
  activeSubscriptions: 156,
  trialSubscriptions: 23,
  churnRate: 2.5
}

export default function PricingPage() {
  const [editingPlan, setEditingPlan] = useState<number | null>(null)

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Fiyatlandırma Yönetimi</h1>
          <p className="text-slate-600">Abonelik planlarını yönetin ve istatistikleri görüntüleyin</p>
        </div>
        <Button className="flex items-center">
          <Plus className="h-4 w-4 mr-2" />
          Yeni Plan Ekle
        </Button>
      </div>

      {/* Revenue Stats */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-slate-600">
              Toplam Gelir
            </CardTitle>
            <DollarSign className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">
              ₺{subscriptionStats.totalRevenue.toLocaleString()}
            </div>
            <p className="text-xs text-green-600">Bu ay</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-slate-600">
              Aktif Abonelik
            </CardTitle>
            <CreditCard className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{subscriptionStats.activeSubscriptions}</div>
            <p className="text-xs text-green-600">+12 bu ay</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-slate-600">
              Deneme Sürümü
            </CardTitle>
            <Users className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{subscriptionStats.trialSubscriptions}</div>
            <p className="text-xs text-slate-500">Aktif deneme</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-slate-600">
              Churn Oranı
            </CardTitle>
            <Building2 className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">%{subscriptionStats.churnRate}</div>
            <p className="text-xs text-red-600">Bu ay</p>
          </CardContent>
        </Card>
      </div>

      {/* Pricing Plans */}
      <div>
        <h2 className="text-xl font-semibold text-slate-900 mb-6">Abonelik Planları</h2>

        <div className="grid gap-6 lg:grid-cols-3">
          {pricingPlans.map((plan) => (
            <Card key={plan.id} className={`relative ${plan.popular ? 'border-blue-500 border-2' : ''}`}>
              {plan.popular && (
                <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                  <span className="bg-blue-600 text-white px-4 py-1 rounded-full text-sm font-semibold">
                    Popüler
                  </span>
                </div>
              )}

              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="text-xl">{plan.name}</CardTitle>
                    <p className="text-slate-600 text-sm">{plan.description}</p>
                  </div>
                  <div className="flex space-x-2">
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => setEditingPlan(plan.id)}
                    >
                      <Edit className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="icon" className="text-red-600">
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>

                <div className="mt-4">
                  {plan.price ? (
                    <div className="flex items-baseline">
                      <span className="text-3xl font-bold text-slate-900">₺{plan.price}</span>
                      <span className="text-slate-600 ml-1">/{plan.period}</span>
                    </div>
                  ) : (
                    <div className="text-3xl font-bold text-slate-900">Özel Fiyat</div>
                  )}
                </div>
              </CardHeader>

              <CardContent>
                <div className="space-y-4">
                  {/* Limits */}
                  <div className="grid grid-cols-3 gap-2 text-sm">
                    <div className="text-center p-2 bg-slate-50 rounded">
                      <div className="flex items-center justify-center mb-1">
                        <Truck className="h-4 w-4 text-slate-600" />
                      </div>
                      <div className="font-semibold">
                        {plan.limits.machines === -1 ? '∞' : plan.limits.machines}
                      </div>
                      <div className="text-xs text-slate-600">Makine</div>
                    </div>

                    <div className="text-center p-2 bg-slate-50 rounded">
                      <div className="flex items-center justify-center mb-1">
                        <Users className="h-4 w-4 text-slate-600" />
                      </div>
                      <div className="font-semibold">
                        {plan.limits.managers === -1 ? '∞' : plan.limits.managers}
                      </div>
                      <div className="text-xs text-slate-600">Manager</div>
                    </div>

                    <div className="text-center p-2 bg-slate-50 rounded">
                      <div className="flex items-center justify-center mb-1">
                        <Building2 className="h-4 w-4 text-slate-600" />
                      </div>
                      <div className="font-semibold">
                        {plan.limits.operators === -1 ? '∞' : plan.limits.operators}
                      </div>
                      <div className="text-xs text-slate-600">Operatör</div>
                    </div>
                  </div>

                  {/* Features */}
                  <div className="space-y-2">
                    {plan.features.map((feature, index) => (
                      <div key={index} className="flex items-center text-sm">
                        <CheckCircle className="h-4 w-4 text-green-500 mr-2 flex-shrink-0" />
                        <span className="text-slate-700">{feature}</span>
                      </div>
                    ))}
                  </div>

                  {/* Status */}
                  <div className="pt-4 border-t">
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-medium">Durum:</span>
                      <span className={`text-xs px-2 py-1 rounded-full ${
                        plan.active
                          ? 'bg-green-100 text-green-800'
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {plan.active ? 'Aktif' : 'Pasif'}
                      </span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Recent Subscriptions */}
      <Card>
        <CardHeader>
          <CardTitle>Son Abonelikler</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between p-4 bg-slate-50 rounded-lg">
              <div>
                <p className="font-medium text-slate-900">ABC İnşaat Ltd.</p>
                <p className="text-sm text-slate-600">Professional Plan - ₺799/ay</p>
              </div>
              <div className="text-right">
                <p className="text-sm font-medium text-green-600">Yeni Abonelik</p>
                <p className="text-xs text-slate-500">2 saat önce</p>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 bg-slate-50 rounded-lg">
              <div>
                <p className="font-medium text-slate-900">XYZ Lojistik A.Ş.</p>
                <p className="text-sm text-slate-600">Starter Plan - ₺299/ay</p>
              </div>
              <div className="text-right">
                <p className="text-sm font-medium text-blue-600">Plan Yükseltme</p>
                <p className="text-xs text-slate-500">1 gün önce</p>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 bg-slate-50 rounded-lg">
              <div>
                <p className="font-medium text-slate-900">Mega İnşaat Corp.</p>
                <p className="text-sm text-slate-600">Enterprise Plan - Özel Fiyat</p>
              </div>
              <div className="text-right">
                <p className="text-sm font-medium text-green-600">Yeni Abonelik</p>
                <p className="text-xs text-slate-500">3 gün önce</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}