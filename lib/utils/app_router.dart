import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../screens/crop_calendar_screen.dart';
import '../screens/crop_prediction_screen.dart';
import '../screens/disease_detection_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/help_screen.dart';
import '../screens/home_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/rent_tools_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/smart_connect_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/weather_screen.dart';

/// Main application router class that handles all navigation routes
class AppRouter {
  /// Route constants
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String diseaseDetection = '/disease-detection';
  static const String cropPrediction = '/crop-prediction';
  static const String weather = '/weather';
  static const String rentTools = '/rent-tools';
  static const String smartConnect = '/smart-connect';
  static const String feed = '/feed';
  static const String profile = '/profile';
  static const String settingsRoute = '/settings';
  static const String cropCalendar = '/crop-calendar';
  static const String marketplace = '/marketplace';
  static const String help = '/help';

  /// Generates routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case diseaseDetection:
        return MaterialPageRoute(
          builder: (_) => const DiseaseDetectionScreen(),
          settings: settings,
        );

      case cropPrediction:
        final arguments = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CropPredictionScreen(
            // Remove initialData parameter or make sure it exists in CropPredictionScreen constructor
            // initialData: arguments?['initialData'],
          ),
          settings: settings,
        );

      case weather:
        final arguments = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => WeatherScreen(
            // Remove location parameter or make sure it exists in WeatherScreen constructor
            // location: arguments?['location'],
          ),
          settings: settings,
        );

      case rentTools:
        return MaterialPageRoute(
          builder: (_) => const RentToolsScreen(),
          settings: settings,
        );

      case smartConnect:
        return MaterialPageRoute(
          builder: (_) => const SmartConnectScreen(),
          settings: settings,
        );

      case feed:
        return MaterialPageRoute(
          builder: (_) => const FeedScreen(),
          settings: settings,
        );

      case profile:
        final arguments = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(
            // Remove userId parameter or make sure it exists in ProfileScreen constructor
            // userId: arguments?['userId'],
          ),
          settings: settings,
        );

      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case cropCalendar:
        final arguments = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CropCalendarScreen(
            // Remove selectedDate parameter or make sure it exists in CropCalendarScreen constructor
            // selectedDate: arguments?['selectedDate'],
          ),
          settings: settings,
        );

      case marketplace:
        final arguments = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MarketplaceScreen(
            // Remove category parameter or make sure it exists in MarketplaceScreen constructor
            // category: arguments?['category'],
          ),
          settings: settings,
        );

      case help:
        final arguments = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => HelpScreen(
            // Remove section parameter or make sure it exists in HelpScreen constructor
            // section: arguments?['section'],
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }

  // Navigation helper methods
  /// Navigate to a named route
  static Future<void> pushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(context).pushNamed(
        routeName,
        arguments: arguments,
      );

  /// Replace current route with a named route
  static Future<void> pushReplacementNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.of(context).pushReplacementNamed(
        routeName,
        arguments: arguments,
      );

  /// Navigate to route and remove all previous routes
  static Future<void> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) =>
      Navigator.of(context).pushNamedAndRemoveUntil(
        routeName,
        predicate ?? (route) => false,
        arguments: arguments,
      );

  /// Pop current route
  static void pop(BuildContext context, [Object? result]) =>
      Navigator.of(context).pop(result);

  /// Pop until reaching specified route
  static void popUntil(BuildContext context, String routeName) =>
      Navigator.of(context).popUntil(ModalRoute.withName(routeName));

  // Custom transitions
  /// Fade transition for routes
  static Route<T> fadeTransition<T extends Object?>(
    Widget child,
    RouteSettings settings,
  ) =>
      PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      );

  /// Slide transition for routes
  static Route<T> slideTransition<T extends Object?>(
    Widget child,
    RouteSettings settings, {
    Offset begin = const Offset(1, 0),
  }) {
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: animation.drive(tween),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Scale transition for routes
  static Route<T> scaleTransition<T extends Object?>(
    Widget child,
    RouteSettings settings,
  ) =>
      PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            ScaleTransition(
          scale: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      );

  // Deep link handling
  /// Handle deep links and return appropriate route
  static String? handleDeepLink(String link) {
    final uri = Uri.parse(link);
    
    if (uri.pathSegments.isEmpty) return home;
    
    switch (uri.pathSegments.first) {
      case 'disease-detection':
        return diseaseDetection;
      case 'crop-prediction':
        return cropPrediction;
      case 'weather':
        return weather;
      case 'marketplace':
        return marketplace;
      case 'profile':
        return profile;
      default:
        return home;
    }
  }

  // Route guards
  /// Check if user can navigate to a specific route
  static bool canNavigateToRoute(String routeName, {bool isAuthenticated = false}) {
    const protectedRoutes = [
      home,
      diseaseDetection,
      cropPrediction,
      weather,
      rentTools,
      smartConnect,
      feed,
      profile,
      settingsRoute,
      cropCalendar,
      marketplace,
    ];

    return !protectedRoutes.contains(routeName) || isAuthenticated;
  }

  // Get route title for app bar
  /// Get title for route to display in app bar
  static String getRouteTitle(String routeName) {
    switch (routeName) {
      case home:
        return 'AgriDirect';
      case diseaseDetection:
        return 'Disease Detection';
      case cropPrediction:
        return 'Crop Prediction';
      case weather:
        return 'Weather';
      case rentTools:
        return 'Rent Tools';
      case smartConnect:
        return 'Smart Connect';
      case feed:
        return 'News & Updates';
      case profile:
        return 'Profile';
      case settingsRoute:
        return 'Settings';
      case cropCalendar:
        return 'Crop Calendar';
      case marketplace:
        return 'Marketplace';
      case help:
        return 'Help & Support';
      default:
        return 'AgriDirect';
    }
  }
}

// 404 Not Found Screen
/// Screen displayed when route is not found
class NotFoundScreen extends StatelessWidget {
  /// Constructor for NotFoundScreen
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '404',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  AppRouter.pushReplacementNamed(context, AppRouter.home);
                },
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
}