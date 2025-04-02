import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../models/task_model.dart';
import '../utils/firestore_service.dart';

class GoalDetailScreen extends StatefulWidget {
  final GoalModel goal;
  const GoalDetailScreen({required this.goal, Key? key}) : super(key: key);

  @override
  _GoalDetailScreenState createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  late List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _firestore.getTasks(widget.goal.id);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las tareas: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTaskComplete(TaskModel task, bool isCompleted) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firestore.updateTaskCompletion(task.id, isCompleted);
      await _loadTasks();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al actualizar la tarea: ${e.toString()}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: widget.goal.currentProgress,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(widget.goal.currentProgress * 100).toStringAsFixed(1)}% completado',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Tareas diarias:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: _tasks.isEmpty
                    ? Center(
                  child: Text(
                    'No hay tareas disponibles',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
                    : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (ctx, i) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: CheckboxListTile(
                      title: Text(
                        _tasks[i].title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: _tasks[i].isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      value: _tasks[i].isCompleted,
                      onChanged: (value) => _toggleTaskComplete(_tasks[i], value!),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(_tasks[i]),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addNewTask() async {
    final TextEditingController controller = TextEditingController();

    try {
      final String? newTaskTitle = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nueva tarea'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Título de la tarea',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );

      if (newTaskTitle != null && newTaskTitle.isNotEmpty) {
        setState(() => _isLoading = true);

        final newTask = TaskModel(
          id: '', // Firestore generará el ID automáticamente
          goalId: widget.goal.id,
          title: newTaskTitle,
          isCompleted: false,
          createdAt: DateTime.now(),
          userId: '',
          dueTime: TimeOfDay.now(),
        );

        await _firestore.addTask(newTask);
        await _loadTasks(); // Recargar la lista de tareas
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al agregar tarea: ${e.toString()}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar tarea: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar tarea'),
          content: Text('¿Estás seguro de eliminar "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() => _isLoading = true);
        await _firestore.deleteTask(task.id);
        await _loadTasks(); // Recargar la lista de tareas
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al eliminar tarea: ${e.toString()}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar tarea: ${e.toString()}')),
      );
    }
  }
}