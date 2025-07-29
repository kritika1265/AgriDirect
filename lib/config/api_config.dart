// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://api.agridirect.com/v1';
  static const String weatherApiKey = 'your_weather_api_key';
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String newsApiKey = 'your_news_api_key';
  static const String newsBaseUrl = 'https://newsapi.org/v2';
  
  // ML API endpoints
  static const String mlServiceUrl = 'https://ml.agridirect.com/v1';
  static const String diseaseDetectionUrl = '$mlServiceUrl/detect-disease';
  static const String cropPredictionUrl = '$mlServiceUrl/predict-crop';
  static const String soilAnalysisUrl = '$mlServiceUrl/analyze-soil';
  
  // Marketplace endpoints
  static const String marketplaceUrl = '$baseUrl/marketplace';
  static const String toolRentalUrl = '$baseUrl/tools';
  
  // Community endpoints
  static const String communityUrl = '$baseUrl/community';
  static const String expertUrl = '$baseUrl/experts';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

// lib/config/app_config.dart
class AppConfig {
  static const String appName = 'AgriDirect';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.agridirect.app';
  
  // Firebase configuration
  static const String firebaseProjectId = 'agridirect-app';
  static const String firebaseApiKey = 'your_firebase_api_key';
  
  // Notification configuration
  static const String fcmServerKey = 'your_fcm_server_key';
  
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
  
  // Support configuration
  static const String supportEmail = 'support@agridirect.com';
  static const String supportPhone = '+1-800-AGRI-HELP';
  static const String termsUrl = 'https://agridirect.com/terms';
  static const String privacyUrl = 'https://agridirect.com/privacy';
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

  Crop({
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      seasons: List<String>.from(json['seasons'] ?? []),
      requirements: json['requirements'] ?? {},
      growthDuration: json['growth_duration'] ?? 0,
      careInstructions: Map<String, String>.from(json['care_instructions'] ?? {}),
      commonDiseases: List<String>.from(json['common_diseases'] ?? []),
      compatibleCrops: List<String>.from(json['compatible_crops'] ?? []),
      expectedYield: (json['expected_yield'] ?? 0).toDouble(),
      marketPrice: json['market_price'] ?? {},
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

  CropRecommendation({
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
      cropId: json['crop_id'] ?? '',
      cropName: json['crop_name'] ?? '',
      suitabilityScore: (json['suitability_score'] ?? 0).toDouble(),
      reasons: List<String>.from(json['reasons'] ?? []),
      soilRequirements: json['soil_requirements'] ?? {},
      climateRequirements: json['climate_requirements'] ?? {},
      season: json['season'] ?? '',
      estimatedYield: (json['estimated_yield'] ?? 0).toDouble(),
      profitabilityScore: (json['profitability_score'] ?? 0).toDouble(),
    );
  }
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

  User({
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
      id: json['id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profile_image_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(json['last_login_at'] ?? DateTime.now().toIso8601String()),
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
      preferences: json['preferences'] ?? {},
      isVerified: json['is_verified'] ?? false,
      role: json['role'] ?? 'farmer',
    );
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

  UserProfile({
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
      farmName: json['farm_name'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      farmSize: (json['farm_size'] ?? 0).toDouble(),
      cropTypes: List<String>.from(json['crop_types'] ?? []),
      farmingExperience: json['farming_experience'] ?? 'beginner',
      soilInfo: json['soil_info'] ?? {},
      irrigationType: json['irrigation_type'] ?? '',
      equipmentOwned: List<String>.from(json['equipment_owned'] ?? []),
      primaryLanguage: json['primary_language'] ?? 'en',
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
}