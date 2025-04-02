import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  });

  // Versión CORRECTA de fromMap (ID dentro del mapa)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    final time = map['dueTime'] as String;
    return TaskModel(
      id: map['id'] as String, // El ID viene dentro del mapa
      goalId: map['goalId'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] ?? false,
      dueTime: TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]),
      ),
      dueDate: DateTime.parse(map['dueDate'] as String),
      repeatDays: List<String>.from(map['repeatDays'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      priority: _parsePriority(map['priority']),
    );
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
  'dueTime': '${dueTime.hour}:${dueTime.minute}',
  'dueDate': dueDate.toIso8601String(),
  'repeatDays': repeatDays,
  'createdAt': createdAt.toIso8601String(),
  'priority': priority.toString().split('.').last,
  };
  }
}