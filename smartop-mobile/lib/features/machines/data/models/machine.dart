import 'control_item.dart';

class Machine {
  final String id;
  final String code;
  final String name;
  final String description;
  final String status;
  final String location;
  final String type;
  final DateTime lastMaintenanceDate;
  final DateTime nextMaintenanceDate;
  final double efficiency;
  final String imageUrl;
  final List<ControlItem> controlItems;
  final DateTime? lastControlDate;
  final String? lastControlBy;
  final double controlCompletionRate;

  // New fields for enhanced machine info
  final String? model;
  final String? manufacturer;
  final String? serialNumber;
  final String? installationDate;
  final double? operatingHours;
  final double? maxCapacity;
  final double? powerConsumption;
  final String? assignedOperator;
  final String? department;
  final String? notes;
  final bool? isAutoMode;

  const Machine({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.status,
    required this.location,
    required this.type,
    required this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    required this.efficiency,
    this.imageUrl = '',
    this.controlItems = const [],
    this.lastControlDate,
    this.lastControlBy,
    this.controlCompletionRate = 0.0,
    this.model,
    this.manufacturer,
    this.serialNumber,
    this.installationDate,
    this.operatingHours,
    this.maxCapacity,
    this.powerConsumption,
    this.assignedOperator,
    this.department,
    this.notes,
    this.isAutoMode,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'inactive',
      location: json['location']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      lastMaintenanceDate:
          DateTime.tryParse(json['last_maintenance_date']?.toString() ?? '') ??
          DateTime.now(),
      nextMaintenanceDate:
          DateTime.tryParse(json['next_maintenance_date']?.toString() ?? '') ??
          DateTime.now(),
      efficiency: double.tryParse(json['efficiency']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url']?.toString() ?? '',
      controlItems:
          (json['control_items'] as List<dynamic>?)
              ?.map(
                (item) => ControlItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      lastControlDate: json['last_control_date'] != null
          ? DateTime.tryParse(json['last_control_date'].toString())
          : null,
      lastControlBy: json['last_control_by']?.toString(),
      controlCompletionRate:
          double.tryParse(json['control_completion_rate']?.toString() ?? '0') ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'status': status,
      'location': location,
      'type': type,
      'last_maintenance_date': lastMaintenanceDate.toIso8601String(),
      'next_maintenance_date': nextMaintenanceDate.toIso8601String(),
      'efficiency': efficiency,
      'image_url': imageUrl,
      'control_items': controlItems.map((item) => item.toJson()).toList(),
      'last_control_date': lastControlDate?.toIso8601String(),
      'last_control_by': lastControlBy,
      'control_completion_rate': controlCompletionRate,
    };
  }

  bool get isActive => status == 'active';
  bool get isMaintenance => status == 'maintenance';
  bool get isInactive => status == 'inactive';

  String get statusText {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'maintenance':
        return 'Bakımda';
      case 'inactive':
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  String get efficiencyText => '${efficiency.toStringAsFixed(1)}%';

  bool get needsMaintenance {
    final now = DateTime.now();
    final daysUntilMaintenance = nextMaintenanceDate.difference(now).inDays;
    return daysUntilMaintenance <= 7; // 7 gün veya daha az kaldıysa
  }

  // Kontrol ile ilgili getter'lar
  int get totalControlItems => controlItems.length;
  int get completedControlItems =>
      controlItems.where((item) => item.isCompleted).length;
  int get passedControlItems =>
      controlItems.where((item) => item.isPassed).length;
  int get failedControlItems =>
      controlItems.where((item) => item.isFailed).length;
  int get pendingControlItems =>
      controlItems.where((item) => item.isPending).length;

  bool get hasControlItems => controlItems.isNotEmpty;
  bool get allControlsCompleted =>
      totalControlItems > 0 && pendingControlItems == 0;
  bool get hasFailedControls => failedControlItems > 0;

  double get calculatedControlCompletionRate {
    if (totalControlItems == 0) return 0.0;
    return (completedControlItems / totalControlItems) * 100;
  }

  String get controlStatusText {
    if (totalControlItems == 0) return 'Kontrol tanımlanmamış';
    if (allControlsCompleted) {
      return hasFailedControls
          ? 'Kontrolde sorun var'
          : 'Tüm kontroller başarılı';
    }
    return '$completedControlItems/$totalControlItems kontrol tamamlandı';
  }

  bool get needsControl {
    if (lastControlDate == null) return true;
    final daysSinceLastControl = DateTime.now()
        .difference(lastControlDate!)
        .inDays;
    return daysSinceLastControl >= 1; // Günlük kontrol gerekli
  }

  Machine copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? status,
    String? location,
    String? type,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    double? efficiency,
    String? imageUrl,
    List<ControlItem>? controlItems,
    DateTime? lastControlDate,
    String? lastControlBy,
    double? controlCompletionRate,
  }) {
    return Machine(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      location: location ?? this.location,
      type: type ?? this.type,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      efficiency: efficiency ?? this.efficiency,
      imageUrl: imageUrl ?? this.imageUrl,
      controlItems: controlItems ?? this.controlItems,
      lastControlDate: lastControlDate ?? this.lastControlDate,
      lastControlBy: lastControlBy ?? this.lastControlBy,
      controlCompletionRate:
          controlCompletionRate ?? this.controlCompletionRate,
    );
  }

  @override
  String toString() {
    return 'Machine(id: $id, code: $code, name: $name, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Machine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
