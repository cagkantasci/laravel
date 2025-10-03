class ControlList {
  final int id;
  final String? uuid;
  final String title;
  final String? description;
  final int? machineId;
  final String? machineName;
  final String? machineType;
  final int? userId;
  final String? userName;
  final int? approvedBy;
  final String? approverName;
  final String status;
  final String? priority;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? notes;
  final List<ControlItem> controlItems;
  final double completionPercentage;
  final String? priorityColor;
  final String? statusColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ControlList({
    required this.id,
    this.uuid,
    required this.title,
    this.description,
    this.machineId,
    this.machineName,
    this.machineType,
    this.userId,
    this.userName,
    this.approvedBy,
    this.approverName,
    required this.status,
    this.priority,
    this.scheduledDate,
    this.completedDate,
    this.approvedAt,
    this.rejectionReason,
    this.notes,
    required this.controlItems,
    required this.completionPercentage,
    this.priorityColor,
    this.statusColor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ControlList.fromJson(Map<String, dynamic> json) {
    return ControlList(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      uuid: json['uuid']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      machineId: json['machine_id'] is int ? json['machine_id'] : int.tryParse(json['machine_id']?.toString() ?? ''),
      machineName: json['machine']?['name']?.toString(),
      machineType: json['machine']?['type']?.toString(),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      userName: json['user']?['name']?.toString(),
      approvedBy: json['approved_by'] is int ? json['approved_by'] : int.tryParse(json['approved_by']?.toString() ?? ''),
      approverName: json['approver']?['name']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority']?.toString(),
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.tryParse(json['scheduled_date'].toString())
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.tryParse(json['completed_date'].toString())
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'].toString())
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
      notes: json['notes']?.toString(),
      controlItems:
          (json['control_items'] as List<dynamic>?)
              ?.map((item) => ControlItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      completionPercentage:
          double.tryParse(json['completion_percentage']?.toString() ?? '0') ?? 0.0,
      priorityColor: json['priority_color']?.toString(),
      statusColor: json['status_color']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'description': description,
      'machine_id': machineId,
      'user_id': userId,
      'approved_by': approvedBy,
      'status': status,
      'priority': priority,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'notes': notes,
      'control_items': controlItems.map((item) => item.toJson()).toList(),
      'completion_percentage': completionPercentage,
    };
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get canBeReverted => isApproved || isRejected;

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

  String get priorityText {
    switch (priority) {
      case 'low':
        return 'Düşük';
      case 'medium':
        return 'Orta';
      case 'high':
        return 'Yüksek';
      case 'critical':
        return 'Kritik';
      default:
        return 'Normal';
    }
  }

  int get completedItemsCount => controlItems.where((item) => item.isCompleted).length;
  int get totalItemsCount => controlItems.length;

  ControlList copyWith({
    int? id,
    String? uuid,
    String? title,
    String? description,
    int? machineId,
    String? machineName,
    String? machineType,
    int? userId,
    String? userName,
    int? approvedBy,
    String? approverName,
    String? status,
    String? priority,
    DateTime? scheduledDate,
    DateTime? completedDate,
    DateTime? approvedAt,
    String? rejectionReason,
    String? notes,
    List<ControlItem>? controlItems,
    double? completionPercentage,
    String? priorityColor,
    String? statusColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ControlList(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      machineType: machineType ?? this.machineType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      approvedBy: approvedBy ?? this.approvedBy,
      approverName: approverName ?? this.approverName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
      controlItems: controlItems ?? this.controlItems,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      priorityColor: priorityColor ?? this.priorityColor,
      statusColor: statusColor ?? this.statusColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ControlList(id: $id, title: $title, status: $status)';
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
  final String? id;
  final String title;
  final String? description;
  final String type;
  final bool required;
  final int order;
  final bool? checked;
  final String? value;
  final String? photoUrl;

  const ControlItem({
    this.id,
    required this.title,
    this.description,
    required this.type,
    required this.required,
    required this.order,
    this.checked,
    this.value,
    this.photoUrl,
  });

  factory ControlItem.fromJson(Map<String, dynamic> json) {
    return ControlItem(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      type: json['type']?.toString() ?? 'checkbox',
      required: json['required'] == true,
      order: json['order'] is int ? json['order'] : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      checked: json['checked'] as bool?,
      value: json['value']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'type': type,
      'required': required,
      'order': order,
      'checked': checked,
      'value': value,
      'photo_url': photoUrl,
    };
  }

  bool get isPending => checked != true;
  bool get isCompleted => checked == true;

  ControlItem copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    bool? required,
    int? order,
    bool? checked,
    String? value,
    String? photoUrl,
  }) {
    return ControlItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      required: required ?? this.required,
      order: order ?? this.order,
      checked: checked ?? this.checked,
      value: value ?? this.value,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  String toString() {
    return 'ControlItem(id: $id, title: $title, checked: $checked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ControlItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
