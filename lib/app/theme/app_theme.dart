import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ─── App Theme: Jungle/Nature Inspired with Premium UX ───
/// Implements WCAG AA accessibility, custom typography, glass-morphism,
/// and layered shadows for depth perception.
class AppTheme {
  AppTheme._();

  // ─── 8PT SPACING GRID ───
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;
  static const double space64 = 64;
  static const double space80 = 80;
  static const double space96 = 96;

  // ─── BORDER RADIUS (Rounded, playful style) ───
  static const double radiusSmall = 8;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusXL = 32;
  static const double radiusPill = 100;

  // ─── MIN TAP TARGET (60x60pt) ───
  static const double minTapTarget = 60;
  
  // ─── TEXT SIZES (minimum 17pt body, 22pt headings for accessibility) ───
  static const double textHeading1 = 32;
  static const double textHeading2 = 24;
  static const double textHeading3 = 22;
  static const double textBody = 17;
  static const double textBodySmall = 15;
  static const double textCaption = 13;
  
  // ─── SHADOW DEFINITIONS (Layered for depth) ───
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 16,
      offset: Offset(0, 8),
      spreadRadius: 2,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 24,
      offset: Offset(0, 12),
      spreadRadius: 4,
    ),
  ];

  // ─── Light Theme ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryOrange,
        tertiary: AppColors.accentYellow,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.onSurfaceLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(AppColors.onBackgroundLight, false),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.onBackgroundLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackgroundLight,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        shadowColor: AppColors.shadowLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(minTapTarget, minTapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: textBody,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.nunito(
          fontSize: textBody,
          color: AppColors.onBackgroundLight.withValues(alpha: 0.5),
        ),
      ),
      dividerColor: AppColors.dividerLight,
      splashColor: AppColors.primaryGreen.withValues(alpha: 0.1),
      highlightColor: AppColors.primaryGreen.withValues(alpha: 0.08),
    );
  }

  // ─── Dark Theme ───
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryOrange,
        tertiary: AppColors.accentYellow,
        error: AppColors.error,
        surface: AppColors.surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.onSurfaceDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(AppColors.onBackgroundDark, true),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.onBackgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackgroundDark,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        shadowColor: AppColors.shadowDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(minTapTarget, minTapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: textBody,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.nunito(
          fontSize: textBody,
          color: AppColors.onBackgroundDark.withValues(alpha: 0.5),
        ),
      ),
      dividerColor: AppColors.dividerDark,
      splashColor: AppColors.primaryGreen.withValues(alpha: 0.1),
      highlightColor: AppColors.primaryGreen.withValues(alpha: 0.08),
    );
  }

  /// Builds enhanced text theme with larger accessible sizes and playful fonts.
  /// - Headings: Fredoka One (rounded, playful)
  /// - Body: Nunito (friendly, readable)
  static TextTheme _buildTextTheme(Color color, bool isDark) {
    final Color subtleColor = color.withValues(alpha: 0.7);
    return TextTheme(
      // Display sizes - Large headlines (32pt minimum)
      displayLarge: GoogleFonts.fredoka(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.fredoka(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      
      // Headline sizes - Section titles (22pt minimum)
      headlineLarge: GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      
      // Title sizes
      titleLarge: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      
      // Body sizes - Main content (17pt minimum)
      bodyLarge: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: subtleColor,
        height: 1.4,
      ),
      
      // Label sizes
      labelLarge: GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: subtleColor,
        letterSpacing: 0.2,
      ),
    );
  }
}
