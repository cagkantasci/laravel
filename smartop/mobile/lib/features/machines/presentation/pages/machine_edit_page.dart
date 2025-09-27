import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/machine.dart';

class MachineEditPage extends StatefulWidget {
  final Machine machine;

  const MachineEditPage({super.key, required this.machine});

  @override
  State<MachineEditPage> createState() => _MachineEditPageState();
}

class _MachineEditPageState extends State<MachineEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _modelController;
  late TextEditingController _manufacturerController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _serialNumberController;
  late TextEditingController _installDateController;
  late TextEditingController _operatingHoursController;
  late TextEditingController _maxCapacityController;
  late TextEditingController _powerConsumptionController;
  late TextEditingController _assignedOperatorController;
  late TextEditingController _departmentController;
  late TextEditingController _notesController;

  String _selectedType = '';
  String _selectedStatus = '';
  bool _isActive = true;
  bool _isAutoMode = false;

  final List<String> _machineTypes = [
    'CNC Torna',
    'CNC Freze',
    'Kaynak Makinası',
    'Pres Makinası',
    'Enjeksiyon Makinası',
    'Paketleme Makinası',
    'Konveyör',
    'Test Makinası',
    'Diğer',
  ];

  final List<String> _statusOptions = [
    'active',
    'maintenance',
    'offline',
    'error',
    'idle',
  ];

  final Map<String, String> _statusDisplayNames = {
    'active': 'Çalışıyor',
    'maintenance': 'Bakımda',
    'offline': 'Devre Dışı',
    'error': 'Arızalı',
    'idle': 'Beklemede',
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.machine.name);
    _codeController = TextEditingController(text: widget.machine.code);
    _modelController = TextEditingController(text: widget.machine.model ?? '');
    _manufacturerController = TextEditingController(
      text: widget.machine.manufacturer ?? '',
    );
    _locationController = TextEditingController(text: widget.machine.location);
    _descriptionController = TextEditingController(
      text: widget.machine.description,
    );
    _serialNumberController = TextEditingController(
      text: widget.machine.serialNumber ?? '',
    );
    _installDateController = TextEditingController(
      text: widget.machine.installationDate ?? '',
    );
    _operatingHoursController = TextEditingController(
      text: (widget.machine.operatingHours ?? 0).toString(),
    );
    _maxCapacityController = TextEditingController(
      text: widget.machine.maxCapacity?.toString() ?? '',
    );
    _powerConsumptionController = TextEditingController(
      text: widget.machine.powerConsumption?.toString() ?? '',
    );
    _assignedOperatorController = TextEditingController(
      text: widget.machine.assignedOperator ?? '',
    );
    _departmentController = TextEditingController(
      text: widget.machine.department ?? '',
    );
    _notesController = TextEditingController(text: widget.machine.notes ?? '');

    _selectedType = widget.machine.type;
    // Map machine status to dropdown options
    if (widget.machine.status == 'active') {
      _selectedStatus = 'Çalışıyor';
    } else if (widget.machine.status == 'maintenance') {
      _selectedStatus = 'Bakımda';
    } else if (widget.machine.status == 'error') {
      _selectedStatus = 'Arızalı';
    } else {
      _selectedStatus = 'Durmuş';
    }
    _isActive = widget.machine.isActive;
    _isAutoMode = widget.machine.isAutoMode ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _serialNumberController.dispose();
    _installDateController.dispose();
    _operatingHoursController.dispose();
    _maxCapacityController.dispose();
    _powerConsumptionController.dispose();
    _assignedOperatorController.dispose();
    _departmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makine Düzenle'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveMachine,
            child: const Text(
              'Kaydet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildTechnicalInfoSection(),
              const SizedBox(height: 24),
              _buildOperationalInfoSection(),
              const SizedBox(height: 24),
              _buildStatusSection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Temel Bilgiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Makine Adı *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.precision_manufacturing),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Makine adı gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Makine Kodu *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Makine kodu gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType.isNotEmpty ? _selectedType : null,
              decoration: const InputDecoration(
                labelText: 'Makine Tipi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _machineTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Makine tipi seçiniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.model_training),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _manufacturerController,
              decoration: const InputDecoration(
                labelText: 'Üretici',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serialNumberController,
              decoration: const InputDecoration(
                labelText: 'Seri Numarası',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.engineering, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Teknik Bilgiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxCapacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Maksimum Kapasite (adet/saat)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _powerConsumptionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Güç Tüketimi (kW)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.electrical_services),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _installDateController,
              decoration: const InputDecoration(
                labelText: 'Kurulum Tarihi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'GG.AA.YYYY',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _installDateController.text =
                      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Operasyonel Bilgiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasyon *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lokasyon gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Departman',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assignedOperatorController,
              decoration: const InputDecoration(
                labelText: 'Atanmış Operatör',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _operatingHoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Çalışma Saati (toplam)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'Durum Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus.isNotEmpty ? _selectedStatus : null,
              decoration: const InputDecoration(
                labelText: 'Mevcut Durum *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.analytics),
              ),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_statusDisplayNames[status] ?? status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Durum seçiniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Aktif'),
              subtitle: const Text('Makine aktif durumda'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: const Icon(Icons.power_settings_new),
            ),
            SwitchListTile(
              title: const Text('Otomatik Mod'),
              subtitle: const Text('Makine otomatik modda çalışıyor'),
              value: _isAutoMode,
              onChanged: (value) {
                setState(() {
                  _isAutoMode = value;
                });
              },
              secondary: const Icon(Icons.smart_toy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  'Ek Bilgiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
                alignLabelWithHint: true,
                hintText:
                    'Makine ile ilgili özel notlar, bakım geçmişi, önemli bilgiler...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMachine() {
    if (_formKey.currentState!.validate()) {
      // Mock save operation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Makine bilgileri başarıyla güncellendi!'),
          backgroundColor: Colors.green,
        ),
      );

      // In real app, this would save to database via API
      Navigator.pop(context, true); // Return true to indicate changes were made
    }
  }
}
