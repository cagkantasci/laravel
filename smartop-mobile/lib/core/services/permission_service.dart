class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Role-based permissions
  static const Map<String, List<String>> _rolePermissions = {
    'admin': [
      'user_management',
      'reports_full',
      'dashboard_admin',
      'qr_scanner',
      'notifications',
      'settings',
      'company_management',
      'system_logs',
    ],
    'manager': [
      'reports_limited',
      'dashboard_manager',
      'qr_scanner',
      'notifications',
      'team_management',
      'work_orders',
    ],
    'operator': [
      'dashboard_operator',
      'qr_scanner',
      'work_orders_limited',
      'notifications',
    ],
  };

  // Feature permissions
  static const Map<String, List<String>> _featurePermissions = {
    'dashboard': ['admin', 'manager', 'operator'],
    'user_management': ['admin'],
    'reports': ['admin', 'manager'],
    'qr_scanner': ['admin', 'manager', 'operator'],
    'notifications': ['admin', 'manager', 'operator'],
    'settings': ['admin'],
    'work_orders': ['admin', 'manager', 'operator'],
    'company_profile': ['admin', 'manager'],
  };

  /// Check if user has permission for a specific feature
  bool hasPermission(String userRole, String feature) {
    if (!_featurePermissions.containsKey(feature)) {
      return false;
    }
    return _featurePermissions[feature]!.contains(userRole);
  }

  /// Check if user has specific permission
  bool hasSpecificPermission(String userRole, String permission) {
    if (!_rolePermissions.containsKey(userRole)) {
      return false;
    }
    return _rolePermissions[userRole]!.contains(permission);
  }

  /// Get all permissions for a role
  List<String> getPermissionsForRole(String role) {
    return _rolePermissions[role] ?? [];
  }

  /// Get available features for a role
  List<String> getAvailableFeaturesForRole(String role) {
    List<String> availableFeatures = [];

    _featurePermissions.forEach((feature, allowedRoles) {
      if (allowedRoles.contains(role)) {
        availableFeatures.add(feature);
      }
    });

    return availableFeatures;
  }

  /// Check if user can manage other users
  bool canManageUsers(String userRole) {
    return hasPermission(userRole, 'user_management');
  }

  /// Check if user can view reports
  bool canViewReports(String userRole) {
    return hasPermission(userRole, 'reports');
  }

  /// Check if user can use QR scanner
  bool canUseQRScanner(String userRole) {
    return hasPermission(userRole, 'qr_scanner');
  }

  /// Check if user can access company settings
  bool canAccessCompanySettings(String userRole) {
    return hasSpecificPermission(userRole, 'company_management');
  }

  /// Get dashboard access level for role
  String getDashboardAccessLevel(String role) {
    switch (role) {
      case 'admin':
        return 'full_access';
      case 'manager':
        return 'limited_admin';
      case 'operator':
        return 'basic_access';
      default:
        return 'no_access';
    }
  }

  /// Get role display name in Turkish
  String getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Yönetici';
      case 'manager':
        return 'Müdür';
      case 'operator':
        return 'Operatör';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Get all available roles
  List<Map<String, String>> getAllRoles() {
    return [
      {'value': 'admin', 'label': 'Yönetici'},
      {'value': 'manager', 'label': 'Müdür'},
      {'value': 'operator', 'label': 'Operatör'},
    ];
  }

  /// Check if role can create other roles
  bool canCreateRole(String currentUserRole, String targetRole) {
    // Admin can create any role
    if (currentUserRole == 'admin') {
      return true;
    }

    // Manager can create only operators
    if (currentUserRole == 'manager' && targetRole == 'operator') {
      return true;
    }

    return false;
  }

  /// Check if role can edit other roles
  bool canEditRole(String currentUserRole, String targetRole) {
    // Admin can edit any role
    if (currentUserRole == 'admin') {
      return true;
    }

    // Manager can edit operators
    if (currentUserRole == 'manager' && targetRole == 'operator') {
      return true;
    }

    return false;
  }
}
