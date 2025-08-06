import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'TaskMaster AI';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Priority Colors
  static const Color lowPriorityColor = Color(0xFF10B981);
  static const Color mediumPriorityColor = Color(0xFFF59E0B);
  static const Color highPriorityColor = Color(0xFFEF4444);

  // Project Colors
  static const List<Color> projectColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFFEC4899), // Pink
    Color(0xFF84CC16), // Lime
  ];

  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // API Configuration
  static const int apiTimeout = 30000; // 30 seconds
  static const int mockApiDelay = 1000; // 1 second

  // Sample AI Prompts
  static const List<String> samplePrompts = [
    'Plan my week with 3 work tasks and 2 wellness tasks',
    'Create a study schedule for my Flutter course',
    'Generate tasks for my home renovation project',
    'Plan my daily routine with productivity tasks',
    'Create tasks for my fitness goals this month',
  ];

  // Color parsing utility
  static Color parseColor(String colorString) {
    try {
      // Handle hex color strings (e.g., "0xFF6366F1")
      if (colorString.startsWith('0x')) {
        return Color(int.parse(colorString));
      }

      // Handle Color object strings (e.g., "Color(alpha: 1.0000, red: 0.5176, green: 0.8000, blue: 0.0863, colorSpace: ...)")
      if (colorString.startsWith('Color(')) {
        // Try to extract alpha, red, green, blue values from the Color object string
        final alphaMatch = RegExp(r'alpha:\s*([\d.]+)').firstMatch(colorString);
        final redMatch = RegExp(r'red:\s*([\d.]+)').firstMatch(colorString);
        final greenMatch = RegExp(r'green:\s*([\d.]+)').firstMatch(colorString);
        final blueMatch = RegExp(r'blue:\s*([\d.]+)').firstMatch(colorString);

        if (alphaMatch != null &&
            redMatch != null &&
            greenMatch != null &&
            blueMatch != null) {
          final alpha = (double.parse(alphaMatch.group(1)!) * 255).round();
          final red = (double.parse(redMatch.group(1)!) * 255).round();
          final green = (double.parse(greenMatch.group(1)!) * 255).round();
          final blue = (double.parse(blueMatch.group(1)!) * 255).round();

          return Color.fromARGB(alpha, red, green, blue);
        }

        // If we can't parse the Color object, return default color
        return primaryColor;
      }

      // Try to parse as integer (for backward compatibility)
      if (colorString.contains(RegExp(r'^\d+$'))) {
        return Color(int.parse(colorString));
      }

      // If all parsing attempts fail, return default color
      return primaryColor;
    } catch (e) {
      // If any parsing fails, return default color
      return primaryColor;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.surfaceColor,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        color: AppConstants.surfaceColor,
        shadowColor: Colors.black12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(
            color: AppConstants.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(
            color: AppConstants.errorColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingM,
        ),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIconColor: Colors.black54,
        suffixIconColor: Colors.black54,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
      ),
    );
  }
}
