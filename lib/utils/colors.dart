import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

/// App color constants for agriculture-themed application
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation
  
  // Primary Colors - Green theme for agriculture
  static const Color primary = Color(0xFF2E7D32); // Deep green
  static const Color primaryColor = Color(0xFF4CAF50); // Green (alias for compatibility)
  static const Color primaryLight = Color(0xFF4CAF50); // Light green
  static const Color primaryDark = Color(0xFF1B5E20); // Dark green
  
  // Secondary Colors - Earth tones
  static const Color secondary = Color(0xFF8BC34A); // Light green
  static const Color secondaryColor = Color(0xFF2196F3); // Blue (for compatibility)
  static const Color secondaryLight = Color(0xFFAED581); // Very light green
  static const Color secondaryDark = Color(0xFF689F38); // Medium green
  
  // Accent Colors
  static const Color accent = Color(0xFFFF9800); // Orange for highlights
  static const Color accentColor = Color(0xFFFF9800); // Orange (alias for compatibility)
  static const Color accentLight = Color(0xFFFFB74D); // Light orange
  static const Color accentDark = Color(0xFFF57C00); // Dark orange
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Light gray
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light gray (alias for compatibility)
  static const Color backgroundDark = Color(0xFF121212); // Dark background
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color surfaceColor = Color(0xFFFFFFFF); // White surface (alias for compatibility)
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark surface
  static const Color cardBackground = Color(0xFFFFFFFF); // Card background
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark gray
  static const Color textSecondary = Color(0xFF757575); // Medium gray
  static const Color textLight = Color(0xFFBDBDBD); // Light gray
  static const Color textHint = Color(0xFF9E9E9E); // Hint text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on primary
  static const Color textOnSecondary = Color(0xFF000000); // Black on secondary
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0); // Light border
  static const Color borderLight = Color(0xFFE0E0E0); // Light border
  static const Color borderDark = Color(0xFFBDBDBD); // Dark border
  
  // Shadow Colors
  static const Color shadow = Color(0x1F000000); // Black with opacity
  static const Color shadowLight = Color(0x1A000000); // Light shadow
  static const Color shadowDark = Color(0x33000000); // Dark shadow
  static const Color overlay = Color(0x80000000); // Black with 50% opacity
  
  // Disabled Colors
  static const Color disabled = Color(0xFFBDBDBD); // Gray
  static const Color disabledText = Color(0xFF9E9E9E); // Disabled text
  static const Color placeholder = Color(0xFF9E9E9E); // Medium gray
  
  // Transparent Colors
  static const Color transparent = Colors.transparent;
  
  // Weather Colors
  static const Color sunny = Color(0xFFFFEB3B); // Yellow
  static const Color cloudy = Color(0xFF9E9E9E); // Gray
  static const Color rainy = Color(0xFF2196F3); // Blue
  static const Color stormy = Color(0xFF673AB7); // Purple
  static const Color snowy = Color(0xFFE1F5FE); // Light blue
  
  // Disease Detection Colors
  static const Color healthy = Color(0xFF4CAF50); // Green
  static const Color diseased = Color(0xFFF44336); // Red
  static const Color suspicious = Color(0xFFFF9800); // Orange
  static const Color processing = Color(0xFF2196F3); // Blue
  
  // Crop Growth Stage Colors
  static const Color seedling = Color(0xFF8BC34A); // Light green
  static const Color vegetative = Color(0xFF4CAF50); // Medium green
  static const Color flowering = Color(0xFFE91E63); // Pink
  static const Color fruiting = Color(0xFFFF9800); // Orange
  static const Color harvest = Color(0xFF795548); // Brown
  
  // Soil Type Colors
  static const Color clay = Color(0xFF8D6E63); // Brown
  static const Color sandy = Color(0xFFFFE082); // Light yellow
  static const Color loamy = Color(0xFF6D4C41); // Dark brown
  static const Color peat = Color(0xFF3E2723); // Very dark brown
  
  // Tool Category Colors
  static const Color handTools = Color(0xFF607D8B); // Blue gray
  static const Color powerTools = Color(0xFFFF5722); // Deep orange
  static const Color machinery = Color(0xFF795548); // Brown
  static const Color irrigation = Color(0xFF03A9F4); // Light blue
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
  ];
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary, secondaryDark],
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF9800), Color(0xFFFF5722), Color(0xFFE91E63)],
  );
  
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF87CEEB), Color(0xFF98D8E8), Color(0xFFB0E0E6)],
  );
  
  // Card Colors
  static const Color weatherCard = Color(0xFFE3F2FD); // Light blue
  static const Color diseaseCard = Color(0xFFE8F5E8); // Light green
  static const Color cropCard = Color(0xFFFFF3E0); // Light orange
  static const Color toolCard = Color(0xFFF3E5F5); // Light purple
  static const Color newsCard = Color(0xFFE0F2F1); // Light teal
  
  // Semantic Colors
  static const Color divider = Color(0xFFE0E0E0); // Light gray
  
  // Notification Colors
  static const Color notificationDefault = Color(0xFF2196F3); // Blue
  static const Color notificationWeather = Color(0xFFFF9800); // Orange
  static const Color notificationCrop = Color(0xFF4CAF50); // Green
  static const Color notificationTool = Color(0xFF795548); // Brown
  static const Color notificationNews = Color(0xFF9C27B0); // Purple
  
  // Transparency Levels
  static const double highEmphasis = 0.87;
  static const double mediumEmphasis = 0.60;
  static const double lowEmphasis = 0.38;
  static const double disabledOpacity = 0.12;
  
  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  // Theme-specific colors
  static ColorScheme lightColorScheme = const ColorScheme.light(
    primary: primary,
    onPrimary: textOnPrimary,
    secondary: secondary,
    onSecondary: textOnSecondary,
    surface: surface,
    onSurface: textPrimary,
    background: background,
    onBackground: textPrimary,
    error: error,
    onError: textOnPrimary,
  );
  
  static ColorScheme darkColorScheme = const ColorScheme.dark(
    primary: primaryLight,
    onPrimary: textPrimary,
    secondary: secondaryLight,
    onSecondary: textPrimary,
    surface: surfaceDark,
    onSurface: textOnPrimary,
    background: backgroundDark,
    onBackground: textOnPrimary,
    error: error,
    onError: textOnPrimary,
  );
}