import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<TaskModel>> _tasksByDate = {};
  Map<DateTime, List<GoalModel>> _goalsByDate = {};
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadingFuture = _loadEvents();
  }

  Future<void> _loadEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Cargar tareas
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .get();

      _tasksByDate = {};
      for (final doc in tasksSnapshot.docs) {
        try {
          final task = TaskModel.fromFirestore(doc);
          final normalizedDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
          _tasksByDate[normalizedDate] = [...?_tasksByDate[normalizedDate], task];
        } catch (e) {
          debugPrint('Error parsing task ${doc.id}: $e');
        }
      }

      // Cargar metas
      final goalsSnapshot = await FirebaseFirestore.instance
          .collection('goals')
          .where('userId', isEqualTo: user.uid)
          .get();

      _goalsByDate = {};
      for (final doc in goalsSnapshot.docs) {
        try {
          final goal = GoalModel.fromFirestore(doc);
          final normalizedDate = DateTime(goal.dueDate.year, goal.dueDate.month, goal.dueDate.day);
          _goalsByDate[normalizedDate] = [...?_goalsByDate[normalizedDate], goal];
        } catch (e) {
          debugPrint('Error parsing goal ${doc.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.today, color: AppColors.primaryPurple, size: 30),
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar eventos'));
          }

          return Column(
            children: [
              // Selector de vista
              Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.8),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: SegmentedButton<CalendarFormat>(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.selected)) {
                          return AppColors.primaryPurple;
                        }
                        return Colors.white;
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.white;
                        }
                        return AppColors.textPrimary;
                      }),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: CalendarFormat.week,
                        icon: Icon(Icons.calendar_view_week),
                        label: Text('Semana'),
                      ),
                      ButtonSegment(
                        value: CalendarFormat.month,
                        icon: Icon(Icons.calendar_view_month),
                        label: Text('Mes'),
                      ),
                    ],
                    selected: <CalendarFormat>{_calendarFormat},
                    onSelectionChanged: (newFormat) {
                      setState(() => _calendarFormat = newFormat.first);
                    },
                  ),
                ),
              ),

              // Calendario
              _buildCalendar(),
              Expanded(child: _buildEventList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.edit_calendar, color: AppColors.accentPink),
        backgroundColor: AppColors.primaryPurple,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withOpacity(0.8),
            blurRadius: 9,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        eventLoader: (day) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          return [
            ...?_tasksByDate[normalizedDay],
            ...?_goalsByDate[normalizedDay],
          ];
        },
        calendarStyle: CalendarStyle(
          defaultDecoration: BoxDecoration(shape: BoxShape.circle),
          weekendDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentPink.withOpacity(0.7),
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primaryPurple,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.primaryPurple,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomRight,
          markersMaxCount: 3,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primaryPurple),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primaryPurple),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: AppColors.textPrimary),
          weekendStyle: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    final normalizedDay = _selectedDay != null
        ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
        : DateTime.now();

    final dayTasks = _tasksByDate[normalizedDay] ?? [];
    final dayGoals = _goalsByDate[normalizedDay] ?? [];

    if (dayTasks.isEmpty && dayGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 60, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'No hay eventos para este día',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        if (dayGoals.isNotEmpty) ...[
          _buildSectionTitle('Metas que vencen', Icons.flag),
          ...dayGoals.map((goal) => _buildGoalItem(goal)).toList(),
          SizedBox(height: 16),
        ],
        if (dayTasks.isNotEmpty) ...[
          _buildSectionTitle('Tareas programadas', Icons.task),
          ...dayTasks.map((task) => _buildTaskItem(task)).toList(),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryPurple, size: 24),
          SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTaskColor(task).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              task.isCompleted ? Icons.check : Icons.access_time,
              color: _getTaskColor(task),
            ),
          ),
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
              Text(
                task.description,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (task.goalId != null && task.goalId!.isNotEmpty)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('goals').doc(task.goalId).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final goal = GoalModel.fromFirestore(snapshot.data!);
                    return Text(
                      'Meta: ${goal.title}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryPurple),
                    );
                  }
                  return SizedBox();
                },
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: AppColors.success),
              onPressed: () => _toggleTaskCompletion(task),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _deleteTask(task),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(GoalModel goal) {
    final progressPercent = (goal.currentProgress * 100).toInt();

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$progressPercent%',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          goal.title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.currentProgress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                minHeight: 6,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Fecha límite: ${_formatDate(goal.dueDate)}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTaskColor(TaskModel task) {
    if (task.isCompleted) return AppColors.success;
    switch (task.priority) {
      case Priority.high: return AppColors.error;
      case Priority.medium: return AppColors.warning;
      case Priority.low: return AppColors.success;
      default: return AppColors.primaryPurple;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id)
          .update({'isCompleted': !task.isCompleted});
      await _loadEvents();
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
      await _loadEvents();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<void> _showAddEventDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'medium';
    String? selectedGoalId;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate == null) return;

    try {
      final goalsSnapshot = await FirebaseFirestore.instance
          .collection('goals')
          .where('userId', isEqualTo: user.uid)
          .get();

      final goals = goalsSnapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();

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
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      items: Priority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority.toString().split('.').last,
                          child: Text(
                            priority.toString().split('.').last[0].toUpperCase() +
                                priority.toString().split('.').last.substring(1),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedPriority = value!),
                      decoration: InputDecoration(
                        labelText: 'Prioridad',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (goals.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedGoalId,
                        hint: Text('Asociar a meta (opcional)'),
                        items: goals.map((goal) {
                          return DropdownMenuItem(
                            value: goal.id,
                            child: Text(goal.title),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedGoalId = value),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('El título es obligatorio')),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance.collection('tasks').add({
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'dueDate': Timestamp.fromDate(pickedDate),
                        'isCompleted': false,
                        'priority': selectedPriority,
                        'goalId': selectedGoalId,
                        'userId': user.uid,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      await _loadEvents();
                      Navigator.pop(context);
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
    } catch (e) {
      debugPrint('Error showing add event dialog: $e');
    }
  }
}