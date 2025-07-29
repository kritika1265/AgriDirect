class CropModel {
  final String id;
  final String name;
  final String scientificName;
  final String category;
  final String season;
  final int growthDuration; // in days
  final List<String> soilTypes;
  final double waterRequirement; // mm per day
  final String climate;
  final List<String> diseases;
  final List<String> pests;
  final Map<String, dynamic> nutritionRequirements;
  final String imageUrl;
  final List<CropGrowthStage> growthStages;
  final Map<String, String> careInstructions;

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

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      category: json['category'] ?? '',
      season: json['season'] ?? '',
      growthDuration: json['growthDuration'] ?? 0,
      soilTypes: List<String>.from(json['soilTypes'] ?? []),
      waterRequirement: (json['waterRequirement'] ?? 0).toDouble(),
      climate: json['climate'] ?? '',
      diseases: List<String>.from(json['diseases'] ?? []),
      pests: List<String>.from(json['pests'] ?? []),
      nutritionRequirements: Map<String, dynamic>.from(json['nutritionRequirements'] ?? {}),
      imageUrl: json['imageUrl'] ?? '',
      growthStages: (json['growthStages'] as List?)?.map((stage) => CropGrowthStage.fromJson(stage)).toList() ?? [],
      careInstructions: Map<String, String>.from(json['careInstructions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}

class CropGrowthStage {
  final String name;
  final int startDay;
  final int endDay;
  final String description;
  final List<String> activities;
  final String imageUrl;

  CropGrowthStage({
    required this.name,
    required this.startDay,
    required this.endDay,
    required this.description,
    this.activities = const [],
    this.imageUrl = '',
  });

  factory CropGrowthStage.fromJson(Map<String, dynamic> json) {
    return CropGrowthStage(
      name: json['name'] ?? '',
      startDay: json['startDay'] ?? 0,
      endDay: json['endDay'] ?? 0,
      description: json['description'] ?? '',
      activities: List<String>.from(json['activities'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDay': startDay,
      'endDay': endDay,
      'description': description,
      'activities': activities,
      'imageUrl': imageUrl,
    };
  }
}