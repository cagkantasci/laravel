class WorkTask {
  final String id;
  final String title;
  final String description;
  final String status; // pending, in_progress, completed, cancelled
  final String priority; // low, medium, high
  final String location;
  final String address;
  final DateTime startDate;
  final DateTime endDate;
  final int estimatedDays;
  final int actualDays;
  final String assignedOperator;
  final String machineType;
  final String clientName;
  final String contactPerson;
  final String contactPhone;
  final double estimatedCost;
  final double actualCost;
  final List<String> requiredEquipment;
  final List<String> materials;
  final String workType; // excavation, road_work, foundation, etc.
  final String notes;
  final double progressPercentage;

  const WorkTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.location,
    required this.address,
    required this.startDate,
    required this.endDate,
    required this.estimatedDays,
    required this.actualDays,
    required this.assignedOperator,
    required this.machineType,
    required this.clientName,
    required this.contactPerson,
    required this.contactPhone,
    required this.estimatedCost,
    required this.actualCost,
    required this.requiredEquipment,
    required this.materials,
    required this.workType,
    required this.notes,
    required this.progressPercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'location': location,
      'address': address,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'estimatedDays': estimatedDays,
      'actualDays': actualDays,
      'assignedOperator': assignedOperator,
      'machineType': machineType,
      'clientName': clientName,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'requiredEquipment': requiredEquipment,
      'materials': materials,
      'workType': workType,
      'notes': notes,
      'progressPercentage': progressPercentage,
    };
  }

  factory WorkTask.fromJson(Map<String, dynamic> json) {
    return WorkTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      estimatedDays: json['estimatedDays'] ?? 0,
      actualDays: json['actualDays'] ?? 0,
      assignedOperator: json['assignedOperator'] ?? '',
      machineType: json['machineType'] ?? '',
      clientName: json['clientName'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      actualCost: (json['actualCost'] ?? 0).toDouble(),
      requiredEquipment: List<String>.from(json['requiredEquipment'] ?? []),
      materials: List<String>.from(json['materials'] ?? []),
      workType: json['workType'] ?? '',
      notes: json['notes'] ?? '',
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
    );
  }

  WorkTask copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? location,
    String? address,
    DateTime? startDate,
    DateTime? endDate,
    int? estimatedDays,
    int? actualDays,
    String? assignedOperator,
    String? machineType,
    String? clientName,
    String? contactPerson,
    String? contactPhone,
    double? estimatedCost,
    double? actualCost,
    List<String>? requiredEquipment,
    List<String>? materials,
    String? workType,
    String? notes,
    double? progressPercentage,
  }) {
    return WorkTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      address: address ?? this.address,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      actualDays: actualDays ?? this.actualDays,
      assignedOperator: assignedOperator ?? this.assignedOperator,
      machineType: machineType ?? this.machineType,
      clientName: clientName ?? this.clientName,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      requiredEquipment: requiredEquipment ?? this.requiredEquipment,
      materials: materials ?? this.materials,
      workType: workType ?? this.workType,
      notes: notes ?? this.notes,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  bool get isOverdue {
    return DateTime.now().isAfter(endDate) && status != 'completed';
  }

  bool get isHighPriority {
    return priority == 'high';
  }

  bool get isCompleted {
    return status == 'completed';
  }

  bool get isInProgress {
    return status == 'in_progress';
  }

  bool get isPending {
    return status == 'pending';
  }
}
