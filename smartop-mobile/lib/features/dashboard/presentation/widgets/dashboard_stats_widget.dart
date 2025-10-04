import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../user_management/presentation/pages/user_management_page.dart';
import '../../../qr_scanner/presentation/pages/qr_scanner_simple_page.dart';

class DashboardStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isLoading;

  const DashboardStatsWidget({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(AppColors.primaryBlue)),
      );
    }

    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
    }

    return Column(
      children: [
        _buildRoleBasedStats(user.role),
        const SizedBox(height: AppSizes.paddingLarge),
        _buildQuickActions(context, user.role),
      ],
    );
  }

  Widget _buildRoleBasedStats(String role) {
    switch (role) {
      case 'admin':
        return _buildAdminStats();
      case 'manager':
        return _buildManagerStats();
      case 'operator':
        return _buildOperatorStats();
      default:
        return _buildOperatorStats();
    }
  }

  Widget _buildAdminStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Toplam Şirket',
                '${stats['total_companies'] ?? 12}',
                Icons.business,
                const Color(AppColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildStatCard(
                'Aktif Kullanıcı',
                '${stats['active_users'] ?? 156}',
                Icons.people,
                const Color(AppColors.successGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Toplam Makine',
                '${stats['total_machines'] ?? 89}',
                Icons.precision_manufacturing,
                const Color(AppColors.warningOrange),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildStatCard(
                'Bekleyen Onay',
                '${stats['pending_approvals'] ?? 23}',
                Icons.pending_actions,
                const Color(AppColors.errorRed),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagerStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Şirket Makineleri',
                '${stats['company_machines'] ?? 34}',
                Icons.precision_manufacturing,
                const Color(AppColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildStatCard(
                'Aktif Operatör',
                '${stats['company_operators'] ?? 12}',
                Icons.engineering,
                const Color(AppColors.successGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Bugünkü Kontroller',
                '${stats['today_controls'] ?? 18}',
                Icons.checklist,
                const Color(AppColors.warningOrange),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildStatCard(
                'Onay Bekleyen',
                '${stats['pending_approvals'] ?? 7}',
                Icons.pending_actions,
                const Color(AppColors.errorRed),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperatorStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Bugünkü Görevler',
                '${stats['my_today_tasks'] ?? 8}',
                Icons.assignment,
                const Color(AppColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildStatCard(
                'Tamamlanan',
                '${stats['my_completed'] ?? 5}',
                Icons.task_alt,
                const Color(AppColors.successGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Bekleyen Kontrol',
                '${stats['my_pending'] ?? 3}',
                Icons.pending,
                const Color(AppColors.warningOrange),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildStatCard(
                'Gecikmeli',
                '${stats['my_overdue'] ?? 1}',
                Icons.warning,
                const Color(AppColors.errorRed),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.grey300).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.grey900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.0,
              color: Color(AppColors.grey600),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, String role) {
    final permissionService = PermissionService();
    List<QuickAction> actions = [];

    // QR Scanner - Tüm roller için
    if (permissionService.canUseQRScanner(role)) {
      actions.add(
        QuickAction(
          'QR Kod Tara',
          Icons.qr_code_scanner,
          () => _navigateToQRScanner(context),
        ),
      );
    }

    // Kullanıcı Yönetimi - Sadece admin
    if (permissionService.canManageUsers(role)) {
      actions.add(
        QuickAction(
          'Kullanıcı Yönetimi',
          Icons.people,
          () => _navigateToUserManagement(context),
        ),
      );
    }

    // Raporlar - Admin ve Manager
    if (permissionService.canViewReports(role)) {
      actions.add(
        QuickAction(
          'Raporlar',
          Icons.analytics,
          () => _navigateToReports(context),
        ),
      );
    }

    // Role specific actions
    switch (role) {
      case 'admin':
        actions.add(
          QuickAction(
            'Sistem Ayarları',
            Icons.settings,
            () => _showFeatureComingSoon(context),
          ),
        );
        break;
      case 'manager':
        actions.add(
          QuickAction(
            'Onay Bekleyen',
            Icons.pending_actions,
            () => _showFeatureComingSoon(context),
          ),
        );
        actions.add(
          QuickAction(
            'Operatör Yönetimi',
            Icons.engineering,
            () => _showFeatureComingSoon(context),
          ),
        );
        break;
      case 'operator':
        actions.add(
          QuickAction(
            'Bugünkü Görevler',
            Icons.today,
            () => _showFeatureComingSoon(context),
          ),
        );
        actions.add(
          QuickAction(
            'Geçmiş Kontroller',
            Icons.history,
            () => _showFeatureComingSoon(context),
          ),
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı İşlemler',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.grey900),
          ),
        ),
        const SizedBox(height: 16.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 2.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: const Color(AppColors.primaryBlue).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      action.icon,
                      color: const Color(AppColors.primaryBlue),
                      size: 20,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        action.title,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Color(AppColors.primaryBlue),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showFeatureComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik yakında eklenecek...'),
        backgroundColor: Color(AppColors.warningOrange),
      ),
    );
  }

  static void _navigateToReports(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ReportsPage()));
  }

  static void _navigateToUserManagement(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const UserManagementPage()));
  }

  static void _navigateToQRScanner(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const QrCodeScannerPage()));
  }
}

class QuickAction {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  QuickAction(this.title, this.icon, this.onTap);
}
