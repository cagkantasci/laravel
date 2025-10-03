'use client'

import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { apiClient } from '@/lib/api'
import { UserCircle, Mail, Phone, Building2, Shield, Save } from 'lucide-react'

export default function ProfilePage() {
  const [user, setUser] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    current_password: '',
    new_password: '',
    new_password_confirmation: ''
  })

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const userData = localStorage.getItem('user')
        if (userData) {
          const parsedUser = JSON.parse(userData)
          setUser(parsedUser)
          setFormData({
            name: parsedUser.name || '',
            email: parsedUser.email || '',
            phone: parsedUser.phone || '',
            current_password: '',
            new_password: '',
            new_password_confirmation: ''
          })
        }
        setLoading(false)
      } catch (error) {
        console.error('Profile fetch error:', error)
        setLoading(false)
      }
    }

    fetchProfile()
  }, [])

  const handleUpdateProfile = async () => {
    setSaving(true)
    try {
      const data: any = {
        name: formData.name,
        email: formData.email,
        phone: formData.phone
      }

      // Only include password fields if user wants to change password
      if (formData.current_password && formData.new_password) {
        data.current_password = formData.current_password
        data.password = formData.new_password
        data.password_confirmation = formData.new_password_confirmation
      }

      const response = await apiClient.updateProfile(data)

      // Update local storage
      const updatedUser = { ...user, ...response.data }
      localStorage.setItem('user', JSON.stringify(updatedUser))
      setUser(updatedUser)

      // Clear password fields
      setFormData({
        ...formData,
        current_password: '',
        new_password: '',
        new_password_confirmation: ''
      })

      alert('Profil başarıyla güncellendi!')
    } catch (error: any) {
      console.error('Update error:', error)
      alert(error.response?.data?.message || 'Profil güncellenirken bir hata oluştu')
    } finally {
      setSaving(false)
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
      <div className="space-y-6 max-w-4xl">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Profil Ayarları</h1>
          <p className="text-gray-600">Hesap bilgilerinizi görüntüleyin ve güncelleyin</p>
        </div>

        {/* User Info Card */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <UserCircle className="h-5 w-5" />
              Kullanıcı Bilgileri
            </CardTitle>
            <CardDescription>
              Adınız, e-posta adresiniz ve telefon numaranızı güncelleyin
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="name">Ad Soyad</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="Ad Soyad"
                />
              </div>
              <div>
                <Label htmlFor="email">E-posta</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="email@example.com"
                />
              </div>
              <div>
                <Label htmlFor="phone">Telefon</Label>
                <Input
                  id="phone"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  placeholder="+90 555 555 5555"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Account Info Card (Read-only) */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5" />
              Hesap Bilgileri
            </CardTitle>
            <CardDescription>
              Sistem tarafından atanan bilgiler
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label className="text-gray-600">Rol</Label>
                <div className="mt-1 px-3 py-2 bg-gray-50 rounded-md text-sm">
                  {user?.roles?.[0]?.name === 'admin' ? 'Sistem Yöneticisi' :
                   user?.roles?.[0]?.name === 'manager' ? 'Şirket Yöneticisi' : 'Operatör'}
                </div>
              </div>
              {user?.company && (
                <div>
                  <Label className="text-gray-600">Şirket</Label>
                  <div className="mt-1 px-3 py-2 bg-gray-50 rounded-md text-sm flex items-center gap-2">
                    <Building2 className="h-4 w-4 text-gray-500" />
                    {user.company.name}
                  </div>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Password Change Card */}
        <Card>
          <CardHeader>
            <CardTitle>Şifre Değiştir</CardTitle>
            <CardDescription>
              Güvenliğiniz için güçlü bir şifre kullanın
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="current_password">Mevcut Şifre</Label>
              <Input
                id="current_password"
                type="password"
                value={formData.current_password}
                onChange={(e) => setFormData({ ...formData, current_password: e.target.value })}
                placeholder="Mevcut şifreniz"
              />
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="new_password">Yeni Şifre</Label>
                <Input
                  id="new_password"
                  type="password"
                  value={formData.new_password}
                  onChange={(e) => setFormData({ ...formData, new_password: e.target.value })}
                  placeholder="Yeni şifre"
                />
              </div>
              <div>
                <Label htmlFor="new_password_confirmation">Yeni Şifre (Tekrar)</Label>
                <Input
                  id="new_password_confirmation"
                  type="password"
                  value={formData.new_password_confirmation}
                  onChange={(e) => setFormData({ ...formData, new_password_confirmation: e.target.value })}
                  placeholder="Yeni şifre tekrar"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Save Button */}
        <div className="flex justify-end">
          <Button onClick={handleUpdateProfile} disabled={saving} className="min-w-32">
            <Save className="h-4 w-4 mr-2" />
            {saving ? 'Kaydediliyor...' : 'Kaydet'}
          </Button>
        </div>
      </div>
    </AdminLayout>
  )
}
