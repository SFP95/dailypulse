import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      // Manejo mejorado de dueTime
      final timeStr = map['dueTime']?.toString() ?? '00:00';
      final timeParts = timeStr.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;

      // Manejo robusto de dueDate (Timestamp o String)
      DateTime parseDueDate(dynamic date) {
        if (date == null) return DateTime.now();
        if (date is Timestamp) return date.toDate();
        if (date is String) return DateTime.parse(date);
        if (date is DateTime) return date;
        throw FormatException('Formato de fecha no válido');
      }

      return TaskModel(
        id: map['id']?.toString() ?? '',
        goalId: map['goalId']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        title: map['title']?.toString() ?? 'Sin título',
        isCompleted: map['isCompleted'] ?? false,
        dueTime: TimeOfDay(hour: hour, minute: minute),
        dueDate: parseDueDate(map['dueDate']),
        repeatDays: List<String>.from(map['repeatDays'] ?? []),
        createdAt: parseDueDate(map['createdAt']),
        priority: _parsePriority(map['priority']),
        description: map['description']?.toString() ?? '',
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
      'dueDate': Timestamp.fromDate(dueDate), // Guardar como Timestamp
      'repeatDays': repeatDays,
      'createdAt': Timestamp.fromDate(createdAt), // Guardar como Timestamp
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