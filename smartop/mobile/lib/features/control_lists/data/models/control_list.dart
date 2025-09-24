class ControlList {
  final String id;
  final String code;
  final String title;
  final String description;
  final String machineId;
  final String machineCode;
  final String machineName;
  final String status;
  final DateTime createdDate;
  final DateTime? completedDate;
  final String createdBy;
  final String? completedBy;
  final List<ControlItem> items;
  final double completionPercentage;

  const ControlList({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.machineId,
    required this.machineCode,
    required this.machineName,
    required this.status,
    required this.createdDate,
    this.completedDate,
    required this.createdBy,
    this.completedBy,
    required this.items,
    required this.completionPercentage,
  });

  factory ControlList.fromJson(Map<String, dynamic> json) {
    return ControlList(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      machineId: json['machine_id']?.toString() ?? '',
      machineCode: json['machine_code']?.toString() ?? '',
      machineName: json['machine_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdDate:
          DateTime.tryParse(json['created_date']?.toString() ?? '') ??
          DateTime.now(),
      completedDate: json['completed_date'] != null
          ? DateTime.tryParse(json['completed_date'].toString())
          : null,
      createdBy: json['created_by']?.toString() ?? '',
      completedBy: json['completed_by']?.toString(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) => ControlItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      completionPercentage:
          double.tryParse(json['completion_percentage']?.toString() ?? '0') ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'machine_id': machineId,
      'machine_code': machineCode,
      'machine_name': machineName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'created_by': createdBy,
      'completed_by': completedBy,
      'items': items.map((item) => item.toJson()).toList(),
      'completion_percentage': completionPercentage,
    };
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'in_progress':
        return 'Devam Ediyor';
      case 'completed':
        return 'Tamamlandı';
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      default:
        return 'Bilinmiyor';
    }
  }

  int get completedItemsCount => items.where((item) => item.isCompleted).length;
  int get totalItemsCount => items.length;

  ControlList copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? machineId,
    String? machineCode,
    String? machineName,
    String? status,
    DateTime? createdDate,
    DateTime? completedDate,
    String? createdBy,
    String? completedBy,
    List<ControlItem>? items,
    double? completionPercentage,
  }) {
    return ControlList(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      machineId: machineId ?? this.machineId,
      machineCode: machineCode ?? this.machineCode,
      machineName: machineName ?? this.machineName,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      completedDate: completedDate ?? this.completedDate,
      createdBy: createdBy ?? this.createdBy,
      completedBy: completedBy ?? this.completedBy,
      items: items ?? this.items,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  @override
  String toString() {
    return 'ControlList(id: $id, code: $code, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ControlList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ControlItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final bool isRequired;
  final String status;
  final String? result;
  final String? notes;
  final DateTime? completedDate;
  final String? completedBy;

  const ControlItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isRequired,
    required this.status,
    this.result,
    this.notes,
    this.completedDate,
    this.completedBy,
  });

  factory ControlItem.fromJson(Map<String, dynamic> json) {
    return ControlItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'check',
      isRequired: json['is_required'] == true,
      status: json['status']?.toString() ?? 'pending',
      result: json['result']?.toString(),
      notes: json['notes']?.toString(),
      completedDate: json['completed_date'] != null
          ? DateTime.tryParse(json['completed_date'].toString())
          : null,
      completedBy: json['completed_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'is_required': isRequired,
      'status': status,
      'result': result,
      'notes': notes,
      'completed_date': completedDate?.toIso8601String(),
      'completed_by': completedBy,
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isPassed => result == 'pass';
  bool get isFailed => result == 'fail';

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'completed':
        return 'Tamamlandı';
      default:
        return 'Bilinmiyor';
    }
  }

  String get resultText {
    switch (result) {
      case 'pass':
        return 'Başarılı';
      case 'fail':
        return 'Başarısız';
      case 'na':
        return 'Uygulanamaz';
      default:
        return 'Beklemede';
    }
  }

  ControlItem copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    bool? isRequired,
    String? status,
    String? result,
    String? notes,
    DateTime? completedDate,
    String? completedBy,
  }) {
    return ControlItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      status: status ?? this.status,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      completedDate: completedDate ?? this.completedDate,
      completedBy: completedBy ?? this.completedBy,
    );
  }

  @override
  String toString() {
    return 'ControlItem(id: $id, title: $title, status: $status, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ControlItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
