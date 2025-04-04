import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum Priority { low, medium, high }

class TaskModel {
  final String id;
  final String userId;
  final String? goalId;
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final bool isCompleted;
  final Priority priority;
  final DateTime createdAt;
  final List<String> repeatDays;

  TaskModel({
    required this.id,
    required this.userId,
    this.goalId,
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.dueTime,
    this.isCompleted = false,
    this.priority = Priority.medium,
    required this.createdAt,
    this.repeatDays = const [],
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    try {
      // Parse time from "HH:mm" format
      final timeParts = (map['dueTime']?.toString() ?? '00:00').split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return TaskModel(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        goalId: map['goalId'],
        title: map['title'] ?? 'Sin título',
        description: map['description'] ?? '',
        dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        dueTime: TimeOfDay(hour: hour, minute: minute),
        isCompleted: map['isCompleted'] ?? false,
        priority: _parsePriority(map['priority']),
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        repeatDays: List<String>.from(map['repeatDays'] ?? []),
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
      'userId': userId,
      'goalId': goalId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'dueTime': '${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}',
      'isCompleted': isCompleted,
      'priority': priority.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'repeatDays': repeatDays,
    };
  }

  DateTime get combinedDateTime {
    return DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );
  }
}