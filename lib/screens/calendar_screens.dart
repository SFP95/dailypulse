import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser!;

    // Cargar tareas
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .get();

    _tasksByDate = {};
    for (final doc in tasksSnapshot.docs) {
      final task = TaskModel.fromMap({...doc.data(), 'id': doc.id});
      final taskDate = task.dueDate;
      final normalizedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);

      _tasksByDate[normalizedDate] ??= [];
      _tasksByDate[normalizedDate]!.add(task);
    }

    // Cargar metas
    final goalsSnapshot = await FirebaseFirestore.instance
        .collection('goals')
        .where('userId', isEqualTo: user.uid)
        .get();

    _goalsByDate = {};
    for (final doc in goalsSnapshot.docs) {
      final goal = GoalModel.fromMap({...doc.data(), 'id': doc.id});
      final goalDate = goal.dueDate;
      final normalizedDate = DateTime(goalDate.year, goalDate.month, goalDate.day);

      _goalsByDate[normalizedDate] ??= [];
      _goalsByDate[normalizedDate]!.add(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {
              _loadingFuture = _loadEvents();
            }),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Selector de vista
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SegmentedButton<CalendarFormat>(
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

              // Calendario
              _buildCalendar(),
              SizedBox(height: 16),

              // Lista de eventos
              Expanded(child: _buildEventList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
        backgroundColor: AppColors.background,
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        eventLoader: (day) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          return [
            ...?_tasksByDate[normalizedDay],
            ...?_goalsByDate[normalizedDay],
          ];
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.accentBlue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomRight,
          markersMaxCount: 3,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Container(
                width: 16,
                height: 16,
                margin: EdgeInsets.only(right: 1, bottom: 1),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${events.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }
            return null;
          },
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primaryLila,
            borderRadius: BorderRadius.circular(20),
          ),
          formatButtonTextStyle: TextStyle(color: Colors.white),
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
        child: Text(
          'No hay eventos para este día',
          style: AppTextStyles.bodyLarge,
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12),
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
          Icon(icon, color: AppColors.background),
          SizedBox(width: 8),
          Text(title, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: _getTaskColor(task),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _toggleTaskCompletion(task),
          activeColor: AppColors.accentYellow,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.goalId != null && task.goalId!.isNotEmpty
            ? FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('goals')
              .doc(task.goalId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final goal = GoalModel.fromMap({
                ...?snapshot.data?.data() as Map<String, dynamic>?,
                'id': task.goalId
              });
              return Text(
                'Meta: ${goal.title}',
                style: AppTextStyles.bodySmall,
              );
            }
            return SizedBox();
          },
        )
            : null,
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteTask(task),
        ),
      ),
    );
  }

  Widget _buildGoalItem(GoalModel goal) {
    final progressPercent = (goal.currentProgress * 100).toInt();

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$progressPercent%',
              style: TextStyle(
                color: AppColors.primaryLila,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(goal.title, style: AppTextStyles.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: goal.currentProgress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
        onTap: () {
          // Navegar a pantalla de detalle de meta
        },
      ),
    );
  }

  Color _getTaskColor(TaskModel task) {
    if (task.isCompleted) return AppColors.accentBlue!;

    switch (task.priority) {
      case Priority.high:
        return AppColors.error!;
      case Priority.medium:
        return AppColors.warning!;
      case Priority.low:
        return AppColors.success!;
      default:
        return Theme.of(context).cardTheme.color!;
    }
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(task.id)
        .update({'isCompleted': !task.isCompleted});
    await _loadEvents();
  }

  Future<void> _deleteTask(TaskModel task) async {
    await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
    await _loadEvents();
  }

  Future<void> _showAddEventDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String? selectedPriority = 'media';
    String? selectedGoalId;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final goalsSnapshot = await FirebaseFirestore.instance
          .collection('goals')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      final goals = goalsSnapshot.docs.map((doc) {
        return GoalModel.fromMap({...doc.data(), 'id': doc.id});
      }).toList();

      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Nuevo Evento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Título'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Descripción'),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      items: ['alta', 'media', 'baja']
                          .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(
                          priority[0].toUpperCase() + priority.substring(1),
                        ),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => selectedPriority = value),
                      decoration: InputDecoration(labelText: 'Prioridad'),
                    ),
                    SizedBox(height: 16),
                    if (goals.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedGoalId,
                        hint: Text('Asociar a meta (opcional)'),
                        items: goals
                            .map((goal) => DropdownMenuItem(
                          value: goal.id,
                          child: Text(goal.title),
                        ))
                            .toList(),
                        onChanged: (value) => setState(() => selectedGoalId = value),
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
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('tasks').add({
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'dueDate': Timestamp.fromDate(pickedDate),
                        'isCompleted': false,
                        'priority': selectedPriority,
                        'goalId': selectedGoalId,
                        'userId': FirebaseAuth.instance.currentUser!.uid,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      await _loadEvents();
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        ),
      );
    }
  }
}