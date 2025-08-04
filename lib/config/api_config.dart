// lib/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URLs - can be environment-specific
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.agridirect.com/v1';
  
  // API Keys from environment variables
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static String get newsApiKey => dotenv.env['NEWS_API_KEY'] ?? '';
  
  // Weather API configuration
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // News API configuration  
  static const String newsBaseUrl = 'https://newsapi.org/v2';
  
  // ML API endpoints
  static String get mlServiceUrl => dotenv.env['ML_SERVICE_URL'] ?? 'https://ml.agridirect.com/v1';
  static String get diseaseDetectionUrl => '$mlServiceUrl/detect-disease';
  static String get cropPredictionUrl => '$mlServiceUrl/predict-crop';
  static String get soilAnalysisUrl => '$mlServiceUrl/analyze-soil';
  
  // Marketplace endpoints
  static String get marketplaceUrl => '$baseUrl/marketplace';
  static String get toolRentalUrl => '$baseUrl/tools';
  
  // Community endpoints
  static String get communityUrl => '$baseUrl/community';
  static String get expertUrl => '$baseUrl/experts';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Validation methods
  static bool get hasWeatherApiKey => weatherApiKey.isNotEmpty;
  static bool get hasNewsApiKey => newsApiKey.isNotEmpty;
  
  static void validateConfiguration() {
    if (!hasWeatherApiKey) {
      throw Exception('WEATHER_API_KEY not found in environment variables');
    }
    if (!hasNewsApiKey) {
      throw Exception('NEWS_API_KEY not found in environment variables');
    }
  }
}


class AppConfig {
  static const String appName = 'AgriDirect';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.agridirect.app';
  
  // Firebase configuration from environment
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? 'agridirect-app';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  
  // Notification configuration
  static String get fcmServerKey => dotenv.env['FCM_SERVER_KEY'] ?? '';
  
  // Storage configuration
  static const String storagePrefix = 'agridirect_';
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  
  // ML Model configuration
  static const double confidenceThreshold = 0.7;
  static const int maxPredictions = 5;
  
  // Location configuration
  static const double locationAccuracy = 100.0; // meters
  static const Duration locationTimeout = Duration(seconds: 15);
  
  // Cache configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Support configuration - can be environment-specific
  static String get supportEmail => dotenv.env['SUPPORT_EMAIL'] ?? 'support@agridirect.com';
  static String get supportPhone => dotenv.env['SUPPORT_PHONE'] ?? '+1-800-AGRI-HELP';
  static String get termsUrl => dotenv.env['TERMS_URL'] ?? 'https://agridirect.com/terms';
  static String get privacyUrl => dotenv.env['PRIVACY_URL'] ?? 'https://agridirect.com/privacy';
  
  // Environment detection
  static bool get isProduction => dotenv.env['ENVIRONMENT']?.toLowerCase() == 'production';
  static bool get isDevelopment => dotenv.env['ENVIRONMENT']?.toLowerCase() == 'development';
  static bool get isStaging => dotenv.env['ENVIRONMENT']?.toLowerCase() == 'staging';
  
  // Debug configuration
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  
  // Validation methods
  static bool get hasFirebaseApiKey => firebaseApiKey.isNotEmpty;
  static bool get hasFcmServerKey => fcmServerKey.isNotEmpty;
  
  static void validateConfiguration() {
    if (!hasFirebaseApiKey) {
      throw Exception('FIREBASE_API_KEY not found in environment variables');
    }
    // Add other critical validations as needed
  }
}

// lib/models/crop_model.dart
class Crop {
  final String id;
  final String name;
  final String scientificName;
  final String category;
  final String imageUrl;
  final String description;
  final List<String> seasons;
  final Map<String, dynamic> requirements;
  final int growthDuration; // in days
  final Map<String, String> careInstructions;
  final List<String> commonDiseases;
  final List<String> compatibleCrops;
  final double expectedYield; // per hectare
  final Map<String, dynamic> marketPrice;

  const Crop({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.seasons,
    required this.requirements,
    required this.growthDuration,
    required this.careInstructions,
    required this.commonDiseases,
    required this.compatibleCrops,
    required this.expectedYield,
    required this.marketPrice,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      scientificName: json['scientific_name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      seasons: _parseStringList(json['seasons']),
      requirements: json['requirements'] as Map<String, dynamic>? ?? {},
      growthDuration: _parseInt(json['growth_duration']),
      careInstructions: _parseStringMap(json['care_instructions']),
      commonDiseases: _parseStringList(json['common_diseases']),
      compatibleCrops: _parseStringList(json['compatible_crops']),
      expectedYield: _parseDouble(json['expected_yield']),
      marketPrice: json['market_price'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'category': category,
      'image_url': imageUrl,
      'description': description,
      'seasons': seasons,
      'requirements': requirements,
      'growth_duration': growthDuration,
      'care_instructions': careInstructions,
      'common_diseases': commonDiseases,
      'compatible_crops': compatibleCrops,
      'expected_yield': expectedYield,
      'market_price': marketPrice,
    };
  }

  // Helper methods for safe parsing
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  static Map<String, String> _parseStringMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return value.map((key, val) => MapEntry(key?.toString() ?? '', val?.toString() ?? ''));
    }
    return {};
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Crop &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Crop(id: $id, name: $name)';
}

class CropRecommendation {
  final String cropId;
  final String cropName;
  final double suitabilityScore;
  final List<String> reasons;
  final Map<String, dynamic> soilRequirements;
  final Map<String, dynamic> climateRequirements;
  final String season;
  final double estimatedYield;
  final double profitabilityScore;

