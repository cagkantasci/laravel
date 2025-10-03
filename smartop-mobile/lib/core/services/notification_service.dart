import 'dart:async';
import 'dart:math';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationModel> _notifications = [];
  final StreamController<List<NotificationModel>> _notificationsController =
      StreamController<List<NotificationModel>>.broadcast();
  final StreamController<NotificationModel> _newNotificationController =
      StreamController<NotificationModel>.broadcast();

  Timer? _simulationTimer;
  bool _isSimulationActive = false;

  // Getters
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationsController.stream;
  Stream<NotificationModel> get newNotificationStream =>
      _newNotificationController.stream;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Initialize service with mock data
  void initialize() {
    if (_notifications.isEmpty) {
      _loadMockNotifications();
    }
    _startNotificationSimulation();
    // Immediately emit current notifications
    _notificationsController.add(_notifications);
  }

  // Add a new notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Add to the beginning
    _notificationsController.add(_notifications);
    _newNotificationController.add(notification);
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationsController.add(_notifications);
    }
  }

  // Mark notification as unread
  void markAsUnread(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && _notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: false);
      _notificationsController.add(_notifications);
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _notificationsController.add(_notifications);
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    _notificationsController.add(_notifications);
  }

  // Remove specific notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationsController.add(_notifications);
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Simulate receiving push notifications
  void _startNotificationSimulation() {
    if (_isSimulationActive) return;

    _isSimulationActive = true;
    _simulationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _generateRandomNotification();
    });
  }

  void _generateRandomNotification() {
    final random = Random();
    final notificationTypes = [
      {
        'type': 'machine',
        'titles': ['Makine Durumu', 'Operasyon Tamamlandı', 'Üretim Başladı'],
        'messages': [
          'CNC-001 makinesi aktif duruma geçti',
          'Pres-003 günlük hedefini tamamladı',
          'Torna-002 yeni iş emri aldı',
        ],
      },
      {
        'type': 'warning',
        'titles': ['Dikkat Gerekli', 'Performans Uyarısı', 'Kalite Kontrol'],
        'messages': [
          'Makine sıcaklığı normal değerlerin üzerinde',
          'Üretim hızı hedefin altında kaldı',
          'Kalite kontrol parametresi sınır değerde',
        ],
      },
      {
        'type': 'maintenance',
        'titles': ['Bakım Zamanı', 'Periyodik Kontrol', 'Yedek Parça'],
        'messages': [
          'Pres-001 haftalık bakım zamanı geldi',
          'Torna-003 yağ seviyesi kontrolü gerekli',
          'CNC-002 kesici takım değişimi zamanı',
        ],
      },
      {
        'type': 'quality',
        'titles': ['Kalite Raporu', 'İstatistik Güncelleme', 'Hedef Başarısı'],
        'messages': [
          'Günlük kalite hedefi %98 başarı ile tamamlandı',
          'Haftalık üretim raporu hazır',
          'Müşteri memnuniyet oranı arttı',
        ],
      },
    ];

    final selectedType =
        notificationTypes[random.nextInt(notificationTypes.length)];
    final titles = selectedType['titles'] as List<String>;
    final messages = selectedType['messages'] as List<String>;

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titles[random.nextInt(titles.length)],
      message: messages[random.nextInt(messages.length)],
      type: selectedType['type'] as String,
      timestamp: DateTime.now(),
      data: {
        'machineId': 'M${random.nextInt(10).toString().padLeft(3, '0')}',
        'severity': random.nextInt(3) + 1,
      },
    );

    addNotification(notification);
  }

  void _loadMockNotifications() {
    final mockNotifications = [
      NotificationModel(
        id: '1',
        title: 'Sistem Başlatıldı',
        message: 'SmartOp Mobile sistemi başarıyla başlatıldı. Hoş geldiniz!',
        type: 'success',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: true,
      ),
      NotificationModel(
        id: '2',
        title: 'Makine Durumu Değişikliği',
        message: 'CNC-001 makinesi bakım moduna geçti',
        type: 'machine',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        data: {'machineId': 'CNC-001', 'status': 'maintenance'},
      ),
      NotificationModel(
        id: '3',
        title: 'Üretim Hedefi',
        message: 'Günlük üretim hedefi %85 tamamlandı',
        type: 'info',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '4',
        title: 'Kalite Kontrol Uyarısı',
        message: 'Pres-003 kalite parametreleri kontrol edilmeli',
        type: 'warning',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        data: {'machineId': 'Pres-003', 'parameter': 'temperature'},
      ),
      NotificationModel(
        id: '5',
        title: 'Bakım Hatırlatması',
        message: 'Torna-002 periyodik bakım zamanı yaklaşıyor',
        type: 'maintenance',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        data: {'machineId': 'Torna-002', 'maintenanceType': 'periodic'},
      ),
    ];

    _notifications.addAll(mockNotifications);
    _notificationsController.add(_notifications);
  }

  // Send a test notification
  void sendTestNotification() {
    final testNotification = NotificationModel(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Bildirimi',
      message: 'Bu bir test bildirimidir. Bildirim sistemi çalışıyor.',
      type: 'info',
      timestamp: DateTime.now(),
    );

    addNotification(testNotification);
  }

  // Stop notification simulation
  void stopSimulation() {
    _simulationTimer?.cancel();
    _isSimulationActive = false;
  }

  // Dispose resources
  void dispose() {
    _simulationTimer?.cancel();
    _notificationsController.close();
    _newNotificationController.close();
  }
}
