import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../utils/date_helpers.dart';
import '../utils/firestore_service.dart';

class AddGoalScreen extends StatefulWidget {
  final String userId;
  const AddGoalScreen({required this.userId});

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _targetDate;
  final FirestoreService _firestore = FirestoreService();

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate() && _targetDate != null) {
      final goal = GoalModel(
        id: '', // Firestore lo genera automáticamente
        userId: widget.userId,
        title: _titleController.text,
        description: _descController.text,
        currentProgress: 0.0,
        dueDate: _targetDate!,
      );
      await _firestore.saveGoal(goal);
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}'; // Formato DD/MM/YYYY
    // O usa el paquete `intl` para más opciones:
    // return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Meta')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              ListTile(
                title: Text(_targetDate == null
                    ? 'Seleccionar fecha'
                    : 'Fecha: ${_formatDate(_targetDate!)}'), // Usa la función local
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _targetDate = date);
                },
              ),
              ElevatedButton(
                onPressed: _saveGoal,
                child: Text('Guardar Meta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}