import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/services/notification_service.dart';

class NotificationDetailPage extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailPage({super.key, required this.notification});

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Mark as read when opening detail
    if (!widget.notification.isRead) {
      _notificationService.markAsRead(widget.notification.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Detayı'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_unread':
                  _notificationService.markAsUnread(widget.notification.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Okunmadı olarak işaretlendi'),
                    ),
                  );
                  break;
                case 'delete':
                  _deleteNotification();
                  break;
                case 'share':
                  _shareNotification();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_unread',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_unread),
                    SizedBox(width: 8),
                    Text('Okunmadı İşaretle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Paylaş'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
            _buildMetadata(),
            _buildActions(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getTypeColor(widget.notification.type).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: _getTypeColor(widget.notification.type).withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(widget.notification.type),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(widget.notification.type),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeLabel(widget.notification.type),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getTypeColor(widget.notification.type),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(widget.notification.timestamp),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.notification.priority == 'high'
                      ? const Color(AppColors.errorRed)
                      : widget.notification.priority == 'medium'
                      ? const Color(AppColors.warningOrange)
                      : const Color(AppColors.successGreen),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPriorityLabel(widget.notification.priority),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
            'Mesaj İçeriği',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            widget.notification.body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          if (widget.notification.data?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Ek Bilgiler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.notification.data!.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppColors.grey50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bildirim Bilgileri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildMetadataRow('ID', widget.notification.id),
          _buildMetadataRow('Tip', _getTypeLabel(widget.notification.type)),
          _buildMetadataRow(
            'Öncelik',
            _getPriorityLabel(widget.notification.priority),
          ),
          _buildMetadataRow(
            'Durum',
            widget.notification.isRead ? 'Okundu' : 'Okunmadı',
          ),
          _buildMetadataRow(
            'Gönderim Zamanı',
            _formatDateTime(widget.notification.timestamp),
          ),
          if (widget.notification.isRead)
            _buildMetadataRow('Okunma Zamanı', _formatDateTime(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'İşlemler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _takeAction,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Aksiyona Geç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.primaryBlue),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _archiveNotification,
                  icon: const Icon(Icons.archive),
                  label: const Text('Arşivle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.grey500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'machine':
        return const Color(AppColors.primaryBlue);
      case 'maintenance':
        return const Color(AppColors.warningOrange);
      case 'alert':
        return const Color(AppColors.errorRed);
      case 'task':
        return const Color(AppColors.successGreen);
      case 'system':
        return const Color(AppColors.infoBlue);
      default:
        return const Color(AppColors.grey500);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'machine':
        return Icons.precision_manufacturing;
      case 'maintenance':
        return Icons.build;
      case 'alert':
        return Icons.warning;
      case 'task':
        return Icons.assignment;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'machine':
        return 'Makine Bildirimi';
      case 'maintenance':
        return 'Bakım Bildirimi';
      case 'alert':
        return 'Uyarı Bildirimi';
      case 'task':
        return 'Görev Bildirimi';
      case 'system':
        return 'Sistem Bildirimi';
      default:
        return 'Genel Bildirim';
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'Yüksek';
      case 'medium':
        return 'Orta';
      case 'low':
        return 'Düşük';
      default:
        return 'Normal';
    }
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

  void _deleteNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimi Sil'),
        content: const Text('Bu bildirimi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _notificationService.removeNotification(widget.notification.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Bildirim silindi')));
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

  void _shareNotification() {
    // Simulate sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bildirim paylaşma özelliği geliştiriliyor'),
        backgroundColor: Color(AppColors.infoBlue),
      ),
    );
  }

  void _takeAction() {
    // Navigate to relevant page based on notification type
    String message;
    switch (widget.notification.type) {
      case 'machine':
        message = 'Makine sayfasına yönlendiriliyor...';
        break;
      case 'maintenance':
        message = 'Bakım planlaması sayfasına yönlendiriliyor...';
        break;
      case 'task':
        message = 'Görev detayına yönlendiriliyor...';
        break;
      default:
        message = 'İlgili sayfaya yönlendiriliyor...';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(AppColors.primaryBlue),
      ),
    );
  }

  void _archiveNotification() {
    // Simulate archiving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bildirim arşivlendi'),
        backgroundColor: Color(AppColors.successGreen),
      ),
    );
    Navigator.pop(context);
  }
}
