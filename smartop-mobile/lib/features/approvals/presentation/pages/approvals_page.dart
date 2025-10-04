import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/approval.dart';
import '../../data/services/approval_service.dart';

class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({super.key});

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> with SingleTickerProviderStateMixin {
  final ApprovalService _approvalService = ApprovalService();
  final AuthService _authService = AuthService();

  late TabController _tabController;
  ApprovalStatistics? _statistics;
  List<Approval> _pendingApprovals = [];
  bool _isLoading = false;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    final user = _authService.currentUser;
    if (user == null || (!user.isAdmin && !user.isManager)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu sayfaya erişim yetkiniz yok')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final statistics = await _approvalService.getStatistics();
      final approvals = await _approvalService.getPendingApprovals(
        type: _selectedType,
      );

      setState(() {
        _statistics = statistics;
        _pendingApprovals = approvals;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onay Bekleyenler'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bekleyenler'),
            Tab(text: 'İstatistikler'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_isLoading && _pendingApprovals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingApprovals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Color(AppColors.successGreen),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Onay bekleyen işlem yok',
              style: TextStyle(
                fontSize: AppSizes.textLarge,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: _pendingApprovals.length,
        itemBuilder: (context, index) {
          return _buildApprovalCard(_pendingApprovals[index]);
        },
      ),
    );
  }

  Widget _buildApprovalCard(Approval approval) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTypeIcon(approval.type),
                  color: const Color(AppColors.primaryBlue),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Text(
                    approval.itemTitle,
                    style: const TextStyle(
                      fontSize: AppSizes.textLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              approval.itemDescription,
              style: const TextStyle(color: Colors.grey),
            ),
            if (approval.machineName != null) ...[
              const SizedBox(height: AppSizes.paddingSmall),
              Row(
                children: [
                  const Icon(Icons.precision_manufacturing, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    approval.machineName!,
                    style: const TextStyle(fontSize: AppSizes.textSmall),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSizes.paddingSmall),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  approval.userName,
                  style: const TextStyle(fontSize: AppSizes.textSmall),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy HH:mm', 'tr_TR').format(approval.createdAt),
                  style: const TextStyle(
                    fontSize: AppSizes.textSmall,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showRejectDialog(approval),
                  icon: const Icon(Icons.close, color: Color(AppColors.errorRed)),
                  label: const Text(
                    'Reddet',
                    style: TextStyle(color: Color(AppColors.errorRed)),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                ElevatedButton.icon(
                  onPressed: () => _approveItem(approval),
                  icon: const Icon(Icons.check),
                  label: const Text('Onayla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.successGreen),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          _buildStatCard(
            'Bekleyen Onaylar',
            _statistics!.totalPending.toString(),
            Icons.pending_actions,
            const Color(AppColors.warningOrange),
          ),
          _buildStatCard(
            'Onaylanan',
            _statistics!.totalApproved.toString(),
            Icons.check_circle,
            const Color(AppColors.successGreen),
          ),
          _buildStatCard(
            'Reddedilen',
            _statistics!.totalRejected.toString(),
            Icons.cancel,
            const Color(AppColors.errorRed),
          ),
          _buildStatCard(
            'Bugün Bekleyen',
            _statistics!.todayPending.toString(),
            Icons.today,
            const Color(AppColors.infoBlue),
          ),
          _buildStatCard(
            'Bu Hafta Bekleyen',
            _statistics!.weekPending.toString(),
            Icons.calendar_today,
            const Color(AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.textXXLarge,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'control_list':
        return Icons.checklist;
      case 'work_session':
        return Icons.work;
      default:
        return Icons.assignment;
    }
  }

  Future<void> _approveItem(Approval approval) async {
    try {
      await _approvalService.approve(approval.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onaylandı'),
            backgroundColor: Color(AppColors.successGreen),
          ),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showRejectDialog(Approval approval) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reddetme Nedeni'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Neden reddedildiğini yazın...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen bir neden girin')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                await _approvalService.reject(approval.id, reasonController.text);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reddedildi'),
                      backgroundColor: Color(AppColors.errorRed),
                    ),
                  );
                  await _loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.errorRed),
            ),
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tümü'),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() => _selectedType = value);
                  Navigator.pop(context);
                  _loadData();
                },
              ),
            ),
            ListTile(
              title: const Text('Kontrol Listeleri'),
              leading: Radio<String?>(
                value: 'control_list',
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() => _selectedType = value);
                  Navigator.pop(context);
                  _loadData();
                },
              ),
            ),
            ListTile(
              title: const Text('İş Seansları'),
              leading: Radio<String?>(
                value: 'work_session',
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() => _selectedType = value);
                  Navigator.pop(context);
                  _loadData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
