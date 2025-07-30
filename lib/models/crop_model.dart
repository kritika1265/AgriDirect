/// Model class representing a crop with all its properties and growth information
class CropModel {
  /// Unique identifier for the crop
  final String id;
  
  /// Display name of the crop
  final String name;
  
  /// Scientific name of the crop
  final String scientificName;
  
  /// Category or type of the crop (e.g., cereal, vegetable, fruit)
  final String category;
  
  /// Growing season for the crop
  final String season;
  
  /// Duration of growth cycle in days
  final int growthDuration;
  
  /// List of suitable soil types for this crop
  final List<String> soilTypes;
  
  /// Water requirement in mm per day
  final double waterRequirement;
  
  /// Suitable climate conditions
  final String climate;
  
  /// List of common diseases affecting this crop
  final List<String> diseases;
  
  /// List of common pests affecting this crop
  final List<String> pests;
  
  /// Nutritional requirements as key-value pairs
  final Map<String, dynamic> nutritionRequirements;
  
  /// URL to crop image
  final String imageUrl;
  
  /// List of growth stages for this crop
  final List<CropGrowthStage> growthStages;
  
  /// Care instructions as key-value pairs
  final Map<String, String> careInstructions;

  /// Creates a new CropModel instance
  CropModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.season,
    required this.growthDuration,
    required this.soilTypes,
    required this.waterRequirement,
    required this.climate,
    this.diseases = const [],
    this.pests = const [],
    this.nutritionRequirements = const {},
    this.imageUrl = '',
    this.growthStages = const [],
    this.careInstructions = const {},
  });

  /// Creates a CropModel from JSON data
  factory CropModel.fromJson(Map<String, dynamic> json) => CropModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    scientificName: json['scientificName'] as String? ?? '',
    category: json['category'] as String? ?? '',
    season: json['season'] as String? ?? '',
    growthDuration: json['growthDuration'] as int? ?? 0,
    soilTypes: (json['soilTypes'] as List<dynamic>?)?.cast<String>() ?? [],
    waterRequirement: (json['waterRequirement'] as num?)?.toDouble() ?? 0.0,
    climate: json['climate'] as String? ?? '',
    diseases: (json['diseases'] as List<dynamic>?)?.cast<String>() ?? [],
    pests: (json['pests'] as List<dynamic>?)?.cast<String>() ?? [],
    nutritionRequirements: json['nutritionRequirements'] as Map<String, dynamic>? ?? {},
    imageUrl: json['imageUrl'] as String? ?? '',
    growthStages: (json['growthStages'] as List<dynamic>?)
        ?.map((stage) => CropGrowthStage.fromJson(stage as Map<String, dynamic>))
        .toList() ?? [],
    careInstructions: (json['careInstructions'] as Map<String, dynamic>?)
        ?.cast<String, String>() ?? {},
  );

  /// Converts the CropModel to JSON format
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scientificName': scientificName,
    'category': category,
    'season': season,
    'growthDuration': growthDuration,
    'soilTypes': soilTypes,
    'waterRequirement': waterRequirement,
    'climate': climate,
    'diseases': diseases,
    'pests': pests,
    'nutritionRequirements': nutritionRequirements,
    'imageUrl': imageUrl,
    'growthStages': growthStages.map((stage) => stage.toJson()).toList(),
    'careInstructions': careInstructions,
  };
}

/// Model class representing a growth stage of a crop
class CropGrowthStage {
  /// Name of the growth stage
  final String name;
  
  /// Starting day of this stage
  final int startDay;
  
  /// Ending day of this stage
  final int endDay;
  
  /// Description of what happens during this stage
  final String description;
  
  /// List of activities to perform during this stage
  final List<String> activities;
  
  /// URL to stage-specific image
  final String imageUrl;

  /// Creates a new CropGrowthStage instance
  CropGrowthStage({
    required this.name,
    required this.startDay,
    required this.endDay,
    required this.description,
    this.activities = const [],
    this.imageUrl = '',
  });

  /// Creates a CropGrowthStage from JSON data
  factory CropGrowthStage.fromJson(Map<String, dynamic> json) => CropGrowthStage(
    name: json['name'] as String? ?? '',
    startDay: json['startDay'] as int? ?? 0,
    endDay: json['endDay'] as int? ?? 0,
    description: json['description'] as String? ?? '',
    activities: (json['activities'] as List<dynamic>?)?.cast<String>() ?? [],
    imageUrl: json['imageUrl'] as String? ?? '',
  );

  /// Converts the CropGrowthStage to JSON format
  Map<String, dynamic> toJson() => {
    'name': name,
    'startDay': startDay,
    'endDay': endDay,
    'description': description,
    'activities': activities,
    'imageUrl': imageUrl,
  };
}