import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color canvas = Colors.white;
  static const Color inkBlue = Color(0xFF4C36E3);
  static const Color lightInk = Color(0xFFE2DFFF);
  static const Color softLilac = Color(0xFFF3F0FF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color inkText = Color(0xFF1E1B4B);
  static const Color grayText = Color(0xFF6E7191);
  static const Color softGray = Color(0xFFF8FAFC);
  static const Color activeGauge = Color(0xFF6366F1);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.inkBlue,
        background: AppColors.canvas,
        primary: AppColors.inkBlue,
        surface: AppColors.canvas,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.inkText),
        titleTextStyle: TextStyle(
          color: AppColors.inkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        // Pangolin for hand-drawn titles
        displayLarge: GoogleFonts.pangolin(
          textStyle: baseTextTheme.displayLarge?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        displayMedium: GoogleFonts.pangolin(
          textStyle: baseTextTheme.displayMedium?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        displaySmall: GoogleFonts.pangolin(
          textStyle: baseTextTheme.displaySmall?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        headlineLarge: GoogleFonts.pangolin(
          textStyle: baseTextTheme.headlineLarge?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        headlineMedium: GoogleFonts.pangolin(
          textStyle: baseTextTheme.headlineMedium?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        headlineSmall: GoogleFonts.pangolin(
          textStyle: baseTextTheme.headlineSmall?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleLarge: GoogleFonts.pangolin(
          textStyle: baseTextTheme.titleLarge?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleMedium: GoogleFonts.pangolin(
          textStyle: baseTextTheme.titleMedium?.copyWith(
            color: AppColors.inkText,
          ),
        ),
        titleSmall: GoogleFonts.pangolin(
          textStyle: baseTextTheme.titleSmall?.copyWith(
            color: AppColors.inkText,
          ),
        ),
        
        // Nunito for clear body text and digits
        bodyLarge: GoogleFonts.nunito(
          textStyle: baseTextTheme.bodyLarge?.copyWith(
            color: AppColors.inkText,
          ),
        ),
        bodyMedium: GoogleFonts.nunito(
          textStyle: baseTextTheme.bodyMedium?.copyWith(
            color: AppColors.grayText,
          ),
        ),
        bodySmall: GoogleFonts.nunito(
          textStyle: baseTextTheme.bodySmall?.copyWith(
            color: AppColors.grayText,
          ),
        ),
        labelLarge: GoogleFonts.nunito(
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
