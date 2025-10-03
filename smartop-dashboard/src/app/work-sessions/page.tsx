'use client';

import { useState, useEffect } from 'react';
import AdminLayout from '@/components/layout/admin-layout';
import { apiClient } from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { CheckCircle2, XCircle, Clock, Calendar, MapPin, FileText, User } from 'lucide-react';

interface WorkSession {
  id: number;
  uuid: string;
  machine: {
    id: number;
    name: string;
    code: string;
  };
  operator: {
    id: number;
    name: string;
    email: string;
  };
  start_time: string;
  end_time: string | null;
  duration_minutes: number | null;
  status: 'in_progress' | 'completed' | 'approved' | 'rejected';
  location: string | null;
  start_notes: string | null;
  end_notes: string | null;
  approved_by: number | null;
  approved_at: string | null;
  approval_notes: string | null;
  created_at: string;
  updated_at: string;
}

export default function WorkSessionsPage() {
  const [sessions, setSessions] = useState<WorkSession[]>([]);
  const [filteredSessions, setFilteredSessions] = useState<WorkSession[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedSession, setSelectedSession] = useState<WorkSession | null>(null);
  const [isApprovalDialogOpen, setIsApprovalDialogOpen] = useState(false);
  const [approvalNotes, setApprovalNotes] = useState('');
  const [activeTab, setActiveTab] = useState('completed');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchWorkSessions();
  }, []);

  useEffect(() => {
    filterSessions();
  }, [sessions, activeTab, searchTerm]);

  const fetchWorkSessions = async () => {
    setIsLoading(true);
    try {
      const response = await apiClient.getWorkSessions();
      // API response'u normalize et - data içinde array olabilir
      const sessionsData = Array.isArray(response)
        ? response
        : Array.isArray(response.data)
        ? response.data
        : [];
      setSessions(sessionsData);
    } catch (error) {
      console.error('Çalışma seansları yüklenirken hata:', error);
      setSessions([]);
    } finally {
      setIsLoading(false);
    }
  };

  const filterSessions = () => {
    let filtered = sessions;

    // Durum filtresi
    if (activeTab !== 'all') {
      filtered = filtered.filter(s => s.status === activeTab);
    }

    // Arama filtresi
    if (searchTerm) {
      const search = searchTerm.toLowerCase();
      filtered = filtered.filter(s =>
        s.machine.name.toLowerCase().includes(search) ||
        s.machine.code.toLowerCase().includes(search) ||
        s.operator.name.toLowerCase().includes(search) ||
        (s.location && s.location.toLowerCase().includes(search))
      );
    }

    setFilteredSessions(filtered);
  };

  const handleApprove = async (sessionId: number) => {
    try {
      await apiClient.approveWorkSession(sessionId.toString(), approvalNotes);
      await fetchWorkSessions();
      setIsApprovalDialogOpen(false);
      setApprovalNotes('');
      setSelectedSession(null);
    } catch (error) {
      console.error('Onay işlemi sırasında hata:', error);
    }
  };

  const handleReject = async (sessionId: number) => {
    if (!approvalNotes.trim()) {
      alert('Lütfen red sebebini belirtiniz');
      return;
    }

    try {
      await apiClient.rejectWorkSession(sessionId.toString(), approvalNotes);
      await fetchWorkSessions();
      setIsApprovalDialogOpen(false);
      setApprovalNotes('');
      setSelectedSession(null);
    } catch (error) {
      console.error('Reddetme işlemi sırasında hata:', error);
    }
  };

  const openApprovalDialog = (session: WorkSession) => {
    setSelectedSession(session);
    setApprovalNotes('');
    setIsApprovalDialogOpen(true);
  };

  const formatDuration = (minutes: number | null) => {
    if (!minutes) return 'N/A';
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours} saat ${mins} dakika`;
  };

  const formatDateTime = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('tr-TR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const getStatusBadge = (status: string) => {
    const statusConfig = {
      in_progress: { label: 'Devam Ediyor', color: 'bg-blue-100 text-blue-800' },
      completed: { label: 'Tamamlandı', color: 'bg-orange-100 text-orange-800' },
      approved: { label: 'Onaylandı', color: 'bg-green-100 text-green-800' },
      rejected: { label: 'Reddedildi', color: 'bg-red-100 text-red-800' },
    };

    const config = statusConfig[status as keyof typeof statusConfig] || statusConfig.completed;
    return <Badge className={config.color}>{config.label}</Badge>;
  };

  return (
    <AdminLayout>
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Çalışma Seansları</h1>
          <p className="text-gray-500 mt-1">Operatör çalışma seanslarını görüntüleyin ve onaylayın</p>
        </div>
        <Button type="button" onClick={fetchWorkSessions}>
          Yenile
        </Button>
      </div>

      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <div>
              <CardTitle>Çalışma Seansları Listesi</CardTitle>
              <CardDescription>Toplam {filteredSessions.length} kayıt</CardDescription>
            </div>
            <div className="w-80">
              <Input
                placeholder="Makine, operatör veya lokasyon ara..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="all">Tümü</TabsTrigger>
              <TabsTrigger value="completed">
                Tamamlanan ({sessions.filter(s => s.status === 'completed').length})
              </TabsTrigger>
              <TabsTrigger value="approved">
                Onaylanan ({sessions.filter(s => s.status === 'approved').length})
              </TabsTrigger>
              <TabsTrigger value="rejected">
                Reddedilen ({sessions.filter(s => s.status === 'rejected').length})
              </TabsTrigger>
            </TabsList>

            <TabsContent value={activeTab} className="mt-6">
              {isLoading ? (
                <div className="text-center py-12">Yükleniyor...</div>
              ) : filteredSessions.length === 0 ? (
                <div className="text-center py-12 text-gray-500">
                  Çalışma seansı bulunamadı
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Makine</TableHead>
                      <TableHead>Operatör</TableHead>
                      <TableHead>Başlangıç</TableHead>
                      <TableHead>Bitiş</TableHead>
                      <TableHead>Süre</TableHead>
                      <TableHead>Lokasyon</TableHead>
                      <TableHead>Durum</TableHead>
                      <TableHead>İşlemler</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredSessions.map((session) => (
                      <TableRow key={session.id}>
                        <TableCell>
                          <div>
                            <div className="font-medium">{session.machine.name}</div>
                            <div className="text-sm text-gray-500">{session.machine.code}</div>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div>
                            <div className="font-medium">{session.operator.name}</div>
                            <div className="text-sm text-gray-500">{session.operator.email}</div>
                          </div>
                        </TableCell>
                        <TableCell>{formatDateTime(session.start_time)}</TableCell>
                        <TableCell>
                          {session.end_time ? formatDateTime(session.end_time) : '-'}
                        </TableCell>
                        <TableCell>{formatDuration(session.duration_minutes)}</TableCell>
                        <TableCell>
                          {session.location ? (
                            <div className="flex items-center gap-1">
                              <MapPin className="w-4 h-4 text-gray-400" />
                              <span className="text-sm">{session.location}</span>
                            </div>
                          ) : (
                            '-'
                          )}
                        </TableCell>
                        <TableCell>{getStatusBadge(session.status)}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button
                              type="button"
                              variant="outline"
                              size="sm"
                              onClick={() => openApprovalDialog(session)}
                            >
                              Detay
                            </Button>
                            {session.status === 'completed' && (
                              <Button
                                type="button"
                                size="sm"
                                className="bg-green-600 hover:bg-green-700"
                                onClick={() => {
                                  setSelectedSession(session);
                                  setApprovalNotes('');
                                  handleApprove(session.id);
                                }}
                              >
                                <CheckCircle2 className="w-4 h-4 mr-1" />
                                Onayla
                              </Button>
                            )}
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {/* Detay ve Onay Dialog */}
      <Dialog open={isApprovalDialogOpen} onOpenChange={setIsApprovalDialogOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>Çalışma Seansı Detayı</DialogTitle>
            <DialogDescription>
              Çalışma seansını inceleyip onaylayabilir veya reddedebilirsiniz
            </DialogDescription>
          </DialogHeader>

          {selectedSession && (
            <div className="space-y-6">
              {/* Makine ve Operatör Bilgileri */}
              <div className="grid grid-cols-2 gap-4">
                <Card>
                  <CardContent className="pt-6">
                    <div className="flex items-center gap-3">
                      <div className="p-3 bg-blue-100 rounded-lg">
                        <Calendar className="w-6 h-6 text-blue-600" />
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Makine</p>
                        <p className="font-semibold">{selectedSession.machine.name}</p>
                        <p className="text-xs text-gray-500">{selectedSession.machine.code}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardContent className="pt-6">
                    <div className="flex items-center gap-3">
                      <div className="p-3 bg-green-100 rounded-lg">
                        <User className="w-6 h-6 text-green-600" />
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Operatör</p>
                        <p className="font-semibold">{selectedSession.operator.name}</p>
                        <p className="text-xs text-gray-500">{selectedSession.operator.email}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>

              {/* Zaman Bilgileri */}
              <Card>
                <CardContent className="pt-6 space-y-3">
                  <div className="flex justify-between">
                    <span className="text-gray-600">Başlangıç:</span>
                    <span className="font-medium">{formatDateTime(selectedSession.start_time)}</span>
                  </div>
                  {selectedSession.end_time && (
                    <div className="flex justify-between">
                      <span className="text-gray-600">Bitiş:</span>
                      <span className="font-medium">{formatDateTime(selectedSession.end_time)}</span>
                    </div>
                  )}
                  <div className="flex justify-between items-center pt-3 border-t">
                    <span className="text-gray-600 flex items-center gap-2">
                      <Clock className="w-4 h-4" />
                      Toplam Süre:
                    </span>
                    <span className="font-bold text-lg text-blue-600">
                      {formatDuration(selectedSession.duration_minutes)}
                    </span>
                  </div>
                  {selectedSession.location && (
                    <div className="flex justify-between pt-2">
                      <span className="text-gray-600 flex items-center gap-2">
                        <MapPin className="w-4 h-4" />
                        Lokasyon:
                      </span>
                      <span className="font-medium">{selectedSession.location}</span>
                    </div>
                  )}
                </CardContent>
              </Card>

              {/* Notlar */}
              {(selectedSession.start_notes || selectedSession.end_notes) && (
                <Card>
                  <CardContent className="pt-6 space-y-3">
                    {selectedSession.start_notes && (
                      <div>
                        <Label className="flex items-center gap-2 mb-2">
                          <FileText className="w-4 h-4" />
                          Başlangıç Notları
                        </Label>
                        <p className="text-sm text-gray-700 bg-gray-50 p-3 rounded">
                          {selectedSession.start_notes}
                        </p>
                      </div>
                    )}
                    {selectedSession.end_notes && (
                      <div>
                        <Label className="flex items-center gap-2 mb-2">
                          <FileText className="w-4 h-4" />
                          Bitiş Notları
                        </Label>
                        <p className="text-sm text-gray-700 bg-gray-50 p-3 rounded">
                          {selectedSession.end_notes}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              )}

              {/* Onay Notları */}
              {selectedSession.status === 'completed' && (
                <div className="space-y-2">
                  <Label htmlFor="approval-notes">
                    Onay/Red Notları {selectedSession.status === 'completed' && '(İsteğe bağlı)'}
                  </Label>
                  <Textarea
                    id="approval-notes"
                    placeholder="Onay veya red sebebinizi yazın..."
                    value={approvalNotes}
                    onChange={(e) => setApprovalNotes(e.target.value)}
                    rows={3}
                  />
                </div>
              )}

              {/* Onay Durum Bilgisi */}
              {(selectedSession.status === 'approved' || selectedSession.status === 'rejected') && (
                <Card className={selectedSession.status === 'approved' ? 'bg-green-50' : 'bg-red-50'}>
                  <CardContent className="pt-6">
                    <div className="space-y-2">
                      <div className="flex items-center gap-2">
                        {selectedSession.status === 'approved' ? (
                          <CheckCircle2 className="w-5 h-5 text-green-600" />
                        ) : (
                          <XCircle className="w-5 h-5 text-red-600" />
                        )}
                        <span className="font-semibold">
                          {selectedSession.status === 'approved' ? 'Onaylandı' : 'Reddedildi'}
                        </span>
                      </div>
                      {selectedSession.approved_at && (
                        <p className="text-sm text-gray-600">
                          Tarih: {formatDateTime(selectedSession.approved_at)}
                        </p>
                      )}
                      {selectedSession.approval_notes && (
                        <div className="mt-3">
                          <Label className="text-sm">Not:</Label>
                          <p className="text-sm mt-1 p-2 bg-white rounded">
                            {selectedSession.approval_notes}
                          </p>
                        </div>
                      )}
                    </div>
                  </CardContent>
                </Card>
              )}

              {/* İşlem Butonları */}
              {selectedSession.status === 'completed' && (
                <div className="flex gap-3 pt-4">
                  <Button
                    type="button"
                    className="flex-1 bg-green-600 hover:bg-green-700"
                    onClick={() => handleApprove(selectedSession.id)}
                  >
                    <CheckCircle2 className="w-4 h-4 mr-2" />
                    Onayla
                  </Button>
                  <Button
                    type="button"
                    variant="destructive"
                    className="flex-1"
                    onClick={() => handleReject(selectedSession.id)}
                  >
                    <XCircle className="w-4 h-4 mr-2" />
                    Reddet
                  </Button>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
    </AdminLayout>
  );
}
