import 'package:flutter/material.dart';
import '../../../../core/services/offline_service.dart';

class OfflineStatusWidget extends StatefulWidget {
  const OfflineStatusWidget({super.key});

  @override
  State<OfflineStatusWidget> createState() => _OfflineStatusWidgetState();
}

class _OfflineStatusWidgetState extends State<OfflineStatusWidget> {
  final OfflineService _offlineService = OfflineService();
  Map<String, dynamic>? _offlineStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfflineStatus();
  }

  Future<void> _loadOfflineStatus() async {
    try {
      final status = await _offlineService.getOfflineStatus();
      setState(() {
        _offlineStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Bağlantı durumu kontrol ediliyor...'),
            ],
          ),
        ),
      );
    }

    if (_offlineStatus == null) {
      return const SizedBox.shrink();
    }

    final isOnline = _offlineStatus!['isOnline'] as bool;
    final pendingCount = _offlineStatus!['pendingSyncCount'] as int;
    final lastSyncTime = _offlineStatus!['lastSyncTime'] as String?;

    return Card(
      color: isOnline ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: isOnline ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isOnline ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const Spacer(),
                if (!isOnline && pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$pendingCount bekliyor',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            if (!isOnline) ...[
              const SizedBox(height: 8),
              Text(
                'İnternet bağlantısı yok. Veriler yerel olarak kaydediliyor.',
                style: TextStyle(fontSize: 12, color: Colors.orange[700]),
              ),
            ],
            if (lastSyncTime != null) ...[
              const SizedBox(height: 8),
              Text(
                'Son senkronizasyon: ${_formatDateTime(DateTime.parse(lastSyncTime))}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (isOnline && pendingCount > 0) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _syncNow,
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Şimdi Senkronize Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  Future<void> _syncNow() async {
    try {
      await _offlineService.syncPendingData();
      await _loadOfflineStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senkronizasyon tamamlandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senkronizasyon hatası'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class OfflineDebugPage extends StatefulWidget {
  const OfflineDebugPage({super.key});

  @override
  State<OfflineDebugPage> createState() => _OfflineDebugPageState();
}

class _OfflineDebugPageState extends State<OfflineDebugPage> {
  final OfflineService _offlineService = OfflineService();
  Map<String, dynamic>? _offlineStatus;
  List<dynamic> _pendingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _offlineService.getOfflineStatus();
      final pending = await _offlineService.getPendingSyncItems();

      setState(() {
        _offlineStatus = status;
        _pendingItems = pending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Debug'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OfflineStatusWidget(),
                  const SizedBox(height: 24),

                  // Debug actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debug İşlemleri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: _addMockPendingData,
                                child: const Text('Mock Veri Ekle'),
                              ),
                              ElevatedButton(
                                onPressed: _loadMockOfflineData,
                                child: const Text('Offline Veri Yükle'),
                              ),
                              ElevatedButton(
                                onPressed: _clearAllData,
                                child: const Text('Tümünü Temizle'),
                              ),
                              ElevatedButton(
                                onPressed: _testSync,
                                child: const Text('Sync Test Et'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pending sync items
                  if (_pendingItems.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bekleyen Senkronizasyon (${_pendingItems.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            ..._pendingItems.map(
                              (item) => Card(
                                color: Colors.orange[50],
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.sync_problem,
                                    color: Colors.orange,
                                  ),
                                  title: Text(item['action'] ?? 'Unknown'),
                                  subtitle: Text(
                                    'ID: ${item['id']}\n'
                                    'Zaman: ${DateTime.parse(item['timestamp']).toString()}',
                                  ),
                                  isThreeLine: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Status info
                  if (_offlineStatus != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Durum Bilgisi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildStatusRow(
                              'Online',
                              _offlineStatus!['isOnline'].toString(),
                            ),
                            _buildStatusRow(
                              'Bekleyen Sync',
                              _offlineStatus!['pendingSyncCount'].toString(),
                            ),
                            _buildStatusRow(
                              'Offline Veri Var',
                              _offlineStatus!['hasOfflineData'].toString(),
                            ),
                            if (_offlineStatus!['lastSyncTime'] != null)
                              _buildStatusRow(
                                'Son Sync',
                                _offlineStatus!['lastSyncTime'].toString(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  Future<void> _addMockPendingData() async {
    await _offlineService.addPendingSync('control_completed', {
      'controlId': 'CL${DateTime.now().millisecondsSinceEpoch}',
      'machineId': 'M001',
      'results': ['OK', 'OK', 'NOK'],
    });

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mock veri eklendi')));
    }
  }

  Future<void> _loadMockOfflineData() async {
    await _offlineService.loadMockOfflineData();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock offline veri yüklendi')),
      );
    }
  }

  Future<void> _clearAllData() async {
    await _offlineService.clearOfflineData();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm offline veri temizlendi')),
      );
    }
  }

  Future<void> _testSync() async {
    try {
      await _offlineService.syncPendingData();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync testi tamamlandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync testi hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
