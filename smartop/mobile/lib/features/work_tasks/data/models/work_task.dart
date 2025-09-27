class WorkTask {
  final String id;
  final String title;
  final String description;
  final String status; // pending, in_progress, completed, cancelled
  final String priority; // high, medium, low
  final String location;
  final String address;
  final DateTime startDate;
  final DateTime? endDate;
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
  final String
  workType; // excavation, demolition, construction, transportation, etc.
  final String notes;
  final List<String> photos;
  final double progressPercentage;
  final String? cancelReason;

  const WorkTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.location,
    required this.address,
    required this.startDate,
    this.endDate,
    required this.estimatedDays,
    this.actualDays = 0,
    required this.assignedOperator,
    required this.machineType,
    required this.clientName,
    required this.contactPerson,
    required this.contactPhone,
    required this.estimatedCost,
    this.actualCost = 0.0,
    this.requiredEquipment = const [],
    this.materials = const [],
    required this.workType,
    this.notes = '',
    this.photos = const [],
    this.progressPercentage = 0.0,
    this.cancelReason,
  });

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Bekliyor';
      case 'in_progress':
        return 'Devam Ediyor';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmeyen';
    }
  }

  String get priorityText {
    switch (priority) {
      case 'high':
        return 'Yüksek';
      case 'medium':
        return 'Orta';
      case 'low':
        return 'Düşük';
      default:
        return 'Orta';
    }
  }

  String get workTypeText {
    switch (workType) {
      case 'excavation':
        return 'Kazı İşleri';
      case 'demolition':
        return 'Yıkım İşleri';
      case 'construction':
        return 'İnşaat İşleri';
      case 'transportation':
        return 'Taşıma İşleri';
      case 'landscaping':
        return 'Peyzaj İşleri';
      case 'road_work':
        return 'Yol İşleri';
      case 'pipeline':
        return 'Boru Hattı İşleri';
      case 'foundation':
        return 'Temel İşleri';
      default:
        return 'Genel İşler';
    }
  }

  bool get isOverdue {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!) && status != 'completed';
  }

  bool get isUrgent {
    return priority == 'high' || isOverdue;
  }

  int get remainingDays {
    if (endDate == null) return estimatedDays;
    final remaining = endDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
}
