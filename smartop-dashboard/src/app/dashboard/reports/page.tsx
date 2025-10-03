'use client'

import { useState } from 'react'
import AuthWrapper from '@/components/auth/auth-wrapper'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  BarChart3,
  Download,
  Calendar,
  Filter,
  TrendingUp,
  TrendingDown,
  FileText,
  PieChart,
  Activity
} from 'lucide-react'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, PieChart as RechartsPieChart, Pie, Cell } from 'recharts'

// Mock data for reports
const monthlyPerformance = [
  { month: 'Oca', controls: 120, approved: 115, rejected: 5, completion: 95.8 },
  { month: 'Şub', controls: 135, approved: 130, rejected: 5, completion: 96.3 },
  { month: 'Mar', controls: 150, approved: 142, rejected: 8, completion: 94.7 },
  { month: 'Nis', controls: 165, approved: 158, rejected: 7, completion: 95.8 },
  { month: 'May', controls: 180, approved: 172, rejected: 8, completion: 95.6 },
  { month: 'Haz', controls: 195, approved: 186, rejected: 9, completion: 95.4 }
]

const machineTypePerformance = [
  { type: 'Ekskavatör', count: 45, success_rate: 96.2 },
  { type: 'Buldozer', count: 32, success_rate: 94.8 },
  { type: 'Kamyon', count: 28, success_rate: 97.1 },
  { type: 'Forklift', count: 15, success_rate: 92.3 }
]

const companyPerformance = [
  { name: 'A Şirketi', value: 35, color: '#3B82F6' },
  { name: 'B Şirketi', value: 25, color: '#10B981' },
  { name: 'C Şirketi', value: 20, color: '#F59E0B' },
  { name: 'D Şirketi', value: 15, color: '#EF4444' },
  { name: 'Diğer', value: 5, color: '#6B7280' }
]

const dailyActivity = [
  { day: 'Pzt', controls: 28, issues: 2 },
  { day: 'Sal', controls: 32, issues: 1 },
  { day: 'Çar', controls: 30, issues: 3 },
  { day: 'Per', controls: 35, issues: 2 },
  { day: 'Cum', controls: 33, issues: 1 },
  { day: 'Cmt', controls: 12, issues: 0 },
  { day: 'Paz', controls: 8, issues: 1 }
]

