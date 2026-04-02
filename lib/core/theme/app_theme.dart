import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette (Neon Observatory)
  static const primary = Color(0xFF00EEFC); // Vibrant Cyan
  static const primaryLight = Color(0xFF8FF5FF);
  static const primaryDark = Color(0xFF005D63);

  static const secondary = Color(0xFFBF81FF); // Vibrant Purple
  static const secondaryDark = Color(0xFF7701D0);

  // Surface colors - Light (Daylight Calibration)
  static const backgroundLight = Color(0xFFFAFCFF); // Frosty white
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF1F5F9);
  static const onSurfaceLight = Color(0xFF060E20); // Very dark slate
  static const onSurfaceVariantLight = Color(0xFF40485D);

  // Surface colors - Dark (Neon Observatory Core)
  static const backgroundDark = Color(0xFF000000); // True Black
  static const surfaceDark = Color(0xFF060E20); // Deep Midnight Slate
  static const surfaceVariantDark = Color(0xFF141F38); // Glassmorphism container
  static const onSurfaceDark = Color(0xFFDEE5FF);
  static const onSurfaceVariantDark = Color(0xFFA3AAC4);

  // Semantic
  static const success = Color(0xFF1EE9B6);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFFF716C);
  static const info = Color(0xFF8FF5FF);

  // Chat bubbles
  static const userBubble = Color(0xFF141F38);
  static const assistantBubbleLight = Color(0xFFF1F5F9);
  static const assistantBubbleDark = Color(0xFF091328);
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
  static ThemeData light() {
    final textTheme = GoogleFonts.manropeTextTheme();
    final displayTheme = GoogleFonts.spaceGroteskTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: textTheme.copyWith(
        displayLarge: displayTheme.displayLarge,
        displayMedium: displayTheme.displayMedium,
        displaySmall: displayTheme.displaySmall,
        headlineLarge: displayTheme.headlineLarge,
        headlineMedium: displayTheme.headlineMedium,
        headlineSmall: displayTheme.headlineSmall,
        titleLarge: displayTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.onSurfaceLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.3),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark, // Dark cyan for contrast
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  static ThemeData dark() {
    final textTheme = GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme);
    final displayTheme = GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: textTheme.copyWith(
        displayLarge: displayTheme.displayLarge,
        displayMedium: displayTheme.displayMedium,
        displaySmall: displayTheme.displaySmall,
        headlineLarge: displayTheme.headlineLarge,
        headlineMedium: displayTheme.headlineMedium,
        headlineSmall: displayTheme.headlineSmall,
        titleLarge: displayTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceVariantDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF40485D), width: 0.5), // outline_variant
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF40485D), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.05),
        thickness: 1,
      ),
    );
  }
}