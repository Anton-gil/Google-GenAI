// lib/utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D8F); // Teal blue
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);
  
  static const Color secondary = Color(0xFFFF8A65); // Warm orange
  static const Color secondaryLight = Color(0xFFFFAB91);
  static const Color secondaryDark = Color(0xFFE64A19);
  
  static const Color accent = Color(0xFFFFD54F); // Golden yellow
  static const Color accentLight = Color(0xFFFFF176);
  static const Color accentDark = Color(0xFFF57F17);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Special colors for artisan theme
  static const Color artisanGold = Color(0xFFDAA520);
  static const Color artisanBrown = Color(0xFF8D6E63);
  static const Color artisanTerracotta = Color(0xFFD2691E);
  static const Color artisanEarth = Color(0xFFA0522D);
  
  // Card and component colors
  static const Color cardShadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D8F),
    Color(0xFF4DB6AC),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFFFF8A65),
    Color(0xFFFFAB91),
  ];
  
  static const List<Color> goldGradient = [
    Color(0xFFDAA520),
    Color(0xFFFFF176),
  ];
  
  // Cultural theme colors
  static const Color indianSaffron = Color(0xFFFF9933);
  static const Color indianGreen = Color(0xFF138808);
  static const Color indianNavy = Color(0xFF000080);
}