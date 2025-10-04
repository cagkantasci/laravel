import 'auth_service.dart';

/// Yetkilendirme helper sınıfı
/// Kullanıcı rollerine göre erişim kontrolleri sağlar
class PermissionHelper {
  static final PermissionHelper _instance = PermissionHelper._internal();
  factory PermissionHelper() => _instance;
  PermissionHelper._internal();

  /// Belirli bir özelliğe erişim var mı kontrol eder
  bool hasPermission(String permission) {
    final role = AuthService.currentUser?.role;
    if (role == null) return false;

    // Admin her şeye erişebilir
    if (role == 'admin') return true;

    // Rol bazlı yetkiler
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  /// Kullanıcının belirli bir role sahip olup olmadığını kontrol eder
  bool hasRole(String role) {
    final userRole = AuthService.currentUser?.role;
    return userRole == role;
  }

  /// Kullanıcının belirli rollerden birine sahip olup olmadığını kontrol eder
  bool hasAnyRole(List<String> roles) {
    final userRole = AuthService.currentUser?.role;
    if (userRole == null) return false;
    return roles.contains(userRole);
  }

  /// Admin mi kontrol eder
  bool isAdmin() {
    return hasRole('admin');
  }

  /// Manager mı kontrol eder
  bool isManager() {
    return hasRole('manager');
  }

  /// Operator mı kontrol eder
  bool isOperator() {
    return hasRole('operator');
  }

  /// Rol bazlı yetki tanımlamaları
  static final Map<String, List<String>> _rolePermissions = {
    'admin': [
      // Tüm yetkiler
      'view_dashboard',
      'view_analytics',
      'view_companies',
      'create_companies',
      'edit_companies',
      'delete_companies',
      'view_users',
      'create_users',
      'edit_users',
      'delete_users',
      'view_machines',
      'create_machines',
      'edit_machines',
      'delete_machines',
      'view_control_templates',
      'create_control_templates',
      'edit_control_templates',
      'delete_control_templates',
      'view_control_lists',
      'create_control_lists',
      'edit_control_lists',
      'delete_control_lists',
      'assign_control_lists',
      'fill_control_lists',
      'approve_control_lists',
      'reject_control_lists',
      'view_work_sessions',
      'create_work_sessions',
      'edit_work_sessions',
      'delete_work_sessions',
      'approve_work_sessions',
      'reject_work_sessions',
      'view_reports',
      'export_reports',
      'view_settings',
      'edit_settings',
    ],
    'manager': [
      // Dashboard
      'view_dashboard',
      'view_analytics',
      // Kullanıcılar
      'view_users',
      'create_users',
      'edit_users',
      // Makineler
      'view_machines',
      'create_machines',
      'edit_machines',
      // Kontrol Şablonları
      'view_control_templates',
      'create_control_templates',
      'edit_control_templates',
      // Kontrol Listeleri
      'view_control_lists',
      'create_control_lists',
      'edit_control_lists',
      'assign_control_lists',
      'approve_control_lists',
      'reject_control_lists',
      // Çalışma Seansları
      'view_work_sessions',
      'approve_work_sessions',
      'reject_work_sessions',
      // Raporlar
      'view_reports',
      'export_reports',
      // Ayarlar
      'view_settings',
    ],
    'operator': [
      // NO Dashboard access
      // Makineler (only assigned machines)
      'view_machines',
      // Kontrol Listeleri (fill only)
      'view_control_lists',
      'fill_control_lists',
      // Çalışma Seansları (own only)
      'create_work_sessions',
      'view_own_work_sessions',
      // Profile
      'edit_own_profile',
    ],
  };

  /// Belirli bir özellik için kullanıcı mesajı döndürür
  String getPermissionDeniedMessage(String permission) {
    return 'Bu işlem için yetkiniz bulunmamaktadır.\nGerekli yetki: $permission';
  }

  /// Rol adını Türkçe olarak döndürür
  String getRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'Sistem Yöneticisi';
      case 'manager':
        return 'Şirket Yöneticisi';
      case 'operator':
        return 'Operatör';
      default:
        return 'Bilinmeyen';
    }
  }

  /// Mevcut kullanıcının rol adını döndürür
  String? getCurrentRoleName() {
    final role = AuthService.currentUser?.role;
    if (role == null) return null;
    return getRoleName(role);
  }
}
