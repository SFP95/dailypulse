import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {

  // --- Paleta Principal (Inspirada en tus imágenes) ---
  static const primaryPurple = Color(0xFF444068); // Morado oscuro ("SHOP NAME")
  static const primaryLila = Color(0xFFBB9FDC);   // Lila claro
  static const accentPink = Color(0xFFF0BBD9);    // Rosa ("Family Expenses")
  static const accentYellow = Color(0xFFF2D8A7);  // Amarillo pastel
  static const accentBlue = Color(0xFFACBDEC);    // Azul claro

  // --- Estados (Feedback visual) ---
  static const success = Color(0xFF6BCB94);      // Verde
  static const error = Color(0xFFFC6F6F);       // Rojo/Naranja (antes "warning")
  static const warning = Color(0xFFEACC81);     // Naranja (antes "naranja")
  static const disabled = Color(0xC8B0AEAE);    // Gris deshabilitado

  // --- Neutrales (Fondos y texto) ---
  static const background = Color(0xFFF8F6F9);   // Fondo claro
  static const cardBackground = Colors.white;    // Nuevo: para tarjetas
  static const textPrimary = Color(0xFF212121);  // Texto oscuro
  static const textSecondary = Color(0xE78D8D8D);// Texto secundario
  static const divider = Color(0xFFEEEEEE);      // Nuevo: para separadores
}