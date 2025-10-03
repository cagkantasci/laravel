import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/mock_auth_service.dart';
import 'control_list_detail_page.dart';

class ControlListsPage extends StatefulWidget {
  const ControlListsPage({super.key});

  @override
  State<ControlListsPage> createState() => _ControlListsPageState();
}

class _ControlListsPageState extends State<ControlListsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _allControlLists = [];
  List<Map<String, dynamic>> _filteredControlLists = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadControlLists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadControlLists() {
    // Mock data for control lists
    _allControlLists = [
      {
        'id': 'CL001',
        'title': 'CNC Tezgah #1 Günlük Kontrol',
        'machine': 'CNC Tezgah #1',
        'machineCode': 'M001',
        'category': 'Günlük',
        'status': 'completed',
        'priority': 'Yüksek',
        'assignedTo': 'Ahmet Yılmaz',
        'dueDate': DateTime.now().subtract(const Duration(hours: 2)),
        'completedDate': DateTime.now().subtract(const Duration(hours: 1)),
        'description': 'CNC tezgahının günlük rutin kontrol listesi',
        'progress': 100.0,
        'totalItems': 15,
        'completedItems': 15,
        'isOverdue': false,
      },
      {
        'id': 'CL002',
        'title': 'Hadde Makinesi #2 Haftalık Kontrol',
        'machine': 'Hadde Makinesi #2',
        'machineCode': 'M002',
        'category': 'Haftalık',
        'status': 'in_progress',
        'priority': 'Orta',
        'assignedTo': 'Fatma Demir',
        'dueDate': DateTime.now().add(const Duration(hours: 4)),
        'completedDate': null,
        'description': 'Hadde makinesinin haftalık bakım kontrolü',
        'progress': 60.0,
        'totalItems': 20,
        'completedItems': 12,
        'isOverdue': false,
      },
      {
        'id': 'CL003',
        'title': 'Pres Makinesi #3 Güvenlik Kontrolü',
        'machine': 'Pres Makinesi #3',
        'machineCode': 'M003',
        'category': 'Güvenlik',
        'status': 'pending',
        'priority': 'Yüksek',
        'assignedTo': 'Mehmet Kaya',
        'dueDate': DateTime.now().subtract(const Duration(hours: 1)),
        'completedDate': null,
        'description': 'Pres makinesinin acil güvenlik kontrolü',
        'progress': 0.0,
        'totalItems': 25,
        'completedItems': 0,
        'isOverdue': true,
      },
      {
        'id': 'CL004',
        'title': 'Tornalama Tezgahı #4 Kalibrasyon',
        'machine': 'Tornalama Tezgahı #4',
        'machineCode': 'M004',
        'category': 'Kalibrasyon',
        'status': 'in_progress',
        'priority': 'Orta',
        'assignedTo': 'Ayşe Öz',
        'dueDate': DateTime.now().add(const Duration(days: 1)),
        'completedDate': null,
        'description': 'Torna tezgahının hassasiyet kalibrasyonu',
        'progress': 35.0,
        'totalItems': 18,
        'completedItems': 6,
        'isOverdue': false,
      },
      {
        'id': 'CL005',
        'title': 'Kaynak Makinesi #5 Aylık Bakım',
        'machine': 'Kaynak Makinesi #5',
        'machineCode': 'M005',
        'category': 'Aylık',
        'status': 'completed',
        'priority': 'Düşük',
        'assignedTo': 'Ali Veli',
        'dueDate': DateTime.now().subtract(const Duration(days: 2)),
        'completedDate': DateTime.now().subtract(const Duration(days: 1)),
        'description': 'Kaynak makinesinin aylık genel bakımı',
        'progress': 100.0,
        'totalItems': 12,
        'completedItems': 12,
        'isOverdue': false,
      },
    ];
    _filteredControlLists = _allControlLists;
  }

  void _filterControlLists() {
    setState(() {
      _filteredControlLists = _allControlLists.where((list) {
        final matchesSearch =
            list['title'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            list['machine'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            list['machineCode'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        return matchesSearch;
      }).toList();
    });
  }

  List<Map<String, dynamic>> _getFilteredLists(int tabIndex) {
    switch (tabIndex) {
      case 0: // Tümü
        return _filteredControlLists;
      case 1: // Bekleyen
        return _filteredControlLists
            .where((list) => list['status'] == 'pending')
            .toList();
      case 2: // Devam Eden
        return _filteredControlLists
            .where((list) => list['status'] == 'in_progress')
            .toList();
      case 3: // Tamamlanan
        return _filteredControlLists
            .where((list) => list['status'] == 'completed')
            .toList();
      default:
        return _filteredControlLists;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockAuthService.getCurrentUser();
    final canCreate = PermissionService().hasPermission(
      user?.role ?? '',
      'user_management',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Listeleri'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Tümü (${_allControlLists.length})',
              icon: const Icon(Icons.list, size: 16),
            ),
            Tab(
              text:
                  'Bekleyen (${_allControlLists.where((l) => l['status'] == 'pending').length})',
              icon: const Icon(Icons.schedule, size: 16),
            ),
            Tab(
              text:
                  'Devam Eden (${_allControlLists.where((l) => l['status'] == 'in_progress').length})',
              icon: const Icon(Icons.play_circle, size: 16),
            ),
            Tab(
              text:
                  'Tamamlanan (${_allControlLists.where((l) => l['status'] == 'completed').length})',
              icon: const Icon(Icons.check_circle, size: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildControlListView(0),
                _buildControlListView(1),
                _buildControlListView(2),
                _buildControlListView(3),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: _createNewControlList,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Kontrol'),
              backgroundColor: const Color(AppColors.primaryBlue),
            )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Kontrol listesi, makine ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _filterControlLists();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(AppColors.primaryBlue)),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _filterControlLists();
        },
      ),
    );
  }

  Widget _buildControlListView(int tabIndex) {
    final lists = _getFilteredLists(tabIndex);

    if (lists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Kontrol listesi bulunamadı',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni kontrol listesi oluşturmak için + butonunu kullanın',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final controlList = lists[index];
        return _buildControlListCard(controlList);
      },
    );
  }

  Widget _buildControlListCard(Map<String, dynamic> controlList) {
    final isOverdue = controlList['isOverdue'] ?? false;
    final status = controlList['status'];
    final progress = controlList['progress'].toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? const BorderSide(color: Color(AppColors.errorRed), width: 2)
            : BorderSide.none,
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
                children: [
                  Expanded(
                    child: Text(
                      controlList['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(status, isOverdue),
                ],
              ),
              const SizedBox(height: 12),

              // Machine Info
              Row(
                children: [
                  Icon(
                    Icons.precision_manufacturing,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${controlList['machine']} (${controlList['machineCode']})',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İlerleme: ${controlList['completedItems']}/${controlList['totalItems']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${progress.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(progress),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom Info Row
              Row(
                children: [
                  // Category
                  _buildInfoChip(
                    controlList['category'],
                    Icons.category,
                    const Color(AppColors.infoBlue),
                  ),
                  const SizedBox(width: 8),
                  // Priority
                  _buildInfoChip(
                    controlList['priority'],
                    Icons.flag,
                    _getPriorityColor(controlList['priority']),
                  ),
                  const Spacer(),
                  // Due Date
                  Row(
                    children: [
                      Icon(
                        isOverdue ? Icons.schedule : Icons.access_time,
                        size: 14,
                        color: isOverdue
                            ? const Color(AppColors.errorRed)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(controlList['dueDate']),
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue
                              ? const Color(AppColors.errorRed)
                              : Colors.grey[600],
                          fontWeight: isOverdue ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isOverdue) {
    Color color;
    String text;
    IconData icon;

    if (isOverdue) {
      color = const Color(AppColors.errorRed);
      text = 'Gecikmiş';
      icon = Icons.warning;
    } else {
      switch (status) {
        case 'pending':
          color = const Color(AppColors.warningOrange);
          text = 'Bekleyen';
          icon = Icons.schedule;
          break;
        case 'in_progress':
          color = const Color(AppColors.infoBlue);
          text = 'Devam Eden';
          icon = Icons.play_circle;
          break;
        case 'completed':
          color = const Color(AppColors.successGreen);
          text = 'Tamamlandı';
          icon = Icons.check_circle;
          break;
        default:
          color = const Color(AppColors.grey500);
          text = 'Bilinmiyor';
          icon = Icons.help;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return const Color(AppColors.successGreen);
    if (progress >= 50) return const Color(AppColors.warningOrange);
    return const Color(AppColors.errorRed);
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Yüksek':
        return const Color(AppColors.errorRed);
      case 'Orta':
        return const Color(AppColors.warningOrange);
      case 'Düşük':
        return const Color(AppColors.successGreen);
      default:
        return const Color(AppColors.grey500);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inSeconds > 0) {
      return 'Az önce';
    } else {
      final futureDifference = date.difference(now);
      if (futureDifference.inDays > 0) {
        return '${futureDifference.inDays} gün sonra';
      } else if (futureDifference.inHours > 0) {
        return '${futureDifference.inHours} saat sonra';
      } else {
        return '${futureDifference.inMinutes} dakika sonra';
      }
    }
  }

  void _openControlListDetail(Map<String, dynamic> controlList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ControlListDetailPage(controlList: controlList),
      ),
    ).then((_) {
      // Refresh the list when returning from detail page
      _loadControlLists();
    });
  }

  void _createNewControlList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeni kontrol listesi oluşturma özelliği geliştiriliyor'),
        backgroundColor: Color(AppColors.primaryBlue),
      ),
    );
  }
}
