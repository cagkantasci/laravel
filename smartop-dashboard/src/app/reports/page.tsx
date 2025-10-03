'use client'

import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { apiClient } from '@/lib/api'
import {
  FileText,
  Download,
  Calendar,
  TrendingUp,
  BarChart3,
  PieChart,
  Filter,
  Search,
  FileSpreadsheet,
  FileBarChart
} from 'lucide-react'

interface ReportStats {
  total_machines: number
  completed_controls: number
  active_users: number
  maintenance_count: number
  total_work_sessions: number
  average_session_duration: number
}

export default function ReportsPage() {
  const [loading, setLoading] = useState(false)
  const [stats, setStats] = useState<ReportStats | null>(null)
  const [dateRange, setDateRange] = useState({
    start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    end: new Date().toISOString().split('T')[0]
  })

  useEffect(() => {
    fetchStats()
  }, [dateRange])

  const fetchStats = async () => {
    try {
      const response = await fetch(`http://127.0.0.1:8001/api/dashboard/statistics?start_date=${dateRange.start}&end_date=${dateRange.end}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Accept': 'application/json',
        },
      })

      if (response.ok) {
        const data = await response.json()
        setStats(data.data)
      }
    } catch (error) {
      console.error('Stats fetch error:', error)
    }
  }

  const reportTypes = [
    {
      id: 'machine-performance',
      title: 'Makine Performans Raporu',
      description: 'Makinelerin çalışma süreleri, arıza oranları ve verimlilik analizi',
      icon: BarChart3,
      color: 'bg-blue-100 text-blue-600'
    },
    {
      id: 'control-lists',
      title: 'Kontrol Listesi Raporu',
      description: 'Tamamlanan, bekleyen ve onaylanmış kontrol listeleri özeti',
      icon: FileBarChart,
      color: 'bg-green-100 text-green-600'
    },
    {
      id: 'user-activity',
      title: 'Kullanıcı Aktivite Raporu',
      description: 'Kullanıcıların sistem kullanımı ve performans metrikleri',
      icon: TrendingUp,
      color: 'bg-purple-100 text-purple-600'
    },
    {
      id: 'maintenance',
      title: 'Bakım Raporu',
      description: 'Planlı ve acil bakım işlemleri, maliyet analizi',
      icon: FileText,
      color: 'bg-orange-100 text-orange-600'
    }
  ]

  const handleGenerateReport = async (reportType: string, format: 'pdf' | 'excel') => {
    setLoading(true)
    try {
      // API call to generate report
      const response = await apiClient.generateReport({
        type: reportType,
        format,
        start_date: dateRange.start,
        end_date: dateRange.end
      })

      // Download the report
      if (response.data?.download_url) {
        window.open(response.data.download_url, '_blank')
      } else {
        alert('Rapor oluşturuldu ve indirilmeye hazır!')
      }
    } catch (error: any) {
      console.error('Report generation error:', error)
      alert('Rapor oluşturulurken hata oluştu: ' + (error.response?.data?.message || error.message))
    } finally {
      setLoading(false)
    }
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Raporlama</h1>
            <p className="text-gray-600">Sistem performansı ve operasyonel raporlar</p>
          </div>
        </div>

        {/* Date Range Selector */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Calendar className="h-5 w-5" />
              Tarih Aralığı
            </CardTitle>
            <CardDescription>Rapor oluşturmak için tarih aralığı seçin</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="start_date">Başlangıç Tarihi</Label>
                <Input
                  id="start_date"
                  type="date"
                  value={dateRange.start}
                  onChange={(e) => setDateRange({ ...dateRange, start: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="end_date">Bitiş Tarihi</Label>
                <Input
                  id="end_date"
                  type="date"
                  value={dateRange.end}
                  onChange={(e) => setDateRange({ ...dateRange, end: e.target.value })}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Report Types */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {reportTypes.map((report) => {
            const Icon = report.icon
            return (
              <Card key={report.id} className="hover:shadow-lg transition-shadow">
                <CardHeader>
                  <div className="flex items-center gap-3">
                    <div className={`p-3 rounded-lg ${report.color}`}>
                      <Icon className="h-6 w-6" />
                    </div>
                    <div>
                      <CardTitle>{report.title}</CardTitle>
                      <CardDescription className="mt-1">{report.description}</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="flex gap-3">
                    <Button
                      onClick={() => handleGenerateReport(report.id, 'pdf')}
                      disabled={loading}
                      className="flex-1"
                      variant="outline"
                    >
                      <Download className="h-4 w-4 mr-2" />
                      PDF İndir
                    </Button>
                    <Button
                      onClick={() => handleGenerateReport(report.id, 'excel')}
                      disabled={loading}
                      className="flex-1"
                      variant="outline"
                    >
                      <FileSpreadsheet className="h-4 w-4 mr-2" />
                      Excel İndir
                    </Button>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>

        {/* Quick Stats */}
        <Card>
          <CardHeader>
            <CardTitle>Rapor Özeti</CardTitle>
            <CardDescription>Seçili tarih aralığı için hızlı istatistikler</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
              <div className="text-center p-4 bg-blue-50 rounded-lg">
                <p className="text-2xl font-bold text-blue-600">
                  {stats?.total_machines || 0}
                </p>
                <p className="text-sm text-gray-600">Toplam Makine</p>
              </div>
              <div className="text-center p-4 bg-green-50 rounded-lg">
                <p className="text-2xl font-bold text-green-600">
                  {stats?.completed_controls || 0}
                </p>
                <p className="text-sm text-gray-600">Tamamlanan Kontrol</p>
              </div>
              <div className="text-center p-4 bg-purple-50 rounded-lg">
                <p className="text-2xl font-bold text-purple-600">
                  {stats?.active_users || 0}
                </p>
                <p className="text-sm text-gray-600">Aktif Kullanıcı</p>
              </div>
              <div className="text-center p-4 bg-orange-50 rounded-lg">
                <p className="text-2xl font-bold text-orange-600">
                  {stats?.maintenance_count || 0}
                </p>
                <p className="text-sm text-gray-600">Bakım İşlemi</p>
              </div>
              <div className="text-center p-4 bg-indigo-50 rounded-lg">
                <p className="text-2xl font-bold text-indigo-600">
                  {stats?.total_work_sessions || 0}
                </p>
                <p className="text-sm text-gray-600">Çalışma Seansı</p>
              </div>
              <div className="text-center p-4 bg-pink-50 rounded-lg">
                <p className="text-2xl font-bold text-pink-600">
                  {stats?.average_session_duration || 0}h
                </p>
                <p className="text-sm text-gray-600">Ort. Süre</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  )
}
