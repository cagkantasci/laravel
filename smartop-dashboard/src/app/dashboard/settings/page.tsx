'use client'

import { useState } from 'react'
import AuthWrapper from '@/components/auth/auth-wrapper'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Settings,
  User,
  Bell,
  Shield,
  Database,
  Mail,
  Palette,
  Globe,
  Save,
  Eye,
  EyeOff
} from 'lucide-react'

export default function SettingsPage() {
  const [showPassword, setShowPassword] = useState(false)
  const [activeTab, setActiveTab] = useState('profile')

  const tabs = [
    { id: 'profile', label: 'Profil', icon: User },
    { id: 'security', label: 'Güvenlik', icon: Shield },
    { id: 'notifications', label: 'Bildirimler', icon: Bell },
    { id: 'system', label: 'Sistem', icon: Database },
    { id: 'appearance', label: 'Görünüm', icon: Palette },
    { id: 'integrations', label: 'Entegrasyonlar', icon: Globe }
  ]

  return (
    <AuthWrapper>
      <div className="space-y-6">
        {/* Page Header */}
        <div>
          <h1 className="text-3xl font-bold text-slate-900 flex items-center">
            <Settings className="h-8 w-8 mr-3 text-blue-600" />
            Sistem Ayarları
          </h1>
          <p className="text-slate-600">Sistem ayarlarını yönetin ve özelleştirin</p>
        </div>

        <div className="flex gap-6">
          {/* Sidebar */}
          <div className="w-64 space-y-1">
            {tabs.map((tab) => {
              const Icon = tab.icon
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full flex items-center space-x-3 px-3 py-2 rounded-lg text-left transition-colors ${
                    activeTab === tab.id
                      ? 'bg-blue-100 text-blue-700 font-medium'
                      : 'text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  <Icon className="h-4 w-4" />
                  <span>{tab.label}</span>
                </button>
              )
            })}
          </div>

          {/* Main Content */}
          <div className="flex-1">
            {activeTab === 'profile' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Profil Bilgileri</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="firstName">Ad</Label>
                        <Input id="firstName" defaultValue="Admin" />
                      </div>
                      <div>
                        <Label htmlFor="lastName">Soyad</Label>
                        <Input id="lastName" defaultValue="User" />
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="email">Email</Label>
                      <Input id="email" type="email" defaultValue="admin@smartop.com" />
                    </div>
                    <div>
                      <Label htmlFor="phone">Telefon</Label>
                      <Input id="phone" defaultValue="+90 555 111 1111" />
                    </div>
                    <div>
                      <Label htmlFor="company">Şirket</Label>
                      <Input id="company" defaultValue="SmartOp Demo Company" />
                    </div>
                    <Button className="bg-blue-600 hover:bg-blue-700">
                      <Save className="h-4 w-4 mr-2" />
                      Kaydet
                    </Button>
                  </CardContent>
                </Card>
              </div>
            )}

            {activeTab === 'security' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Şifre Değiştir</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="currentPassword">Mevcut Şifre</Label>
                      <div className="relative">
                        <Input
                          id="currentPassword"
                          type={showPassword ? 'text' : 'password'}
                          placeholder="Mevcut şifrenizi girin"
                        />
                        <Button
                          type="button"
                          variant="ghost"
                          size="sm"
                          className="absolute right-0 top-0 h-full px-3"
                          onClick={() => setShowPassword(!showPassword)}
                        >
                          {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </Button>
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="newPassword">Yeni Şifre</Label>
                      <Input id="newPassword" type="password" placeholder="Yeni şifrenizi girin" />
                    </div>
                    <div>
                      <Label htmlFor="confirmPassword">Yeni Şifre (Tekrar)</Label>
                      <Input id="confirmPassword" type="password" placeholder="Yeni şifrenizi tekrar girin" />
                    </div>
                    <Button className="bg-blue-600 hover:bg-blue-700">
                      <Shield className="h-4 w-4 mr-2" />
                      Şifre Güncelle
                    </Button>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle>İki Faktörlü Kimlik Doğrulama</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="font-medium">2FA Durumu</p>
                        <p className="text-sm text-slate-600">Hesabınızı ekstra güvenlik ile koruyun</p>
                      </div>
                      <Button variant="outline">Etkinleştir</Button>
                    </div>
                  </CardContent>
                </Card>
              </div>
            )}

            {activeTab === 'notifications' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Bildirim Tercihleri</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-medium">Email Bildirimleri</p>
                          <p className="text-sm text-slate-600">Önemli güncellemeleri email ile alın</p>
                        </div>
                        <input type="checkbox" className="rounded" defaultChecked />
                      </div>
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-medium">Onay Bekleyen İşlemler</p>
                          <p className="text-sm text-slate-600">Onay bekleyen kontrol listeleri için bildirim</p>
                        </div>
                        <input type="checkbox" className="rounded" defaultChecked />
                      </div>
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-medium">Sistem Uyarıları</p>
                          <p className="text-sm text-slate-600">Sistem hataları ve uyarıları</p>
                        </div>
                        <input type="checkbox" className="rounded" defaultChecked />
                      </div>
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-medium">Haftalık Raporlar</p>
                          <p className="text-sm text-slate-600">Haftalık performans raporları</p>
                        </div>
                        <input type="checkbox" className="rounded" />
                      </div>
                    </div>
                    <Button className="bg-blue-600 hover:bg-blue-700">
                      <Save className="h-4 w-4 mr-2" />
                      Tercihleri Kaydet
                    </Button>
                  </CardContent>
                </Card>
              </div>
            )}

            {activeTab === 'system' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Sistem Bilgileri</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm font-medium text-slate-600">Sistem Versiyonu</p>
                        <p className="font-mono">v1.0.0</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium text-slate-600">Son Güncelleme</p>
                        <p>29 Eylül 2025</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium text-slate-600">Database Versiyonu</p>
                        <p className="font-mono">MySQL 8.0.35</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium text-slate-600">API Versiyonu</p>
                        <p className="font-mono">v1.0</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle>Sistem Ayarları</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="companyName">Sistem Adı</Label>
                      <Input id="companyName" defaultValue="SmartOp Kontrol Sistemi" />
                    </div>
                    <div>
                      <Label htmlFor="timezone">Saat Dilimi</Label>
                      <select className="w-full h-10 px-3 py-2 text-sm border border-input bg-background rounded-md">
                        <option>Europe/Istanbul</option>
                        <option>UTC</option>
                      </select>
                    </div>
                    <div>
                      <Label htmlFor="language">Dil</Label>
                      <select className="w-full h-10 px-3 py-2 text-sm border border-input bg-background rounded-md">
                        <option>Türkçe</option>
                        <option>English</option>
                      </select>
                    </div>
                    <Button className="bg-blue-600 hover:bg-blue-700">
                      <Save className="h-4 w-4 mr-2" />
                      Ayarları Kaydet
                    </Button>
                  </CardContent>
                </Card>
              </div>
            )}

            {activeTab === 'appearance' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Görünüm Ayarları</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>Tema</Label>
                      <div className="flex space-x-4 mt-2">
                        <label className="flex items-center space-x-2">
                          <input type="radio" name="theme" value="light" defaultChecked />
                          <span>Açık Tema</span>
                        </label>
                        <label className="flex items-center space-x-2">
                          <input type="radio" name="theme" value="dark" />
                          <span>Koyu Tema</span>
                        </label>
                        <label className="flex items-center space-x-2">
                          <input type="radio" name="theme" value="auto" />
                          <span>Otomatik</span>
                        </label>
                      </div>
                    </div>
                    <div>
                      <Label>Renk Paleti</Label>
                      <div className="flex space-x-2 mt-2">
                        <div className="w-8 h-8 bg-blue-600 rounded-full border-2 border-blue-200"></div>
                        <div className="w-8 h-8 bg-green-600 rounded-full"></div>
                        <div className="w-8 h-8 bg-purple-600 rounded-full"></div>
                        <div className="w-8 h-8 bg-orange-600 rounded-full"></div>
                      </div>
                    </div>
                    <Button className="bg-blue-600 hover:bg-blue-700">
                      <Save className="h-4 w-4 mr-2" />
                      Görünüm Kaydet
                    </Button>
                  </CardContent>
                </Card>
              </div>
            )}

            {activeTab === 'integrations' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>API Entegrasyonları</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="apiKey">API Anahtarı</Label>
                      <div className="flex space-x-2">
                        <Input id="apiKey" value="sk_live_*********************" readOnly />
                        <Button variant="outline">Yenile</Button>
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="webhookUrl">Webhook URL</Label>
                      <Input id="webhookUrl" placeholder="https://example.com/webhook" />
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle>Harici Entegrasyonlar</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="flex items-center justify-between p-3 border rounded-lg">
                      <div className="flex items-center space-x-3">
                        <Mail className="h-8 w-8 text-red-600" />
                        <div>
                          <p className="font-medium">Gmail</p>
                          <p className="text-sm text-slate-600">Email bildirimleri için</p>
                        </div>
                      </div>
                      <Button variant="outline">Bağlan</Button>
                    </div>
                    <div className="flex items-center justify-between p-3 border rounded-lg">
                      <div className="flex items-center space-x-3">
                        <Database className="h-8 w-8 text-blue-600" />
                        <div>
                          <p className="font-medium">ERP Sistemi</p>
                          <p className="text-sm text-slate-600">Veri senkronizasyonu</p>
                        </div>
                      </div>
                      <Button variant="outline">Kurulum</Button>
                    </div>
                  </CardContent>
                </Card>
              </div>
            )}
          </div>
        </div>
      </div>
    </AuthWrapper>
  )
}