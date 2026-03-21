import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF2EC4B6);
  static const Color accent = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF476F);
  static const Color success = Color(0xFF06D6A0);

  // Light theme
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF1A1A2E);
  static const Color onSurfaceLight = Color(0xFF2D2D3A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE8E8EE);

  // Dark theme
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF252540);
  static const Color onBackgroundDark = Color(0xFFF5F5F5);
  static const Color onSurfaceDark = Color(0xFFE0E0E8);
  static const Color cardDark = Color(0xFF2A2A45);
  static const Color dividerDark = Color(0xFF3A3A55);

  // Coin colors
  static const Color coinGold = Color(0xFFFFD166);
  static const Color coinGoldDark = Color(0xFFF0B830);

  // Streak / fire
  static const Color streakFire = Color(0xFFFF4500);
  static const Color streakGlow = Color(0xFFFF8C00);

  // Star ratings
  static const Color starFilled = Color(0xFFFFD166);
  static const Color starEmpty = Color(0xFFD0D0D0);

  // Baby mode pastel backgrounds
  static const List<Color> babyPastels = [
    Color(0xFFFFF176),
    Color(0xFFB3E5FC),
    Color(0xFFC8E6C9),
    Color(0xFFFFCCBC),
    Color(0xFFE1BEE7),
    Color(0xFFFFE0B2),
    Color(0xFFB2EBF2),
    Color(0xFFF8BBD0),
  ];

  // Category colors
  static const Color farmCategory = Color(0xFF8BC34A);
  static const Color wildCategory = Color(0xFFFF9800);
  static const Color oceanCategory = Color(0xFF03A9F4);
  static const Color exoticCategory = Color(0xFF9C27B0);

  // Difficulty colors
  static const Color easyGreen = Color(0xFF4CAF50);
  static const Color mediumYellow = Color(0xFFFFC107);
  static const Color hardRed = Color(0xFFF44336);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF2EC4B6), Color(0xFF5BD8CD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFD166), Color(0xFFFFE08A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldenGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Custom shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}
