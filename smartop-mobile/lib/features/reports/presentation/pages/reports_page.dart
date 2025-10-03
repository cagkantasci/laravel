import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/authorization_service.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      requiredPermission: 'reports',
      unauthorizedTitle: 'Raporlara Erişim Engellendi',
      unauthorizedMessage:
          'Raporları görüntülemek için yönetici veya müdür yetkisine sahip olmalısınız.',
      child: const _ReportsPageContent(),
    );
  }
}

class _ReportsPageContent extends StatefulWidget {
  const _ReportsPageContent();

  @override
  State<_ReportsPageContent> createState() => _ReportsPageContentState();
}

class _ReportsPageContentState extends State<_ReportsPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  String _selectedMachine = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.grey50),
      appBar: AppBar(
        title: const Text('Raporlama'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReports,
            tooltip: 'Rapor İndir',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Performans'),
            Tab(text: 'Bakım'),
            Tab(text: 'Maliyet'),
            Tab(text: 'Kalite'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPerformanceReports(),
          _buildMaintenanceReports(),
          _buildCostReports(),
          _buildQualityReports(),
        ],
      ),
    );
  }

  Widget _buildPerformanceReports() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader('Performans Raporları'),
          const SizedBox(height: 20),

          // Özet kartları
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Ortalama Verimlilik',
                  '87.5%',
                  Icons.trending_up,
                  const Color(AppColors.successGreen),
                  '+2.3% geçen aya göre',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Toplam Üretim',
                  '12,450',
                  Icons.production_quantity_limits,
                  const Color(AppColors.primaryBlue),
                  'parça üretildi',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Çalışma Süresi',
                  '672 sa',
                  Icons.access_time,
                  const Color(AppColors.warningOrange),
                  'Bu ay toplam',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Duruş Süresi',
                  '48 sa',
                  Icons.pause_circle,
                  const Color(AppColors.errorRed),
                  'Plansız duruş',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Performance Charts
          _buildPerformanceCharts(),
          const SizedBox(height: 20),

          // Detaylı rapor listesi
          _buildReportList([
            ReportItem(
              title: 'Makine Performans Analizi',
              description: 'Tüm makinelerin detaylı performans raporu',
              date: DateTime.now().subtract(const Duration(hours: 2)),
              type: 'PDF',
              size: '2.4 MB',
              icon: Icons.analytics,
            ),
            ReportItem(
              title: 'Verimlilik Trend Analizi',
              description: 'Son 6 aylık verimlilik trend raporu',
              date: DateTime.now().subtract(const Duration(days: 1)),
              type: 'Excel',
              size: '1.8 MB',
              icon: Icons.trending_up,
            ),
            ReportItem(
              title: 'Üretim Kapasitesi Raporu',
              description: 'Mevcut ve maksimum kapasite analizi',
              date: DateTime.now().subtract(const Duration(days: 3)),
              type: 'PDF',
              size: '3.2 MB',
              icon: Icons.bar_chart,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildMaintenanceReports() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader('Bakım Raporları'),
          const SizedBox(height: 20),

          // Bakım özet kartları
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Planlı Bakım',
                  '24',
                  Icons.schedule,
                  const Color(AppColors.successGreen),
                  'Bu ay tamamlandı',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Acil Bakım',
                  '3',
                  Icons.warning,
                  const Color(AppColors.errorRed),
                  'Bu ay gerçekleşti',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildReportList([
            ReportItem(
              title: 'Bakım Maliyet Analizi',
              description: 'Bakım giderlerinin detaylı analizi',
              date: DateTime.now().subtract(const Duration(hours: 4)),
              type: 'PDF',
              size: '1.9 MB',
              icon: Icons.build,
            ),
            ReportItem(
              title: 'Parça Değişim Raporu',
              description: 'Değiştirilen parçalar ve maliyetleri',
              date: DateTime.now().subtract(const Duration(days: 2)),
              type: 'Excel',
              size: '2.1 MB',
              icon: Icons.settings,
            ),
            ReportItem(
              title: 'Bakım Takvimi',
              description: 'Gelecek bakım planlaması',
              date: DateTime.now().subtract(const Duration(days: 5)),
              type: 'PDF',
              size: '1.5 MB',
              icon: Icons.calendar_today,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildCostReports() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader('Maliyet Analizi Raporları'),
          const SizedBox(height: 20),

          // Maliyet özet kartları
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Toplam Maliyet',
                  '₺125,450',
                  Icons.monetization_on,
                  const Color(AppColors.errorRed),
                  'Bu ay',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Tasarruf',
                  '₺8,230',
                  Icons.savings,
                  const Color(AppColors.successGreen),
                  'Önceki aya göre',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildReportList([
            ReportItem(
              title: 'Enerji Tüketim Raporu',
              description: 'Makine bazında enerji maliyeti analizi',
              date: DateTime.now().subtract(const Duration(hours: 1)),
              type: 'PDF',
              size: '2.8 MB',
              icon: Icons.electrical_services,
            ),
            ReportItem(
              title: 'İşçilik Maliyet Analizi',
              description: 'Operatör maliyetleri ve verimlilik',
              date: DateTime.now().subtract(const Duration(days: 1)),
              type: 'Excel',
              size: '1.7 MB',
              icon: Icons.people,
            ),
            ReportItem(
              title: 'ROI Analiz Raporu',
              description: 'Yatırım getirisi analizi',
              date: DateTime.now().subtract(const Duration(days: 4)),
              type: 'PDF',
              size: '3.5 MB',
              icon: Icons.trending_up,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildQualityReports() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader('Kalite Kontrol Raporları'),
          const SizedBox(height: 20),

          // Kalite özet kartları
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Kalite Oranı',
                  '98.7%',
                  Icons.verified,
                  const Color(AppColors.successGreen),
                  'Ortalama başarı',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Hatalı Üretim',
                  '156',
                  Icons.error,
                  const Color(AppColors.errorRed),
                  'Bu ay tespit edildi',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildReportList([
            ReportItem(
              title: 'Kalite Kontrol Özeti',
              description: 'Aylık kalite kontrol test sonuçları',
              date: DateTime.now().subtract(const Duration(hours: 3)),
              type: 'PDF',
              size: '2.2 MB',
              icon: Icons.check_circle,
            ),
            ReportItem(
              title: 'Hata Analiz Raporu',
              description: 'Üretim hatalarının detaylı analizi',
              date: DateTime.now().subtract(const Duration(days: 2)),
              type: 'Excel',
              size: '1.9 MB',
              icon: Icons.bug_report,
            ),
            ReportItem(
              title: 'Müşteri Geri Bildirim',
              description: 'Kalite ile ilgili müşteri yorumları',
              date: DateTime.now().subtract(const Duration(days: 6)),
              type: 'PDF',
              size: '1.3 MB',
              icon: Icons.feedback,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildReportHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.grey900),
          ),
        ),
        const Spacer(),
        Text(
          _formatDateRange(_selectedDateRange),
          style: const TextStyle(fontSize: 14, color: Color(AppColors.grey600)),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.grey700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(AppColors.grey500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(List<ReportItem> reports) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Son Raporlar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.grey900),
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportItem(report);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(ReportItem report) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(AppColors.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          report.icon,
          color: const Color(AppColors.primaryBlue),
          size: 24,
        ),
      ),
      title: Text(
        report.title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            report.description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(AppColors.grey600),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatDate(report.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(AppColors.grey500),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getFileTypeColor(report.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  report.type,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getFileTypeColor(report.type),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                report.size,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(AppColors.grey500),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (value) {
          switch (value) {
            case 'download':
              _downloadReport(report);
              break;
            case 'share':
              _shareReport(report);
              break;
            case 'delete':
              _deleteReport(report);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'download',
            child: Row(
              children: [
                Icon(Icons.download, size: 16),
                SizedBox(width: 8),
                Text('İndir'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, size: 16),
                SizedBox(width: 8),
                Text('Paylaş'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('Sil', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(AppColors.errorRed);
      case 'excel':
        return const Color(AppColors.successGreen);
      default:
        return const Color(AppColors.primaryBlue);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor Filtreleri'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tarih Aralığı:'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now(),
                    initialDateRange: _selectedDateRange,
                  );
                  if (dateRange != null) {
                    setState(() {
                      _selectedDateRange = dateRange;
                    });
                  }
                },
                child: Text(_formatDateRange(_selectedDateRange)),
              ),
              const SizedBox(height: 16),
              const Text('Makine:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMachine,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tüm Makineler')),
                  DropdownMenuItem(value: 'cnc001', child: Text('CNC-001')),
                  DropdownMenuItem(value: 'pres002', child: Text('Pres-002')),
                  DropdownMenuItem(value: 'torna003', child: Text('Torna-003')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMachine = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('Filtreler uygulandı');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
              foregroundColor: Colors.white,
            ),
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _exportReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor Dışa Aktar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hangi formatda dışa aktarmak istiyorsunuz?'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _exportAs('PDF');
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.errorRed),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _exportAs('Excel');
                    },
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.successGreen),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _exportAs(String format) {
    _showSnackBar('$format formatında rapor hazırlanıyor...');

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showSnackBar('Rapor başarıyla dışa aktarıldı');
      }
    });
  }

  void _downloadReport(ReportItem report) {
    _showSnackBar('${report.title} indiriliyor...');
  }

  void _shareReport(ReportItem report) {
    _showSnackBar('${report.title} paylaşım seçenekleri açılıyor...');
  }

  void _deleteReport(ReportItem report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raporu Sil'),
        content: Text(
          '${report.title} raporunu silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('Rapor silindi');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.errorRed),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'Tarih seçin';
    return '${_formatDate(range.start).split(' ')[0]} - ${_formatDate(range.end).split(' ')[0]}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(AppColors.primaryBlue),
      ),
    );
  }
}

class ReportItem {
  final String title;
  final String description;
  final DateTime date;
  final String type;
  final String size;
  final IconData icon;

  ReportItem({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.size,
    required this.icon,
  });
}

// Chart Extensions for Reports Page
extension ReportsChartExtensions on _ReportsPageContentState {
  Widget _buildPerformanceCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performans Trendleri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Line Chart - Verimlilik Trendi
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Haftalık Verimlilik Trendi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 10,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final days = [
                              'Pzt',
                              'Sal',
                              'Çar',
                              'Per',
                              'Cum',
                              'Cmt',
                              'Paz',
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < days.length) {
                              return Text(
                                days[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    minX: 0,
                    maxX: 6,
                    minY: 70,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 85),
                          const FlSpot(1, 87),
                          const FlSpot(2, 83),
                          const FlSpot(3, 90),
                          const FlSpot(4, 88),
                          const FlSpot(5, 92),
                          const FlSpot(6, 89),
                        ],
                        isCurved: true,
                        color: const Color(AppColors.primaryBlue),
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(
                            AppColors.primaryBlue,
                          ).withOpacity(0.1),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                                radius: 4,
                                color: const Color(AppColors.primaryBlue),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Bar Chart - Makine Bazlı Performans
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Makine Bazlı Performans',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final machines = [
                              'M001',
                              'M002',
                              'M003',
                              'M004',
                              'M005',
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < machines.length) {
                              return Text(
                                machines[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: 87,
                            color: const Color(AppColors.successGreen),
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: 73,
                            color: const Color(AppColors.warningOrange),
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: 45,
                            color: const Color(AppColors.errorRed),
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: 92,
                            color: const Color(AppColors.successGreen),
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(
                            toY: 81,
                            color: const Color(AppColors.warningOrange),
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Pie Chart - Makine Durumları
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Makine Durum Dağılımı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: const Color(AppColors.successGreen),
                              value: 65,
                              title: '65%',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: const Color(AppColors.warningOrange),
                              value: 25,
                              title: '25%',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: const Color(AppColors.errorRed),
                              value: 10,
                              title: '10%',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(
                            'Aktif',
                            const Color(AppColors.successGreen),
                          ),
                          const SizedBox(height: 8),
                          _buildLegendItem(
                            'Bakımda',
                            const Color(AppColors.warningOrange),
                          ),
                          const SizedBox(height: 8),
                          _buildLegendItem(
                            'Arızalı',
                            const Color(AppColors.errorRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
