import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/scan_history_service.dart';
import '../../data/models/scan_history_item.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScanHistoryService _historyService = ScanHistoryService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarama Geçmişi'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearHistoryDialog();
                  break;
                case 'export':
                  _exportHistory();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Dışa Aktar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Geçmişi Temizle',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Tümü (${_historyService.totalScans})',
              icon: const Icon(Icons.list, size: 16),
            ),
            Tab(
              text: 'Başarılı (${_historyService.successfulScans})',
              icon: const Icon(Icons.check_circle, size: 16),
            ),
            Tab(
              text: 'Başarısız (${_historyService.failedScans})',
              icon: const Icon(Icons.error, size: 16),
            ),
            Tab(
              text: 'İstatistikler',
              icon: const Icon(Icons.analytics, size: 16),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllHistory(),
          _buildSuccessfulHistory(),
          _buildFailedHistory(),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildAllHistory() {
    return StreamBuilder<List<ScanHistoryItem>>(
      stream: _historyService.historyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = snapshot.data!;

        if (history.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return _buildHistoryCard(item);
          },
        );
      },
    );
  }

  Widget _buildSuccessfulHistory() {
    return StreamBuilder<List<ScanHistoryItem>>(
      stream: _historyService.historyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final successfulScans = _historyService.getSuccessfulScans();

        if (successfulScans.isEmpty) {
          return _buildEmptyState(message: 'Başarılı tarama bulunamadı');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: successfulScans.length,
          itemBuilder: (context, index) {
            final item = successfulScans[index];
            return _buildHistoryCard(item);
          },
        );
      },
    );
  }

  Widget _buildFailedHistory() {
    return StreamBuilder<List<ScanHistoryItem>>(
      stream: _historyService.historyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final failedScans = _historyService.getFailedScans();

        if (failedScans.isEmpty) {
          return _buildEmptyState(message: 'Başarısız tarama bulunamadı');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: failedScans.length,
          itemBuilder: (context, index) {
            final item = failedScans[index];
            return _buildHistoryCard(item);
          },
        );
      },
    );
  }

  Widget _buildStatistics() {
    return StreamBuilder<List<ScanHistoryItem>>(
      stream: _historyService.historyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                'Toplam Tarama',
                _historyService.totalScans.toString(),
                Icons.qr_code_scanner,
                const Color(AppColors.primaryBlue),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                'Başarılı Tarama',
                _historyService.successfulScans.toString(),
                Icons.check_circle,
                const Color(AppColors.successGreen),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                'Başarısız Tarama',
                _historyService.failedScans.toString(),
                Icons.error,
                const Color(AppColors.errorRed),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                'Başarı Oranı',
                '${_historyService.successRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                const Color(AppColors.warningOrange),
              ),
              const SizedBox(height: 20),

              // Kod Türü Dağılımı
              _buildCodeTypeDistribution(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(ScanHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.isSuccessful
                          ? const Color(AppColors.successGreen).withOpacity(0.1)
                          : const Color(AppColors.errorRed).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.isSuccessful ? Icons.check_circle : Icons.error,
                      color: item.isSuccessful
                          ? const Color(AppColors.successGreen)
                          : const Color(AppColors.errorRed),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.scannedCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getCodeTypeColor(
                                  item.codeType,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.codeType,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getCodeTypeColor(item.codeType),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.formattedScanTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteHistoryItem(item),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.result,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({String message = 'Henüz tarama geçmişi yok'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'QR kod taramaya başlayın',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeTypeDistribution() {
    final scansByType = _historyService.scansByType;

    if (scansByType.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kod Türü Dağılımı',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...scansByType.entries.map(
          (entry) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCodeTypeColor(entry.key),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getCodeTypeColor(String codeType) {
    switch (codeType.toLowerCase()) {
      case 'machine':
        return const Color(AppColors.primaryBlue);
      case 'control':
        return const Color(AppColors.successGreen);
      case 'maintenance':
        return const Color(AppColors.warningOrange);
      case 'url':
        return const Color(AppColors.infoBlue);
      default:
        return const Color(AppColors.grey500);
    }
  }

  void _showItemDetails(ScanHistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tarama Detayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Kod', item.scannedCode),
            _buildDetailRow('Tür', item.codeType),
            _buildDetailRow('Sonuç', item.result),
            _buildDetailRow(
              'Durum',
              item.isSuccessful ? 'Başarılı' : 'Başarısız',
            ),
            _buildDetailRow('Zaman', item.formattedScanTime),
            if (item.metadata?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              const Text(
                'Ek Bilgiler:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...item.metadata!.entries.map(
                (entry) => _buildDetailRow(entry.key, entry.value.toString()),
              ),
            ],
          ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteHistoryItem(ScanHistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geçmişten Sil'),
        content: const Text(
          'Bu tarama kaydını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _historyService.removeScanItem(item.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.errorRed),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geçmişi Temizle'),
        content: const Text(
          'Tüm tarama geçmişini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _historyService.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarama geçmişi temizlendi')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.errorRed),
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geçmiş dışa aktarma özelliği geliştiriliyor'),
        backgroundColor: Color(AppColors.primaryBlue),
      ),
    );
  }
}
