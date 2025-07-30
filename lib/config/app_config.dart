import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // App Information
  static const String appName = 'AgriDirect';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  
  // API Configuration
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static String get weatherApiBaseUrl => dotenv.env['WEATHER_API_BASE_URL'] ?? 'https://api.openweathermap.org/data/2.5';
  static String get newsApiKey => dotenv.env['NEWS_API_KEY'] ?? '';
  static String get newsApiBaseUrl => dotenv.env['NEWS_API_BASE_URL'] ?? 'https://newsapi.org/v2';
  static String get backendApiBaseUrl => dotenv.env['BACKEND_API_BASE_URL'] ?? '';
  
  // Google Services
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  // ML Model Configuration
  static const String diseaseModelPath = 'assets/models/plant_disease_model.tflite';
  static const String cropRecommendationModelPath = 'assets/models/crop_recommendation_model.tflite';
  static const String soilAnalysisModelPath = 'assets/models/soil_analysis_model.tflite';
  static const String pestDetectionModelPath = 'assets/models/pest_detection_model.tflite';
  
  // Label Files
  static const String diseaseLabelsPath = 'assets/labels/plant_disease_labels.txt';
  static const String cropLabelsPath = 'assets/labels/crop_labels.txt';
  static const String soilLabelsPath = 'assets/labels/soil_labels.txt';
  static const String pestLabelsPath = 'assets/labels/pest_labels.txt';
  
  // Data Files
  static const String cropCalendarPath = 'assets/data/crop_calendar.json';
  static const String farmingTipsPath = 'assets/data/farming_tips.json';
  static const String toolCategoriesPath = 'assets/data/tool_categories.json';
  
  // App Settings
  static const int maxImageSize = 1024; // Max image size for ML processing
  static const int cacheExpirationHours = 24;
  static const int weatherUpdateIntervalMinutes = 30;
  static const int locationUpdateIntervalMinutes = 15;
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration imageProcessingTimeout = Duration(minutes: 2);
  static const Duration mlInferenceTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Configuration
  static const double imageQuality = 0.8;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  
  // Notification Configuration
  static const String notificationChannelId = 'agridirect_notifications';
  static const String notificationChannelName = 'AgriDirect Notifications';
  static const String notificationChannelDescription = 'General notifications from AgriDirect';
  
  // Weather Alert Configuration
  static const String weatherAlertChannelId = 'weather_alerts';
  static const String weatherAlertChannelName = 'Weather Alerts';
  static const String weatherAlertChannelDescription = 'Weather warnings and alerts';
  
  // Crop Calendar Configuration
  static const String cropReminderChannelId = 'crop_reminders';
  static const String cropReminderChannelName = 'Crop Reminders';
  static const String cropReminderChannelDescription = 'Farming activity reminders';
  
  // Supported Languages
  static const List<String> supportedLanguages = [
    'en', // English
    'hi', // Hindi
    'gu', // Gujarati
    'mr', // Marathi
    'ta', // Tamil
    'te', // Telugu
    'kn', // Kannada
    'ml', // Malayalam
    'bn', // Bengali
    'pa', // Punjabi
  ];
  
  // Default Language
  static const String defaultLanguage = 'en';
  
  // Database Configuration
  static const String databaseName = 'agridirect.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String weatherCacheKey = 'weather_cache';
  static const String cropDataCacheKey = 'crop_data_cache';
  static const String lastLocationKey = 'last_location';
  static const String themePreferenceKey = 'theme_preference';
  static const String languagePreferenceKey = 'language_preference';
  static const String notificationPreferenceKey = 'notification_preference';
  
  // Feature Flags
  static const bool enableDiseaseDetection = true;
  static const bool enableCropPrediction = true;
  static const bool enableWeatherAlerts = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Development Mode
  static bool get isDevelopment => dotenv.env['ENVIRONMENT'] == 'development';
  static bool get isProduction => dotenv.env['ENVIRONMENT'] == 'production';
  
  // Logging Configuration
  static bool get enableLogging => isDevelopment || dotenv.env['ENABLE_LOGGING'] == 'true';
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'info';
  
  // Contact Information
  static const String supportEmail = 'support@agridirect.com';
  static const String feedbackEmail = 'feedback@agridirect.com';
  static const String websiteUrl = 'https://agridirect.com';
  static const String privacyPolicyUrl = 'https://agridirect.com/privacy';
  static const String termsOfServiceUrl = 'https://agridirect.com/terms';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/agridirect';
  static const String twitterUrl = 'https://twitter.com/agridirect';
  static const String instagramUrl = 'https://instagram.com/agridirect';
  static const String youtubeUrl = 'https://youtube.com/agridirect';
}

// ApiConfig class for backward compatibility with ApiService
class ApiConfig {
  // Base URL for your main API (uses backendApiBaseUrl from AppConfig)
  static String get baseUrl => AppConfig.backendApiBaseUrl.isNotEmpty 
      ? AppConfig.backendApiBaseUrl 
      : 'https://your-api-domain.com/api/v1';
  
  // API Key for main backend authentication
  static String get apiKey => dotenv.env['BACKEND_API_KEY'] ?? dotenv.env['API_KEY'] ?? '';
  
  // Other configuration constants
  static const int defaultTimeout = 30;
  static const String defaultLanguage = 'en';
  static const String defaultUnits = 'metric';
}