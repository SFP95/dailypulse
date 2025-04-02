import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String goalId;
  final String userId;
  final String title;
  final bool isCompleted;
  final TimeOfDay dueTime;
  final List<String> repeatDays;

  TaskModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    required this.dueTime,
    this.repeatDays = const [], required DateTime createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    final time = map['dueTime'] as String; // Formato "HH:mm"
    return TaskModel(
      id: id,
      goalId: map['goalId'],
      userId: map['userId'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
      dueTime: TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]),
      ),
      repeatDays: List<String>.from(map['repeatDays'] ?? []),
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'userId': userId,
      'title': title,
      'isCompleted': isCompleted,
      'dueTime': '${dueTime.hour}:${dueTime.minute}',
      'repeatDays': repeatDays,
    };
  }
}