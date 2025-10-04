class Approval {
  final int id;
  final String type; // 'control_list', 'work_session'
  final int itemId;
  final String itemTitle;
  final String itemDescription;
  final int userId;
  final String userName;
  final String userEmail;
  final String status; // 'pending', 'approved', 'rejected'
  final String? machineName;
  final String? machineCode;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final int? approvedBy;
  final String? approverName;
  final String? rejectionReason;

  const Approval({
    required this.id,
    required this.type,
    required this.itemId,
    required this.itemTitle,
    required this.itemDescription,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    this.machineName,
    this.machineCode,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.approverName,
    this.rejectionReason,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      itemId: json['item_id'] ?? 0,
      itemTitle: json['item_title'] ?? '',
      itemDescription: json['item_description'] ?? '',
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      status: json['status'] ?? 'pending',
      machineName: json['machine_name'],
      machineCode: json['machine_code'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      approvedBy: json['approved_by'],
      approverName: json['approver_name'],
      rejectionReason: json['rejection_reason'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class ApprovalStatistics {
  final int totalPending;
  final int totalApproved;
  final int totalRejected;
  final int todayPending;
  final int weekPending;

  const ApprovalStatistics({
    required this.totalPending,
    required this.totalApproved,
    required this.totalRejected,
    required this.todayPending,
    required this.weekPending,
  });

  factory ApprovalStatistics.fromJson(Map<String, dynamic> json) {
    return ApprovalStatistics(
      totalPending: json['total_pending'] ?? 0,
      totalApproved: json['total_approved'] ?? 0,
      totalRejected: json['total_rejected'] ?? 0,
      todayPending: json['today_pending'] ?? 0,
      weekPending: json['week_pending'] ?? 0,
    );
  }
}
