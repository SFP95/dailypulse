import 'package:dailypulse/screens/calendar_screens.dart';
import 'package:dailypulse/screens/profile_screens.dart';
import 'package:dailypulse/screens/task_screens.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';
import 'goal_detail_screen.dart';
import 'goal_screens.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(30), // Ajusta el radio aquí
          ),
        ),
        title: Container(
          alignment: Alignment.center,
          child: Text('Daily Pulse',
              style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.accentBlue,
              )),
        ),
        /*actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],*/
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Colors.white],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: [
            GoalsScreen(),
            //_buildGoalsSummary(),   //clase goals -- pendiente
            CalendarScreen(),       //clase calendar
            TasksScreen(),
            //_buildTasksList(),      //clase tasks -- pendiente
            ProfileScreen(),        //clase profile
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(30)),
          child: BottomNavigationBar(
            backgroundColor: AppColors.background,
            selectedItemColor: AppColors.primaryPurple,
            unselectedItemColor: AppColors.textSecondary,
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            onTap: (index) => _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.flag_outlined),
                activeIcon: Icon(Icons.flag),
                label: 'Metas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Calendario',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.checklist_outlined),
                activeIcon: Icon(Icons.checklist),
                label: 'Tareas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: AppColors.primaryPurple,
        elevation: 4,
        shape: CircleBorder(),
      ),*/
    );
  }

  Widget _buildGoalsSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('goals')
          .where('userId', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
        }

        final goals = snapshot.data!.docs.map((doc) {
          return GoalModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        if (goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.not_interested, size: 60, color: AppColors.textSecondary),
                SizedBox(height: 20),
                Text('No tienes metas creadas',
                    style: AppTextStyles.bodyLarge),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _showAddGoalDialog,
                  child: Text('Crear primera meta', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return _buildGoalCard(goal, context);
          },
        );
      },
    );
  }


  Widget _buildGoalCard(GoalModel goal, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoalDetailScreen(goal: goal),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      goal.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getProgressColor(goal.currentProgress),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(goal.currentProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (goal.description.isNotEmpty)
                Text(
                  goal.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.currentProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(goal.currentProgress)),
                  minHeight: 8,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha límite: ${_formatDate(goal.dueDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryPurple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GoalDetailScreen(goal: goal),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Color _getProgressColor(double progress) {
    if (progress < 0.3) return AppColors.error;
    if (progress < 0.7) return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: widget.userId)
          .where('isCompleted', isEqualTo: false)
          .orderBy('dueDate')
          .snapshots(),
      builder: (context, snapshot) {
        // Mantén tu implementación actual de tasks
        return Center(child: Text('Lista de tareas pendientes', style: AppTextStyles.bodyLarge));
      },
    );
  }

  Future<void> _showAddGoalDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('goals').add({
                  'title': titleController.text,
                  'description': descController.text,
                  'currentProgress': 0.0,
                  'dueDate': DateTime.now().add(Duration(days: 30)),
                  'userId': widget.userId,
                  'createdAt': FieldValue.serverTimestamp(),
                  'isCompleted': false,
                });
                Navigator.pop(context);
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}