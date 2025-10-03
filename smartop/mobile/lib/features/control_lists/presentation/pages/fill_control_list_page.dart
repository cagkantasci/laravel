import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/control_list.dart';
import '../../data/services/control_list_service.dart';

/// Operatörlerin kontrol listesini doldurduğu sayfa
class FillControlListPage extends StatefulWidget {
  final ControlList controlList;

  const FillControlListPage({
    super.key,
    required this.controlList,
  });

  @override
  State<FillControlListPage> createState() => _FillControlListPageState();
}

class _FillControlListPageState extends State<FillControlListPage> {
  final ControlListService _service = ControlListService();
  late ControlList _controlList;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controlList = widget.controlList;
    _hasStarted = _controlList.isInProgress;
  }

  Future<void> _startControlList() async {
    setState(() => _isLoading = true);

    try {
      final updated = await _service.startControlList(_controlList.id.toString());
      setState(() {
        _controlList = updated;
        _hasStarted = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontrol listesi başlatıldı'),
            backgroundColor: Color(AppColors.successGreen),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateItem(ControlItem item, Map<String, dynamic> updates) async {
    setState(() => _isSaving = true);

    try {
      await _service.updateControlItem(
        _controlList.id.toString(),
        item.id!,
        updates,
      );

      // Update local item
      final itemIndex = _controlList.controlItems.indexWhere((i) => i.id == item.id);
      if (itemIndex != -1) {
        final updatedItem = item.copyWith(
          checked: updates['checked'] as bool?,
          value: updates['value'] as String?,
          photoUrl: updates['photo_url'] as String?,
        );

        final updatedItems = List<ControlItem>.from(_controlList.controlItems);
        updatedItems[itemIndex] = updatedItem;

        final completedCount = updatedItems.where((i) => i.isCompleted).length;
        final totalCount = updatedItems.length;
        final percentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;

        setState(() {
          _controlList = _controlList.copyWith(
            controlItems: updatedItems,
            completionPercentage: percentage,
          );
          _isSaving = false;
        });
      } else {
        setState(() => _isSaving = false);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydetme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeControlList() async {
    // Zorunlu itemları kontrol et
    final requiredItems = _controlList.controlItems.where((i) => i.required);
    final completedRequired = requiredItems.where((i) => i.isCompleted);

    if (completedRequired.length < requiredItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm zorunlu kontroller tamamlanmalı'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontrolü Tamamla'),
        content: const Text(
          'Kontrol listesini tamamlamak istediğinizden emin misiniz? '
          'Tamamlandıktan sonra değişiklik yapamazsınız.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
            ),
            child: const Text('Tamamla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      try {
        final updated = await _service.completeControlList(_controlList.id.toString());
        setState(() {
          _controlList = updated;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontrol listesi tamamlandı'),
              backgroundColor: Color(AppColors.successGreen),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tamamlama hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _controlList.completionPercentage;
    final canEdit = _hasStarted && !_controlList.isCompleted && !_controlList.isApproved;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Listesi'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          if (canEdit && _hasStarted)
            IconButton(
              onPressed: _completeControlList,
              icon: const Icon(Icons.check_circle),
              tooltip: 'Tamamla',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Card
                  _buildHeaderCard(progress),

                  // Items List
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: _controlList.controlItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildControlItemCard(item, index + 1, canEdit);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: !_hasStarted
          ? _buildStartButton()
          : canEdit
              ? _buildCompleteButton()
              : null,
    );
  }

  Widget _buildHeaderCard(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _controlList.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_controlList.uuid != null) ...[
            const SizedBox(height: 4),
            Text(
              _controlList.uuid!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_controlList.machineName != null) ...[
            Row(
              children: [
                Icon(Icons.precision_manufacturing, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _controlList.machineName!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 100 ? Colors.green : const Color(AppColors.primaryBlue),
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_controlList.completedItemsCount}/${_controlList.totalItemsCount}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            progress == 100
                ? 'Tüm kontroller tamamlandı'
                : _hasStarted
                    ? 'Kontrol devam ediyor...'
                    : 'Başlatmak için aşağıdaki butona basın',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlItemCard(ControlItem item, int number, bool canEdit) {
    final isCompleted = item.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green
                        : canEdit
                            ? const Color(AppColors.primaryBlue)
                            : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '$number',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.required)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Zorunlu',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (canEdit && !isCompleted) ...[
              const SizedBox(height: 12),
              _buildItemActions(item),
            ],
            if (isCompleted) ...[
              const SizedBox(height: 12),
              _buildCompletedInfo(item),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemActions(ControlItem item) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : () => _updateItem(item, {
                    'checked': true,
                  }),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Tamam'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(0, 36),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _isSaving ? null : () => _showValueDialog(item),
          icon: const Icon(Icons.note_add, size: 16),
          label: const Text('Değer Gir'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(0, 36),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedInfo(ControlItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Tamamlandı',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (item.value != null && item.value!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Değer:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showValueDialog(ControlItem item) {
    final valueController = TextEditingController(text: item.value ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değer Gir'),
        content: TextField(
          controller: valueController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Değer giriniz...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final updates = <String, dynamic>{
                'value': valueController.text,
                'checked': true,
              };

              _updateItem(item, updates);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
            ),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _startControlList,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Kontrole Başla',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _completeControlList,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Kontrolü Tamamla',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
