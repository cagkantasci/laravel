'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { apiClient } from '@/lib/api'
import { ArrowLeft, DollarSign, Calendar, Save, Plus } from 'lucide-react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'

const EXPENSE_CATEGORIES = [
  'Office Supplies',
  'Marketing',
  'Software',
  'Equipment',
  'Utilities',
  'Rent',
  'Salaries',
  'Travel',
  'Legal',
  'Insurance',
  'Maintenance',
  'Other'
]

const INCOME_CATEGORIES = [
  'Service Revenue',
  'Product Sales',
  'Consulting',
  'Licensing',
  'Investment',
  'Grants',
  'Refunds',
  'Other'
]

export default function NewFinancePage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  
  const [formData, setFormData] = useState({
    type: 'expense',
    title: '',
    description: '',
    amount: '',
    currency: 'TRY',
    category: '',
    transaction_date: new Date().toISOString().split('T')[0],
    status: 'completed'
  })

  useEffect(() => {
    // Check if user has access
    if (typeof window !== 'undefined') {
      const userData = localStorage.getItem('user')
      if (userData) {
        const parsedUser = JSON.parse(userData)
        const role = parsedUser.roles?.[0]?.name
        
        // Only admin and manager can access finances
        if (role === 'operator') {
          router.push('/dashboard')
          return
        }
      }
    }
  }, [])

  const handleInputChange = (name: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))
    
    // Clear category when type changes
    if (name === 'type') {
      setFormData(prev => ({
        ...prev,
        category: ''
      }))
    }
  }

  const validateForm = () => {
    if (!formData.title.trim()) {
      setError('İşlem başlığı gereklidir')
      return false
    }
    
    if (!formData.amount || parseFloat(formData.amount) <= 0) {
      setError('Geçerli bir tutar giriniz')
      return false
    }
    
    if (!formData.category) {
      setError('Kategori seçiniz')
      return false
    }
    
    if (!formData.transaction_date) {
      setError('İşlem tarihi gereklidir')
      return false
    }
    
    return true
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setSuccess('')
    
    if (!validateForm()) {
      return
    }
    
    try {
      setLoading(true)
      
      const transactionData = {
        ...formData,
        amount: parseFloat(formData.amount)
      }
      
      await apiClient.createFinancialTransaction(transactionData)
      
      setSuccess('Finansal işlem başarıyla oluşturuldu!')
      
      // Redirect after 2 seconds
      setTimeout(() => {
        router.push('/finances')
      }, 2000)
      
    } catch (error: any) {
      console.error('Transaction creation error:', error)
      setError(error.response?.data?.message || 'İşlem oluştururken bir hata oluştu')
    } finally {
      setLoading(false)
    }
  }

  const categories = formData.type === 'income' ? INCOME_CATEGORIES : EXPENSE_CATEGORIES

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center space-x-4">
          <Button
            variant="outline"
            size="sm"
            onClick={() => router.back()}
          >
            <ArrowLeft className="mr-2 h-4 w-4" />
            Geri
          </Button>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Yeni Finansal İşlem</h1>
            <p className="text-muted-foreground">
              Gelir veya gider işlemi ekleyin
            </p>
          </div>
        </div>

        {/* Alerts */}
        {error && (
          <Alert variant="destructive">
            <AlertTitle>Hata</AlertTitle>
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {success && (
          <Alert>
            <AlertTitle>Başarılı</AlertTitle>
            <AlertDescription>{success}</AlertDescription>
          </Alert>
        )}

        {/* Form */}
        <Card className="max-w-2xl">
          <CardHeader>
            <CardTitle className="flex items-center">
              <DollarSign className="mr-2 h-5 w-5" />
              İşlem Detayları
            </CardTitle>
            <CardDescription>
              Yeni finansal işlem bilgilerini doldurun
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Transaction Type */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="type">İşlem Türü *</Label>
                  <Select
                    value={formData.type}
                    onValueChange={(value: string) => handleInputChange('type', value)}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="income">Gelir</SelectItem>
                      <SelectItem value="expense">Gider</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label htmlFor="status">Durum</Label>
                  <Select
                    value={formData.status}
                    onValueChange={(value: string) => handleInputChange('status', value)}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="completed">Tamamlandı</SelectItem>
                      <SelectItem value="pending">Beklemede</SelectItem>
                      <SelectItem value="cancelled">İptal</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              {/* Title */}
              <div>
                <Label htmlFor="title">İşlem Başlığı *</Label>
                <Input
                  id="title"
                  type="text"
                  value={formData.title}
                  onChange={(e) => handleInputChange('title', e.target.value)}
                  placeholder="Örn: Ofis kirası, Müşteri ödemesi..."
                  required
                />
              </div>

              {/* Amount and Currency */}
              <div className="grid grid-cols-3 gap-4">
                <div className="col-span-2">
                  <Label htmlFor="amount">Tutar *</Label>
                  <Input
                    id="amount"
                    type="number"
                    step="0.01"
                    min="0"
                    value={formData.amount}
                    onChange={(e) => handleInputChange('amount', e.target.value)}
                    placeholder="0.00"
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="currency">Para Birimi</Label>
                  <Select
                    value={formData.currency}
                    onValueChange={(value: string) => handleInputChange('currency', value)}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="TRY">TRY (₺)</SelectItem>
                      <SelectItem value="USD">USD ($)</SelectItem>
                      <SelectItem value="EUR">EUR (€)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              {/* Category */}
              <div>
                <Label htmlFor="category">Kategori *</Label>
                <Select
                  value={formData.category}
                  onValueChange={(value: string) => handleInputChange('category', value)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Kategori seçiniz" />
                  </SelectTrigger>
                  <SelectContent>
                    {categories.map((category) => (
                      <SelectItem key={category} value={category}>
                        {category}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Transaction Date */}
              <div>
                <Label htmlFor="transaction_date">İşlem Tarihi *</Label>
                <Input
                  id="transaction_date"
                  type="date"
                  value={formData.transaction_date}
                  onChange={(e) => handleInputChange('transaction_date', e.target.value)}
                  required
                />
              </div>

              {/* Description */}
              <div>
                <Label htmlFor="description">Açıklama</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) => handleInputChange('description', e.target.value)}
                  placeholder="İşlem hakkında detaylar..."
                  rows={4}
                />
              </div>

              {/* Submit Button */}
              <div className="flex justify-end space-x-2">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => router.back()}
                  disabled={loading}
                >
                  İptal
                </Button>
                <Button type="submit" disabled={loading}>
                  {loading ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Kaydediliyor...
                    </>
                  ) : (
                    <>
                      <Save className="mr-2 h-4 w-4" />
                      İşlemi Kaydet
                    </>
                  )}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  )
}