import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GoalModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double currentProgress;
  final DateTime createdAt;
  final DateTime dueDate;
  final bool isCompleted;
  final List<String> categories;
  final String color;
  final String priority;

  GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.currentProgress = 0.0,
    required this.createdAt,
    required this.dueDate,
    this.isCompleted = false,
    this.categories = const [],
    this.color = '#FF5733',
    this.priority = '2 medium',
  });

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Sin título',
      description: data['description'] ?? '',
      currentProgress: (data['currentProgress'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      categories: List<String>.from(data['categories'] ?? []),
      color: data['color']?.toString() ?? '#FF5733',
      priority: data['priority']?.toString() ?? '2 medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'currentProgress': currentProgress,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'categories': categories,
      'color': color,
      'priority': priority,
    };
  }

  Color get colorAsColor {
    try {
      return Color(int.parse(color.substring(1), radix: 16));
      } catch (e) {
        return Colors.blue.withOpacity(1.0); // Fallback color
      }
    }

  int get priorityValue {
    try {
      return int.parse(priority.split(' ').first);
    } catch (e) {
      return 2; // Medium priority by default
    }
  }

  GoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? currentProgress,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    List<String>? categories,
    String? color,
    String? priority,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      currentProgress: currentProgress ?? this.currentProgress,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      categories: categories ?? this.categories,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }
}