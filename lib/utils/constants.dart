class AppConstants {
  // App Information
  static const String appName = 'AgriDirect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Agriculture Assistant';

  // API Endpoints
  static const String baseApiUrl = 'https://api.agridirect.com/v1';
  static const String weatherApiUrl = 'https://api.openweathermap.org/data/2.5';
  static const String mlApiUrl = 'https://ml.agridirect.com/v1';

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String authTokenKey = 'auth_token';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String onboardingKey = 'onboarding_completed';
  static const String notificationKey = 'notification_settings';
  static const String locationKey = 'user_location';

  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultTheme = 'light';
  static const int defaultTimeout = 30; // seconds
  static const int maxRetryAttempts = 3;
  static const double defaultLatitude = 28.6139; // Delhi
  static const double defaultLongitude = 77.2090;

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int phoneNumberLength = 10;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);

  // Image Constants
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String appLogo = 'assets/images/app_logo.png';
  static const String splashBackground = 'assets/images/splash_bg.png';
  static const String welcomeBackground = 'assets/images/welcome_bg.png';
  static const String noDataImage = 'assets/images/no_data.png';
  static const String errorImage = 'assets/images/error.png';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String cropsCollection = 'crops';
  static const String weatherCollection = 'weather_data';
  static const String predictionsCollection = 'predictions';
  static const String notificationsCollection = 'notifications';
  static const String feedbackCollection = 'feedback';

  // ML Model Constants
  static const String diseaseModelPath = 'assets/models/plant_disease_model.tflite';
  static const String cropModelPath = 'assets/models/crop_recommendation_model.tflite';
  static const String soilModelPath = 'assets/models/soil_analysis_model.tflite';
  static const String pestModelPath = 'assets/models/pest_detection_model.tflite';

  // Label Files
  static const String diseaseLabelsPath = 'assets/labels/plant_disease_labels.txt';
  static const String cropLabelsPath = 'assets/labels/crop_labels.txt';
  static const String soilLabelsPath = 'assets/labels/soil_labels.txt';
  static const String pestLabelsPath = 'assets/labels/pest_labels.txt';

  // Error Messages
  static const String networkError = 'Network connection failed. Please check your internet connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String validationError = 'Please fill all required fields correctly.';
  static const String locationError = 'Unable to get your location. Please enable location services.';
  static const String cameraError = 'Camera access denied. Please allow camera permission.';
  static const String storageError = 'Storage access denied. Please allow storage permission.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String predictionSuccess = 'Prediction completed successfully!';
  static const String dataUploadSuccess = 'Data uploaded successfully!';

  // Crop Categories
  static const List<String> cropCategories = [
    'Cereals',
    'Pulses',
    'Vegetables',
    'Fruits',
    'Spices',
    'Cash Crops',
    'Fodder Crops',
  ];

  // Seasons
  static const List<String> seasons = [
    'Kharif',
    'Rabi',
    'Zaid',
    'Perennial',
  ];

  // Soil Types
  static const List<String> soilTypes = [
    'Clay',
    'Sandy',
    'Loamy',
    'Silty',
    'Peaty',
    'Chalky',
  ];

  // Farm Sizes
  static const List<String> farmSizes = [
    'Small (< 2 acres)',
    'Medium (2-10 acres)',
    'Large (> 10 acres)',
  ];

  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'gu', 'name': 'Gujarati'},
    {'code': 'mr', 'name': 'Marathi'},
    {'code': 'ta', 'name': 'Tamil'},
    {'code': 'te', 'name': 'Telugu'},
  ];

  // Weather Conditions
  static const Map<String, String> weatherIcons = {
    'clear': '☀️',
    'clouds': '☁️',
    'rain': '🌧️',
    'drizzle': '🌦️',
    'thunderstorm': '⛈️',
    'snow': '❄️',
    'mist': '🌫️',
    'fog': '🌫️',
    'haze': '🌫️',
  };

  // Notification Types
  static const String weatherAlert = 'weather_alert';
  static const String cropReminder = 'crop_reminder';
  static const String diseaseAlert = 'disease_alert';
  static const String marketUpdate = 'market_update';
  static const String generalNotification = 'general';

  // Permissions
  static const List<String> requiredPermissions = [
    'camera',
    'location',
    'storage',
    'notification',
  ];
}