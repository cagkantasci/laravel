import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/mock_auth_service.dart';
import '../../data/models/control_list.dart';
import '../../data/services/control_list_service.dart';
import 'fill_control_list_page.dart';
import 'package:intl/intl.dart';

class ControlListsPage extends StatefulWidget {
  const ControlListsPage({super.key});

  @override
  State<ControlListsPage> createState() => _ControlListsPageState();
}

class _ControlListsPageState extends State<ControlListsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ControlListService _controlListService = ControlListService();
  String _searchQuery = '';
  List<ControlList> _allControlLists = [];
  List<ControlList> _filteredControlLists = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadControlLists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadControlLists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lists = await _controlListService.getMyControlLists();
      if (mounted) {
        setState(() {
          _allControlLists = lists;
          _filteredControlLists = lists;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kontrol listeleri yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterControlLists() {
    setState(() {
      _filteredControlLists = _allControlLists.where((list) {
        final matchesSearch =
            list.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (list.machineName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (list.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        return matchesSearch;
      }).toList();
    });
  }

  List<ControlList> _getFilteredLists(int tabIndex) {
    switch (tabIndex) {
      case 0: // Tümü
        return _filteredControlLists;
      case 1: // Bekleyen
        return _filteredControlLists
            .where((list) => list.isPending)
            .toList();
      case 2: // Devam Eden
        return _filteredControlLists
            .where((list) => list.isInProgress)
            .toList();
      case 3: // Tamamlanan
        return _filteredControlLists
            .where((list) => list.isCompleted)
            .toList();
      case 4: // Onaylanan
        return _filteredControlLists
            .where((list) => list.isApproved)
            .toList();
      default:
        return _filteredControlLists;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockAuthService.getCurrentUser();
    final userRole = user?.role ?? '';
    final permissionService = PermissionService();

    final canCreate = permissionService.canCreateControlList(userRole);
    final canApprove = permissionService.canApproveControlList(userRole);
    final canRevert = permissionService.canRevertControlList(userRole);
    final canEdit = permissionService.canEditControlList(userRole);
    final canDelete = permissionService.canDeleteControlList(userRole);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Listeleri'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadControlLists,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(
              text: 'Tümü (${_allControlLists.length})',
              icon: const Icon(Icons.list, size: 16),
            ),
            Tab(
              text:
                  'Bekleyen (${_allControlLists.where((l) => l.isPending).length})',
              icon: const Icon(Icons.schedule, size: 16),
            ),
            Tab(
              text:
                  'Devam Eden (${_allControlLists.where((l) => l.isInProgress).length})',
              icon: const Icon(Icons.play_circle, size: 16),
            ),
            Tab(
              text:
                  'Tamamlanan (${_allControlLists.where((l) => l.isCompleted).length})',
              icon: const Icon(Icons.check_circle, size: 16),
            ),
            Tab(
              text:
                  'Onaylanan (${_allControlLists.where((l) => l.isApproved).length})',
              icon: const Icon(Icons.verified, size: 16),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadControlLists,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildControlListView(0),
                        _buildControlListView(1),
                        _buildControlListView(2),
                        _buildControlListView(3),
                        _buildControlListView(4),
                      ],
                    ),
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

  Widget _buildControlListCard(ControlList controlList) {
    final progress = controlList.completionPercentage;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                      controlList.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(controlList.status),
                ],
              ),
              if (controlList.uuid != null) ...[
                const SizedBox(height: 4),
                Text(
                  controlList.uuid!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Machine Info
              if (controlList.machineName != null) ...[
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
                        controlList.machineName!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İlerleme: ${controlList.completedItemsCount}/${controlList.totalItemsCount}',
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
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(controlList.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (controlList.userName != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        controlList.userName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              // Revert Button (for approved/rejected lists)
              if (controlList.canBeReverted && canRevert) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _revertControlList(controlList),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Geri Al'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    IconData icon;

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
      case 'approved':
        color = Colors.green;
        text = 'Onaylandı';
        icon = Icons.verified;
        break;
      case 'rejected':
        color = const Color(AppColors.errorRed);
        text = 'Reddedildi';
        icon = Icons.cancel;
        break;
      default:
        color = const Color(AppColors.grey500);
        text = 'Bilinmiyor';
        icon = Icons.help;
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

  Color _getProgressColor(double progress) {
    if (progress >= 80) return const Color(AppColors.successGreen);
    if (progress >= 50) return const Color(AppColors.warningOrange);
    return const Color(AppColors.errorRed);
  }

  void _openControlListDetail(ControlList controlList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FillControlListPage(controlList: controlList),
      ),
    ).then((_) {
      _loadControlLists();
    });
  }

  Future<void> _revertControlList(ControlList controlList) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geri Al'),
        content: Text(
          '"${controlList.title}" kontrol listesinin ${controlList.status == 'approved' ? 'onay' : 'red'} işlemini geri almak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Geri Al', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _controlListService.revertControlList(controlList.id.toString());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İşlem başarıyla geri alındı'),
              backgroundColor: Color(AppColors.successGreen),
            ),
          );
          _loadControlLists();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Geri alma hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
