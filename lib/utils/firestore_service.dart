import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== Operaciones con Metas (Goals) ==========

  /// Obtener todas las metas de un usuario (Stream en tiempo real)
  Stream<List<GoalModel>> getGoals(String userId) {
    return _db.collection('goals')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true) // Ordenar por fecha
        .snapshots()
        .handleError((error) => throw "Error al cargar metas: $error")
        .map((snapshot) => snapshot.docs
        .map((doc) => GoalModel.fromFirestore(doc))
        .toList());
  }

  /// Obtener una meta por ID
  Future<GoalModel?> getGoalById(String goalId) async {
    try {
      final doc = await _db.collection('goals').doc(goalId).get();
      return doc.exists ? GoalModel.fromFirestore(doc) : null;
    } catch (e) {
      throw "Error al obtener meta: $e";
    }
  }

  /// Crear o actualizar una meta
  Future<void> saveGoal(GoalModel goal) async {
    try {
      await _db.collection('goals')
          .doc(goal.id.isEmpty ? null : goal.id) // Auto-ID si está vacío
          .set(goal.toMap(), SetOptions(merge: true)); // Merge para no sobrescribir
    } catch (e) {
      throw "Error al guardar meta: $e";
    }
  }

  /// Eliminar una meta y sus tareas asociadas (en lote)
  Future<void> deleteGoal(String goalId) async {
    final batch = _db.batch();

    try {
      // 1. Eliminar la meta
      batch.delete(_db.collection('goals').doc(goalId));

      // 2. Eliminar todas sus tareas (consulta en lote)
      final tasks = await _db.collection('tasks')
          .where('goalId', isEqualTo: goalId)
          .get();

      for (final doc in tasks.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw "Error al eliminar meta: $e";
    }
  }

  // ========== Operaciones con Tareas (Tasks) ==========

  /// Obtener tareas de una meta (Stream en tiempo real)
  Stream<List<TaskModel>> getTasksByGoal(String goalId) {
    return _db.collection('tasks')
        .where('goalId', isEqualTo: goalId)
        .orderBy('dueDate') // Ordenar por fecha de vencimiento
        .snapshots()
        .handleError((error) => throw "Error al cargar tareas: $error")
        .map((snapshot) => snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList());
  }

  /// Obtener tareas urgentes (alta prioridad)
  Stream<List<TaskModel>> getUrgentTasks(String userId) {
    return _db.collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('priority', isEqualTo: 'high')
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList());
  }

  /// Marcar tarea como completada
  Future<void> completeTask(String taskId) async {
    try {
      await _db.collection('tasks').doc(taskId).update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(), // Fecha automática
      });
    } catch (e) {
      throw "Error al completar tarea: $e";
    }
  }
}