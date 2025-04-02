import 'package:dailypulse/models/user_model.dart';

import '../utils/date_helpers.dart';

class ProgressModel {
  final String id;
  final String userId;
  final String goalId;
  final DateTime date;
  final double percentage;
  final int tasksCompleted;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.goalId,
    required this.date,
    required this.percentage,
    required this.tasksCompleted,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map, String id) {
    return ProgressModel(
      id: id,
      userId: map['userId'],
      goalId: map['goalId'],
      date: DateHelpers.parseDateTime(map['date']),
      percentage: map['percentage']?.toDouble() ?? 0.0,
      tasksCompleted: map['tasksCompleted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'goalId': goalId,
      'date': date.toIso8601String(),
      'percentage': percentage,
      'tasksCompleted': tasksCompleted,
    };
  }
}