  const CropRecommendation({
    required this.cropId,
    required this.cropName,
    required this.suitabilityScore,
    required this.reasons,
    required this.soilRequirements,
    required this.climateRequirements,
    required this.season,
    required this.estimatedYield,
    required this.profitabilityScore,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      cropId: json['crop_id']?.toString() ?? '',
      cropName: json['crop_name']?.toString() ?? '',
      suitabilityScore: Crop._parseDouble(json['suitability_score']),
      reasons: Crop._parseStringList(json['reasons']),
      soilRequirements: json['soil_requirements'] as Map<String, dynamic>? ?? {},
      climateRequirements: json['climate_requirements'] as Map<String, dynamic>? ?? {},
      season: json['season']?.toString() ?? '',
      estimatedYield: Crop._parseDouble(json['estimated_yield']),
      profitabilityScore: Crop._parseDouble(json['profitability_score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'crop_name': cropName,
      'suitability_score': suitabilityScore,
      'reasons': reasons,
      'soil_requirements': soilRequirements,
      'climate_requirements': climateRequirements,
      'season': season,
      'estimated_yield': estimatedYield,
      'profitability_score': profitabilityScore,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropRecommendation &&
          runtimeType == other.runtimeType &&
          cropId == other.cropId;

  @override
  int get hashCode => cropId.hashCode;

  @override
  String toString() => 'CropRecommendation(cropId: $cropId, cropName: $cropName)';
}

// lib/models/user_model.dart
class User {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final UserProfile? profile;
  final Map<String, dynamic> preferences;
  final bool isVerified;
  final String role; // farmer, expert, admin

  const User({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.profile,
    this.preferences = const {},
    this.isVerified = false,
    this.role = 'farmer',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      lastLoginAt: _parseDateTime(json['last_login_at']),
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>) : null,
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      isVerified: json['is_verified'] == true,
      role: json['role']?.toString() ?? 'farmer',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'profile': profile?.toJson(),
      'preferences': preferences,
      'is_verified': isVerified,
      'role': role,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? profileImageUrl,
    UserProfile? profile,
    Map<String, dynamic>? preferences,
    bool? isVerified,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id,
      phoneNumber: phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      isVerified: isVerified ?? this.isVerified,
      role: role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, phoneNumber: $phoneNumber, name: $name)';
}

class UserProfile {
  final String farmName;
  final String location;
  final double latitude;
  final double longitude;
  final String state;
  final String district;
  final double farmSize; // in hectares
  final List<String> cropTypes;
  final String farmingExperience; // beginner, intermediate, expert
  final Map<String, dynamic> soilInfo;
  final String irrigationType;
  final List<String> equipmentOwned;
  final String primaryLanguage;

  const UserProfile({
    required this.farmName,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.state,
    required this.district,
    required this.farmSize,
    required this.cropTypes,
    required this.farmingExperience,
    required this.soilInfo,
    required this.irrigationType,
    required this.equipmentOwned,
    required this.primaryLanguage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      farmName: json['farm_name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      latitude: Crop._parseDouble(json['latitude']),
      longitude: Crop._parseDouble(json['longitude']),
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      farmSize: Crop._parseDouble(json['farm_size']),
      cropTypes: Crop._parseStringList(json['crop_types']),
      farmingExperience: json['farming_experience']?.toString() ?? 'beginner',
      soilInfo: json['soil_info'] as Map<String, dynamic>? ?? {},
      irrigationType: json['irrigation_type']?.toString() ?? '',
      equipmentOwned: Crop._parseStringList(json['equipment_owned']),
      primaryLanguage: json['primary_language']?.toString() ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farm_name': farmName,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'state': state,
      'district': district,
      'farm_size': farmSize,
      'crop_types': cropTypes,
      'farming_experience': farmingExperience,
      'soil_info': soilInfo,
      'irrigation_type': irrigationType,
      'equipment_owned': equipmentOwned,
      'primary_language': primaryLanguage,
    };
  }

  UserProfile copyWith({
    String? farmName,
    String? location,
    double? latitude,
    double? longitude,
    String? state,
    String? district,
    double? farmSize,
    List<String>? cropTypes,
    String? farmingExperience,
    Map<String, dynamic>? soilInfo,
    String? irrigationType,
    List<String>? equipmentOwned,
    String? primaryLanguage,
  }) {
    return UserProfile(
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      state: state ?? this.state,
      district: district ?? this.district,
      farmSize: farmSize ?? this.farmSize,
      cropTypes: cropTypes ?? this.cropTypes,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      soilInfo: soilInfo ?? this.soilInfo,
      irrigationType: irrigationType ?? this.irrigationType,
      equipmentOwned: equipmentOwned ?? this.equipmentOwned,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          farmName == other.farmName &&
          location == other.location;

  @override
  int get hashCode => farmName.hashCode ^ location.hashCode;

  @override
  String toString() => 'UserProfile(farmName: $farmName, location: $location)';
}