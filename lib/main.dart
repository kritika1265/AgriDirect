import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/firebase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/ml_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';
import 'services/notification_service.dart';

import 'utils/colors.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables first
  await dotenv.load();
  
  // Set up error handling for the app
  _setupErrorHandling();
  
  try {
    // Initialize the application
    await _initializeApp();
    
    // Run the app
    runApp(const AgriDirectApp());
  } catch (e, stackTrace) {
    // Handle initialization errors
    _handleInitializationError(e, stackTrace);
  }
}

/// Initialize all app dependencies
Future<void> _initializeApp() async {
  try {
    // Initialize Firebase
    await _initializeFirebase();
    
    // Initialize other services
    await _initializeServices();
    
    // Set up system UI
    await _setupSystemUI();
    
    if (kDebugMode) {
      print('✅ App initialization completed successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ App initialization failed: $e');
    }
    rethrow;
  }
}

/// Initialize Firebase with proper error handling
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      // Remove DefaultFirebaseOptions.currentPlatform if firebase_options.dart doesn't exist
      // You need to run `flutterfire configure` to generate firebase_options.dart
    );
    
    // Initialize Firebase config instance
    final firebaseConfig = FirebaseConfig();
    await firebaseConfig.initialize();
    
    if (kDebugMode) {
      print('✅ Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Firebase initialization failed: $e');
    }
    throw Exception('Failed to initialize Firebase: $e');
  }
}

/// Initialize other services
Future<void> _initializeServices() async {
  try {
    // Initialize notifications
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    if (kDebugMode) {
      print('✅ Services initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Warning: Some services failed to initialize: $e');
    }
    // Don't throw error - app can work without some services
  }
}

/// Set up system UI preferences
Future<void> _setupSystemUI() async {
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    if (kDebugMode) {
      print('✅ System UI configured');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Warning: System UI setup failed: $e');
    }
    // Don't throw error - app can work without custom UI settings
  }
}

/// Set up global error handling
void _setupErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
      print('StackTrace: ${details.stack}');
    }
  };
  
  // Handle other errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('Platform Error: $error');
      print('StackTrace: $stack');
    }
    return true;
  };
}

/// Handle initialization errors
void _handleInitializationError(Object error, StackTrace stackTrace) {
  if (kDebugMode) {
    print('❌ Critical initialization error: $error');
    print('StackTrace: $stackTrace');
  }
  
  // Run a minimal error app
  runApp(
    MaterialApp(
      title: 'AgriDirect - Error',
      home: InitializationErrorScreen(error: error.toString()),
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// Error screen shown when app fails to initialize
class InitializationErrorScreen extends StatelessWidget {
  /// Creates an initialization error screen
  const InitializationErrorScreen({
    required this.error,
    super.key,
  });

  /// The error message to display
  final String error;

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade600,
              ),
              const SizedBox(height: 24),
              Text(
                'Failed to Start AgriDirect',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The app encountered an error during initialization. Please restart the app or contact support if the problem persists.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Information:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
}

/// Main application widget
class AgriDirectApp extends StatelessWidget {
  /// Creates the main application widget
  const AgriDirectApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false, // Initialize immediately
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          lazy: false, // Initialize immediately for theme
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(),
          lazy: false, // Initialize immediately for connectivity
        ),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MLProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(themeProvider.isDarkMode),
            // Replace AppRouter().router with your actual router implementation
            home: const Placeholder(), // Replace with your home screen
            builder: (context, child) {
              // Handle app-level errors
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) =>
                  _buildErrorWidget(errorDetails);
              
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.textScalerOf(context)
                        .scale(1)
                        .clamp(0.8, 1.2),
                  ),
                ),
                child: child!,
              );
            },
          ),
      ),
    );

  /// Build custom error widget for runtime errors
  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) => Material(
      child: Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              Text(
                errorDetails.exception.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );

  /// Build app theme
  ThemeData _buildTheme(bool isDarkMode) {
    final colorScheme = isDarkMode
        ? ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          )
        : ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: 'Roboto',
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}