import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final String description;
  final double currentProgress;
  final DateTime dueDate;
  final String userId;
  final DateTime createdAt;
  final bool isCompleted;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    this.currentProgress = 0.0,
    required this.dueDate,
    required this.userId,
    required this.createdAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'currentProgress': currentProgress,
      'dueDate': Timestamp.fromDate(dueDate),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      currentProgress: (map['currentProgress'] ?? 0.0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  static GoalModel empty() {
    return GoalModel(
      id: '',
      title: '',
      description: '',
      dueDate: DateTime.now().add(Duration(days: 1)),
      userId: '',
      createdAt: DateTime.now(),
    );
  }
}