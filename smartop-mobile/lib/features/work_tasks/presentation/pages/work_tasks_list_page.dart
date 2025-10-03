import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class WorkTasksListPage extends StatefulWidget {
  const WorkTasksListPage({super.key});

  @override
  State<WorkTasksListPage> createState() => _WorkTasksListPageState();
}

class _WorkTasksListPageState extends State<WorkTasksListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Yapılacak İşler',
          style: TextStyle(
            fontSize: AppSizes.textLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _addNewTask, icon: const Icon(Icons.add)),
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Bekliyor'),
            Tab(text: 'Devam Eden'),
            Tab(text: 'Tamamlanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(_getAllTasks()),
          _buildTaskList(_getPendingTasks()),
          _buildTaskList(_getInProgressTasks()),
          _buildTaskList(_getCompletedTasks()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: const Color(AppColors.primaryBlue),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Bu kategoride iş bulunmuyor',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final isUrgent = task['priority'] == 'high' || task['isOverdue'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isUrgent
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
            : null,
      ),
      child: InkWell(
        onTap: () => _openTaskDetail(task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      color: _getTaskStatusColor(
                        task['status'],
                      ).withOpacity(0.1),
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
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 16),
                            SizedBox(width: 8),
                            Text('Kopyala'),
                          ],
                        ),
                      ),
                      if (task['status'] != 'completed')
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Sil', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                    onSelected: (value) => _handleTaskAction(value, task),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task['location'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    task['assignedOperator'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${task['estimatedDays']} gün',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  if (task['status'] == 'in_progress')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          AppColors.primaryBlue,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '%${task['progressPercentage'].toInt()}',
                        style: const TextStyle(
                          color: Color(AppColors.primaryBlue),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllTasks() {
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
        'startDate': now.subtract(const Duration(days: 5)),
        'endDate': now.add(const Duration(days: 10)),
        'estimatedDays': 15,
        'assignedOperator': 'Mehmet Demir',
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
        'startDate': now.add(const Duration(days: 2)),
        'endDate': now.add(const Duration(days: 8)),
        'estimatedDays': 6,
        'assignedOperator': 'Fatma Kaya',
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
        'startDate': now.add(const Duration(days: 1)),
        'endDate': now.add(const Duration(days: 12)),
        'estimatedDays': 11,
        'assignedOperator': 'Ali Yılmaz',
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
        'startDate': now.subtract(const Duration(days: 20)),
        'endDate': now.subtract(const Duration(days: 8)),
        'estimatedDays': 12,
        'assignedOperator': 'Hasan Çelik',
        'progressPercentage': 100.0,
        'isOverdue': false,
      },
    ];
  }

  List<Map<String, dynamic>> _getPendingTasks() {
    return _getAllTasks().where((task) => task['status'] == 'pending').toList();
  }

  List<Map<String, dynamic>> _getInProgressTasks() {
    return _getAllTasks()
        .where((task) => task['status'] == 'in_progress')
        .toList();
  }

  List<Map<String, dynamic>> _getCompletedTasks() {
    return _getAllTasks()
        .where((task) => task['status'] == 'completed')
        .toList();
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

  void _openTaskDetail(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Durum: ${_getTaskStatusText(task['status'])}'),
              Text('Konum: ${task['location']}'),
              Text('Operatör: ${task['assignedOperator']}'),
              Text('İlerleme: %${task['progressPercentage'].toInt()}'),
              const SizedBox(height: 16),
              Text(task['description']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
            if (task['status'] == 'pending')
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

  void _handleTaskAction(String action, Map<String, dynamic> task) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Düzenleme sayfası yakında eklenecek')),
        );
        break;
      case 'duplicate':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İş kopyalandı')));
        break;
      case 'delete':
        _showDeleteConfirmation(task);
        break;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İşi Sil'),
          content: Text(
            '${task['title']} işini silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('İş silindi')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _addNewTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni iş ekleme sayfası yakında eklenecek')),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrele',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.priority_high),
                title: const Text('Önceliğe Göre'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Öncelik filtresi yakında eklenecek'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Konuma Göre'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Konum filtresi yakında eklenecek'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Operatöre Göre'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Operatör filtresi yakında eklenecek'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
