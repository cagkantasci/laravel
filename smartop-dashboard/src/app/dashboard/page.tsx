'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { apiClient } from '@/lib/api'
import {
  Users,
  Cog,
  ClipboardList,
  AlertTriangle,
  CheckCircle,
  Clock,
  Activity
} from 'lucide-react'

export default function DashboardPage() {
  const router = useRouter()
  const [stats, setStats] = useState<any>(null)
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

        // Operator dashboard'a erişemez
        if (role === 'operator') {
          router.push('/machines')
          return
        }
      }
    }

    const fetchStats = async () => {
      try {
        const response = await apiClient.getDashboardStats()
        setStats(response.data || response)
      } catch (error) {
        console.error('Dashboard stats error:', error)
        // Set empty stats if API fails
        setStats({
          total_hours: 0,
          active_users: 0,
          total_users: 0,
          active_machines: 0,
          maintenance_machines: 0,
          total_machines: 0,
          pending_control_lists: 0,
          total_control_lists: 0,
          recent_activities: []
        })
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [router])

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
      <div className="space-y-6">
        {/* Operational Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Toplam Saat</CardTitle>
              <Clock className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats?.total_hours || 0}</div>
              <p className="text-xs text-muted-foreground">
                Bu ayki toplam çalışma
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Aktif Kullanıcı</CardTitle>
              <Users className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats?.active_users || 0}</div>
              <p className="text-xs text-muted-foreground">
                Toplam {stats?.total_users || 0} kullanıcıdan
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Aktif Makine</CardTitle>
              <Cog className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats?.active_machines || 0}</div>
              <p className="text-xs text-muted-foreground">
                {stats?.maintenance_machines || 0} bakımda, {stats?.total_machines || 0} toplam
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Bekleyen Onay</CardTitle>
              <ClipboardList className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats?.pending_control_lists || 0}</div>
              <p className="text-xs text-muted-foreground">
                Toplam {stats?.total_control_lists || 0} kontrolden
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Recent Activities - Full width */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Activity className="h-5 w-5" />
              Son Aktiviteler
            </CardTitle>
            <CardDescription>
              Sistemdeki son işlemler ve değişiklikler
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {stats?.recent_activities?.length ? (
                stats.recent_activities.slice(0, 5).map((activity: any, index: number) => (
                  <div key={index} className="flex items-center space-x-4">
                    <div className="flex-shrink-0">
                      {activity.type === 'success' ? (
                        <CheckCircle className="h-5 w-5 text-green-500" />
                      ) : activity.type === 'warning' ? (
                        <AlertTriangle className="h-5 w-5 text-yellow-500" />
                      ) : (
                        <Clock className="h-5 w-5 text-blue-500" />
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900">
                        {activity.message}
                      </p>
                      <p className="text-sm text-gray-500">
                        {activity.user} • {new Date(activity.created_at).toLocaleString('tr-TR')}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-gray-500">Henüz aktivite bulunmuyor.</p>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  )
}