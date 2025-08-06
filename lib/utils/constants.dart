/// Application constants used throughout the AgriDirect app
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App Information
  static const String appName = 'AgriDirect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Agriculture Assistant';
  
  // Support Contact Information
  static const String supportPhoneNumber = '+911234567890';
  static const String supportWhatsAppNumber = '911234567890';
  static const String supportEmail = 'support@agridirect.com';
  static const String privacyPolicyUrl = 'https://agridirect.com/privacy';
  static const String termsOfServiceUrl = 'https://agridirect.com/terms';

  // API Endpoints
  static const String baseUrl = 'https://api.agridirect.com';
  static const String baseApiUrl = 'https://api.agridirect.com/v1';
  static const String apiVersion = 'v1';
  static const String weatherApiUrl = 'https://api.openweathermap.org/data/2.5';
  static const String mlApiUrl = 'https://ml.agridirect.com/v1';
  static const String cropRecommendationApiUrl = '$baseUrl/crop-recommendation';
  static const String diseaseDetectionApiUrl = '$baseUrl/disease-detection';
  static const String marketplaceEndpoint = '/marketplace';
  static const int apiTimeout = 30000; // 30 seconds
  static const int defaultTimeout = 30; // seconds
  static const int maxRetryAttempts = 3;
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String authTokenKey = 'auth_token';
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String onboardingKey = 'onboarding_completed';
  static const String notificationKey = 'notification_settings';
  static const String locationKey = 'user_location';
  static const String isFirstLaunchKey = 'is_first_launch';

  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultTheme = 'light';
  static const double defaultLatitude = 22.3072; // Anand, Gujarat
  static const double defaultLongitude = 72.9581;
  static const double locationAccuracyThreshold = 100.0; // meters

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int phoneNumberLength = 10;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultRadius = 8.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 6.0;
  static const double cardElevation = 4.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 48.0;

  // Font Sizes
  static const double headlineFontSize = 24.0;
  static const double titleFontSize = 20.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Constants
  static const String imageBasePath = 'assets/images/';
  static const String iconBasePath = 'assets/icons/';
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String appLogo = 'assets/images/app_logo.png';
  static const String splashBackground = 'assets/images/splash_bg.png';
  static const String welcomeBackground = 'assets/images/welcome_bg.png';
  static const String noDataImage = 'assets/images/no_data.png';
  static const String errorImage = 'assets/images/error.png';
  static const String placeholderImage = '${imageBasePath}placeholder.png';
  
  // Image Settings
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Weather Units
  static const String temperatureUnit = '°C';
  static const String humidityUnit = '%';
  static const String windSpeedUnit = 'km/h';
  static const String precipitationUnit = 'mm';

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
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later';
  static const String authError = 'Authentication failed. Please login again.';
  static const String validationError = 'Please fill all required fields correctly.';
  static const String locationError = 'Unable to get your location. Please enable location services.';
  static const String locationErrorMessage = 'Unable to get your location';
  static const String cameraError = 'Camera access denied. Please allow camera permission.';
  static const String cameraErrorMessage = 'Unable to access camera';
  static const String storageError = 'Storage access denied. Please allow storage permission.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String notFoundError = 'Resource not found.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully';
  static const String predictionSuccess = 'Prediction completed successfully!';
  static const String dataUploadSuccess = 'Data uploaded successfully!';
  static const String dataLoadedSuccess = 'Data loaded successfully';
  static const String dataSavedSuccess = 'Data saved successfully';
  static const String dataSavedMessage = 'Data saved successfully';
  static const String dataUpdatedSuccess = 'Data updated successfully';
  static const String dataDeletedSuccess = 'Data deleted successfully';

  // Crop Categories
  static const List<String> cropCategories = [
    'Cereals',
    'Pulses',
    'Oilseeds',
    'Vegetables',
    'Fruits',
    'Spices',
    'Cash Crops',
    'Fodder Crops',
  ];

  // News Categories
  static const List<String> newsCategories = [
    'All',
    'Research',
    'Policy',
    'Technology',
    'Market',
    'Weather',
    'Crop Management',
    'Livestock',
    'Organic Farming',
    'Government Schemes',
  ];

  // Market Categories (Original)
  static const List<String> marketCategories = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Spices',
    'Pulses',
    'Oilseeds',
  ];

  // Marketplace Categories (Extended for e-commerce)
  static const List<String> marketplaceCategories = [
    'All',
    'Grains',
    'Vegetables',
    'Fruits',
    'Seeds',
    'Fertilizers',
    'Tools',
    'Dairy',
    'Livestock',
    'Organic',
  ];

  // Available locations for marketplace and services
  static const List<String> locations = [
    'All',
    'Anand, Gujarat',
    'Bharuch, Gujarat',
    'Vadodara, Gujarat',
    'Ahmedabad, Gujarat',
    'Surat, Gujarat',
    'Rajkot, Gujarat',
    'Gandhinagar, Gujarat',
    'Bhavnagar, Gujarat',
    'Jamnagar, Gujarat',
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

  // Regional Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिंदी'},
    {'code': 'gu', 'name': 'ગુજરાતી'},
    {'code': 'mr', 'name': 'मराठी'},
    {'code': 'ta', 'name': 'தமிழ்'},
    {'code': 'te', 'name': 'తెలుగు'},
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

  // Social Media
  static const String facebookUrl = 'https://facebook.com/agridirect';
  static const String twitterUrl = 'https://twitter.com/agridirect';
  static const String instagramUrl = 'https://instagram.com/agridirect';
  static const String youtubeUrl = 'https://youtube.com/agridirect';

  // Feature Flags (you can use these to enable/disable features)
  static const bool isDiseaseDetectionEnabled = true;
  static const bool isCropRecommendationEnabled = true;
  static const bool isWeatherForecastEnabled = true;
  static const bool isMarketplaceEnabled = true;
}