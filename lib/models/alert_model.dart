
import 'package:flutter/material.dart';

enum AlertType {
  medication,
  appointment,
  vitalOutOfRange,
  prescriptionExpiry,
  general;

  String get label {
    switch (this) {
      case AlertType.medication:
        return 'Médicament';
      case AlertType.appointment:
        return 'Rendez-vous';
      case AlertType.vitalOutOfRange:
        return 'Constante anormale';
      case AlertType.prescriptionExpiry:
        return 'Ordonnance expirée';
      case AlertType.general:
        return 'Information';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertType.medication:
        return Icons.medication;
      case AlertType.appointment:
        return Icons.calendar_today;
      case AlertType.vitalOutOfRange:
        return Icons.warning;
      case AlertType.prescriptionExpiry:
        return Icons.description;
      case AlertType.general:
        return Icons.notifications;
    }
  }
}

enum AlertPriority {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case AlertPriority.low:
        return 'Basse';
      case AlertPriority.medium:
        return 'Moyenne';
      case AlertPriority.high:
        return 'Haute';
      case AlertPriority.critical:
        return 'Critique';
    }
  }

  Color get color {
    switch (this) {
      case AlertPriority.low:
        return Colors.green;
      case AlertPriority.medium:
        return Colors.orange;
      case AlertPriority.high:
        return Colors.red;
      case AlertPriority.critical:
        return Colors.purple;
    }
  }
}

class Alert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertPriority priority;
  final DateTime scheduledAt;
  final DateTime? triggeredAt;
  final DateTime? readAt;
  final bool isRecurring;
  final int? recurringIntervalMinutes;
  final String? actionId;
  final Map<String, dynamic>? actionData;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.scheduledAt,
    this.triggeredAt,
    this.readAt,
    this.isRecurring = false,
    this.recurringIntervalMinutes,
    this.actionId,
    this.actionData,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRead => readAt != null;
  bool get isTriggered => triggeredAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'scheduledAt': scheduledAt.toIso8601String(),
      'triggeredAt': triggeredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringIntervalMinutes': recurringIntervalMinutes,
      'actionId': actionId,
      'actionData': actionData,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Alert.fromMap(Map<String, dynamic> map, [String? id]) {
    return Alert(
      id: id ?? map['id'],
      title: map['title'],
      message: map['message'],
      type: AlertType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => AlertType.general,
      ),
      priority: AlertPriority.values.firstWhere(
            (e) => e.name == map['priority'],
        orElse: () => AlertPriority.medium,
      ),
      scheduledAt: DateTime.parse(map['scheduledAt']),
      triggeredAt: map['triggeredAt'] != null
          ? DateTime.parse(map['triggeredAt'])
          : null,
      readAt: map['readAt'] != null
          ? DateTime.parse(map['readAt'])
          : null,
      isRecurring: map['isRecurring'],
      recurringIntervalMinutes: map['recurringIntervalMinutes'],
      actionId: map['actionId'],
      actionData: map['actionData'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}