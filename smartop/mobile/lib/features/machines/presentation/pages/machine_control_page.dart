import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/machine.dart';
import '../../data/models/control_item.dart';

class MachineControlPage extends StatefulWidget {
  final Machine machine;

  const MachineControlPage({super.key, required this.machine});

  @override
  State<MachineControlPage> createState() => _MachineControlPageState();
}

class _MachineControlPageState extends State<MachineControlPage> {
  late Machine _machine;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final Map<String, List<String>> _controlPhotos = {};

  @override
  void initState() {
    super.initState();
    _machine = widget.machine;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_machine.code} - Kontrol'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveControls),
        ],
      ),
      body: Column(
        children: [
          _buildControlSummary(),
          Expanded(child: _buildControlList()),
        ],
      ),
      floatingActionButton: _machine.allControlsCompleted
          ? FloatingActionButton.extended(
              onPressed: _completeAllControls,
              icon: const Icon(Icons.check_circle),
              label: const Text('Kontrolü Tamamla'),
              backgroundColor: const Color(AppColors.successGreen),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildControlSummary() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
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
              const Text(
                'Kontrol Durumu',
                style: TextStyle(
                  fontSize: AppSizes.textLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_machine.completedControlItems}/${_machine.totalControlItems}',
                style: const TextStyle(
                  fontSize: AppSizes.textLarge,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          LinearProgressIndicator(
            value: _machine.calculatedControlCompletionRate / 100,
            backgroundColor: const Color(AppColors.grey300),
            valueColor: AlwaysStoppedAnimation<Color>(
              _machine.hasFailedControls
                  ? const Color(AppColors.errorRed)
                  : const Color(AppColors.successGreen),
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            _machine.controlStatusText,
            style: TextStyle(
              fontSize: AppSizes.textMedium,
              color: _machine.hasFailedControls
                  ? const Color(AppColors.errorRed)
                  : const Color(AppColors.grey700),
            ),
          ),
          if (_machine.lastControlDate != null) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              'Son kontrol: ${_formatDate(_machine.lastControlDate!)} - ${_machine.lastControlBy}',
              style: const TextStyle(
                fontSize: AppSizes.textSmall,
                color: Color(AppColors.grey500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      itemCount: _machine.controlItems.length,
      itemBuilder: (context, index) {
        final item = _machine.controlItems[index];
        return _buildControlItem(item, index);
      },
    );
  }

  Widget _buildControlItem(ControlItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ExpansionTile(
        leading: _buildControlIcon(item),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: AppSizes.textMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: const TextStyle(
                fontSize: AppSizes.textSmall,
                color: Color(AppColors.grey500),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(item.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Text(
                    item.typeText,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTypeColor(item.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (item.isRequired) ...[
                  const SizedBox(width: AppSizes.paddingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.errorRed).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: const Text(
                      'Zorunlu',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(AppColors.errorRed),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: _buildStatusChip(item),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: _buildControlDetails(item, index),
          ),
        ],
      ),
    );
  }

  Widget _buildControlIcon(ControlItem item) {
    Color color;
    IconData icon;

    if (item.isCompleted) {
      if (item.isPassed) {
        color = const Color(AppColors.successGreen);
        icon = Icons.check_circle;
      } else if (item.isFailed) {
        color = const Color(AppColors.errorRed);
        icon = Icons.error;
      } else {
        color = const Color(AppColors.warningOrange);
        icon = Icons.help;
      }
    } else {
      color = const Color(AppColors.grey300);
      icon = Icons.radio_button_unchecked;
    }

    return Icon(icon, color: color);
  }

  Widget _buildStatusChip(ControlItem item) {
    Color color;
    String text;

    if (item.isCompleted) {
      if (item.isPassed) {
        color = const Color(AppColors.successGreen);
        text = 'Başarılı';
      } else if (item.isFailed) {
        color = const Color(AppColors.errorRed);
        text = 'Başarısız';
      } else {
        color = const Color(AppColors.warningOrange);
        text = 'Uygulanamaz';
      }
    } else {
      color = const Color(AppColors.grey500);
      text = 'Beklemede';
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
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppSizes.textSmall,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildControlDetails(ControlItem item, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.type == 'measurement') ...[
          _buildMeasurementControl(item, index),
        ] else ...[
          _buildGeneralControl(item, index),
        ],
        const SizedBox(height: AppSizes.paddingMedium),
        _buildPhotoSection(item),
        const SizedBox(height: AppSizes.paddingMedium),
        _buildNotesSection(item, index),
        if (item.isCompleted && item.completedDate != null) ...[
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Tamamlandı: ${_formatDateTime(item.completedDate!)} - ${item.completedBy}',
            style: const TextStyle(
              fontSize: AppSizes.textSmall,
              color: Color(AppColors.grey500),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMeasurementControl(ControlItem item, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: item.value ?? ''),
                decoration: InputDecoration(
                  labelText: 'Ölçüm Değeri',
                  hintText: 'Değer girin',
                  suffixText: item.unit,
                  border: const OutlineInputBorder(),
                  enabled: !item.isCompleted,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateControlItem(index, value: value),
              ),
            ),
          ],
        ),
        if (item.rangeText.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Geçerli aralık: ${item.rangeText}',
            style: const TextStyle(
              fontSize: AppSizes.textSmall,
              color: Color(AppColors.grey500),
            ),
          ),
        ],
        if (item.value != null && !item.isValueInRange) ...[
          const SizedBox(height: AppSizes.paddingSmall),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: const Color(AppColors.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, size: 16, color: Color(AppColors.errorRed)),
                SizedBox(width: AppSizes.paddingSmall),
                Text(
                  'Değer geçerli aralık dışında!',
                  style: TextStyle(
                    fontSize: AppSizes.textSmall,
                    color: Color(AppColors.errorRed),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSizes.paddingMedium),
        _buildResultButtons(item, index),
      ],
    );
  }

  Widget _buildGeneralControl(ControlItem item, int index) {
    return _buildResultButtons(item, index);
  }

  Widget _buildResultButtons(ControlItem item, int index) {
    if (item.isCompleted) {
      return Row(
        children: [
          ElevatedButton(
            onPressed: () =>
                _updateControlItem(index, status: 'pending', result: null),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.warningOrange),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yeniden Kontrol Et'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _completeControl(index, 'pass'),
            icon: const Icon(Icons.check),
            label: const Text('Başarılı'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.successGreen),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _completeControl(index, 'fail'),
            icon: const Icon(Icons.close),
            label: const Text('Başarısız'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.errorRed),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _completeControl(index, 'na'),
            icon: const Icon(Icons.remove),
            label: const Text('Uygulanamaz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.grey500),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(ControlItem item) {
    final photos = _controlPhotos[item.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Icon(Icons.camera_alt, size: 16, color: Color(AppColors.grey500)),
            const SizedBox(width: AppSizes.paddingSmall),
            Text(
              'Sorun Fotoğrafları',
              style: TextStyle(
                fontSize: AppSizes.textSmall,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.grey700),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _takePhoto(item.id),
              icon: const Icon(Icons.add_a_photo, size: 16),
              label: const Text('Fotoğraf Çek'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(AppColors.primaryBlue),
                side: BorderSide(color: Color(AppColors.primaryBlue)),
              ),
            ),
            if (photos.isNotEmpty) ...[
              const SizedBox(width: AppSizes.paddingSmall),
              OutlinedButton.icon(
                onPressed: () => _viewPhotos(item.id),
                icon: const Icon(Icons.photo_library, size: 16),
                label: Text('Görüntüle (${photos.length})'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(AppColors.grey700),
                  side: BorderSide(color: Color(AppColors.grey300)),
                ),
              ),
            ],
          ],
        ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingSmall),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSizes.paddingSmall),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: Image.file(
                      File(photos[index]),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection(ControlItem item, int index) {
    return TextField(
      controller: TextEditingController(text: item.notes ?? ''),
      decoration: const InputDecoration(
        labelText: 'Notlar',
        hintText: 'Kontrol hakkında notlarınızı yazın...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) => _updateControlItem(index, notes: value),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'safety':
        return const Color(AppColors.errorRed);
      case 'measurement':
        return const Color(AppColors.infoBlue);
      case 'function':
        return const Color(AppColors.successGreen);
      case 'visual':
        return const Color(AppColors.warningOrange);
      default:
        return const Color(AppColors.grey500);
    }
  }

  void _updateControlItem(
    int index, {
    String? status,
    String? result,
    String? value,
    String? notes,
  }) {
    final updatedItems = List<ControlItem>.from(_machine.controlItems);
    updatedItems[index] = updatedItems[index].copyWith(
      status: status,
      result: result,
      value: value,
      notes: notes,
    );

    setState(() {
      _machine = _machine.copyWith(controlItems: updatedItems);
    });
  }

  void _completeControl(int index, String result) {
    final now = DateTime.now();
    _updateControlItem(index, status: 'completed', result: result);

    // Completion date ve by bilgilerini ayrıca güncelle
    final updatedItems = List<ControlItem>.from(_machine.controlItems);
    updatedItems[index] = updatedItems[index].copyWith(
      completedDate: now,
      completedBy: 'Mevcut Kullanıcı', // Bu gerçek uygulamada auth'dan gelecek
    );

    setState(() {
      _machine = _machine.copyWith(controlItems: updatedItems);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${updatedItems[index].title} kontrolü tamamlandı'),
        backgroundColor: result == 'pass'
            ? const Color(AppColors.successGreen)
            : result == 'fail'
            ? const Color(AppColors.errorRed)
            : const Color(AppColors.warningOrange),
      ),
    );
  }

  void _completeAllControls() {
    if (!_machine.allControlsCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm kontroller tamamlanmadan kontrol sonlandırılamaz'),
          backgroundColor: Color(AppColors.errorRed),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontrolü Tamamla'),
        content: Text(
          'Tüm kontroller tamamlandı. ${_machine.hasFailedControls ? 'Bazı kontrollerde sorun tespit edildi.' : 'Tüm kontroller başarılı.'}\n\nKontrolü sonlandırmak istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _finishControl();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _machine.hasFailedControls
                  ? const Color(AppColors.warningOrange)
                  : const Color(AppColors.successGreen),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tamamla'),
          ),
        ],
      ),
    );
  }

  void _finishControl() {
    final now = DateTime.now();
    setState(() {
      _machine = _machine.copyWith(
        lastControlDate: now,
        lastControlBy: 'Mevcut Kullanıcı',
        controlCompletionRate: _machine.calculatedControlCompletionRate,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _machine.hasFailedControls
              ? 'Kontrol tamamlandı - Dikkat gerektirir'
              : 'Kontrol başarıyla tamamlandı',
        ),
        backgroundColor: _machine.hasFailedControls
            ? const Color(AppColors.warningOrange)
            : const Color(AppColors.successGreen),
      ),
    );

    Navigator.of(context).pop(_machine); // Güncellenmiş makineyi geri döndür
  }

  void _saveControls() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kontrol verileri kaydedildi'),
        backgroundColor: Color(AppColors.successGreen),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _takePhoto(String controlId) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        setState(() {
          if (_controlPhotos[controlId] == null) {
            _controlPhotos[controlId] = [];
          }
          _controlPhotos[controlId]!.add(photo.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fotoğraf başarıyla çekildi'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf çekerken hata: $e'),
            backgroundColor: Color(AppColors.errorRed),
          ),
        );
      }
    }
  }

  void _viewPhotos(String controlId) {
    final photos = _controlPhotos[controlId] ?? [];
    if (photos.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              AppBar(
                title: const Text('Çekilen Fotoğraflar'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(photos[index]), fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
