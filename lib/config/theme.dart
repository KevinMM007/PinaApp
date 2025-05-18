import 'package:flutter/material.dart';

class AppTheme {
  // Colores relacionados con la piña
  static const Color primary = Color(0xFF4CAF50);     // Verde
  static const Color secondary = Color(0xFFFFEB3B);   // Amarillo
  static const Color accent = Color(0xFFF57C00);      // Naranja
  static const Color background = Color(0xFFFFFDE7);  // Crema suave
  
  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      color: primary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}