'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { apiClient, FinancialTransaction } from '@/lib/api'
import {
  TrendingUp,
  TrendingDown,
  Search,
  Filter,
  Download,
  Plus,
  ArrowLeft,
  Calendar,
  DollarSign,
  Edit,
  Trash2,
} from 'lucide-react'
import { Badge } from '@/components/ui/badge'

export default function TransactionsPage() {
  const router = useRouter()
  const [transactions, setTransactions] = useState<FinancialTransaction[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [typeFilter, setTypeFilter] = useState('all')
  const [statusFilter, setStatusFilter] = useState('all')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)

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

    fetchTransactions()
  }, [currentPage, typeFilter, statusFilter, searchTerm])

  const fetchTransactions = async () => {
    try {
      setLoading(true)
      
      const params: any = {
        page: currentPage,
        per_page: 20,
      }
      
      if (typeFilter !== 'all') {
        params.type = typeFilter
      }
      
      if (statusFilter !== 'all') {
        params.status = statusFilter
      }
      
      if (searchTerm) {
        params.search = searchTerm
      }
      
      const response = await apiClient.getFinancialTransactions(params)
      
      setTransactions(response.data.data || [])
      setTotalPages(response.data.last_page || 1)
    } catch (error) {
      console.error('Transactions fetch error:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    setCurrentPage(1)
    fetchTransactions()
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
      ? { label: 'Gelir', variant: 'default' as const, icon: TrendingUp, color: 'text-green-600' }
      : { label: 'Gider', variant: 'destructive' as const, icon: TrendingDown, color: 'text-red-600' }
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
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Button
              variant="outline"
              size="sm"
              onClick={() => router.push('/finances')}
            >
              <ArrowLeft className="mr-2 h-4 w-4" />
              Geri
            </Button>
            <div>
              <h1 className="text-2xl font-bold tracking-tight">Tüm İşlemler</h1>
              <p className="text-muted-foreground">
                Finansal işlem geçmişi ve yönetimi
              </p>
            </div>
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

        {/* Filters */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Filtreler</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSearch} className="flex flex-col space-y-4 md:flex-row md:space-y-0 md:space-x-4">
              <div className="flex-1">
                <Input
                  placeholder="İşlem ara..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full"
                />
              </div>
              
              <Select value={typeFilter} onValueChange={(value: string) => setTypeFilter(value)}>
                <SelectTrigger className="w-full md:w-[180px]">
                  <SelectValue placeholder="Tür" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Tüm Türler</SelectItem>
                  <SelectItem value="income">Gelir</SelectItem>
                  <SelectItem value="expense">Gider</SelectItem>
                </SelectContent>
              </Select>
              
              <Select value={statusFilter} onValueChange={(value: string) => setStatusFilter(value)}>
                <SelectTrigger className="w-full md:w-[180px]">
                  <SelectValue placeholder="Durum" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Tüm Durumlar</SelectItem>
                  <SelectItem value="completed">Tamamlandı</SelectItem>
                  <SelectItem value="pending">Beklemede</SelectItem>
                  <SelectItem value="cancelled">İptal</SelectItem>
                </SelectContent>
              </Select>
              
              <Button type="submit">
                <Search className="mr-2 h-4 w-4" />
                Ara
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Transactions List */}
        <Card>
          <CardHeader>
            <CardTitle>İşlemler ({transactions.length})</CardTitle>
          </CardHeader>
          <CardContent>
            {transactions.length === 0 ? (
              <div className="text-center py-12">
                <DollarSign className="mx-auto h-12 w-12 text-muted-foreground/50" />
                <h3 className="mt-4 text-lg font-semibold">İşlem bulunamadı</h3>
                <p className="text-muted-foreground">
                  Arama kriterlerinizi değiştirmeyi deneyin
                </p>
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
                      className="flex items-center justify-between p-4 border rounded-lg hover:bg-muted/50 transition-colors"
                    >
                      <div className="flex items-center space-x-4">
                        <div className={`p-3 rounded-full ${transaction.type === 'income' ? 'bg-green-100' : 'bg-red-100'}`}>
                          <TypeIcon className={`h-5 w-5 ${typeBadge.color}`} />
                        </div>
                        <div>
                          <div className="font-semibold text-lg">{transaction.title}</div>
                          <div className="text-sm text-muted-foreground">
                            {transaction.category} • {new Date(transaction.transaction_date).toLocaleDateString('tr-TR')}
                          </div>
                          {transaction.description && (
                            <div className="text-sm text-muted-foreground mt-1 max-w-md truncate">
                              {transaction.description}
                            </div>
                          )}
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-6">
                        <div className="text-right">
                          <div className={`font-bold text-xl ${typeBadge.color}`}>
                            {transaction.type === 'income' ? '+' : '-'}{formatCurrency(transaction.amount, transaction.currency)}
                          </div>
                          <Badge variant={statusBadge.variant} className="mt-1">
                            {statusBadge.label}
                          </Badge>
                        </div>
                        
                        <div className="flex items-center space-x-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => router.push(`/finances/transactions/${transaction.uuid}`)}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                        </div>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
              disabled={currentPage === 1}
            >
              Önceki
            </Button>
            
            <span className="text-sm text-muted-foreground">
              Sayfa {currentPage} / {totalPages}
            </span>
            
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
              disabled={currentPage === totalPages}
            >
              Sonraki
            </Button>
          </div>
        )}
      </div>
    </AdminLayout>
  )
}