export default function ReportsPage() {
  const [dateRange, setDateRange] = useState('last_30_days')
  const [reportType, setReportType] = useState('overview')

  const totalControls = monthlyPerformance.reduce((sum, month) => sum + month.controls, 0)
  const totalApproved = monthlyPerformance.reduce((sum, month) => sum + month.approved, 0)
  const totalRejected = monthlyPerformance.reduce((sum, month) => sum + month.rejected, 0)
  const averageCompletion = monthlyPerformance.reduce((sum, month) => sum + month.completion, 0) / monthlyPerformance.length

  return (
    <AuthWrapper>
      <div className="space-y-6">
        {/* Page Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-slate-900 flex items-center">
              <BarChart3 className="h-8 w-8 mr-3 text-blue-600" />
              Raporlar & Analytics
            </h1>
            <p className="text-slate-600">Detaylı sistem raporları ve performans analizi</p>
          </div>
          <div className="flex space-x-2">
            <Button variant="outline">
              <Calendar className="h-4 w-4 mr-2" />
              Tarih Seç
            </Button>
            <Button className="bg-blue-600 hover:bg-blue-700">
              <Download className="h-4 w-4 mr-2" />
              Rapor İndir
            </Button>
          </div>
        </div>

        {/* Filters */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col sm:flex-row gap-4">
              <div className="flex-1">
                <Label htmlFor="date-range">Tarih Aralığı</Label>
                <select
                  id="date-range"
                  value={dateRange}
                  onChange={(e) => setDateRange(e.target.value)}
                  className="w-full h-10 px-3 py-2 text-sm border border-input bg-background rounded-md focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                >
                  <option value="last_7_days">Son 7 Gün</option>
                  <option value="last_30_days">Son 30 Gün</option>
                  <option value="last_3_months">Son 3 Ay</option>
                  <option value="last_6_months">Son 6 Ay</option>
                  <option value="last_year">Son 1 Yıl</option>
                  <option value="custom">Özel Tarih</option>
                </select>
              </div>
              <div className="flex-1">
                <Label htmlFor="report-type">Rapor Türü</Label>
                <select
                  id="report-type"
                  value={reportType}
                  onChange={(e) => setReportType(e.target.value)}
                  className="w-full h-10 px-3 py-2 text-sm border border-input bg-background rounded-md focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                >
                  <option value="overview">Genel Bakış</option>
                  <option value="performance">Performans</option>
                  <option value="machines">Makine Bazlı</option>
                  <option value="operators">Operatör Bazlı</option>
                  <option value="companies">Şirket Bazlı</option>
                </select>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Key Metrics */}
        <div className="grid gap-6 md:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">
                Toplam Kontrol
              </CardTitle>
              <FileText className="h-4 w-4 text-blue-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{totalControls}</div>
              <p className="text-xs text-green-600 flex items-center mt-1">
                <TrendingUp className="h-3 w-3 mr-1" />
                %12 artış
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">
                Onaylanan
              </CardTitle>
              <Activity className="h-4 w-4 text-green-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{totalApproved}</div>
              <p className="text-xs text-green-600 flex items-center mt-1">
                <TrendingUp className="h-3 w-3 mr-1" />
                %8 artış
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">
                Reddedilen
              </CardTitle>
              <Activity className="h-4 w-4 text-red-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{totalRejected}</div>
              <p className="text-xs text-red-600 flex items-center mt-1">
                <TrendingDown className="h-3 w-3 mr-1" />
                %3 azalış
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">
                Başarı Oranı
              </CardTitle>
              <PieChart className="h-4 w-4 text-purple-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{averageCompletion.toFixed(1)}%</div>
              <p className="text-xs text-green-600 flex items-center mt-1">
                <TrendingUp className="h-3 w-3 mr-1" />
                %2 artış
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Charts Section */}
        <div className="grid gap-6 lg:grid-cols-2">
          {/* Monthly Performance */}
          <Card className="col-span-1">
            <CardHeader>
              <CardTitle>Aylık Performans Trendi</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={monthlyPerformance}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="approved" fill="#10B981" name="Onaylanan" />
                  <Bar dataKey="rejected" fill="#EF4444" name="Reddedilen" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Company Distribution */}
          <Card className="col-span-1">
            <CardHeader>
              <CardTitle>Şirket Dağılımı</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <RechartsPieChart>
                  <Pie
                    data={companyPerformance}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name} %${(percent * 100).toFixed(0)}`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {companyPerformance.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </RechartsPieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>

        {/* Detailed Tables */}
        <div className="grid gap-6 lg:grid-cols-2">
          {/* Machine Type Performance */}
          <Card>
            <CardHeader>
              <CardTitle>Makine Tipi Performansı</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {machineTypePerformance.map((machine, index) => (
                  <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div>
                      <div className="font-medium text-slate-900">{machine.type}</div>
                      <div className="text-sm text-slate-600">{machine.count} kontrol</div>
                    </div>
                    <div className="text-right">
                      <div className="font-medium text-slate-900">{machine.success_rate}%</div>
                      <div className="text-sm text-slate-600">başarı oranı</div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Daily Activity */}
          <Card>
            <CardHeader>
              <CardTitle>Haftalık Aktivite</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={200}>
                <LineChart data={dailyActivity}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="day" />
                  <YAxis />
                  <Tooltip />
                  <Line type="monotone" dataKey="controls" stroke="#3B82F6" name="Kontroller" />
                  <Line type="monotone" dataKey="issues" stroke="#EF4444" name="Sorunlar" />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>

        {/* Export Options */}
        <Card>
          <CardHeader>
            <CardTitle>Rapor İndirme Seçenekleri</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-3">
              <Button variant="outline" className="h-auto p-4 flex flex-col items-center space-y-2">
                <FileText className="h-8 w-8 text-blue-600" />
                <div className="text-center">
                  <div className="font-medium">PDF Raporu</div>
                  <div className="text-sm text-slate-600">Detaylı analiz raporu</div>
                </div>
              </Button>

              <Button variant="outline" className="h-auto p-4 flex flex-col items-center space-y-2">
                <BarChart3 className="h-8 w-8 text-green-600" />
                <div className="text-center">
                  <div className="font-medium">Excel Raporu</div>
                  <div className="text-sm text-slate-600">Ham veri ve tablolar</div>
                </div>
              </Button>

              <Button variant="outline" className="h-auto p-4 flex flex-col items-center space-y-2">
                <PieChart className="h-8 w-8 text-purple-600" />
                <div className="text-center">
                  <div className="font-medium">Dashboard</div>
                  <div className="text-sm text-slate-600">İnteraktif görselleştirme</div>
                </div>
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </AuthWrapper>
  )
}