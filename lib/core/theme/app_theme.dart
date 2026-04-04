import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF060E20);
  static const surface = Color(0xFF060E20);
  static const surfaceContainerLowest = Color(0xFF000000);
  static const surfaceContainerLow = Color(0xFF06122D);
  static const surfaceContainer = Color(0xFF05183C);
  static const surfaceContainerHigh = Color(0xFF031D4B);
  static const surfaceContainerHighest = Color(0xFF00225A);
  static const primary = Color(0xFFB9C8DE);
  static const primaryContainer = Color(0xFF39485A);
  static const onSurface = Color(0xFFDEE5FF);
  static const onSurfaceVariant = Color(0xFF91AAEB);
  static const surfaceVariant = Color(0xFF00225A);
  static const tertiary = Color(0xFFEDECFF);
  static const onPrimary = Color(0xFF334153);
  static const outlineVariant = Color(0xFF2B4680);


  // Legacy aliases
  static const surfaceVariantDark = surfaceContainerHigh;
  static const surfaceVariantLight = surfaceContainerHigh;
  static const primaryDark = primary;
  static const primaryLight = primary;
  static const onSurfaceVariantDark = onSurfaceVariant;
  static const onSurfaceVariantLight = onSurfaceVariant;
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const info = Color(0xFF2196F3);
  static const error = Color(0xFFF44336);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.surface,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurface: AppColors.onSurface,
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        tertiary: AppColors.tertiary,
        onPrimary: AppColors.onPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(fontSize: 57, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.manrope(fontSize: 18),
        bodyMedium: GoogleFonts.manrope(fontSize: 14),
        labelMedium: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData light() {
    // Basic light theme implementation to resolve undefined method error
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
    );
  }
}
