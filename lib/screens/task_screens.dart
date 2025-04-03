import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return _buildAuthRequiredState();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        //title: Text('Mis Tareas', style: AppTextStyles.headlineMedium),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tasks')
            .where('userId', isEqualTo: currentUser.uid)
            .where('isCompleted', isEqualTo: false)
            .orderBy('dueDate')
            .orderBy('dueTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
          }

          final tasks = snapshot.data!.docs.map((doc) {
            return TaskModel.fromMap({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            });
          }).toList();

          return tasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) => _buildTaskItem(tasks[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.primaryPurple,
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _toggleTaskCompletion(task),
          activeColor: AppColors.primaryPurple,
        ),
        title: Text(
          task.title,
          style: AppTextStyles.bodyLarge.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  task.description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            Text(
              'Vence: ${DateFormat('dd/MM/yyyy').format(task.dueDate)} a las ${task.dueTime.format(context)}',
              style: AppTextStyles.bodySmall,
            ),
            if (task.repeatDays.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Repite: ${task.repeatDays.join(', ')}',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            Text(
              'Prioridad: ${task.priority.toString().split('.').last}',
              style: AppTextStyles.bodySmall.copyWith(
                color: _getPriorityColor(task.priority),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: AppColors.error),
          onPressed: () => _deleteTask(task.id),
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    Priority selectedPriority = Priority.medium;
    List<String> repeatDays = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Nueva Tarea'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Título*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Fecha límite'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text('Hora límite'),
                    subtitle: Text(selectedTime.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<Priority>(
                    value: selectedPriority,
                    items: Priority.values.map((Priority priority) {
                      return DropdownMenuItem<Priority>(
                        value: priority,
                        child: Text(
                          priority.toString().split('.').last.toUpperCase(),
                        ),
                      );
                    }).toList(),
                    onChanged: (Priority? value) {
                      if (value != null) {
                        setState(() => selectedPriority = value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day) {
                      final isSelected = repeatDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              repeatDays.add(day);
                            } else {
                              repeatDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
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
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    await _firestore.collection('tasks').add({
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                      'dueDate': selectedDate.toIso8601String(),
                      'dueTime': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      'isCompleted': false,
                      'priority': selectedPriority.toString().split('.').last,
                      'repeatDays': repeatDays,
                      'userId': user.uid,
                      'goalId': '', // Ajusta según tu necesidad
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tarea creada con éxito')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al crear tarea: $e')),
                    );
                  }
                },
                child: Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
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
          Text(
            'Ocurrió un error',
            style: AppTextStyles.headlineSmall,
          ),
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
            onPressed: () => setState(() {}),
            child: Text('Reintentar', style: TextStyle(color: AppColors.accentPink),),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthRequiredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 50, color: AppColors.primaryPurple),
          SizedBox(height: 20),
          Text(
            'Debes iniciar sesión',
            style: AppTextStyles.headlineSmall,
          ),
          SizedBox(height: 10),
          Text(
            'Para ver tus tareas necesitas autenticarte',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 20),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task, size: 60, color: AppColors.textSecondary),
          SizedBox(height: 20),
          Text('No tienes tareas pendientes', style: AppTextStyles.bodyLarge),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _showAddTaskDialog(context),
            child: Text('Crear primera tarea', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'isCompleted': !task.isCompleted,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar tarea: $e')),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea eliminada con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar tarea: $e')),
      );
    }
  }
}