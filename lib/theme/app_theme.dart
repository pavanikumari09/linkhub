import 'package:flutter/material.dart';

/// App theme with Material 3 design
/// Primary background: #FCF5EE
/// Accent/icon color: #850E35
class AppTheme {
  // Primary colors
  static const Color primaryBackground = Color(0xFFFCF5EE);
  static const Color accentColor = Color(0xFF850E35);
  
  // Additional colors for Material 3
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        onPrimary: onPrimary,
        secondary: accentColor.withAlpha((0.8 * 255).round()),
        surface: surfaceColor,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: primaryBackground,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBackground,
        foregroundColor: accentColor,
        elevation: 0,
        centerTitle: false,
      ),
      
      // Card theme with rounded corners and soft shadows
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withAlpha((0.1 * 255).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // FAB theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: onPrimary,
        elevation: 4,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor.withAlpha((0.3 * 255).round())),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha((0.3 * 255).round())),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: accentColor.withAlpha((0.1 * 255).round()),
        labelStyle: const TextStyle(color: accentColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
