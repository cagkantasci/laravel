import 'package:flutter/foundation.dart';
import 'network/api_client.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'services/offline_sync_service.dart';

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Initialize all app services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize offline services (always needed)
      await ConnectivityService().initialize();
      await OfflineSyncService().initialize();

      // Initialize API client and auth
      await ApiClient().init();
      await AuthService().init();

      // Initialize notification service
      NotificationService().initialize();

      _isInitialized = true;
    } catch (e) {
      // Log error but don't throw to prevent app crash
      debugPrint('App initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // Reset initialization state (useful for testing)
  void reset() {
    _isInitialized = false;
  }
}
