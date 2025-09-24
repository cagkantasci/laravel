class Todo {
  final int? id;
  final String title;
  final String description;
  final String category;
  final Priority priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.priority = Priority.medium,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Factory constructor for creating Todo from database map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      priority: Priority.values[map['priority'] ?? 1],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      isCompleted: map['is_completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Convert Todo to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.index,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated values
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Todo{id: $id, title: $title, category: $category, priority: $priority, isCompleted: $isCompleted}';
  }
}

enum Priority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Düşük';
      case Priority.medium:
        return 'Orta';
      case Priority.high:
        return 'Yüksek';
      case Priority.urgent:
        return 'Acil';
    }
  }

  int get colorValue {
    switch (this) {
      case Priority.low:
        return 0xFF4CAF50; // Green
      case Priority.medium:
        return 0xFF2196F3; // Blue
      case Priority.high:
        return 0xFFFF9800; // Orange
      case Priority.urgent:
        return 0xFFF44336; // Red
    }
  }
}
