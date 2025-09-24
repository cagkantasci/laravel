class ControlItem {
  final String id;
  final String title;
  final String description;
  final String type; // 'visual', 'measurement', 'function', 'safety'
  final bool isRequired;
  final String status; // 'pending', 'completed'
  final String? result; // 'pass', 'fail', 'na'
  final String? value; // Ölçüm değeri
  final String? unit; // Birim
  final String? minValue; // Minimum değer
  final String? maxValue; // Maximum değer
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
    this.value,
    this.unit,
    this.minValue,
    this.maxValue,
    this.notes,
    this.completedDate,
    this.completedBy,
  });

  factory ControlItem.fromJson(Map<String, dynamic> json) {
    return ControlItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'visual',
      isRequired: json['is_required'] == true,
      status: json['status']?.toString() ?? 'pending',
      result: json['result']?.toString(),
      value: json['value']?.toString(),
      unit: json['unit']?.toString(),
      minValue: json['min_value']?.toString(),
      maxValue: json['max_value']?.toString(),
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
      'value': value,
      'unit': unit,
      'min_value': minValue,
      'max_value': maxValue,
      'notes': notes,
      'completed_date': completedDate?.toIso8601String(),
      'completed_by': completedBy,
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isPassed => result == 'pass';
  bool get isFailed => result == 'fail';
  bool get isNotApplicable => result == 'na';

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

  String get typeText {
    switch (type) {
      case 'visual':
        return 'Görsel Kontrol';
      case 'measurement':
        return 'Ölçüm';
      case 'function':
        return 'Fonksiyon Testi';
      case 'safety':
        return 'Güvenlik Kontrolü';
      default:
        return 'Genel Kontrol';
    }
  }

  // Ölçüm değerinin geçerli aralıkta olup olmadığını kontrol et
  bool get isValueInRange {
    if (value == null || minValue == null || maxValue == null) return true;

    final numValue = double.tryParse(value!);
    final numMin = double.tryParse(minValue!);
    final numMax = double.tryParse(maxValue!);

    if (numValue == null || numMin == null || numMax == null) return true;

    return numValue >= numMin && numValue <= numMax;
  }

  String get displayValue {
    if (value == null) return '-';
    return unit != null ? '$value $unit' : value!;
  }

  String get rangeText {
    if (minValue == null || maxValue == null) return '';
    final unitText = unit != null ? ' $unit' : '';
    return '$minValue - $maxValue$unitText';
  }

  ControlItem copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    bool? isRequired,
    String? status,
    String? result,
    String? value,
    String? unit,
    String? minValue,
    String? maxValue,
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
      value: value ?? this.value,
      unit: unit ?? this.unit,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
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
