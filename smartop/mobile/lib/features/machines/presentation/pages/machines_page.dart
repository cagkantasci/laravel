import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/machine.dart';
import '../../data/dummy_machine_data.dart';
import 'machine_detail_page.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage>
    with TickerProviderStateMixin {
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

  void _loadMachines() {
    setState(() {
      _allMachines = DummyMachineData.getMachines();
      _filteredMachines = _allMachines;
    });
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

              // Efficiency and Maintenance
              Row(
                children: [
                  if (machine.isActive) ...[
                    Expanded(
                      child: _buildInfoItem(
                        Icons.trending_up,
                        'Verimlilik: ${machine.efficiencyText}',
                        machine.efficiency >= 90
                            ? const Color(AppColors.successGreen)
                            : machine.efficiency >= 70
                            ? const Color(AppColors.warningOrange)
                            : const Color(AppColors.errorRed),
                      ),
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
}
