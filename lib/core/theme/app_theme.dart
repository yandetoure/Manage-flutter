import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentBlue,
        surface: AppColors.card,
        error: AppColors.danger,
        onSurface: AppColors.textMain,
      ),
      textTheme: GoogleFonts.instrumentSansTextTheme().apply(
        bodyColor: AppColors.textMain,
        displayColor: AppColors.textMain,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background.withOpacity(0.8),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.instrumentSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0F172A).withOpacity(0.9),
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white, // Pure white background
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentBlue,
        surface: Colors.white,
        error: AppColors.danger,
        onSurface: Color(0xFF1E293B),
      ),
      textTheme: GoogleFonts.instrumentSansTextTheme().apply(
        bodyColor: const Color(0xFF1E293B),
        displayColor: const Color(0xFF1E293B),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.instrumentSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }
}
