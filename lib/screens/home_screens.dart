import 'package:dailypulse/screens/calendar_screens.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';
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
      appBar: AppBar(
        //title: Text('DailyPulse', style: AppTextStyles.headlineLarge),

        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: [
          // Página 1: Resumen de Metas
          _buildGoalsSummary(),
          CalendarScreen(),
          // Página 2: Tareas Pendientes
          _buildTasksList(),
          // Página 3: Perfil
          _buildProfileSection(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primaryyellow,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (index) => _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: Icon(Icons.add),
        backgroundColor: AppColors.primarylila,
      ),
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
          return Center(child: CircularProgressIndicator());
        }

        final goals = snapshot.data!.docs.map((doc) {
          return GoalModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        if (goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No tienes metas creadas',
                    style: AppTextStyles.bodyLarge),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showAddGoalDialog,
                  child: Text('Crear primera meta'),
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
                  Text(
                    goal.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(
                      '${(goal.currentProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primarylila,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                goal.description,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: goal.currentProgress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primarylila),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha límite: ${_formatDate(goal.dueDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16),
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

  Widget _buildTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: widget.userId)
          .where('isCompleted', isEqualTo: false)
          .orderBy('dueDate')
          .snapshots(),
      builder: (context, snapshot) {
        // Implementación similar a _buildGoalsSummary()
        // Mostrar lista de tareas pendientes
        return Center(child: Text('Lista de tareas pendientes'));
      },
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
           // backgroundImage: Icon(Icons.person)
          ),
          SizedBox(height: 20),
          Text(
            'Bienvenido',
            style: AppTextStyles.headlineSmall,
          ),
          SizedBox(height: 10),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _signOut,
            child: Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryblue,
            ),
          ),
        ],
      ),
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