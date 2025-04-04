import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class GoalsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return _buildAuthErrorState(context);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('goals')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
          }

          final goals = snapshot.data!.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();

          if (goals.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) => _buildGoalCard(goals[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context, currentUser.uid),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.primaryPurple,
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildAuthErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: AppColors.error),
          SizedBox(height: 20),
          Text('Debes iniciar sesión', style: AppTextStyles.headlineSmall),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('Iniciar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gps_off, size: 90, color: AppColors.textSecondary),
          SizedBox(height: 20),
          Text('No tienes metas creadas', style: AppTextStyles.headlineSmall),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _showAddGoalDialog(context, FirebaseAuth.instance.currentUser?.uid ?? ''),
            child: Text('Crear primera meta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: AppColors.error),
          SizedBox(height: 20),
          Text('Ocurrió un error', style: AppTextStyles.headlineSmall),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final progressPercent = (goal.currentProgress * 100).toInt();

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text('$progressPercent%'),
                  backgroundColor: _getProgressColor(goal.currentProgress),
                ),
              ],
            ),
            if (goal.description.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                goal.description,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.currentProgress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(goal.currentProgress)),
                minHeight: 8,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vence: ${_formatDate(goal.dueDate)}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _deleteGoal(goal.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return AppColors.error.withOpacity(0.2);
    if (progress < 0.7) return AppColors.warning.withOpacity(0.2);
    return AppColors.success.withOpacity(0.2);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _showAddGoalDialog(BuildContext context, String userId) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(Duration(days: 30));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título*'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Fecha límite'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  selectedDate = picked;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El título es obligatorio')),
                );
                return;
              }

              try {
                // Verificación EXTRA de seguridad
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || user.uid != userId) {
                  throw Exception('Usuario no autenticado o UID no coincide');
                }

                // Crear documento con TODOS los campos requeridos
                final newGoal = {
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                  'currentProgress': 0.0,
                  'dueDate': Timestamp.fromDate(selectedDate),
                  'userId': user.uid, // Usar UID del usuario autenticado
                  'createdAt': FieldValue.serverTimestamp(),
                  'isCompleted': false,
                };

                print('Intentando crear meta con datos: $newGoal');

                await FirebaseFirestore.instance.collection('goals').add(newGoal);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Meta creada con éxito')),
                );
              } catch (e) {
                print('Error completo al crear meta: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al crear meta: ${e.toString()}')),
                );
              }
            },
            child: Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    print('Usuario UID: ${FirebaseAuth.instance.currentUser?.uid}');
  }

  Future<void> _deleteGoal(String goalId) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(goalId).delete();
    } catch (e) {
      print('Error al eliminar meta: $e');
    }
  }
}