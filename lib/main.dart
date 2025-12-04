import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Custom theme extension for app-specific colors
class AppColors extends ThemeExtension<AppColors> {
  final Color cardBackground;
  final Color inputBackground;
  final Color subtitleGray;
  final Color successGreen;
  final Color errorRed;
  final Color warningOrange;

  const AppColors({
    required this.cardBackground,
    required this.inputBackground,
    required this.subtitleGray,
    required this.successGreen,
    required this.errorRed,
    required this.warningOrange,
  });

  @override
  AppColors copyWith({
    Color? cardBackground,
    Color? inputBackground,
    Color? subtitleGray,
    Color? successGreen,
    Color? errorRed,
    Color? warningOrange,
  }) {
    return AppColors(
      cardBackground: cardBackground ?? this.cardBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      subtitleGray: subtitleGray ?? this.subtitleGray,
      successGreen: successGreen ?? this.successGreen,
      errorRed: errorRed ?? this.errorRed,
      warningOrange: warningOrange ?? this.warningOrange,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      subtitleGray: Color.lerp(subtitleGray, other.subtitleGray, t)!,
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
      errorRed: Color.lerp(errorRed, other.errorRed, t)!,
      warningOrange: Color.lerp(warningOrange, other.warningOrange, t)!,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // GL.iNet brand colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color darkBackground = Color(0xFF1A1D29);
  static const Color cardBackground = Color(0xFF252836);
  static const Color inputBackground = Color(0xFF2D303E);
  static const Color subtitleGray = Color(0xFF8E8E93);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GL.iNet Repeater Setup',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: primaryBlue,
          secondary: primaryBlue,
          surface: cardBackground,
          onSurface: Colors.white,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputBackground,
          hintStyle: const TextStyle(color: subtitleGray),
          labelStyle: const TextStyle(color: subtitleGray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            color: subtitleGray,
          ),
          labelMedium: TextStyle(
            color: subtitleGray,
            fontSize: 14,
          ),
        ),
        extensions: const <ThemeExtension<dynamic>>[
          AppColors(
            cardBackground: cardBackground,
            inputBackground: inputBackground,
            subtitleGray: subtitleGray,
            successGreen: successGreen,
            errorRed: errorRed,
            warningOrange: warningOrange,
          ),
        ],
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
