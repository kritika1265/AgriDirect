import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme state and user preferences
/// Handles light/dark mode switching and theme customizations
class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _fontSizeKey = 'font_size';
  
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = const Color(0xFF4CAF50); // Agricultural green
  double _fontSizeScale = 1.0;
  bool _isInitialized = false;

  /// Current theme mode (light, dark, or system)
  ThemeMode get themeMode => _themeMode;
  
  /// Current accent color
  Color get accentColor => _accentColor;
  
  /// Current font size scale
  double get fontSizeScale => _fontSizeScale;
  
  /// Whether the provider has been initialized
  bool get isInitialized => _isInitialized;
  
  /// Whether dark mode is currently active
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  /// Initialize theme provider from saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeIndex = prefs.getInt(_themePreferenceKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeIndex];
      
      // Load accent color
      final colorValue = prefs.getInt(_accentColorKey) ?? _accentColor.value;
      _accentColor = Color(colorValue);
      
      // Load font size scale
      _fontSizeScale = prefs.getDouble(_fontSizeKey) ?? 1.0;
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing theme provider: $e');
    }
  }
  
  /// Set theme mode and persist to preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    // Update system UI overlay style
    _updateSystemUIOverlay();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themePreferenceKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
  
  /// Set accent color and persist to preferences
  Future<void> setAccentColor(Color color) async {
    if (_accentColor == color) return;
    
    _accentColor = color;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentColorKey, color.value);
    } catch (e) {
      debugPrint('Error saving accent color: $e');
    }
  }
  
  /// Set font size scale and persist to preferences
  Future<void> setFontSizeScale(double scale) async {
    if (_fontSizeScale == scale) return;
    
    _fontSizeScale = scale.clamp(0.8, 1.4);
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, _fontSizeScale);
    } catch (e) {
      debugPrint('Error saving font size scale: $e');
    }
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
  
  /// Get light theme data
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
      ),
      textTheme: _getScaledTextTheme(ThemeData.light().textTheme),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  
  /// Get dark theme data
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
      ),
      textTheme: _getScaledTextTheme(ThemeData.dark().textTheme),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
      ),
    );
  }
  
  /// Get scaled text theme based on font size preference
  TextTheme _getScaledTextTheme(TextTheme baseTheme) {
    return baseTheme.apply(
      fontSizeFactor: _fontSizeScale,
    );
  }
  
  /// Update system UI overlay style based on current theme
  void _updateSystemUIOverlay() {
    final isLight = !isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isLight ? Colors.white : Colors.black,
        systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      ),
    );
  }
  
  /// Get predefined accent colors for user selection
  List<Color> get predefinedAccentColors => [
    const Color(0xFF4CAF50), // Green (default agricultural)
    const Color(0xFF2196F3), // Blue
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF9800), // Orange
    const Color(0xFFF44336), // Red
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF009688), // Teal
  ];
  
  /// Get font size options for user selection
  List<FontSizeOption> get fontSizeOptions => [
    FontSizeOption('Small', 0.8),
    FontSizeOption('Default', 1.0),
    FontSizeOption('Large', 1.2),
    FontSizeOption('Extra Large', 1.4),
  ];
  
  /// Reset theme to defaults
  Future<void> resetToDefaults() async {
    await setThemeMode(ThemeMode.system);
    await setAccentColor(const Color(0xFF4CAF50));
    await setFontSizeScale(1.0);
  }
}

/// Data class for font size options
class FontSizeOption {
  final String name;
  final double scale;
  
  const FontSizeOption(this.name, this.scale);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FontSizeOption &&
          runtimeType == other.runtimeType &&
          scale == other.scale;
  
  @override
  int get hashCode => scale.hashCode;
}