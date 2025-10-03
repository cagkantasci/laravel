'use client'

import React, { useState, useEffect } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
  Settings,
  User,
  Shield,
  Bell,
  Palette,
  Database,
  Globe,
  Smartphone,
  Key,
  Mail,
  Save,
  Eye,
  EyeOff,
  Upload,
  Download,
  RefreshCw,
  AlertTriangle,
  CheckCircle,
  Info
} from 'lucide-react'

interface SettingsSection {
  id: string
  title: string
  description: string
  icon: any
}

export default function SettingsPage() {
  const [activeSection, setActiveSection] = useState('profile')
  const [showPassword, setShowPassword] = useState(false)
  const [settings, setSettings] = useState({
    profile: {
      name: 'Admin User',
      email: 'admin@smartop.com',
      phone: '+90 555 123 4567',
      title: 'Sistem Yöneticisi',
      avatar: ''
    },
    security: {
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      twoFactorEnabled: false,
      sessionTimeout: 60,
      loginAttempts: 5
    },
    notifications: {
      emailNotifications: true,
      pushNotifications: true,
      smsNotifications: false,
      criticalAlerts: true,
      dailyReports: true,
      weeklyReports: false,
      maintenanceAlerts: true
    },
    appearance: {
      theme: 'light',
      language: 'tr',
      dateFormat: 'DD/MM/YYYY',
      timeFormat: '24h',
      timezone: 'Europe/Istanbul'
    },
    system: {
      backupFrequency: 'daily',
      dataRetention: 365,
      auditLogs: true,
      debugMode: false,
      maintenanceMode: false,
      cacheEnabled: true
    }
  })

  const sections: SettingsSection[] = [
    {
      id: 'profile',
      title: 'Profil Ayarları',
      description: 'Kişisel bilgilerinizi yönetin',
      icon: User
    },
    {
      id: 'security',
      title: 'Güvenlik',
      description: 'Şifre ve güvenlik ayarları',
      icon: Shield
    },
    {
      id: 'notifications',
      title: 'Bildirimler',
      description: 'Bildirim tercihlerinizi ayarlayın',
      icon: Bell
    },
    {
      id: 'appearance',
      title: 'Görünüm',
      description: 'Tema ve dil ayarları',
      icon: Palette
    },
    {
      id: 'system',
      title: 'Sistem',
      description: 'Sistem yönetimi ve bakım',
      icon: Database
    }
  ]

  const handleSave = (sectionId: string) => {
    // API call to save settings
    console.log(`Saving ${sectionId} settings:`, settings[sectionId as keyof typeof settings])
    // Show success message
  }

  const renderProfileSettings = () => (
    <div className="space-y-6">
      <div className="flex items-center space-x-6">
        <div className="relative">
          <div className="w-20 h-20 bg-gray-200 rounded-full flex items-center justify-center">
            <User className="h-10 w-10 text-gray-500" />
          </div>
          <Button size="sm" className="absolute -bottom-2 -right-2" variant="outline">
            <Upload className="h-3 w-3" />
          </Button>
        </div>
        <div>
          <h3 className="text-lg font-semibold">Profil Fotoğrafı</h3>
          <p className="text-sm text-gray-600">JPG, PNG veya GIF formatında, maksimum 5MB</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Ad Soyad</label>
          <Input
            value={settings.profile.name}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              profile: { ...prev.profile, name: e.target.value }
            }))}
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
          <Input
            type="email"
            value={settings.profile.email}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              profile: { ...prev.profile, email: e.target.value }
            }))}
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Telefon</label>
          <Input
            value={settings.profile.phone}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              profile: { ...prev.profile, phone: e.target.value }
            }))}
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Unvan</label>
          <Input
            value={settings.profile.title}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              profile: { ...prev.profile, title: e.target.value }
            }))}
          />
        </div>
      </div>

      <Button onClick={() => handleSave('profile')}>
        <Save className="h-4 w-4 mr-2" />
        Profil Bilgilerini Kaydet
      </Button>
    </div>
  )

  const renderSecuritySettings = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Şifre Değiştir</CardTitle>
          <CardDescription>Hesap güvenliğiniz için düzenli olarak şifrenizi değiştirin</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Mevcut Şifre</label>
            <div className="relative">
              <Input
                type={showPassword ? 'text' : 'password'}
                value={settings.security.currentPassword}
                onChange={(e) => setSettings(prev => ({
                  ...prev,
                  security: { ...prev.security, currentPassword: e.target.value }
                }))}
              />
              <Button
                type="button"
                variant="ghost"
                size="sm"
                className="absolute right-2 top-1/2 -translate-y-1/2"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </Button>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Yeni Şifre</label>
            <Input
              type={showPassword ? 'text' : 'password'}
              value={settings.security.newPassword}
              onChange={(e) => setSettings(prev => ({
                ...prev,
                security: { ...prev.security, newPassword: e.target.value }
              }))}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Yeni Şifre (Tekrar)</label>
            <Input
              type={showPassword ? 'text' : 'password'}
              value={settings.security.confirmPassword}
              onChange={(e) => setSettings(prev => ({
                ...prev,
                security: { ...prev.security, confirmPassword: e.target.value }
              }))}
            />
          </div>
          <Button>
            <Key className="h-4 w-4 mr-2" />
            Şifreyi Güncelle
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Güvenlik Ayarları</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h4 className="font-medium">İki Faktörlü Doğrulama</h4>
              <p className="text-sm text-gray-600">Hesabınıza ek güvenlik katmanı ekleyin</p>
            </div>
            <div className="flex items-center space-x-2">
              <Badge variant={settings.security.twoFactorEnabled ? 'default' : 'secondary'}>
                {settings.security.twoFactorEnabled ? 'Aktif' : 'Pasif'}
              </Badge>
              <Button variant="outline" size="sm">
                {settings.security.twoFactorEnabled ? 'Devre Dışı Bırak' : 'Etkinleştir'}
              </Button>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Oturum Zaman Aşımı (dakika)</label>
              <Input
                type="number"
                value={settings.security.sessionTimeout}
                onChange={(e) => setSettings(prev => ({
                  ...prev,
                  security: { ...prev.security, sessionTimeout: parseInt(e.target.value) }
                }))}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Maksimum Giriş Denemesi</label>
              <Input
                type="number"
                value={settings.security.loginAttempts}
                onChange={(e) => setSettings(prev => ({
                  ...prev,
                  security: { ...prev.security, loginAttempts: parseInt(e.target.value) }
                }))}
              />
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )

  const renderNotificationSettings = () => (
    <div className="space-y-6">
      {Object.entries({
        'Email Bildirimleri': 'emailNotifications',
        'Push Bildirimleri': 'pushNotifications',
        'SMS Bildirimleri': 'smsNotifications',
        'Kritik Uyarılar': 'criticalAlerts',
        'Günlük Raporlar': 'dailyReports',
        'Haftalık Raporlar': 'weeklyReports',
        'Bakım Uyarıları': 'maintenanceAlerts'
      }).map(([label, key]) => (
        <div key={key} className="flex items-center justify-between p-4 border rounded-lg">
          <div>
            <h4 className="font-medium">{label}</h4>
            <p className="text-sm text-gray-600">
              {key === 'emailNotifications' && 'Email ile bildirim alın'}
              {key === 'pushNotifications' && 'Tarayıcı bildirimleri'}
              {key === 'smsNotifications' && 'SMS ile bildirim alın'}
              {key === 'criticalAlerts' && 'Acil durumlar için anlık bildirim'}
              {key === 'dailyReports' && 'Her gün özet rapor'}
              {key === 'weeklyReports' && 'Haftalık detaylı rapor'}
              {key === 'maintenanceAlerts' && 'Bakım zamanları için hatırlatma'}
            </p>
          </div>
          <button
            onClick={() => setSettings(prev => ({
              ...prev,
              notifications: {
                ...prev.notifications,
                [key]: !prev.notifications[key as keyof typeof prev.notifications]
              }
            }))}
            className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
              settings.notifications[key as keyof typeof settings.notifications] ? 'bg-blue-600' : 'bg-gray-200'
            }`}
          >
            <span
              className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                settings.notifications[key as keyof typeof settings.notifications] ? 'translate-x-6' : 'translate-x-1'
              }`}
            />
          </button>
        </div>
      ))}

      <Button onClick={() => handleSave('notifications')}>
        <Save className="h-4 w-4 mr-2" />
        Bildirim Ayarlarını Kaydet
      </Button>
    </div>
  )

  const renderAppearanceSettings = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Tema</label>
          <select
            value={settings.appearance.theme}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              appearance: { ...prev.appearance, theme: e.target.value }
            }))}
            className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="light">Açık Tema</option>
            <option value="dark">Koyu Tema</option>
            <option value="auto">Sistem Ayarı</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Dil</label>
          <select
            value={settings.appearance.language}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              appearance: { ...prev.appearance, language: e.target.value }
            }))}
            className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="tr">Türkçe</option>
            <option value="en">English</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Tarih Formatı</label>
          <select
            value={settings.appearance.dateFormat}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              appearance: { ...prev.appearance, dateFormat: e.target.value }
            }))}
            className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="DD/MM/YYYY">DD/MM/YYYY</option>
            <option value="MM/DD/YYYY">MM/DD/YYYY</option>
            <option value="YYYY-MM-DD">YYYY-MM-DD</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Saat Formatı</label>
          <select
            value={settings.appearance.timeFormat}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              appearance: { ...prev.appearance, timeFormat: e.target.value }
            }))}
            className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="24h">24 Saat</option>
            <option value="12h">12 Saat (AM/PM)</option>
          </select>
        </div>

        <div className="md:col-span-2">
          <label className="block text-sm font-medium text-gray-700 mb-2">Zaman Dilimi</label>
          <select
            value={settings.appearance.timezone}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              appearance: { ...prev.appearance, timezone: e.target.value }
            }))}
            className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="Europe/Istanbul">İstanbul (UTC+3)</option>
            <option value="UTC">UTC</option>
            <option value="Europe/London">Londra (UTC+0)</option>
            <option value="America/New_York">New York (UTC-5)</option>
          </select>
        </div>
      </div>

      <Button onClick={() => handleSave('appearance')}>
        <Save className="h-4 w-4 mr-2" />
        Görünüm Ayarlarını Kaydet
      </Button>
    </div>
  )

  const renderSystemSettings = () => (
    <div className="space-y-6">
      <Card className="border-red-200 bg-red-50">
        <CardHeader>
          <CardTitle className="text-lg flex items-center text-red-800">
            <AlertTriangle className="h-5 w-5 mr-2" />
            Dikkat
          </CardTitle>
          <CardDescription className="text-red-700">
            Bu ayarlar sistem performansını etkileyebilir. Değişiklik yapmadan önce lütfen dikkatli olun.
          </CardDescription>
        </CardHeader>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Yedekleme Sıklığı</label>
          <select
            value={settings.system.backupFrequency}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              system: { ...prev.system, backupFrequency: e.target.value }
            }))}
            className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="hourly">Saatlik</option>
            <option value="daily">Günlük</option>
            <option value="weekly">Haftalık</option>
            <option value="monthly">Aylık</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Veri Saklama Süresi (gün)</label>
          <Input
            type="number"
            value={settings.system.dataRetention}
            onChange={(e) => setSettings(prev => ({
              ...prev,
              system: { ...prev.system, dataRetention: parseInt(e.target.value) }
            }))}
          />
        </div>
      </div>

      <div className="space-y-4">
        {Object.entries({
          'Denetim Logları': 'auditLogs',
          'Debug Modu': 'debugMode',
          'Bakım Modu': 'maintenanceMode',
          'Cache Sistemi': 'cacheEnabled'
        }).map(([label, key]) => (
          <div key={key} className="flex items-center justify-between p-4 border rounded-lg">
            <div>
              <h4 className="font-medium">{label}</h4>
              <p className="text-sm text-gray-600">
                {key === 'auditLogs' && 'Tüm kullanıcı aktivitelerini kaydet'}
                {key === 'debugMode' && 'Geliştirici hata mesajlarını göster'}
                {key === 'maintenanceMode' && 'Sistemi bakım moduna al'}
                {key === 'cacheEnabled' && 'Performans için cache kullan'}
              </p>
            </div>
            <div className="flex items-center space-x-2">
              <Badge variant={settings.system[key as keyof typeof settings.system] ? 'default' : 'secondary'}>
                {settings.system[key as keyof typeof settings.system] ? 'Aktif' : 'Pasif'}
              </Badge>
              <button
                onClick={() => setSettings(prev => ({
                  ...prev,
                  system: {
                    ...prev.system,
                    [key]: !prev.system[key as keyof typeof prev.system]
                  }
                }))}
                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                  settings.system[key as keyof typeof settings.system] ? 'bg-blue-600' : 'bg-gray-200'
                }`}
              >
                <span
                  className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                    settings.system[key as keyof typeof settings.system] ? 'translate-x-6' : 'translate-x-1'
                  }`}
                />
              </button>
            </div>
          </div>
        ))}
      </div>

      <div className="flex space-x-4">
        <Button variant="outline">
          <Download className="h-4 w-4 mr-2" />
          Sistem Yedeklemesi Al
        </Button>
        <Button variant="outline">
          <RefreshCw className="h-4 w-4 mr-2" />
          Cache Temizle
        </Button>
        <Button onClick={() => handleSave('system')}>
          <Save className="h-4 w-4 mr-2" />
          Sistem Ayarlarını Kaydet
        </Button>
      </div>
    </div>
  )

  const renderContent = () => {
    switch (activeSection) {
      case 'profile':
        return renderProfileSettings()
      case 'security':
        return renderSecuritySettings()
      case 'notifications':
        return renderNotificationSettings()
      case 'appearance':
        return renderAppearanceSettings()
      case 'system':
        return renderSystemSettings()
      default:
        return renderProfileSettings()
    }
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Ayarlar</h1>
          <p className="text-gray-600">Sistem ve hesap ayarlarınızı yönetin</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Sidebar */}
          <div className="lg:col-span-1">
            <Card>
              <CardContent className="p-0">
                <nav className="space-y-1">
                  {sections.map((section) => {
                    const IconComponent = section.icon
                    return (
                      <button
                        key={section.id}
                        onClick={() => setActiveSection(section.id)}
                        className={`w-full flex items-center px-4 py-3 text-left hover:bg-gray-50 ${
                          activeSection === section.id ? 'bg-blue-50 border-r-2 border-blue-500 text-blue-700' : 'text-gray-700'
                        }`}
                      >
                        <IconComponent className="h-5 w-5 mr-3" />
                        <div>
                          <div className="font-medium">{section.title}</div>
                          <div className="text-xs text-gray-500">{section.description}</div>
                        </div>
                      </button>
                    )
                  })}
                </nav>
              </CardContent>
            </Card>
          </div>

          {/* Content */}
          <div className="lg:col-span-3">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  {React.createElement(sections.find(s => s.id === activeSection)?.icon || Settings, { className: "h-5 w-5 mr-2" })}
                  {sections.find(s => s.id === activeSection)?.title}
                </CardTitle>
                <CardDescription>
                  {sections.find(s => s.id === activeSection)?.description}
                </CardDescription>
              </CardHeader>
              <CardContent>
                {renderContent()}
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}