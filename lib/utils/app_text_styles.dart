import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  // Títulos
  static const headlineLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Subtítulos
  static const titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Cuerpo
  static const bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.5,
  );

  // Botones
  static const button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Títulos grandes (para encabezados principales)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w800, // Extra-bold
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  // Texto corporal medio (para contenido principal)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5, // Interlineado
  );

  // Texto pequeño (para detalles y subtítulos)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Encabezados pequeños (para secciones)
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600, // Semi-bold
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  // Añade estos estilos adicionales que son útiles:
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.primaryPurple,
  );

  static const headlineMedium = TextStyle(
  fontSize: 23.0,
  fontWeight: FontWeight.w600, // Semi-bold
  color: AppColors.textPrimary,
  letterSpacing: 0.15,
  );


}