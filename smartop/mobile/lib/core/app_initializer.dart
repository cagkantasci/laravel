import 'network/api_client.dart';
import 'services/auth_service.dart';
import 'services/mock_auth_service.dart';

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Initialize all app services
  Future<void> initialize({bool useMockServices = true}) async {
    if (_isInitialized) return;

    try {
      if (useMockServices) {
        // Initialize with mock services for offline testing
        await MockAuthService().init();
      } else {
        // Initialize API client for real API
        await ApiClient().init();
        await AuthService().init();
      }

      _isInitialized = true;
    } catch (e) {
      // Log error but don't throw to prevent app crash
      print('App initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // Reset initialization state (useful for testing)
  void reset() {
    _isInitialized = false;
  }
}
