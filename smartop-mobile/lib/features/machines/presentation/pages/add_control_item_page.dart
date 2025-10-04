import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/control_item.dart';

class AddControlItemPage extends StatefulWidget {
  final int machineId;
  final ControlItem? controlItem; // null for new, existing for edit

  const AddControlItemPage({
    super.key,
    required this.machineId,
    this.controlItem,
  });

  @override
  State<AddControlItemPage> createState() => _AddControlItemPageState();
}

class _AddControlItemPageState extends State<AddControlItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController();
  final _minValueController = TextEditingController();
  final _maxValueController = TextEditingController();

  String _selectedType = 'visual';
  bool _isRequired = true;
  bool _isLoading = false;

  final List<Map<String, String>> _controlTypes = [
    {'value': 'visual', 'label': 'Görsel Kontrol'},
    {'value': 'measurement', 'label': 'Ölçüm Kontrolü'},
    {'value': 'function', 'label': 'Fonksiyon Kontrolü'},
    {'value': 'safety', 'label': 'Güvenlik Kontrolü'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.controlItem != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final item = widget.controlItem!;
    _titleController.text = item.title;
    _descriptionController.text = item.description;
    _selectedType = item.type;
    _isRequired = item.isRequired;
    _unitController.text = item.unit ?? '';
    _minValueController.text = item.minValue ?? '';
    _maxValueController.text = item.maxValue ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  Future<void> _saveControlItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check user permissions
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null || (!user.isAdmin && !user.isManager)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu işlem için yetkiniz bulunmuyor'),
          backgroundColor: Color(AppColors.errorRed),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.controlItem == null
                  ? 'Kontrol öğesi başarıyla eklendi'
                  : 'Kontrol öğesi başarıyla güncellendi',
            ),
            backgroundColor: const Color(AppColors.successGreen),
          ),
        );

        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: const Color(AppColors.errorRed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.controlItem == null
              ? 'Kontrol Öğesi Ekle'
              : 'Kontrol Öğesi Düzenle',
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveControlItem,
              child: const Text('Kaydet'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: AppSizes.paddingLarge),
            _buildTypeSection(),
            const SizedBox(height: AppSizes.paddingLarge),
            if (_selectedType == 'measurement') ...[
              _buildMeasurementSection(),
              const SizedBox(height: AppSizes.paddingLarge),
            ],
            _buildRequiredSection(),
            const SizedBox(height: AppSizes.paddingXLarge),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(AppColors.primaryBlue),
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                const Text(
                  'Temel Bilgiler',
                  style: TextStyle(
                    fontSize: AppSizes.textLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Kontrol Başlığı *',
                hintText: 'Örn: Motor Yağ Seviyesi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kontrol başlığı gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama *',
                hintText: 'Kontrol işleminin detaylı açıklaması',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Açıklama gereklidir';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: const Color(AppColors.primaryBlue),
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                const Text(
                  'Kontrol Türü',
                  style: TextStyle(
                    fontSize: AppSizes.textLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Kontrol Türü',
                border: OutlineInputBorder(),
              ),
              items: _controlTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Text(type['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.straighten,
                  color: const Color(AppColors.primaryBlue),
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                const Text(
                  'Ölçüm Parametreleri',
                  style: TextStyle(
                    fontSize: AppSizes.textLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Birim',
                hintText: 'Örn: °C, bar, rpm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minValueController,
                    decoration: const InputDecoration(
                      labelText: 'Min Değer',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: TextFormField(
                    controller: _maxValueController,
                    decoration: const InputDecoration(
                      labelText: 'Max Değer',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.priority_high,
                  color: const Color(AppColors.primaryBlue),
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                const Text(
                  'Zorunluluk',
                  style: TextStyle(
                    fontSize: AppSizes.textLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            SwitchListTile(
              title: const Text('Zorunlu Kontrol'),
              subtitle: const Text('Bu kontrolün yapılması zorunlu mu?'),
              value: _isRequired,
              onChanged: (value) {
                setState(() {
                  _isRequired = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveControlItem,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              widget.controlItem == null
                  ? 'Kontrol Öğesi Ekle'
                  : 'Değişiklikleri Kaydet',
              style: const TextStyle(
                fontSize: AppSizes.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
