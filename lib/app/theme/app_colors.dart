import 'package:flutter/material.dart';

/// ─── App Colors: Jungle/Nature Theme with WCAG AA Compliance ───
/// Primary: Deep Forest Green (#1B5E20)
/// Secondary: Warm Sunset Orange (#D97706)
/// Accent: Vibrant Jungle Yellow (#FCD34D)
/// Supports both light and dark themes with proper contrast ratios
class AppColors {
  AppColors._();

  // ─── JUNGLE PALETTE - Primary Colors ───
  static const Color primaryDeepGreen = Color(0xFF1B5E20);    // Deep forest (WCAG AAA)
  static const Color primaryGreen = Color(0xFF2D7A3D);        // Primary green
  static const Color primaryLightGreen = Color(0xFF4CAF50);   // Light green for states
  
  static const Color secondaryOrange = Color(0xFFD97706);     // Warm sunset orange
  static const Color secondaryTan = Color(0xFFB8860B);        // Earthy brown/tan
  static const Color secondaryBrown = Color(0xFF784D3C);      // Deep earth brown

  static const Color accentYellow = Color(0xFFFCD34D);        // Vibrant jungle yellow
  static const Color accentGolden = Color(0xFFF59E0B);        // Golden (accessibility)
  
  // Error & Success
  static const Color error = Color(0xFFC41E3A);               // Deep red (WCAG AAA)
  static const Color success = Color(0xFF059669);             // Verified green
  static const Color warning = Color(0xFFEA8C55);             // Warm warning

  // ─── LIGHT THEME PALETTE ───
  // Background: Soft cream/off-white for nature feel
  static const Color backgroundLight = Color(0xFFFEFDF3);     // Soft cream
  static const Color surfaceLight = Color(0xFFFFFFFF);        // Pure white
  static const Color surfaceVariantLight = Color(0xFFF5F3F0); // Warm gray
  static const Color onBackgroundLight = Color(0xFF1B1B1B);   // Near black text
  static const Color onSurfaceLight = Color(0xFF2B2520);      // Brown text
  static const Color cardLight = Color(0xFFFFFFFF);           // White cards
  static const Color dividerLight = Color(0xFFE8DCC8);        // Warm divider

  // ─── DARK THEME PALETTE ───
  // Background: Deep jungle green for immersive experience
  static const Color backgroundDark = Color(0xFF1B2B20);      // Deep jungle
  static const Color surfaceDark = Color(0xFF2A4630);         // Darker jungle
  static const Color surfaceVariantDark = Color(0xFF3D5A3F);  // Medium jungle
  static const Color onBackgroundDark = Color(0xFFF5F3F0);    // Light text
  static const Color onSurfaceDark = Color(0xFFE8DCC8);       // Light warm text
  static const Color cardDark = Color(0xFF2E4333);            // Dark card
  static const Color dividerDark = Color(0xFF4A5F50);         // Subtle divider

  // ─── SEMANTIC COLORS ───
  // Gamification & Rewards
  static const Color coinGold = Color(0xFFFCD34D);            // XP/coin gold
  static const Color starFilled = Color(0xFFFCD34D);          // Star reward
  static const Color starEmpty = Color(0xFFCBBDC5);           // Empty star

  // Streaks & Achievements
  static const Color streakFire = Color(0xFFDC2626);          // Flame red
  static const Color streakGlow = Color(0xFFFF8C00);          // Glow orange
  
  // Status indicators
  static const Color indicatorPositive = Color(0xFF10B981);   // Achievement green
  static const Color indicatorWarning = Color(0xFFF59E0B);    // Warning amber
  
  // ─── GRADIENTS ─── 
  // Jungle greens
  static const List<Color> jungleGradient = [
    Color(0xFF1B5E20),  // Deep green
    Color(0xFF2D7A3D),  // Primary green
    Color(0xFF4CAF50),  // Light green
  ];
  
  // Sunset warm
  static const List<Color> sunsetGradient = [
    Color(0xFFF59E0B),  // Golden
    Color(0xFFD97706),  // Orange
    Color(0xFFB8860B),  // Brown
  ];
  
  // Forest depth
  static const List<Color> forestGradient = [
    Color(0xFF1B5E20),  // Deep
    Color(0xFF3B8A3F),  // Mid
  ];

  // ─── GLASSMORPHISM COLORS ───
  static const Color glassDark = Color(0x1A000000);           // 10% black
  static const Color glassLight = Color(0x0DFFFFFF);          // 5% white
  
  // ─── SHADOW COLORS ───
  static const Color shadowDark = Color(0x26000000);          // 15% black shadow
  static const Color shadowLight = Color(0x08000000);         // 3% subtle shadow

  // Baby mode pastel backgrounds (softer palette)
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
