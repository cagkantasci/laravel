import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../machines/presentation/pages/machines_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const MachinesPage(),
    const ControlListsPlaceholder(),
    const ProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(AppColors.primaryBlue),
        unselectedItemColor: const Color(AppColors.grey500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.precision_manufacturing),
            label: 'Makineler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Kontrol Listeleri',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.grey50),
      appBar: AppBar(
        title: const Text('SmartOp Dashboard'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bildirimler yakında eklenecek...'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.of(
                context,
              ).pushNamed(AppRoutes.qrScanner);
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('QR Kod: $result'),
                    backgroundColor: const Color(AppColors.successGreen),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(),

            const SizedBox(height: AppSizes.paddingLarge),

            // Stats Cards
            _buildStatsGrid(),

            const SizedBox(height: AppSizes.paddingLarge),

            // Quick Actions
            _buildQuickActions(context),

            const SizedBox(height: AppSizes.paddingLarge),

            // Recent Activity
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(AppColors.primaryBlue), Color(AppColors.primaryDark)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryBlue).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoş Geldiniz!',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.textXXLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          const Text(
            'Admin Kullanıcısı',
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.textMedium,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.white70,
                size: AppSizes.iconSmall,
              ),
              const SizedBox(width: AppSizes.paddingSmall / 2),
              Text(
                'Son Giriş: ${DateTime.now().toString().substring(0, 16)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: AppSizes.textSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.paddingMedium,
      mainAxisSpacing: AppSizes.paddingMedium,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Toplam Makine',
          '24',
          Icons.precision_manufacturing,
          const Color(AppColors.primaryBlue),
        ),
        _buildStatCard(
          'Aktif Makine',
          '18',
          Icons.check_circle,
          const Color(AppColors.successGreen),
        ),
        _buildStatCard(
          'Bekleyen Onay',
          '5',
          Icons.pending_actions,
          const Color(AppColors.warningOrange),
        ),
        _buildStatCard(
          'Günlük Kontrol',
          '12',
          Icons.assignment_turned_in,
          const Color(AppColors.infoBlue),
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
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: AppSizes.iconLarge),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppSizes.textXXLarge,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppSizes.textSmall,
                  color: Color(AppColors.grey500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı İşlemler',
          style: TextStyle(
            fontSize: AppSizes.textLarge,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.grey700),
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'QR Tara',
                Icons.qr_code_scanner,
                const Color(AppColors.primaryBlue),
                () => _openQRScanner(context),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildActionButton(
                'Yeni Kontrol',
                Icons.add_task,
                const Color(AppColors.successGreen),
                () => _showSnackBar(context, 'Yeni kontrol yakında...'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Raporlar',
                Icons.analytics,
                const Color(AppColors.warningOrange),
                () => _showSnackBar(context, 'Raporlar yakında...'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildActionButton(
                'Ayarlar',
                Icons.settings,
                const Color(AppColors.grey500),
                () => _showSnackBar(context, 'Ayarlar yakında...'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.iconLarge),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.textSmall,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son Aktiviteler',
          style: TextStyle(
            fontSize: AppSizes.textLarge,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.grey700),
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'Makine M001 kontrolü tamamlandı',
                '10 dakika önce',
                Icons.check_circle,
                const Color(AppColors.successGreen),
              ),
              const Divider(height: 1),
              _buildActivityItem(
                'Yeni kontrol listesi oluşturuldu',
                '25 dakika önce',
                Icons.assignment,
                const Color(AppColors.infoBlue),
              ),
              const Divider(height: 1),
              _buildActivityItem(
                'Makine M005 bakım gerekiyor',
                '1 saat önce',
                Icons.warning,
                const Color(AppColors.warningOrange),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(icon, color: color, size: AppSizes.iconMedium),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppSizes.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: AppSizes.textSmall,
                    color: Color(AppColors.grey500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openQRScanner(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.qrScanner);
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Kod Tarandı: $result'),
          backgroundColor: const Color(AppColors.successGreen),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// Placeholder sayfalar
class MachinesPlaceholder extends StatelessWidget {
  const MachinesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makineler'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.precision_manufacturing,
              size: 80,
              color: Color(AppColors.grey300),
            ),
            SizedBox(height: AppSizes.paddingLarge),
            Text(
              'Makine Yönetimi',
              style: TextStyle(
                fontSize: AppSizes.textXLarge,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.grey500),
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Yakında eklenecek...',
              style: TextStyle(
                fontSize: AppSizes.textMedium,
                color: Color(AppColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ControlListsPlaceholder extends StatelessWidget {
  const ControlListsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Listeleri'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist, size: 80, color: Color(AppColors.grey300)),
            SizedBox(height: AppSizes.paddingLarge),
            Text(
              'Kontrol Listeleri',
              style: TextStyle(
                fontSize: AppSizes.textXLarge,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.grey500),
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Yakında eklenecek...',
              style: TextStyle(
                fontSize: AppSizes.textMedium,
                color: Color(AppColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Color(AppColors.grey300)),
            SizedBox(height: AppSizes.paddingLarge),
            Text(
              'Kullanıcı Profili',
              style: TextStyle(
                fontSize: AppSizes.textXLarge,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.grey500),
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Yakında eklenecek...',
              style: TextStyle(
                fontSize: AppSizes.textMedium,
                color: Color(AppColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
