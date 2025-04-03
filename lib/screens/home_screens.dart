import 'package:dailypulse/screens/calendar_screens.dart';
import 'package:dailypulse/screens/profile_screens.dart';
import 'package:dailypulse/screens/task_screens.dart';
import 'package:flutter/material.dart';
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
            GoalsScreen(),          //clase goals -- pendiente
            CalendarScreen(),       //clase calendar
            TasksScreen(),          //clase tasks -- pendiente
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}