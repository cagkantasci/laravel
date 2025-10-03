'use client'

import { useEffect, useState } from 'react'
import AdminLayout from '@/components/layout/admin-layout'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Label } from '@/components/ui/label'
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Search, Clock, CheckCircle, XCircle, AlertTriangle, Eye, Calendar, User, ClipboardList } from 'lucide-react'

interface PendingControl {
  id: number
  machine_name: string
  operator_name: string
  control_list_title: string
  submitted_at: string
  status: 'pending' | 'approved' | 'rejected'
  total_items: number
  passed_items: number
  failed_items: number
}

export default function ApprovalsPage() {
  const [controls, setControls] = useState<PendingControl[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('pending')

  useEffect(() => {
    setControls([
      { id: 1, machine_name: 'CNC-001', operator_name: 'Mehmet Kaya', control_list_title: 'Günlük Kontrol', submitted_at: '2025-09-30T08:15:00Z', status: 'pending', total_items: 8, passed_items: 7, failed_items: 1 },
      { id: 2, machine_name: 'CNC-002', operator_name: 'Ayşe Özkan', control_list_title: 'Haftalık Bakım', submitted_at: '2025-09-30T07:45:00Z', status: 'pending', total_items: 5, passed_items: 5, failed_items: 0 }
    ])
    setLoading(false)
  }, [])

  const filteredControls = controls.filter(c => 
    (c.machine_name.toLowerCase().includes(searchTerm.toLowerCase()) || c.operator_name.toLowerCase().includes(searchTerm.toLowerCase())) &&
    (statusFilter === 'all' || c.status === statusFilter)
  )

  const handleApprove = (id: number) => {
    setControls(prev => prev.map(c => c.id === id ? { ...c, status: 'approved' } : c))
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><div className="text-lg">Yükleniyor...</div></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div><h1 className="text-2xl font-bold">Kontrol Listesi Onayları</h1><p className="text-gray-600">Operatörler tarafından gönderilen kontrol listelerini inceleyin</p></div>
        <div className="grid grid-cols-4 gap-6">
          <Card><CardContent className="pt-6"><div className="flex items-center space-x-2"><Clock className="h-8 w-8 text-yellow-600" /><div><p className="text-2xl font-bold">{controls.filter(c => c.status === 'pending').length}</p><p className="text-sm text-gray-600">Bekleyen</p></div></div></CardContent></Card>
          <Card><CardContent className="pt-6"><div className="flex items-center space-x-2"><CheckCircle className="h-8 w-8 text-green-600" /><div><p className="text-2xl font-bold">{controls.filter(c => c.status === 'approved').length}</p><p className="text-sm text-gray-600">Onaylanan</p></div></div></CardContent></Card>
          <Card><CardContent className="pt-6"><div className="flex items-center space-x-2"><XCircle className="h-8 w-8 text-red-600" /><div><p className="text-2xl font-bold">{controls.filter(c => c.status === 'rejected').length}</p><p className="text-sm text-gray-600">Reddedilen</p></div></div></CardContent></Card>
          <Card><CardContent className="pt-6"><div className="flex items-center space-x-2"><AlertTriangle className="h-8 w-8 text-orange-600" /><div><p className="text-2xl font-bold">0</p><p className="text-sm text-gray-600">Acil</p></div></div></CardContent></Card>
        </div>
        <Card><CardContent className="pt-6"><div className="flex gap-4"><div className="flex-1 relative"><Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" /><Input placeholder="Makine veya operatör ile ara..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="pl-10" /></div><select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="border rounded-md px-3 py-2"><option value="all">Tüm</option><option value="pending">Bekleyen</option><option value="approved">Onaylanan</option><option value="rejected">Reddedilen</option></select></div></CardContent></Card>
        <div className="space-y-4">
          {filteredControls.map((control) => (
            <Card key={control.id}><CardContent className="p-6"><div className="flex justify-between"><div className="flex-1"><div className="flex items-center gap-2 mb-2"><h3 className="font-semibold text-lg">{control.machine_name}</h3><Badge className={control.status === 'pending' ? 'bg-yellow-100 text-yellow-800' : 'bg-green-100 text-green-800'}>{control.status === 'pending' ? 'Bekliyor' : 'Onaylandı'}</Badge></div><p className="text-sm text-gray-600 mb-3">{control.control_list_title}</p><div className="grid grid-cols-3 gap-4"><div><p className="text-xs text-gray-500">Operatör</p><p className="text-sm font-medium">{control.operator_name}</p></div><div><p className="text-xs text-gray-500">Tarih</p><p className="text-sm font-medium">{new Date(control.submitted_at).toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })}</p></div><div><p className="text-xs text-gray-500">Sonuç</p><p className="text-sm font-medium"><span className="text-green-600">{control.passed_items}</span> / <span className="text-red-600">{control.failed_items}</span></p></div></div></div>{control.status === 'pending' && <div className="flex gap-2"><Button size="sm" variant="outline" className="text-red-600" onClick={() => setControls(prev => prev.map(c => c.id === control.id ? { ...c, status: 'rejected' } : c))}>Reddet</Button><Button size="sm" className="bg-green-600" onClick={() => handleApprove(control.id)}>Onayla</Button></div>}</div></CardContent></Card>
          ))}
        </div>
      </div>
    </AdminLayout>
  )
}
