import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/mock_auth_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../machines/presentation/pages/machines_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

import '../../../control_lists/presentation/pages/control_list_detail_page.dart';
import '../../../work_tasks/presentation/pages/work_tasks_list_page.dart';
import '../../../qr_scanner/presentation/pages/qr_scanner_page.dart';
import '../../../user_management/presentation/pages/user_management_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../../core/widgets/offline_indicator.dart';

import '../widgets/dashboard_stats_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final PermissionService _permissionService = PermissionService();

  List<Widget> _getPages() {
    return [
      const DashboardHome(),
      const MachinesPage(),
      const ControlListsPage(),
      const ProfilePage(),
    ];
  }

  List<BottomNavigationBarItem> _getNavigationItems() {
    // Tüm kullanıcılar için temel navigation items
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    ];

    // Makine yönetimi - Sadece admin ve manager
    final user = MockAuthService.getCurrentUser();
    final userRole = user?.role ?? 'operator';

    if (_permissionService.hasPermission(userRole, 'reports')) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.precision_manufacturing),
          label: 'Makineler',
        ),
      );
    }

    // Kontrol listeleri - Tüm roller
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.checklist),
        label: 'Kontroller',
      ),
    );

    // Profil - Tüm roller
    items.add(
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    final navigationItems = _getNavigationItems();

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index < pages.length) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(AppColors.primaryBlue),
        unselectedItemColor: const Color(AppColors.grey500),
        items: navigationItems,
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Mock data for now - later will be replaced with real API calls
      await Future.delayed(const Duration(milliseconds: 1500));

      _dashboardStats = {
        // Admin stats
        'total_companies': 12,
        'active_users': 156,
        'total_machines': 89,
        'pending_approvals': 23,

        // Manager stats
        'company_machines': 34,
        'company_operators': 12,
        'today_controls': 18,

        // Operator stats
        'my_today_tasks': 8,
        'my_completed': 5,
        'my_pending': 3,
        'my_overdue': 1,
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri yüklenirken hata: $e'),
            backgroundColor: const Color(AppColors.errorRed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.grey50),
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          StreamBuilder<List<dynamic>>(
            stream: NotificationService().notificationsStream,
            builder: (context, snapshot) {
              final unreadCount = NotificationService().unreadCount;
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _handleQRScan(),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadDashboardData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingMedium,
            AppSizes.paddingMedium,
            AppSizes.paddingMedium,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline Status Indicator
              const OfflineIndicator(),

              // Enhanced Dashboard Stats
              DashboardStatsWidget(
                stats: _dashboardStats,
                isLoading: _isLoading,
              ),

              const SizedBox(height: AppSizes.paddingLarge),

              // Yapılacak İşler
              _buildWorkTasks(),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    final userRole = MockAuthService.getCurrentUserRole();
    if (userRole == 'admin') {
      return 'SmartOp Dashboard';
    } else {
      final user = MockAuthService.getCurrentUser();
      return user?.company ?? 'SmartOp Teknoloji';
    }
  }

  Future<void> _handleQRScan() async {
    try {
      // Navigate to QR Scanner page instead of showing placeholder
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerPage()),
      );
    } catch (e) {
      _showFeatureComingSoon('QR Kod tarama özelliği kullanılamıyor');
    }
  }

  Widget _buildWorkTasks() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
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
        children: [
          Row(
            children: [
              const Icon(
                Icons.work,
                color: Color(AppColors.primaryBlue),
                size: AppSizes.iconMedium,
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              const Text(
                'Yapılacak İşler',
                style: TextStyle(
                  fontSize: AppSizes.textXLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showAllWorkTasks,
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          ..._getMockWorkTasks()
              .take(3)
              .map((task) => _buildWorkTaskCard(task)),
        ],
      ),
    );
  }

  Widget _buildWorkTaskCard(Map<String, dynamic> task) {
    final isUrgent = task['priority'] == 'high' || task['isOverdue'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? Colors.red.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _openWorkTaskDetail(task),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTaskStatusColor(task['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getTaskStatusText(task['status']),
                    style: TextStyle(
                      color: _getTaskStatusColor(task['status']),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (isUrgent)
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                if (task['priority'] == 'high')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ACİL',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              task['location'],
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  task['assignedOperator'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${task['estimatedDays']} gün',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockWorkTasks() {
    final now = DateTime.now();
    return [
      {
        'id': 'W001',
        'title': 'İstanbul Havalimanı Kazı İşleri',
        'description':
            'Terminal 3 genişletme projesi için kazı ve hafriyat işleri',
        'status': 'in_progress',
        'priority': 'high',
        'location': 'İstanbul Havalimanı, Arnavutköy',
        'address':
            'İstanbul Havalimanı Terminal 3 İnşaat Sahası, Arnavutköy/İstanbul',
        'startDate': now.subtract(const Duration(days: 5)),
        'endDate': now.add(const Duration(days: 10)),
        'estimatedDays': 15,
        'actualDays': 5,
        'assignedOperator': 'Mehmet Demir',
        'machineType': 'Ekskavatör CAT 320',
        'clientName': 'İGA İstanbul Havalimanı',
        'contactPerson': 'Eng. Ahmet Kaya',
        'contactPhone': '+90 212 555 0123',
        'estimatedCost': 250000.0,
        'actualCost': 95000.0,
        'requiredEquipment': ['Ekskavatör', 'Hafriyat Kamyonu', 'Kompaktör'],
        'materials': ['Yakıt', 'Hidrolik Yağ'],
        'workType': 'excavation',
        'notes':
            'Yağmurlu havalarda çalışma durduruluyor. Güvenlik kurallarına uygun çalışın.',
        'progressPercentage': 60.0,
        'isOverdue': false,
      },
      {
        'id': 'W002',
        'title': 'Ankara-İzmir Otoyolu Asfalt Çalışması',
        'description':
            'KM 45-52 arası üst yapı asfalt serimi ve sıkıştırma işleri',
        'status': 'pending',
        'priority': 'medium',
        'location': 'Ankara-İzmir Otoyolu KM:45',
        'address': 'Ankara-İzmir Otoyolu 45. Kilometre, Polatlı/Ankara',
        'startDate': now.add(const Duration(days: 2)),
        'endDate': now.add(const Duration(days: 8)),
        'estimatedDays': 6,
        'actualDays': 0,
        'assignedOperator': 'Fatma Kaya',
        'machineType': 'Asfalt Finişeri',
        'clientName': 'Karayolları Genel Müdürlüğü',
        'contactPerson': 'Müh. Selim Öztürk',
        'contactPhone': '+90 312 555 0456',
        'estimatedCost': 180000.0,
        'actualCost': 0.0,
        'requiredEquipment': ['Asfalt Finişeri', 'Silindir', 'Asfalt Kamyonu'],
        'materials': ['Asfalt Karışımı', 'Primer'],
        'workType': 'road_work',
        'notes': 'Hava sıcaklığı minimum 5°C olmalı.',
        'progressPercentage': 0.0,
        'isOverdue': false,
      },
      {
        'id': 'W003',
        'title': 'Bursa OSB Fabrika Temeli',
        'description':
            'Yeni fabrika binası temel kazısı ve beton döküm hazırlığı',
        'status': 'pending',
        'priority': 'high',
        'location': 'Bursa Organize Sanayi Bölgesi',
        'address': 'BOSB 5. Cadde No:42, Nilüfer/Bursa',
        'startDate': now.add(const Duration(days: 1)),
        'endDate': now.add(const Duration(days: 12)),
        'estimatedDays': 11,
        'actualDays': 0,
        'assignedOperator': 'Ali Yılmaz',
        'machineType': 'Ekskavatör + Dozer',
        'clientName': 'ABC İnşaat Ltd. Şti.',
        'contactPerson': 'Proje Müd. Zeynep Arslan',
        'contactPhone': '+90 224 555 0789',
        'estimatedCost': 320000.0,
        'actualCost': 0.0,
        'requiredEquipment': ['Ekskavatör', 'Dozer', 'Kamyon', 'Vibratör'],
        'materials': ['Yakıt', 'Gres'],
        'workType': 'foundation',
        'notes': 'Zeminde su seviyesi yüksek, su pompası gerekebilir.',
        'progressPercentage': 0.0,
        'isOverdue': false,
      },
      {
        'id': 'W004',
        'title': 'İzmir Liman Yolu Genişletme',
        'description': 'Liman girişi yol genişletme ve altyapı çalışmaları',
        'status': 'completed',
        'priority': 'medium',
        'location': 'İzmir Alsancak Limanı',
        'address': 'Alsancak Liman Girişi, Konak/İzmir',
        'startDate': now.subtract(const Duration(days: 20)),
        'endDate': now.subtract(const Duration(days: 8)),
        'estimatedDays': 12,
        'actualDays': 12,
        'assignedOperator': 'Hasan Çelik',
        'machineType': 'Dozer + Greyder',
        'clientName': 'TCDD Liman İşletmeleri',
        'contactPerson': 'Op. Şefi Murat Kızıl',
        'contactPhone': '+90 232 555 0321',
        'estimatedCost': 195000.0,
        'actualCost': 187500.0,
        'requiredEquipment': ['Dozer', 'Greyder', 'Su Tankeri'],
        'materials': ['Dolgu Malzemesi', 'Stabilize'],
        'workType': 'road_work',
        'notes': 'İş başarıyla tamamlandı. Müşteri memnuniyeti yüksek.',
        'progressPercentage': 100.0,
        'isOverdue': false,
      },
    ];
  }

  Color _getTaskStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return const Color(AppColors.primaryBlue);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTaskStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Bekliyor';
      case 'in_progress':
        return 'Devam Ediyor';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmeyen';
    }
  }

  void _openWorkTaskDetail(Map<String, dynamic> taskData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(taskData['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Durum: ${_getTaskStatusText(taskData['status'])}'),
              Text('Konum: ${taskData['location']}'),
              Text('Operatör: ${taskData['assignedOperator']}'),
              Text('İlerleme: %${taskData['progressPercentage'].toInt()}'),
              const SizedBox(height: 16),
              Text(taskData['description']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
            if (taskData['status'] == 'pending')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İş başlatıldı')),
                  );
                },
                child: const Text('İşi Başlat'),
              ),
          ],
        );
      },
    );
  }

  void _showAllWorkTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkTasksListPage()),
    );
  }

  void _showFeatureComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(AppColors.warningOrange),
      ),
    );
  }
}

