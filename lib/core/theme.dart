import 'package:flutter/material.dart';

class AppColors {
  static const Color canvas = Colors.white;
  static const Color page = Color(0xFFF4F3F9);
  static const Color inkBlue = Color(0xFF4D3CFF);
  static const Color lightInk = Color(0xFFE2DFFF);
  static const Color softLilac = Color(0xFFFAF9FF);
  static const Color border = Color(0xFFE7E4F4);
  static const Color inkText = Color(0xFF201381);
  static const Color grayText = Color(0xFF5D5791);
  static const Color softGray = Color(0xFFF8FAFC);
  static const Color activeGauge = Color(0xFF6366F1);
  static const Color blueSoft = Color(0xFF7C6CFF);
  static const Color green = Color(0xFF00856D);

  // Muscle Map Heatmap
  static const Color muscleNotWorked = Color(0xFFD8DDDA);
  static const Color muscleLight = Color(0xFFF3D85F);
  static const Color muscleModerate = Color(0xFFB9E66E);
  static const Color muscleStrong = Color(0xFF54C45F);
  static const Color muscleMax = Color(0xFF15803D);

  // UI Components
  static const Color panelBackground = Color(0xFFECEDEB);
  static const Color weekButtonBackground = Color(0xFFE3E3DF);
  static const Color weekButtonText = Color(0xFFB1B1AD);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color workoutGreen = Color(0xFF14C53A);
  static const Color badgeBackground = Color(0xFFF4F4F2);
  static const Color switchBackground = Color(0xFFE4E4E4);
  static const Color lightBorder = border;
  static const Color focusAccent = blueSoft;
  static const Color softBlue = softLilac;

  // Tab bar
  static const Color tabBarBorder = Color(0xFFF0EEF8);
  static const Color tabInactive = Color(0xFF615C99);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.inkBlue,
        surface: AppColors.canvas,
        primary: AppColors.inkBlue,
      ),
      scaffoldBackgroundColor: AppColors.page,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.page,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.inkText),
        titleTextStyle: TextStyle(
          color: AppColors.inkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.title(
          textStyle: baseTextTheme.displayLarge?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        displayMedium: AppTypography.title(
          textStyle: baseTextTheme.displayMedium?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        displaySmall: AppTypography.title(
          textStyle: baseTextTheme.displaySmall?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        headlineLarge: AppTypography.title(
          textStyle: baseTextTheme.headlineLarge?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        headlineMedium: AppTypography.title(
          textStyle: baseTextTheme.headlineMedium?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        headlineSmall: AppTypography.title(
          textStyle: baseTextTheme.headlineSmall?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleLarge: AppTypography.title(
          textStyle: baseTextTheme.titleLarge?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleMedium: AppTypography.title(
          textStyle: baseTextTheme.titleMedium?.copyWith(
            color: AppColors.inkText,
          ),
        ),
        titleSmall: AppTypography.title(
          textStyle: baseTextTheme.titleSmall?.copyWith(
            color: AppColors.inkText,
          ),
        ),
        bodyLarge: AppTypography.body(
          textStyle: baseTextTheme.bodyLarge?.copyWith(
            color: AppColors.inkText,
          ),
        ),
        bodyMedium: AppTypography.body(
          textStyle: baseTextTheme.bodyMedium?.copyWith(
            color: AppColors.grayText,
          ),
        ),
        bodySmall: AppTypography.body(
          textStyle: baseTextTheme.bodySmall?.copyWith(
            color: AppColors.grayText,
          ),
        ),
        labelLarge: AppTypography.body(
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: AppColors.inkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AppTypography {
  static const String primaryFont = 'Comic Sans MS';
  static const List<String> fallbackFonts = [
    'Trebuchet MS',
    'Segoe UI',
    'Arial',
    'sans-serif',
  ];

  static TextStyle title({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) {
    return _prototypeTextStyle(
      textStyle: textStyle,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) {
    return _prototypeTextStyle(
      textStyle: textStyle,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _prototypeTextStyle({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) {
    return (textStyle ?? const TextStyle()).copyWith(
      fontFamily: primaryFont,
      fontFamilyFallback: fallbackFonts,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
