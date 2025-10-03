import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'error', 'success'
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String priority; // 'high', 'medium', 'low'

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
    this.priority = 'medium',
  });

  // Getter for body (alias for message)
  String get body => message;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
    String? priority,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  IconData get icon {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'success':
        return Icons.check_circle;
      case 'machine':
        return Icons.precision_manufacturing;
      case 'maintenance':
        return Icons.build;
      case 'quality':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      case 'machine':
        return Colors.blue;
      case 'maintenance':
        return Colors.purple;
      case 'quality':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