class ControlListsPage extends StatefulWidget {
  const ControlListsPage({super.key});

  @override
  State<ControlListsPage> createState() => _ControlListsPageState();
}

class _ControlListsPageState extends State<ControlListsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _statusTabs = [
    {'key': 'all', 'label': 'Tümü', 'icon': Icons.list},
    {'key': 'pending', 'label': 'Bekleyen', 'icon': Icons.pending},
    {'key': 'in_progress', 'label': 'Devam Eden', 'icon': Icons.play_circle},
    {'key': 'completed', 'label': 'Tamamlanan', 'icon': Icons.check_circle},
    {'key': 'approved', 'label': 'Onaylanan', 'icon': Icons.verified},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.grey50),
      appBar: AppBar(
        title: const Text('Kontrol Listeleri'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddControlListDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Kontrol listelerinde ara...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(AppColors.grey500),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              // Status Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: _statusTabs
                    .map(
                      (tab) => Tab(
                        icon: Icon(tab['icon'], size: 18),
                        text: tab['label'],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statusTabs
            .map((tab) => _buildControlListView(tab['key']))
            .toList(),
      ),
    );
  }

  Widget _buildControlListView(String status) {
    // Mock data - will be replaced with real data
    final mockControlLists = _getMockControlLists(status);

    if (mockControlLists.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: mockControlLists.length,
      itemBuilder: (context, index) {
        final controlList = mockControlLists[index];
        return _buildControlListCard(controlList);
      },
    );
  }

  Widget _buildControlListCard(Map<String, dynamic> controlList) {
    final status = controlList['status'] as String;
    final color = _getStatusColor(status);
    final isOverdue = controlList['isOverdue'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.grey300).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isOverdue
            ? Border.all(color: const Color(AppColors.errorRed), width: 2)
            : null,
      ),
      child: InkWell(
        onTap: () => _openControlListDetail(controlList),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controlList['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.grey900),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayText(status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Machine Info
              Row(
                children: [
                  const Icon(
                    Icons.precision_manufacturing,
                    size: 16,
                    color: Color(AppColors.grey500),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${controlList['machineCode']} - ${controlList['machineName']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(AppColors.grey600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                controlList['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(AppColors.grey600),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İlerleme: ${controlList['completedItems']}/${controlList['totalItems']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppColors.grey600),
                        ),
                      ),
                      Text(
                        '${controlList['completionPercentage'].toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(AppColors.grey600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: controlList['completionPercentage'] / 100,
                    backgroundColor: const Color(AppColors.grey300),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Color(AppColors.grey500),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controlList['assignedUser'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppColors.grey600),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: Color(AppColors.grey500),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(DateTime.parse(controlList['createdDate'])),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppColors.grey600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (isOverdue) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.errorRed).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Color(AppColors.errorRed),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Gecikmiş - Acil Müdahale Gerekiyor',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(AppColors.errorRed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'pending':
        message = 'Bekleyen kontrol listesi bulunmuyor';
        icon = Icons.pending;
        break;
      case 'in_progress':
        message = 'Devam eden kontrol listesi bulunmuyor';
        icon = Icons.play_circle;
        break;
      case 'completed':
        message = 'Tamamlanan kontrol listesi bulunmuyor';
        icon = Icons.check_circle;
        break;
      case 'approved':
        message = 'Onaylanan kontrol listesi bulunmuyor';
        icon = Icons.verified;
        break;
      default:
        message = 'Kontrol listesi bulunmuyor';
        icon = Icons.list;
    }

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: const Color(AppColors.grey300)),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(AppColors.grey500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockControlLists(String status) {
    final allLists = [
      {
        'id': '1',
        'title': 'Haftalık Rutin Kontrol',
        'description': 'CNC Torna Tezgahı haftalık bakım ve kontrol listesi',
        'machineCode': 'M001',
        'machineName': 'CNC Torna Tezgahı',
        'status': 'completed',
        'completionPercentage': 100.0,
        'completedItems': 8,
        'totalItems': 8,
        'assignedUser': 'Ahmet Yılmaz',
        'createdDate': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'isOverdue': false,
      },
      {
        'id': '2',
        'title': 'Günlük Güvenlik Kontrolü',
        'description': 'Kaynak Makinası günlük güvenlik kontrol listesi',
        'machineCode': 'M002',
        'machineName': 'Kaynak Makinası',
        'status': 'in_progress',
        'completionPercentage': 60.0,
        'completedItems': 3,
        'totalItems': 5,
        'assignedUser': 'Mehmet Demir',
        'createdDate': DateTime.now()
            .subtract(const Duration(hours: 8))
            .toIso8601String(),
        'isOverdue': false,
      },
      {
        'id': '3',
        'title': 'Aylık Kalibrasyon Kontrolü',
        'description': 'Freze Tezgahı aylık kalibrasyon ve hassasiyet kontrolü',
        'machineCode': 'M003',
        'machineName': 'Freze Tezgahı',
        'status': 'pending',
        'completionPercentage': 0.0,
        'completedItems': 0,
        'totalItems': 6,
        'assignedUser': 'Fatma Kaya',
        'createdDate': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'isOverdue': false,
      },
      {
        'id': '4',
        'title': 'Acil Bakım Kontrolü',
        'description': 'Pres Makinası arıza sonrası güvenlik kontrolü',
        'machineCode': 'M004',
        'machineName': 'Pres Makinası',
        'status': 'pending',
        'completionPercentage': 25.0,
        'completedItems': 1,
        'totalItems': 4,
        'assignedUser': 'Ali Özkan',
        'createdDate': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
        'isOverdue': true,
      },
      {
        'id': '5',
        'title': 'Yıllık Genel Bakım',
        'description': 'Kesme Makinası yıllık genel bakım ve revizyon kontrolü',
        'machineCode': 'M005',
        'machineName': 'Kesme Makinası',
        'status': 'approved',
        'completionPercentage': 100.0,
        'completedItems': 12,
        'totalItems': 12,
        'assignedUser': 'Zeynep Arslan',
        'createdDate': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
        'isOverdue': false,
      },
    ];

    // Search filter
    var filteredLists = allLists;
    if (_searchQuery.isNotEmpty) {
      filteredLists = allLists.where((list) {
        final query = _searchQuery.toLowerCase();
        return (list['title'] as String).toLowerCase().contains(query) ||
            (list['description'] as String).toLowerCase().contains(query) ||
            (list['machineCode'] as String).toLowerCase().contains(query) ||
            (list['machineName'] as String).toLowerCase().contains(query);
      }).toList();
    }

    // Status filter
    if (status != 'all') {
      filteredLists = filteredLists
          .where((list) => list['status'] == status)
          .toList();
    }

    return filteredLists;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(AppColors.warningOrange);
      case 'in_progress':
        return const Color(AppColors.primaryBlue);
      case 'completed':
        return const Color(AppColors.successGreen);
      case 'approved':
        return const Color(AppColors.successGreen);
      case 'rejected':
        return const Color(AppColors.errorRed);
      default:
        return const Color(AppColors.grey500);
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'pending':
        return 'Bekliyor';
      case 'in_progress':
        return 'Devam Ediyor';
      case 'completed':
        return 'Tamamlandı';
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      default:
        return 'Bilinmiyor';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} gün önce';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} saat önce';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  void _openControlListDetail(Map<String, dynamic> controlList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ControlListDetailPage(controlList: controlList),
      ),
    );
  }

  void _showAddControlListDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeni kontrol listesi oluşturma yakında eklenecek...'),
        backgroundColor: Color(AppColors.warningOrange),
      ),
    );
  }

  void _showFilterDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gelişmiş filtreleme yakında eklenecek...'),
        backgroundColor: Color(AppColors.warningOrange),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'tr';

  @override
  Widget build(BuildContext context) {
    final user = MockAuthService.getCurrentUser();

    return Scaffold(
      backgroundColor: const Color(AppColors.grey50),
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Kullanıcı bilgisi bulunamadı'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeader(user),

                  const SizedBox(height: 20),

                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Kişisel Bilgiler',
                    subtitle: 'Profil bilgilerinizi düzenleyin',
                    onTap: _showEditProfileDialog,
                  ),

                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Şifre Değiştir',
                    subtitle: 'Hesap güvenliğinizi güncelleyin',
                    onTap: _showChangePasswordDialog,
                  ),

                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Bildirimler',
                    subtitle: 'Bildirim tercihlerinizi ayarlayın',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        _showFeatureComingSoon('Bildirim ayarları kaydedildi');
                      },
                      activeColor: const Color(AppColors.primaryBlue),
                    ),
                  ),

                  // Role-based menu items
                  ..._buildRoleBasedMenuItems(user),

                  _buildMenuItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Koyu Tema',
                    subtitle: 'Tema tercihini değiştirin',
                    trailing: Switch(
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                        _showFeatureComingSoon(
                          'Tema ayarları yakında aktif olacak',
                        );
                      },
                      activeColor: const Color(AppColors.primaryBlue),
                    ),
                  ),

                  _buildMenuItem(
                    icon: Icons.language_outlined,
                    title: 'Dil Seçimi',
                    subtitle: _selectedLanguage == 'tr' ? 'Türkçe' : 'English',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLanguageDialog,
                  ),

                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Yardım ve Destek',
                    subtitle: 'SSS, iletişim bilgileri',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showFeatureComingSoon(
                      'Yardım sayfası yakında eklenecek',
                    ),
                  ),

                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Uygulama Hakkında',
                    subtitle: 'Sürüm bilgileri ve lisanslar',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showAboutDialog,
                  ),

                  const SizedBox(height: 20),

                  // Logout Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.errorRed),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text(
                            'Çıkış Yap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.grey300).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Color(AppColors.primaryBlue),
            ),
          ),

          const SizedBox(height: 16),

          // User Name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.grey900),
            ),
          ),

          const SizedBox(height: 4),

          // User Email
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 14,
              color: Color(AppColors.grey600),
            ),
          ),

          const SizedBox(height: 8),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleDisplayText(user.role),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getRoleColor(user.role),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Company
          Text(
            user.company ?? 'Şirket Bilgisi Yok',
            style: const TextStyle(
              fontSize: 14,
              color: Color(AppColors.grey600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.grey300).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(AppColors.primaryBlue),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.grey900),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Color(AppColors.grey600)),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(AppColors.errorRed);
      case 'manager':
        return const Color(AppColors.warningOrange);
      case 'operator':
        return const Color(AppColors.primaryBlue);
      default:
        return const Color(AppColors.grey500);
    }
  }

  String _getRoleDisplayText(String role) {
    switch (role) {
      case 'admin':
        return 'Yönetici';
      case 'manager':
        return 'Müdür';
      case 'operator':
        return 'Operatör';
      default:
        return 'Kullanıcı';
    }
  }

  void _showEditProfileDialog() {
    final user = MockAuthService.getCurrentUser();
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final companyController = TextEditingController(text: user.company);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(
                labelText: 'Şirket',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFeatureComingSoon('Profil güncelleme yakında aktif olacak');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
              foregroundColor: Colors.white,
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mevcut Şifre',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre Tekrar',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFeatureComingSoon('Şifre değiştirme yakında aktif olacak');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
              foregroundColor: Colors.white,
            ),
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Türkçe'),
              value: 'tr',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.of(context).pop();
                _showFeatureComingSoon('Dil değişimi yakında aktif olacak');
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.of(context).pop();
                _showFeatureComingSoon(
                  'Language change will be available soon',
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'SmartOp Mobile',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(AppColors.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.precision_manufacturing,
          color: Color(AppColors.primaryBlue),
          size: 32,
        ),
      ),
      children: const [
        Text('Endüstriyel makine kontrol ve izleme sistemi.'),
        SizedBox(height: 8),
        Text('© 2025 SmartOp Teknoloji'),
      ],
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.errorRed),
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await MockAuthService().logout();
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Çıkış yapılırken hata: $e'),
              backgroundColor: const Color(AppColors.errorRed),
            ),
          );
        }
      }
    }
  }

  void _showFeatureComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(AppColors.warningOrange),
      ),
    );
  }

  List<Widget> _buildRoleBasedMenuItems(dynamic user) {
    final permissionService = PermissionService();
    final userRole = user?.role ?? '';
    List<Widget> roleMenuItems = [];

    // Admin specific menu items
    if (permissionService.hasPermission(userRole, 'user_management')) {
      roleMenuItems.add(
        _buildMenuItem(
          icon: Icons.admin_panel_settings,
          title: 'Yönetici Paneli',
          subtitle: 'Sistem yönetimi ve ayarları',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () =>
              _showFeatureComingSoon('Yönetici paneli yakında aktif olacak'),
        ),
      );

      roleMenuItems.add(
        _buildMenuItem(
          icon: Icons.people_alt,
          title: 'Kullanıcı Yönetimi',
          subtitle: 'Kullanıcıları görüntüle ve yönet',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserManagementPage(),
              ),
            );
          },
        ),
      );
    }

    // Manager specific menu items
    if (permissionService.hasPermission(userRole, 'reports')) {
      roleMenuItems.add(
        _buildMenuItem(
          icon: Icons.analytics,
          title: 'Raporlar',
          subtitle: 'Detaylı analiz ve raporlar',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportsPage()),
            );
          },
        ),
      );
    }

    // Company settings for admin and manager
    if (permissionService.canAccessCompanySettings(userRole)) {
      roleMenuItems.add(
        _buildMenuItem(
          icon: Icons.business,
          title: 'Şirket Ayarları',
          subtitle: 'Şirket bilgileri ve yapılandırma',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () =>
              _showFeatureComingSoon('Şirket ayarları yakında aktif olacak'),
        ),
      );
    }

    return roleMenuItems;
  }
}
