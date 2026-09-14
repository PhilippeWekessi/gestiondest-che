import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum TaskPriority { high, medium, low }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'Élevée';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.low:
        return 'Basse';
    }
  }

  // Valeur envoyée et reçue par l'API REST.
  String get apiValue {
    switch (this) {
      case TaskPriority.high:
        return 'high';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.low:
        return 'low';
    }
  }

  static TaskPriority fromApiValue(String value) {
    switch (value) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.high:
        return AppColors.high;
      case TaskPriority.medium:
        return AppColors.mid;
      case TaskPriority.low:
        return AppColors.low;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskPriority.high:
        return AppColors.highBg;
      case TaskPriority.medium:
        return AppColors.midBg;
      case TaskPriority.low:
        return AppColors.lowBg;
    }
  }
}

class Task {
  final String id; // vide tant que la tâche n'est pas encore créée côté API
  String title;
  String content;
  DateTime dateTime;
  TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    required this.priority,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      dateTime: DateTime.parse(json['date_time']),
      priority: TaskPriorityX.fromApiValue(json['priority'] ?? 'medium'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date_time': dateTime.toIso8601String(),
      'priority': priority.apiValue,
    };
  }
}
