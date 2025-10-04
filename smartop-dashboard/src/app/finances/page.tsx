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
  Download,
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

    fetchFinancialData()
  }, [])

  const fetchFinancialData = async () => {
    try {
      setLoading(true)
      
      // Fetch financial summary
      const summaryResponse = await apiClient.getFinancialSummary({
        start_date: new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0],
        end_date: new Date().toISOString().split('T')[0]
      })
      setSummary(summaryResponse.data)

      // Fetch recent transactions
      const transactionsResponse = await apiClient.getFinancialTransactions({
        per_page: 10,
        page: 1
      })
      setTransactions(transactionsResponse.data.data || [])
    } catch (error) {
      console.error('Financial data error:', error)
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
        {summary && (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Toplam Gelir</CardTitle>
                <TrendingUp className="h-4 w-4 text-green-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-green-600">
                  {formatCurrency(summary.summary.total_income, summary.summary.currency)}
                </div>
                <p className="text-xs text-muted-foreground">
                  Bu ay
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Toplam Gider</CardTitle>
                <TrendingDown className="h-4 w-4 text-red-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-red-600">
                  {formatCurrency(summary.summary.total_expense, summary.summary.currency)}
                </div>
                <p className="text-xs text-muted-foreground">
                  Bu ay
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Net Kar</CardTitle>
                <DollarSign className="h-4 w-4 text-blue-600" />
              </CardHeader>
              <CardContent>
                <div className={`text-2xl font-bold ${summary.summary.net_profit >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                  {formatCurrency(summary.summary.net_profit, summary.summary.currency)}
                </div>
                <p className="text-xs text-muted-foreground">
                  Bu ay
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">İşlem Sayısı</CardTitle>
                <Activity className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {transactions.length}
                </div>
                <p className="text-xs text-muted-foreground">
                  Son 10 işlem
                </p>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Recent Transactions */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>Son İşlemler</CardTitle>
                <CardDescription>
                  En güncel finansal işlemler
                </CardDescription>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={() => router.push('/finances/transactions')}
              >
                Tümünü Görüntüle
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            {transactions.length === 0 ? (
              <div className="text-center py-8">
                <Activity className="mx-auto h-12 w-12 text-muted-foreground/50" />
                <h3 className="mt-4 text-lg font-semibold">Henüz işlem yok</h3>
                <p className="text-muted-foreground">
                  İlk finansal işleminizi ekleyerek başlayın
                </p>
                <Button
                  onClick={() => router.push('/finances/new')}
                  className="mt-4"
                >
                  <Plus className="mr-2 h-4 w-4" />
                  İlk İşlemi Ekle
                </Button>
              </div>
            ) : (
              <div className="space-y-4">
                {transactions.map((transaction) => {
                  const typeBadge = getTypeBadge(transaction.type)
                  const statusBadge = getStatusBadge(transaction.status)
                  const TypeIcon = typeBadge.icon
                  
                  return (
                    <div
                      key={transaction.uuid}
                      className="flex items-center justify-between p-4 border rounded-lg hover:bg-muted/50 cursor-pointer transition-colors"
                      onClick={() => router.push(`/finances/transactions/${transaction.uuid}`)}
                    >
                      <div className="flex items-center space-x-4">
                        <div className={`p-2 rounded-full ${transaction.type === 'income' ? 'bg-green-100' : 'bg-red-100'}`}>
                          <TypeIcon className={`h-4 w-4 ${transaction.type === 'income' ? 'text-green-600' : 'text-red-600'}`} />
                        </div>
                        <div>
                          <div className="font-medium">{transaction.title}</div>
                          <div className="text-sm text-muted-foreground">
                            {transaction.category} • {new Date(transaction.transaction_date).toLocaleDateString('tr-TR')}
                          </div>
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-4">
                        <div className="text-right">
                          <div className={`font-semibold ${transaction.type === 'income' ? 'text-green-600' : 'text-red-600'}`}>
                            {transaction.type === 'income' ? '+' : '-'}{formatCurrency(transaction.amount, transaction.currency)}
                          </div>
                          <Badge variant={statusBadge.variant} className="text-xs">
                            {statusBadge.label}
                          </Badge>
                        </div>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  )
}