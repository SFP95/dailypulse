import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final String description;
  final double currentProgress;
  final DateTime dueDate;
  final String userId;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.dueDate,
    required this.userId,
  });

  // Método para convertir a Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'currentProgress': currentProgress,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'userId': userId,
    };
  }



  // Método para crear desde Map (desde Firestore)
  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      currentProgress: (map['currentProgress'] ?? 0.0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  // Método empty() para casos de error
  static GoalModel empty() {
    return GoalModel(
      id: '',
      title: '',
      description: '',
      currentProgress: 0.0,
      dueDate: DateTime.now().add(Duration(days: 1)),
      userId: '',
    );
  }

  
  DateTime? get targetDate => null;
}

