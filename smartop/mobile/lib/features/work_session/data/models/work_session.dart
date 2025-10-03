class WorkSession {
  final int id;
  final String uuid;
  final int machineId;
  final int operatorId;
  final int? controlListId;
  final int companyId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String status;
  final String? location;
  final String? startNotes;
  final String? endNotes;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String? approvalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related objects
  final Machine? machine;
  final User? operator;
  final ControlList? controlList;
  final User? approver;

  WorkSession({
    required this.id,
    required this.uuid,
    required this.machineId,
    required this.operatorId,
    this.controlListId,
    required this.companyId,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    required this.status,
    this.location,
    this.startNotes,
    this.endNotes,
    this.approvedBy,
    this.approvedAt,
    this.approvalNotes,
    required this.createdAt,
    required this.updatedAt,
    this.machine,
    this.operator,
    this.controlList,
    this.approver,
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      id: json['id'],
      uuid: json['uuid'],
      machineId: json['machine_id'],
      operatorId: json['operator_id'],
      controlListId: json['control_list_id'],
      companyId: json['company_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      durationMinutes: json['duration_minutes'],
      status: json['status'],
      location: json['location'],
      startNotes: json['start_notes'],
      endNotes: json['end_notes'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      approvalNotes: json['approval_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      machine: json['machine'] != null ? Machine.fromJson(json['machine']) : null,
      operator: json['operator'] != null ? User.fromJson(json['operator']) : null,
      controlList: json['control_list'] != null ? ControlList.fromJson(json['control_list']) : null,
      approver: json['approver'] != null ? User.fromJson(json['approver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'machine_id': machineId,
      'operator_id': operatorId,
      'control_list_id': controlListId,
      'company_id': companyId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status,
      'location': location,
      'start_notes': startNotes,
      'end_notes': endNotes,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'approval_notes': approvalNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get statusText {
    switch (status) {
      case 'in_progress':
        return 'Devam Ediyor';
      case 'completed':
        return 'Tamamlandı';
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      default:
        return status;
    }
  }

  String get durationFormatted {
    if (durationMinutes == null) return 'N/A';
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    return '$hours saat $minutes dakika';
  }
}

// Placeholder classes - These should be imported from their respective files
class Machine {
  final int id;
  final String name;
  final String? model;

  Machine({required this.id, required this.name, this.model});

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      model: json['model'],
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class ControlList {
  final int id;
  final String title;
  final String status;

  ControlList({required this.id, required this.title, required this.status});

  factory ControlList.fromJson(Map<String, dynamic> json) {
    return ControlList(
      id: json['id'],
      title: json['title'],
      status: json['status'],
    );
  }
}
