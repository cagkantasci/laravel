import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/work_session.dart';
import '../../data/services/work_session_service.dart';

class WorkSessionsHistoryPage extends StatefulWidget {
  const WorkSessionsHistoryPage({super.key});

  @override
  State<WorkSessionsHistoryPage> createState() => _WorkSessionsHistoryPageState();
}

class _WorkSessionsHistoryPageState extends State<WorkSessionsHistoryPage> {
  final WorkSessionService _workSessionService = WorkSessionService();
  List<WorkSession> _sessions = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessions = await _workSessionService.getMySessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<WorkSession> get _filteredSessions {
    if (_filterStatus == 'all') {
      return _sessions;
    }
    return _sessions.where((s) => s.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Geçmişi'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Tümü'),
              ),
              const PopupMenuItem(
                value: 'in_progress',
                child: Text('Devam Eden'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Tamamlanan'),
              ),
              const PopupMenuItem(
                value: 'approved',
                child: Text('Onaylanan'),
              ),
              const PopupMenuItem(
                value: 'rejected',
                child: Text('Reddedilen'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredSessions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredSessions.length,
                    itemBuilder: (context, index) {
                      return _buildSessionCard(_filteredSessions[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Çalışma kaydı bulunamadı',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterStatus == 'all'
                ? 'Henüz bir çalışma başlatmadınız'
                : 'Bu statüde çalışma bulunamadı',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(WorkSession session) {
    final statusColor = _getStatusColor(session.status);
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime)
        : DateTime.now().difference(session.startTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      child: InkWell(
        onTap: () => _showSessionDetail(session),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.precision_manufacturing,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            session.machine?.name ?? 'Makine',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      session.statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Time Information
              Row(
                children: [
                  const Icon(Icons.play_arrow, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Başlangıç',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(session.startTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (session.endTime != null) ...[
                    const Icon(Icons.stop, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bitiş',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm').format(session.endTime!),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Duration
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Süre: ${_formatDuration(duration)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Location
              if (session.location != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.location!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],

              // Approval Info
              if (session.isApproved || session.isRejected) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: session.isApproved
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        session.isApproved ? Icons.check_circle : Icons.cancel,
                        color: session.isApproved ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.isApproved
                              ? 'Yönetici tarafından onaylandı'
                              : 'Yönetici tarafından reddedildi',
                          style: TextStyle(
                            fontSize: 12,
                            color: session.isApproved ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours saat $minutes dakika';
  }

  void _showSessionDetail(WorkSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.machine?.name ?? 'Çalışma Detayı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Durum', session.statusText),
              _buildDetailRow(
                'Başlangıç',
                DateFormat('dd.MM.yyyy HH:mm').format(session.startTime),
              ),
              if (session.endTime != null)
                _buildDetailRow(
                  'Bitiş',
                  DateFormat('dd.MM.yyyy HH:mm').format(session.endTime!),
                ),
              if (session.durationMinutes != null)
                _buildDetailRow('Süre', session.durationFormatted),
              if (session.location != null)
                _buildDetailRow('Lokasyon', session.location!),
              if (session.startNotes != null && session.startNotes!.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Başlangıç Notları:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(session.startNotes!),
              ],
              if (session.endNotes != null && session.endNotes!.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Bitiş Notları:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(session.endNotes!),
              ],
              if (session.approvalNotes != null && session.approvalNotes!.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Onay Notları:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(session.approvalNotes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
