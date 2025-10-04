import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/services/machine_service.dart';

class AddMachinePage extends StatefulWidget {
  const AddMachinePage({super.key});

  @override
  State<AddMachinePage> createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  final _formKey = GlobalKey<FormState>();
  final MachineService _machineService = MachineService();
  final AuthService _authService = AuthService();

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _productionDate;
  DateTime? _installationDate;
  bool _isLoading = false;

  final List<String> _machineTypes = [
    'CNC Torna',
    'CNC Freze',
    'Pres',
    'Kaynak Makinesi',
    'Torna',
    'Freze',
    'Taşlama',
    'Delme',
    'Diğer',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _manufacturerController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMachine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }

      // Generate machine code from name and timestamp
      final machineCode = '${_typeController.text.trim().substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      await _machineService.createMachine(
        name: _nameController.text.trim(),
        code: machineCode,
        type: _typeController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        serialNumber: _serialNumberController.text.trim().isEmpty ? null : _serialNumberController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty ? null : _manufacturerController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        description: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        installationDate: _installationDate?.toIso8601String().split('T')[0],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Makine başarıyla eklendi'),
            backgroundColor: Color(AppColors.successGreen),
          ),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: const Color(AppColors.errorRed),
          ),
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
        title: const Text('Yeni Makine Ekle'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            // Machine Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Makine Adı *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.precision_manufacturing),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Makine adı gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Machine Type (Dropdown)
            DropdownButtonFormField<String>(
              value: _typeController.text.isEmpty ? null : _typeController.text,
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
                  _typeController.text = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Makine tipi gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Model
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Serial Number
            TextFormField(
              controller: _serialNumberController,
              decoration: const InputDecoration(
                labelText: 'Seri Numarası',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Manufacturer
            TextFormField(
              controller: _manufacturerController,
              decoration: const InputDecoration(
                labelText: 'Üretici',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.factory),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Production Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _productionDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _productionDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Üretim Tarihi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _productionDate != null
                      ? '${_productionDate!.day}/${_productionDate!.month}/${_productionDate!.year}'
                      : 'Tarih seçiniz',
                  style: TextStyle(
                    color: _productionDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Installation Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _installationDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _installationDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Kurulum Tarihi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                ),
                child: Text(
                  _installationDate != null
                      ? '${_installationDate!.day}/${_installationDate!.month}/${_installationDate!.year}'
                      : 'Tarih seçiniz',
                  style: TextStyle(
                    color: _installationDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Konum',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMachine,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Makine Ekle',
                      style: TextStyle(
                        fontSize: AppSizes.textLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
