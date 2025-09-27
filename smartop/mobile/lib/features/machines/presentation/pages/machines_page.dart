import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/offline_aware_widget.dart';
import '../../data/models/machine.dart';
import '../../data/dummy_machine_data.dart';
import 'machine_detail_page.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage>
    with TickerProviderStateMixin, OfflineCapableMixin {
  late TabController _tabController;
  List<Machine> _allMachines = [];
  List<Machine> _filteredMachines = [];
  String _searchQuery = '';
  String _selectedType = 'Tümü';
  String _selectedLocation = 'Tümü';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMachines();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMachines() async {
    try {
      List<Machine> machines;

      if (isConnected) {
        // Load from API or use dummy data
        machines = DummyMachineData.getMachines();
      } else {
        // Load from offline cache
        final cachedData = await getCachedMachines();
        if (cachedData.isNotEmpty) {
          machines = cachedData.map((data) => Machine.fromJson(data)).toList();
        } else {
          // Fallback to dummy data if no cache
          machines = DummyMachineData.getMachines();
        }
      }

      setState(() {
        _allMachines = machines;
        _filteredMachines = machines;
      });
    } catch (e) {
      // Fallback to dummy data on error
      setState(() {
        _allMachines = DummyMachineData.getMachines();
        _filteredMachines = _allMachines;
      });
    }
  }

  void _filterMachines() {
    setState(() {
      _filteredMachines = _allMachines.where((machine) {
        final matchesSearch =
            machine.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            machine.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            machine.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesType =
            _selectedType == 'Tümü' || machine.type == _selectedType;
        final matchesLocation =
            _selectedLocation == 'Tümü' ||
            machine.location == _selectedLocation;

        return matchesSearch && matchesType && matchesLocation;
      }).toList();
    });
  }

  List<Machine> _getMachinesByTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Tümü
        return _filteredMachines;
      case 1: // Aktif
        return _filteredMachines.where((m) => m.isActive).toList();
      case 2: // Bakımda
        return _filteredMachines.where((m) => m.isMaintenance).toList();
      case 3: // Pasif
        return _filteredMachines.where((m) => m.isInactive).toList();
      default:
        return _filteredMachines;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makine Yönetimi'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Tümü (${_allMachines.length})',
              icon: const Icon(Icons.apps, size: 16),
            ),
            Tab(
              text: 'Aktif (${DummyMachineData.getActiveMachines().length})',
              icon: const Icon(Icons.play_circle, size: 16),
            ),
            Tab(
              text:
                  'Bakım (${DummyMachineData.getMaintenanceMachines().length})',
              icon: const Icon(Icons.build, size: 16),
            ),
            Tab(
              text: 'Pasif (${DummyMachineData.getInactiveMachines().length})',
              icon: const Icon(Icons.pause_circle, size: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMachineList(0),
                _buildMachineList(1),
                _buildMachineList(2),
                _buildMachineList(3),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yeni makine ekleme özelliği yakında...'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Makine'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      color: const Color(AppColors.grey50),
      child: Column(
        children: [
          // Arama çubuğu
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterMachines();
            },
            decoration: InputDecoration(
              hintText: 'Makine ara (kod, isim, açıklama)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Filtreler
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Tip',
                  _selectedType,
                  ['Tümü', ...DummyMachineData.getMachineTypes()],
                  (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                    _filterMachines();
                  },
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: _buildFilterDropdown(
                  'Lokasyon',
                  _selectedLocation,
                  ['Tümü', ...DummyMachineData.getMachineLocations()],
                  (value) {
                    setState(() {
                      _selectedLocation = value!;
                    });
                    _filterMachines();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: const Color(AppColors.grey300)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(label),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: AppSizes.textSmall),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMachineList(int tabIndex) {
    final machines = _getMachinesByTab(tabIndex);

    if (machines.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadMachines();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: machines.length,
        itemBuilder: (context, index) {
          final machine = machines[index];
          return _buildMachineCard(machine);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.precision_manufacturing_outlined,
            size: 80,
            color: Color(AppColors.grey300),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedType != 'Tümü' ||
                    _selectedLocation != 'Tümü'
                ? 'Arama kriterlerine uygun makine bulunamadı'
                : 'Henüz makine bulunmuyor',
            style: const TextStyle(
              fontSize: AppSizes.textLarge,
              color: Color(AppColors.grey500),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty ||
              _selectedType != 'Tümü' ||
              _selectedLocation != 'Tümü') ...[
            const SizedBox(height: AppSizes.paddingMedium),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedType = 'Tümü';
                  _selectedLocation = 'Tümü';
                });
                _filterMachines();
              },
              child: const Text('Filtreleri Temizle'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMachineCard(Machine machine) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MachineDetailPage(machine: machine),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        AppColors.primaryBlue,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      machine.code,
                      style: const TextStyle(
                        fontSize: AppSizes.textSmall,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primaryBlue),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(machine.status),
                ],
              ),

              const SizedBox(height: AppSizes.paddingSmall),

              // Name and Description
              Text(
                machine.name,
                style: const TextStyle(
                  fontSize: AppSizes.textLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                machine.description,
                style: const TextStyle(
                  fontSize: AppSizes.textSmall,
                  color: Color(AppColors.grey500),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.paddingMedium),

              // Info Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on,
                      machine.location,
                      const Color(AppColors.grey500),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.category,
                      machine.type,
                      const Color(AppColors.grey500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingSmall),

              // Performance Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildPerformanceMetric(
                      'Verimlilik',
                      '${(machine.efficiency * 100).toInt()}%',
                      Icons.trending_up,
                      _getEfficiencyColor(machine.efficiency),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPerformanceMetric(
                      'Duruma',
                      machine.statusText,
                      _getStatusIcon(machine.status),
                      _getStatusColor(machine.status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPerformanceMetric(
                      'Kontrol',
                      '${machine.controlCompletionRate.toInt()}%',
                      Icons.checklist,
                      _getControlColor(machine.controlCompletionRate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status Indicators Row
              Row(
                children: [
                  if (machine.needsMaintenance) ...[
                    _buildStatusBadge(
                      'Bakım Gerekli',
                      Icons.build,
                      const Color(AppColors.warningOrange),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (machine.controlCompletionRate < 50) ...[
                    _buildStatusBadge(
                      'Kontrol Gerekli',
                      Icons.warning,
                      const Color(AppColors.errorRed),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (machine.isActive && machine.efficiency > 0.9) ...[
                    _buildStatusBadge(
                      'Yüksek Performans',
                      Icons.star,
                      const Color(AppColors.successGreen),
                    ),
                  ],
                  if (machine.needsMaintenance) ...[
                    const SizedBox(width: AppSizes.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSmall,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          AppColors.warningOrange,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 16,
                            color: Color(AppColors.warningOrange),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Bakım Yakın',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(AppColors.warningOrange),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
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
      case 'active':
        color = const Color(AppColors.successGreen);
        text = 'Aktif';
        icon = Icons.play_circle;
        break;
      case 'maintenance':
        color = const Color(AppColors.warningOrange);
        text = 'Bakımda';
        icon = Icons.build;
        break;
      case 'inactive':
        color = const Color(AppColors.grey500);
        text = 'Pasif';
        icon = Icons.pause_circle;
        break;
      default:
        color = const Color(AppColors.grey500);
        text = 'Bilinmiyor';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.textSmall,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: AppSizes.textSmall, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, IconData icon, Color color) {
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
            label,
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

  Color _getEfficiencyColor(double efficiency) {
    if (efficiency >= 0.9) return const Color(AppColors.successGreen);
    if (efficiency >= 0.7) return const Color(AppColors.warningOrange);
    return const Color(AppColors.errorRed);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(AppColors.successGreen);
      case 'maintenance':
        return const Color(AppColors.warningOrange);
      case 'inactive':
        return const Color(AppColors.grey500);
      default:
        return const Color(AppColors.grey500);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.play_circle;
      case 'maintenance':
        return Icons.build;
      case 'inactive':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  Color _getControlColor(double completionRate) {
    if (completionRate >= 80) return const Color(AppColors.successGreen);
    if (completionRate >= 50) return const Color(AppColors.warningOrange);
    return const Color(AppColors.errorRed);
  }
}
