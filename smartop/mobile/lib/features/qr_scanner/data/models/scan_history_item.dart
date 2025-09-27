class ScanHistoryItem {
  final String id;
  final String scannedCode;
  final String codeType;
  final DateTime scanTime;
  final String result;
  final bool isSuccessful;
  final Map<String, dynamic>? metadata;

  ScanHistoryItem({
    required this.id,
    required this.scannedCode,
    required this.codeType,
    required this.scanTime,
    required this.result,
    required this.isSuccessful,
    this.metadata,
  });

  String get formattedScanTime {
    final now = DateTime.now();
    final difference = now.difference(scanTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scannedCode': scannedCode,
      'codeType': codeType,
      'scanTime': scanTime.toIso8601String(),
      'result': result,
      'isSuccessful': isSuccessful,
      'metadata': metadata,
    };
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'],
      scannedCode: json['scannedCode'],
      codeType: json['codeType'],
      scanTime: DateTime.parse(json['scanTime']),
      result: json['result'],
      isSuccessful: json['isSuccessful'],
      metadata: json['metadata'],
    );
  }
}
