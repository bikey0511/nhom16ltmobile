import 'package:flutter/material.dart';

class AppColors {
  // Lấy cảm hứng tối giản, khác biệt so với mặc định
  static const Color primary = Color(0xFF0FB2B2); // teal cyan
  static const Color primaryDark = Color(0xFF0B8C8C);
  static const Color accent = Color(0xFFFF735C); // coral
  static const Color bg = Color(0xFFF7FAFB);
}

ThemeData buildAppTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}




