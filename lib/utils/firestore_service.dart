import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== Operaciones con Metas (Goals) ==========
  Stream<List<GoalModel>> getGoals(String userId) {
    return _db.collection('goals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GoalModel.fromMap({
      ...doc.data(),
      'id': doc.id,  // Combina los datos con el ID
    }))
        .toList());
  }

  Future<void> saveGoal(GoalModel goal) async {
    await _db.collection('goals').add(goal.toMap());
  }

  // ========== Operaciones con Tareas (Tasks) ==========
  Future<List<TaskModel>> getTasks(String goalId) async {
    final snapshot = await _db.collection('daily_tasks')
        .where('goalId', isEqualTo: goalId)
        .get();
    return snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _db.collection('daily_tasks').doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  // ========== Operaciones con Usuarios (Opcional) ==========
  Future<void> saveUserData(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  addTask(TaskModel newTask) {}

  deleteTask(String id) {}
}