import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF3B82F6); // blue-500
  static const Color primaryDark = Color(0xFF2563EB); // blue-600
  static const Color purple = Color(0xFF8B5CF6); // purple-500
  static const Color green = Color(0xFF22C55E); // green-500
  static const Color greenDark = Color(0xFF16A34A); // green-600
  static const Color red = Color(0xFFEF4444); // red-500
  static const Color amber = Color(0xFFF59E0B); // amber-500

  static const Color bgFrom = Color(0xFFF8FAFC); // slate-50
  static const Color bgTo = Color(0xFFF1F5F9); // slate-100
  static const Color white = Color(0xFFFFFFFF);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: bgFrom,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: slate50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: slate200, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: slate200, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      );
}
