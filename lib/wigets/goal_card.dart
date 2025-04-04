import 'package:flutter/material.dart';
import '../models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected; // Para selección múltiple

  const GoalCard({
    required this.goal,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      color: isSelected
          ? (isDarkMode ? Colors.blue[900] : Colors.blue[50])
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado (Título + Prioridad/Progreso)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      goal.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  _buildProgressIndicator(context),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de progreso
              LinearProgressIndicator(
                value: goal.currentProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                color: _getProgressColor(goal, theme),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),

              // Descripción (si existe)
              if (goal.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    goal.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Footer (Fecha y estado)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(goal.dueDate),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _isOverdue(goal.dueDate)
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  if (goal.isCompleted)
                    Icon(Icons.check_circle, color: Colors.green, size: 16)
                  else if (_isOverdue(goal.dueDate))
                    Text(
                      "Atrasado",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---
  Widget _buildProgressIndicator(BuildContext context) {
    return Chip(
      label: Text("${(goal.currentProgress * 100).toStringAsFixed(0)}%"),
      backgroundColor: _getProgressColor(goal, Theme.of(context)).withOpacity(0.2),
      labelStyle: TextStyle(
        color: _getProgressColor(goal, Theme.of(context)),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: _getProgressColor(goal, Theme.of(context)),
          width: 1,
        ),
      ),
    );
  }

  // --- Lógica de Estilos ---
  Color _getProgressColor(GoalModel goal, ThemeData theme) {
    if (goal.isCompleted) return Colors.green;
    if (goal.currentProgress > 0.7) return Colors.blue;
    if (goal.currentProgress > 0.3) return Colors.orange;
    return theme.primaryColor;
  }

  bool _isOverdue(DateTime dueDate) {
    return !goal.isCompleted && dueDate.isBefore(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}