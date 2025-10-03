import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/services/notification_service.dart';
import 'notification_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    // Initialize notification service and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.initialize();
    });
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
        title: const Text('Bildirimler'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: _notificationService.notificationsStream,
            builder: (context, snapshot) {
              final unreadCount = _notificationService.unreadCount;
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.mark_email_read),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: unreadCount > 0 ? _markAllAsRead : null,
                tooltip: 'Tümünü Okundu İşaretle',
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'test':
                  _notificationService.sendTestNotification();
                  _showSnackBar('Test bildirimi gönderildi');
                  break;
                case 'settings':
                  _showNotificationSettings();
                  break;
                case 'clear':
                  _showClearAllDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active),
                    SizedBox(width: 8),
                    Text('Test Push Bildirimi'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Bildirim Ayarları'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text('Test Bildirimi Gönder'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Tümünü Temizle'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedFilter = 'all';
                  break;
                case 1:
                  _selectedFilter = 'unread';
                  break;
                case 2:
                  _selectedFilter = 'machine';
                  break;
                case 3:
                  _selectedFilter = 'warning';
                  break;
                case 4:
                  _selectedFilter = 'maintenance';
                  break;
                case 5:
                  _selectedFilter = 'quality';
                  break;
              }
            });
          },
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Okunmamış'),
            Tab(text: 'Makine'),
            Tab(text: 'Uyarı'),
            Tab(text: 'Bakım'),
            Tab(text: 'Kalite'),
          ],
        ),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationService.notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = _filterNotifications(snapshot.data!);

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: List.generate(
              6,
              (index) => _buildNotificationsList(notifications),
            ),
          );
        },
      ),
    );
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications,
  ) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'machine':
        return notifications.where((n) => n.type == 'machine').toList();
      case 'warning':
        return notifications.where((n) => n.type == 'warning').toList();
      case 'maintenance':
        return notifications.where((n) => n.type == 'maintenance').toList();
      case 'quality':
        return notifications.where((n) => n.type == 'quality').toList();
      default:
        return notifications;
    }
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : const Color(AppColors.primaryBlue).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead
            ? null
            : Border.all(
                color: const Color(AppColors.primaryBlue).withOpacity(0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.grey300).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: notification.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(notification.icon, color: notification.color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: notification.isRead
                      ? FontWeight.w500
                      : FontWeight.w700,
                  color: const Color(AppColors.grey900),
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(AppColors.primaryBlue),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.grey600),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: const Color(AppColors.grey500),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(AppColors.grey500),
                  ),
                ),
                const Spacer(),
                if (notification.data?['machineId'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.grey300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      notification.data!['machineId'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.grey500),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          onSelected: (value) {
            switch (value) {
              case 'read':
                _notificationService.markAsRead(notification.id);
                break;
              case 'delete':
                _notificationService.removeNotification(notification.id);
                _showSnackBar('Bildirim silindi');
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 16),
                    SizedBox(width: 8),
                    Text('Okundu İşaretle'),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: const Color(AppColors.grey300),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
                ? 'Henüz bildirim yok'
                : 'Bu kategoride bildirim yok',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(AppColors.grey500),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'Bildirimler burada görünecek'
                : 'Diğer kategorileri kontrol edin',
            style: const TextStyle(
              fontSize: 14,
              color: Color(AppColors.grey500),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotificationDetailPage(notification: notification),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirim Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bildirim türlerini yönetin:'),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Makine Bildirimleri'),
              subtitle: const Text('Makine durumu ve performans bildirimleri'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Bakım Bildirimleri'),
              subtitle: const Text('Planlı ve acil bakım bildirimleri'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Görev Bildirimleri'),
              subtitle: const Text('Atanmış görev ve kontrol listeleri'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Sistem Bildirimleri'),
              subtitle: const Text('Uygulama güncellemeleri ve sistem durumu'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bildirim ayarları kaydedildi'),
                  backgroundColor: Color(AppColors.successGreen),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    _showSnackBar('Tüm bildirimler okundu olarak işaretlendi');
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Bildirimleri Temizle'),
        content: const Text(
          'Tüm bildirimleri silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _notificationService.clearAll();
              _showSnackBar('Tüm bildirimler temizlendi');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.errorRed),
              foregroundColor: Colors.white,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sa önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
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
