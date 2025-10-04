import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/machines/presentation/pages/machines_page.dart';
import '../../features/control_lists/presentation/pages/control_lists_page.dart' as control_lists;
import '../../features/finances/presentation/pages/finances_page.dart';
import '../../features/user_management/presentation/pages/user_management_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/approvals/presentation/pages/approvals_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isAdmin = user?.isAdmin ?? false;
    final isManager = user?.isManager ?? false;
    final isOperator = user?.isOperator ?? false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(AppColors.primaryBlue),
            ),
            accountName: Text(
              user?.name ?? 'Kullanıcı',
              style: const TextStyle(
                fontSize: AppSizes.textLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.name ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: AppSizes.textXXLarge,
                  color: Color(AppColors.primaryBlue),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Dashboard - Tüm roller
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Ana Sayfa',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
          ),

          const Divider(),

          // Machines - Admin ve Manager
          if (isAdmin || isManager)
            _buildDrawerItem(
              context,
              icon: Icons.precision_manufacturing,
              title: 'Makineler',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MachinesPage()),
                );
              },
            ),

          // Control Lists - Tüm roller
          _buildDrawerItem(
            context,
            icon: Icons.checklist,
            title: 'Kontrol Listeleri',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const control_lists.ControlListsPage()),
              );
            },
          ),

          // Finances - Admin ve Manager
          if (isAdmin || isManager)
            _buildDrawerItem(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Finans Yönetimi',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FinancesPage()),
                );
              },
            ),

          // Approvals - Admin ve Manager
          if (isAdmin || isManager)
            _buildDrawerItem(
              context,
              icon: Icons.approval,
              title: 'Onaylar',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApprovalsPage()),
                );
              },
            ),

          // Reports - Admin ve Manager
          if (isAdmin || isManager)
            _buildDrawerItem(
              context,
              icon: Icons.assessment,
              title: 'Raporlar',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportsPage()),
                );
              },
            ),

          // User Management - Admin ve Manager
          if (isAdmin || isManager)
            _buildDrawerItem(
              context,
              icon: Icons.people,
              title: 'Kullanıcı Yönetimi',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementPage()),
                );
              },
            ),

          const Divider(),

          // Settings
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Ayarlar',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayarlar sayfası yakında eklenecek')),
              );
            },
          ),

          // Help
          _buildDrawerItem(
            context,
            icon: Icons.help_outline,
            title: 'Yardım',
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),

          const Divider(),

          // Logout
          _buildDrawerItem(
            context,
            icon: Icons.exit_to_app,
            title: 'Çıkış Yap',
            iconColor: const Color(AppColors.errorRed),
            onTap: () async {
              final confirmed = await _showLogoutConfirmation(context);
              if (confirmed == true) {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // App Version
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              'SmartOp v${AppConstants.appVersion}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: AppSizes.textSmall,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? const Color(AppColors.primaryBlue),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Color(AppColors.errorRed)),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yardım'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SmartOp Mobil Uygulama',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.textLarge,
                ),
              ),
              SizedBox(height: AppSizes.paddingMedium),
              Text('📱 Ana Özellikler:'),
              SizedBox(height: AppSizes.paddingSmall),
              Text('• Makine yönetimi ve QR kod tarama'),
              Text('• Kontrol listesi oluşturma ve takibi'),
              Text('• Finansal işlem yönetimi'),
              Text('• Kullanıcı yönetimi'),
              Text('• Detaylı raporlama'),
              SizedBox(height: AppSizes.paddingMedium),
              Text(
                'ℹ️ Destek için: support@smartop.com',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
