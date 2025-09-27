import 'package:flutter/material.dart';
import 'permission_service.dart';
import 'mock_auth_service.dart';

/// Page-level permission guard widget
/// Wraps pages that require specific role-based permissions
class PermissionGuard extends StatelessWidget {
  final Widget child;
  final String requiredPermission;
  final String? requiredRole;
  final Widget? fallbackWidget;
  final String? unauthorizedTitle;
  final String? unauthorizedMessage;

  const PermissionGuard({
    super.key,
    required this.child,
    required this.requiredPermission,
    this.requiredRole,
    this.fallbackWidget,
    this.unauthorizedTitle,
    this.unauthorizedMessage,
  });

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService();
    final currentUser = MockAuthService.getCurrentUser();
    final userRole = currentUser?.role ?? '';

    // Check role-based permission
    bool hasPermission = false;

    if (requiredRole != null) {
      hasPermission = userRole == requiredRole;
    } else {
      hasPermission = permissionService.hasPermission(
        userRole,
        requiredPermission,
      );
    }

    if (hasPermission) {
      return child;
    }

    // Show fallback widget or default unauthorized page
    return fallbackWidget ?? _buildUnauthorizedPage(context);
  }

  Widget _buildUnauthorizedPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(unauthorizedTitle ?? 'Erişim Engellendi'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              Text(
                unauthorizedTitle ?? 'Bu sayfaya erişim yetkiniz bulunmuyor',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                unauthorizedMessage ??
                    'Bu işlemi gerçekleştirmek için gerekli yetkiye sahip değilsiniz. Yöneticinizle iletişime geçin.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Geri Dön'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature-level permission widget
/// Shows or hides UI elements based on permissions
class FeatureGuard extends StatelessWidget {
  final Widget child;
  final String feature;
  final String? userRole;
  final Widget? fallback;

  const FeatureGuard({
    super.key,
    required this.child,
    required this.feature,
    this.userRole,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService();
    final currentUserRole =
        userRole ?? MockAuthService.getCurrentUserRole() ?? '';

    if (permissionService.hasPermission(currentUserRole, feature)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Role-based widget visibility
class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final String? userRole;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.userRole,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserRole =
        userRole ?? MockAuthService.getCurrentUserRole() ?? '';

    if (allowedRoles.contains(currentUserRole)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Mixin for pages that need authorization
mixin AuthorizationMixin<T extends StatefulWidget> on State<T> {
  final PermissionService _permissionService = PermissionService();

  String get currentUserRole => MockAuthService.getCurrentUserRole() ?? '';

  bool hasPermission(String permission) {
    return _permissionService.hasPermission(currentUserRole, permission);
  }

  bool hasRole(String role) {
    return currentUserRole == role;
  }

  bool hasAnyRole(List<String> roles) {
    return roles.contains(currentUserRole);
  }

  void showUnauthorizedMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu işlem için yetkiniz bulunmuyor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void requirePermission(String permission, VoidCallback callback) {
    if (hasPermission(permission)) {
      callback();
    } else {
      showUnauthorizedMessage();
    }
  }

  void requireRole(String role, VoidCallback callback) {
    if (hasRole(role)) {
      callback();
    } else {
      showUnauthorizedMessage();
    }
  }
}

/// Extension methods for easier permission checking
extension PermissionExtension on String {
  bool get isAllowedFor {
    final permissionService = PermissionService();
    final userRole = MockAuthService.getCurrentUserRole() ?? '';
    return permissionService.hasPermission(userRole, this);
  }
}

extension RoleExtension on String {
  bool get isCurrentUserRole {
    final userRole = MockAuthService.getCurrentUserRole() ?? '';
    return userRole == this;
  }
}
