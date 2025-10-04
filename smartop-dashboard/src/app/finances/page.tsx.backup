'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { apiClient, FinancialTransaction, FinancialSummary } from '@/lib/api'
import {
  TrendingUp,
  TrendingDown,
  DollarSign,
  Activity,
  Plus,
  Calendar,
  Filter,
  Search,
  Download,
  Users,
  Building2,
  Truck,
  CreditCard,
  Target,
  UserCheck,
} from 'lucide-react'
import { Badge } from '@/components/ui/badge'

export default function FinancesPage() {
  const router = useRouter()
  const [summary, setSummary] = useState<FinancialSummary | null>(null)
  const [transactions, setTransactions] = useState<FinancialTransaction[]>([])
  const [loading, setLoading] = useState(true)
  const [userRole, setUserRole] = useState<string>('admin')

  useEffect(() => {
    // Get user role
    if (typeof window !== 'undefined') {
      const userData = localStorage.getItem('user')
      if (userData) {
        const parsedUser = JSON.parse(userData)
        const role = parsedUser.roles?.[0]?.name
        setUserRole(role || 'admin')

        // Only admin and manager can access finances
        if (role === 'operator') {
          router.push('/dashboard')
          return
        }
      }
    }

    fetchAnalyticsData()
  }, [])

  const fetchAnalyticsData = async () => {
    try {
      setLoading(true)
      
      // Try test endpoint first
      const testResponse = await fetch('http://127.0.0.1:8000/api/dashboard/analytics/test')
      if (testResponse.ok) {
        const testData = await testResponse.json()
        setAnalytics(testData.data)
      } else {
        throw new Error('Test endpoint failed')
      }
    } catch (error) {
      console.error('Analytics data error:', error)
    } finally {
      setLoading(false)
    }
  }

  const formatCurrency = (amount: number, currency: string = 'TRY') => {
    return new Intl.NumberFormat('tr-TR', {
      style: 'currency',
      currency: currency,
    }).format(amount)
  }

  const getStatusBadge = (status: string) => {
    const statusConfig = {
      completed: { label: 'Tamamlandı', variant: 'default' as const },
      pending: { label: 'Beklemede', variant: 'secondary' as const },
      cancelled: { label: 'İptal', variant: 'destructive' as const },
    }
    return statusConfig[status as keyof typeof statusConfig] || statusConfig.pending
  }

  const getTypeBadge = (type: string) => {
    return type === 'income' 
      ? { label: 'Gelir', variant: 'default' as const, icon: TrendingUp }
      : { label: 'Gider', variant: 'destructive' as const, icon: TrendingDown }
  }

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center h-96">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
        </div>
      </AdminLayout>
    )
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col space-y-4 md:flex-row md:items-center md:justify-between md:space-y-0">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Finansal Yönetim</h1>
            <p className="text-muted-foreground">
              Gelir ve gider takibi, finansal raporlar ve analizler
            </p>
          </div>
          
          <div className="flex items-center space-x-2">
            <Button variant="outline" size="sm">
              <Download className="mr-2 h-4 w-4" />
              Dışa Aktar
            </Button>
            <Button onClick={() => router.push('/finances/new')} size="sm">
              <Plus className="mr-2 h-4 w-4" />
              Yeni İşlem
            </Button>
          </div>
        </div>

        {/* Financial Summary Cards */}
        {analytics && (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Aylık Gelir</CardTitle>
                <TrendingUp className="h-4 w-4 text-green-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-green-600">
                  {formatCurrency(analytics.financial_summary.current_month_revenue, analytics.financial_summary.currency)}
                </div>
                <p className="text-xs text-muted-foreground">
                  Bu ay {analytics.monthly_trends.trends.revenue_change >= 0 ? '+' : ''}{analytics.monthly_trends.trends.revenue_change}%
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Aylık Tekrar Eden Gelir</CardTitle>
                <DollarSign className="h-4 w-4 text-blue-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-blue-600">
                  {formatCurrency(analytics.financial_summary.monthly_recurring_revenue, analytics.financial_summary.currency)}
                </div>
                <p className="text-xs text-muted-foreground">
                  MRR (Monthly Recurring Revenue)
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Yıllık Projeksiyon</CardTitle>
                <Target className="h-4 w-4 text-purple-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-purple-600">
                  {formatCurrency(analytics.financial_summary.projected_annual_revenue, analytics.financial_summary.currency)}
                </div>
                <p className="text-xs text-muted-foreground">
                  Büyüme: %{analytics.financial_summary.growth_rate}
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Aktif Abonelik</CardTitle>
                <CreditCard className="h-4 w-4 text-orange-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-orange-600">
                  {analytics.system_metrics.active_subscriptions}
                </div>
                <p className="text-xs text-muted-foreground">
                  Yeni müşteri: {analytics.monthly_trends.trends.customers_change >= 0 ? '+' : ''}{analytics.monthly_trends.trends.customers_change}%
                </p>
              </CardContent>
            </Card>
          </div>
        )}

        {/* System Metrics Cards */}
        {analytics && (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Toplam Şirket</CardTitle>
                <Building2 className="h-4 w-4 text-blue-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {analytics.system_metrics.total_companies}
                </div>
                <p className="text-xs text-muted-foreground">
                  Deneme: {analytics.system_metrics.trial_companies}
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Toplam Kullanıcı</CardTitle>
                <Users className="h-4 w-4 text-green-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {analytics.system_metrics.total_users}
                </div>
                <p className="text-xs text-muted-foreground">
                  Tüm platformlarda
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Toplam Makine</CardTitle>
                <Truck className="h-4 w-4 text-purple-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {analytics.system_metrics.total_machines}
                </div>
                <p className="text-xs text-muted-foreground">
                  Tüm şirketlerde
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Churn Oranı</CardTitle>
                <UserCheck className="h-4 w-4 text-red-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-red-600">
                  %{analytics.customer_metrics.churn_rate}
                </div>
                <p className="text-xs text-muted-foreground">
                  Bu ay
                </p>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Subscription Plans Breakdown */}
        {analytics && (
          <div className="grid gap-6 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Plan Dağılımı</CardTitle>
                <CardDescription>
                  Aktif abonelik planları ve gelirleri
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {analytics.subscription_breakdown.map((plan) => (
                    <div key={plan.plan_name} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="flex items-center space-x-3">
                        <div 
                          className="w-4 h-4 rounded-full" 
                          style={{ backgroundColor: plan.color }}
                        ></div>
                        <div>
                          <div className="font-medium">{plan.plan_display_name}</div>
                          <div className="text-sm text-muted-foreground">
                            {plan.subscribers} abone
                          </div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="font-semibold">
                          {formatCurrency(plan.revenue, 'TRY')}
                        </div>
                        <div className="text-sm text-muted-foreground">
                          {formatCurrency(plan.base_price, 'TRY')}/ay
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Müşteri Metrikleri</CardTitle>
                <CardDescription>
                  Müşteri edinimi ve değer analizi
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium">Bu Ay Yeni Müşteri</span>
                    <span className="text-2xl font-bold text-green-600">
                      {analytics.customer_metrics.new_customers_this_month}
                    </span>
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium">Geçen Ay</span>
                    <span className="text-lg font-semibold text-muted-foreground">
                      {analytics.customer_metrics.new_customers_last_month}
                    </span>
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium">Müşteri Yaşam Değeri</span>
                    <span className="text-lg font-semibold">
                      {formatCurrency(analytics.customer_metrics.customer_lifetime_value, 'TRY')}
                    </span>
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium">ARPU</span>
                    <span className="text-lg font-semibold">
                      {formatCurrency(analytics.customer_metrics.average_revenue_per_user, 'TRY')}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Manual Transaction Management */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>Manuel İşlem Yönetimi</CardTitle>
                <CardDescription>
                  Özel finansal işlemler için manuel girişler
                </CardDescription>
              </div>
              <div className="flex space-x-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => router.push('/finances/transactions')}
                >
                  Tüm İşlemleri Görüntüle
                </Button>
                <Button
                  onClick={() => router.push('/finances/new')}
                  size="sm"
                >
                  <Plus className="mr-2 h-4 w-4" />
                  Yeni İşlem
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-center py-8">
              <Activity className="mx-auto h-12 w-12 text-muted-foreground/50" />
              <h3 className="mt-4 text-lg font-semibold">Manuel İşlemler</h3>
              <p className="text-muted-foreground">
                Abonelik gelirleri otomatik hesaplanır. İlave giderler için manuel işlem ekleyebilirsiniz.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  )
}