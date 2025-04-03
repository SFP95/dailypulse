import 'package:flutter/material.dart';

enum Priority {
  low,
  medium,
  high,
}

class TaskModel {
  final String id;
  final String goalId;
  final String userId;
  final String title;
  final bool isCompleted;
  final TimeOfDay dueTime;
  final DateTime dueDate;
  final List<String> repeatDays;
  final DateTime createdAt;
  final Priority priority;
  final String description;

  TaskModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    required this.dueTime,
    required this.dueDate,
    this.repeatDays = const [],
    required this.createdAt,
    this.priority = Priority.medium,
    this.description = '',
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    try {
      final timeParts = (map['dueTime'] as String).split(':');
      return TaskModel(
        id: map['id'] as String,
        goalId: map['goalId'] as String,
        userId: map['userId'] as String,
        title: map['title'] as String,
        isCompleted: map['isCompleted'] ?? false,
        dueTime: TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        ),
        dueDate: DateTime.parse(map['dueDate'] as String),
        repeatDays: List<String>.from(map['repeatDays'] ?? []),
        createdAt: DateTime.parse(map['createdAt'] as String),
        priority: _parsePriority(map['priority']),
        description: map['description'] ?? '',
      );
    } catch (e) {
      throw FormatException('Error parsing TaskModel: $e');
    }
  }

  static Priority _parsePriority(dynamic priority) {
    if (priority == null) return Priority.medium;
    if (priority is String) {
      return Priority.values.firstWhere(
            (e) => e.toString().split('.').last == priority.toLowerCase(),
        orElse: () => Priority.medium,
      );
    }
    return Priority.medium;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'title': title,
      'isCompleted': isCompleted,
      'dueTime': '${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}',
      'dueDate': dueDate.toIso8601String(),
      'repeatDays': repeatDays,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'description': description,
    };
  }

  DateTime get combinedDueDateTime {
    return DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );
  }
}