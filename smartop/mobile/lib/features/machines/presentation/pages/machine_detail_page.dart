import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/mock_auth_service.dart';
import '../../data/models/machine.dart';
import 'machine_control_page.dart';
import 'add_control_item_page.dart';

class MachineDetailPage extends StatefulWidget {
  final Machine machine;

  const MachineDetailPage({super.key, required this.machine});

  @override
  State<MachineDetailPage> createState() => _MachineDetailPageState();
}

class _MachineDetailPageState extends State<MachineDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.machine.code),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Makine düzenleme özelliği yakında...'),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'qr':
                  _showQRCode();
                  break;
                case 'maintenance':
                  _scheduleMaintenance();
                  break;
                case 'history':
                  _showHistory();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'qr',
                child: Row(
                  children: [
                    Icon(Icons.qr_code),
                    SizedBox(width: 8),
                    Text('QR Kod Göster'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'maintenance',
                child: Row(
                  children: [
                    Icon(Icons.build),
                    SizedBox(width: 8),
                    Text('Bakım Planla'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('Geçmiş Kayıtlar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMachineHeader(),
            _buildStatusSection(),
            _buildDetailsSection(),
            _buildControlSection(),
            _buildMaintenanceSection(),
            _buildPerformanceSection(),
            const SizedBox(height: AppSizes.paddingXLarge),
          ],
        ),
      ),
      floatingActionButton: widget.machine.isActive
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.qrScanner);
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR Tara'),
              backgroundColor: const Color(AppColors.primaryBlue),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildMachineHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(AppColors.primaryBlue), Color(AppColors.primaryDark)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.paddingLarge),
          // Machine Image Placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            ),
            child: const Icon(
              Icons.precision_manufacturing,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            widget.machine.name,
            style: const TextStyle(
              fontSize: AppSizes.textXXLarge,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            widget.machine.description,
            style: const TextStyle(
              fontSize: AppSizes.textMedium,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingLarge),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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
            'Durum Bilgisi',
            style: TextStyle(
              fontSize: AppSizes.textLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  widget.machine.statusText,
                  _getStatusIcon(widget.machine.status),
                  _getStatusColor(widget.machine.status),
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              if (widget.machine.isActive)
                Expanded(
                  child: _buildStatusCard(
                    widget.machine.efficiencyText,
                    Icons.trending_up,
                    widget.machine.efficiency >= 90
                        ? const Color(AppColors.successGreen)
                        : widget.machine.efficiency >= 70
                        ? const Color(AppColors.warningOrange)
                        : const Color(AppColors.errorRed),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconLarge),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.textMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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
            'Detay Bilgileri',
            style: TextStyle(
              fontSize: AppSizes.textLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildDetailRow('Makine Kodu', widget.machine.code),
          _buildDetailRow('Tip', widget.machine.type),
          _buildDetailRow('Lokasyon', widget.machine.location),
          _buildDetailRow('Durum', widget.machine.statusText),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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
          Row(
            children: [
              const Text(
                'Bakım Bilgileri',
                style: TextStyle(
                  fontSize: AppSizes.textLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (widget.machine.needsMaintenance)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      AppColors.warningOrange,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Color(AppColors.warningOrange),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Dikkat!',
                        style: TextStyle(
                          fontSize: AppSizes.textSmall,
                          color: Color(AppColors.warningOrange),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildDetailRow(
            'Son Bakım',
            _formatDate(widget.machine.lastMaintenanceDate),
          ),
          _buildDetailRow(
            'Sonraki Bakım',
            _formatDate(widget.machine.nextMaintenanceDate),
            widget.machine.needsMaintenance
                ? const Color(AppColors.warningOrange)
                : null,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scheduleMaintenance,
              icon: const Icon(Icons.build),
              label: const Text('Bakım Planla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.warningOrange),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    if (!widget.machine.isActive) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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
            'Performans',
            style: TextStyle(
              fontSize: AppSizes.textLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildPerformanceChart(),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Verimlilik oranı son 30 günün ortalamasıdır.',
            style: TextStyle(
              fontSize: AppSizes.textSmall,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    final efficiency = widget.machine.efficiency;
    final color = efficiency >= 90
        ? const Color(AppColors.successGreen)
        : efficiency >= 70
        ? const Color(AppColors.warningOrange)
        : const Color(AppColors.errorRed);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Verimlilik',
              style: TextStyle(
                fontSize: AppSizes.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.machine.efficiencyText,
              style: TextStyle(
                fontSize: AppSizes.textLarge,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        LinearProgressIndicator(
          value: efficiency / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.textMedium,
                color: Color(AppColors.grey500),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(AppColors.grey500))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppSizes.textMedium,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(AppColors.grey700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(AppColors.successGreen);
      case 'maintenance':
        return const Color(AppColors.warningOrange);
      case 'inactive':
        return const Color(AppColors.grey500);
      default:
        return const Color(AppColors.grey500);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.play_circle;
      case 'maintenance':
        return Icons.build;
      case 'inactive':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Kod'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code,
                  size: 100,
                  color: Color(AppColors.grey300),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              widget.machine.code,
              style: const TextStyle(
                fontSize: AppSizes.textLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _scheduleMaintenance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bakım planlama özelliği yakında eklenecek...'),
      ),
    );
  }

  Widget _buildControlSection() {
    if (!widget.machine.hasControlItems) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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
          Row(
            children: [
              const Text(
                'Kontrol Bilgileri',
                style: TextStyle(
                  fontSize: AppSizes.textLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (widget.machine.needsControl)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      AppColors.warningOrange,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Color(AppColors.warningOrange),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Kontrol Zamanı!',
                        style: TextStyle(
                          fontSize: AppSizes.textSmall,
                          color: Color(AppColors.warningOrange),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Kontrol durumu progress bar
          Row(
            children: [
              const Text(
                'Tamamlanan:',
                style: TextStyle(
                  fontSize: AppSizes.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.machine.completedControlItems}/${widget.machine.totalControlItems}',
                style: const TextStyle(
                  fontSize: AppSizes.textMedium,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          LinearProgressIndicator(
            value: widget.machine.calculatedControlCompletionRate / 100,
            backgroundColor: const Color(AppColors.grey300),
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.machine.hasFailedControls
                  ? const Color(AppColors.errorRed)
                  : widget.machine.allControlsCompleted
                  ? const Color(AppColors.successGreen)
                  : const Color(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            widget.machine.controlStatusText,
            style: TextStyle(
              fontSize: AppSizes.textSmall,
              color: widget.machine.hasFailedControls
                  ? const Color(AppColors.errorRed)
                  : const Color(AppColors.grey700),
            ),
          ),

          if (widget.machine.lastControlDate != null) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildDetailRow(
              'Son Kontrol',
              '${_formatDate(widget.machine.lastControlDate!)} - ${widget.machine.lastControlBy}',
            ),
          ],

          const SizedBox(height: AppSizes.paddingMedium),

          // Kontrol istatistikleri
          Row(
            children: [
              Expanded(
                child: _buildControlStatCard(
                  'Başarılı',
                  widget.machine.passedControlItems.toString(),
                  Icons.check_circle,
                  const Color(AppColors.successGreen),
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: _buildControlStatCard(
                  'Başarısız',
                  widget.machine.failedControlItems.toString(),
                  Icons.error,
                  const Color(AppColors.errorRed),
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: _buildControlStatCard(
                  'Bekleyen',
                  widget.machine.pendingControlItems.toString(),
                  Icons.schedule,
                  const Color(AppColors.warningOrange),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openControlPage(),
              icon: const Icon(Icons.assignment),
              label: const Text('Kontrol Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.machine.needsControl
                    ? const Color(AppColors.warningOrange)
                    : const Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingMedium,
                ),
              ),
            ),
          ),

          // Admin/Manager kontrol yönetimi butonları
          if (_canManageControls()) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addControlItem(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Kontrol Ekle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(AppColors.primaryBlue),
                      side: const BorderSide(
                        color: Color(AppColors.primaryBlue),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _manageControlItems(),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Düzenle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(AppColors.grey700),
                      side: const BorderSide(color: Color(AppColors.grey300)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.textMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: AppSizes.textSmall, color: color),
          ),
        ],
      ),
    );
  }

  void _openControlPage() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MachineControlPage(machine: widget.machine),
      ),
    );

    if (result != null && result is Machine) {
      // Makine güncellendi, sayfayı yenile
      setState(() {
        // widget.machine = result; // Bu final olduğu için yapamayız
        // Bunun yerine parent widget'a bilgi gönderebiliriz
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kontrol bilgileri güncellendi'),
          backgroundColor: Color(AppColors.successGreen),
        ),
      );
    }
  }

  void _showHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geçmiş kayıtlar özelliği yakında eklenecek...'),
      ),
    );
  }

  // Admin/Manager kontrol yönetimi metodları
  bool _canManageControls() {
    final authService = MockAuthService();
    final user = authService.currentUser;
    return user != null && (user.isAdmin || user.isManager);
  }

  Future<void> _addControlItem() async {
    if (!_canManageControls()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu işlem için yetkiniz bulunmuyor'),
          backgroundColor: Color(AppColors.errorRed),
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddControlItemPage(machineId: int.tryParse(widget.machine.id) ?? 0),
      ),
    );

    if (result == true) {
      setState(() {
        // Sayfayı yenile
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kontrol öğesi başarıyla eklendi'),
          backgroundColor: Color(AppColors.successGreen),
        ),
      );
    }
  }

  void _manageControlItems() {
    if (!_canManageControls()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu işlem için yetkiniz bulunmuyor'),
          backgroundColor: Color(AppColors.errorRed),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(AppColors.grey300),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Row(
                    children: [
                      const Text(
                        'Kontrol Öğeleri Yönetimi',
                        style: TextStyle(
                          fontSize: AppSizes.textLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                itemCount: widget.machine.controlItems.length,
                itemBuilder: (context, index) {
                  final item = widget.machine.controlItems[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: AppSizes.paddingSmall,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          AppColors.primaryBlue,
                        ).withOpacity(0.1),
                        child: Icon(
                          _getControlIcon(item.type),
                          color: const Color(AppColors.primaryBlue),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(
                                    item.type,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.typeText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getTypeColor(item.type),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (item.isRequired) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      AppColors.errorRed,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Zorunlu',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(AppColors.errorRed),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddControlItemPage(
                                    machineId:
                                        int.tryParse(widget.machine.id) ?? 0,
                                    controlItem: item,
                                  ),
                                ),
                              );
                              if (result == true) {
                                Navigator.pop(context);
                                setState(() {});
                              }
                              break;
                            case 'delete':
                              _showDeleteConfirmation(item);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Düzenle'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Sil',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getControlIcon(String type) {
    switch (type) {
      case 'visual':
        return Icons.visibility;
      case 'measurement':
        return Icons.straighten;
      case 'function':
        return Icons.settings;
      case 'safety':
        return Icons.security;
      default:
        return Icons.check_circle;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'visual':
        return const Color(AppColors.infoBlue);
      case 'measurement':
        return const Color(AppColors.successGreen);
      case 'function':
        return const Color(AppColors.primaryBlue);
      case 'safety':
        return const Color(AppColors.errorRed);
      default:
        return const Color(AppColors.grey500);
    }
  }

  void _showDeleteConfirmation(item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontrol Öğesi Sil'),
        content: Text(
          '${item.title} kontrol öğesini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Bottom sheet'i kapat
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kontrol öğesi silindi'),
                  backgroundColor: Color(AppColors.successGreen),
                ),
              );
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
}
