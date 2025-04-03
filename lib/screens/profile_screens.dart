import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLila,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              SizedBox(height: 24),
              Text(
                'Bienvenido',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                (user?.displayName ?? '').isNotEmpty
                    ? '${user!.displayName![0].toUpperCase()}${user?.displayName!.substring(1).toLowerCase()}'
                    : '',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: Icon(Icons.logout, size: 20, color: AppColors.primaryLila,),
                label: Text('Cerrar sesión',style: TextStyle(color: AppColors.primaryLila,),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}