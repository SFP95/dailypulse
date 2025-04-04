import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Constructor principal
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

  // Métodos estáticos para consultas
  static Query baseQuery(String userId) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('goalId')
        .orderBy('dueDate');
  }

  static Query forGoal(String userId, String goalId) {
    return baseQuery(userId).where('goalId', isEqualTo: goalId);
  }

  static Query forDateRange(String userId, DateTime start, DateTime end) {
    return baseQuery(userId)
        .where('dueDate', isGreaterThanOrEqualTo: start)
        .where('dueDate', isLessThanOrEqualTo: end);
  }

  // Constructores desde Firestore
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    try {
      return TaskModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id});
    } catch (e) {
      throw FormatException('Error parsing TaskModel from Firestore: $e');
    }
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    try {
      final timeStr = map['dueTime']?.toString() ?? '00:00';
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]) ?? 0;

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

  // Métodos de conversión
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isCompleted': isCompleted,
      'dueDate': Timestamp.fromDate(dueDate),
      'dueTime': '${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}','isCompleted': isCompleted,
      'priority': priority.name, // Usamos .name en lugar de toString()
      'createdAt': Timestamp.fromDate(createdAt),
      'repeatDays': repeatDays,
    };
  }

  // Helpers
  static Priority _parsePriority(dynamic priority) {
    if (priority == null) return Priority.medium;
    if (priority is String) {
      return Priority.values.firstWhere(
            (e) => e.name == priority.toLowerCase(),
        orElse: () => Priority.medium,
      );
    }
    return Priority.medium;
  }

  DateTime get combinedDateTime => DateTime(
    dueDate.year,
    dueDate.month,
    dueDate.day,
    dueTime.hour,
    dueTime.minute,
  );

  // Métodos para UI
  String get formattedDueTime => '${dueTime.hour}:${dueTime.minute.toString().padLeft(2, '0')}';
  String get formattedDueDate => DateFormat('dd/MM/yyyy').format(dueDate);
  String get priorityText => priority.name.toUpperCase();

  // Para debugging
  @override
  String toString() => 'Task($title, due: $formattedDueDate $formattedDueTime)';
}