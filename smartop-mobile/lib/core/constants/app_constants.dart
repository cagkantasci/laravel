class AppConstants {
  // API Configuration
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  static const String apiBaseUrl = 'http://10.0.2.2:8001/api';
  static const String apiTimeout = '30000'; // 30 seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String companyKey = 'company_data';

  // App Info
  static const String appName = 'SmartOp';
  static const String appVersion = '1.0.0';

  // Routes
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String machinesRoute = '/machines';
  static const String controlListsRoute = '/control-lists';
  static const String profileRoute = '/profile';
  static const String qrScannerRoute = '/qr-scanner';

  // Roles
  static const String adminRole = 'admin';
  static const String managerRole = 'manager';
  static const String operatorRole = 'operator';

  // Control List Status
  static const String pendingStatus = 'pending';
  static const String approvedStatus = 'approved';
  static const String rejectedStatus = 'rejected';
  static const String completedStatus = 'completed';

  // Machine Status
  static const String activeMachineStatus = 'active';
  static const String inactiveMachineStatus = 'inactive';
  static const String maintenanceMachineStatus = 'maintenance';

  // Offline Data Settings
  static const int maxOfflineDataDays = 7;
  static const int syncInterval = 15; // minutes
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String machines = '/machines';
  static const String controlLists = '/control-lists';
  static const String profile = '/profile';
  static const String qrScanner = '/qr-scanner';
}

class AppColors {
  // Primary Colors
  static const int primaryBlue = 0xFF1976D2;
  static const int primaryDark = 0xFF0D47A1;
  static const int primaryLight = 0xFF42A5F5;

  // Status Colors
  static const int successGreen = 0xFF4CAF50;
  static const int warningOrange = 0xFFFF9800;
  static const int errorRed = 0xFFE53935;
  static const int dangerRed = 0xFFE53935;
  static const int infoBlue = 0xFF2196F3;

  // Neutral Colors
  static const int grey50 = 0xFFFAFAFA;
  static const int grey100 = 0xFFF5F5F5;
  static const int grey300 = 0xFFE0E0E0;
  static const int grey500 = 0xFF9E9E9E;
  static const int grey600 = 0xFF757575;
  static const int grey700 = 0xFF616161;
  static const int grey900 = 0xFF212121;
}

class AppSizes {
  // Padding & Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Text Sizes
  static const double textSmall = 12.0;
  static const double textMedium = 14.0;
  static const double textLarge = 16.0;
  static const double textXLarge = 20.0;
  static const double textXXLarge = 24.0;
}
