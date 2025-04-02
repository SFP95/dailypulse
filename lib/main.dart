import 'package:dailypulse/screens/calendar_screens.dart';
import 'package:dailypulse/screens/home_screens.dart';
import 'package:dailypulse/screens/login_screens.dart';
import 'package:dailypulse/screens/profile_screens.dart';
import 'package:dailypulse/screens/register_screens.dart';
import 'package:dailypulse/utils/app_colors.dart';
import 'package:dailypulse/utils/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: AppColors.primarylila,
          fontFamily: 'Inter', // Fuente por defecto
          textTheme: const TextTheme(
            headlineLarge: AppTextStyles.headlineLarge,
            titleMedium: AppTextStyles.titleMedium,
            bodyLarge: AppTextStyles.bodyLarge,
          ),
          hintColor: Color.fromARGB(255, 215, 215, 215),
        ),

        home: AuthWrapper(),
        routes: {
          'profile': (context) => ProfileScreen(),
          'calendar': (context) => CalendarScreen(),
          'register': (context) => RegisterScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user != null) {
      // Usuario logueado - mostrar HomeScreen con su ID
      return HomeScreen(userId: user.uid);
    } else {
      // Usuario no logueado - redirigir a login
      return LoginScreen();
    }
  }
}