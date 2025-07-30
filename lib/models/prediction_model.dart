// lib/models/prediction_model.dart
class CropPrediction {
  final String id;
  final List<CropRecommendation> recommendations;
  final Map<String, dynamic> inputParameters;
  final DateTime predictedAt;
  final String season;
  final String location;

  CropPrediction({
    required this.id,
    required this.recommendations,
    required this.inputParameters,
    required this.predictedAt,
    required this.season,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'inputParameters': inputParameters,
      'predictedAt': predictedAt.toIso8601String(),
      'season': season,
      'location': location,
    };
  }

  factory CropPrediction.fromJson(Map<String, dynamic> json) {
    return CropPrediction(
      id: json['id'] ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((r) => CropRecommendation.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      inputParameters: Map<String, dynamic>.from(json['inputParameters'] ?? {}),
      predictedAt: DateTime.parse(json['predictedAt'] ?? DateTime.now().toIso8601String()),
      season: json['season'] ?? '',
      location: json['location'] ?? '',
    );
  }

  CropRecommendation? get topRecommendation => 
      recommendations.isNotEmpty ? recommendations.first : null;

  double get averageConfidence => recommendations.isEmpty 
      ? 0.0 
      : recommendations.map((r) => r.confidence).reduce((a, b) => a + b) / recommendations.length;
}

class CropRecommendation {
  final String cropName;
  final double confidence;
  final double suitabilityScore;
  final String expectedYield;
  final String growingPeriod;
  final String waterRequirement;
  final List<String> tips;

  CropRecommendation({
    required this.cropName,
    required this.confidence,
    required this.suitabilityScore,
    required this.expectedYield,
    required this.growingPeriod,
    required this.waterRequirement,
    required this.tips,
  });

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'confidence': confidence,
      'suitabilityScore': suitabilityScore,
      'expectedYield': expectedYield,
      'growingPeriod': growingPeriod,
      'waterRequirement': waterRequirement,
      'tips': tips,
    };
  }

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      cropName: json['cropName'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      suitabilityScore: (json['suitabilityScore'] ?? 0.0).toDouble(),
      expectedYield: json['expectedYield'] ?? '',
      growingPeriod: json['growingPeriod'] ?? '',
      waterRequirement: json['waterRequirement'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
    );
  }

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
  String get suitabilityPercentage => '${suitabilityScore.toStringAsFixed(1)}%';
}

class SoilAnalysis {
  final String id;
  final String soilType;
  final double confidence;
  final NutrientLevels nutrients;
  final String fertility;
  final List<String> recommendations;
  final DateTime analyzedAt;

  SoilAnalysis({
    required this.id,
    required this.soilType,
    required this.confidence,
    required this.nutrients,
    required this.fertility,
    required this.recommendations,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soilType': soilType,
      'confidence': confidence,
      'nutrients': nutrients.toJson(),
      'fertility': fertility,
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory SoilAnalysis.fromJson(Map<String, dynamic> json) {
    return SoilAnalysis(
      id: json['id'] ?? '',
      soilType: json['soilType'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      nutrients: NutrientLevels.fromJson(json['nutrients'] ?? {}),
      fertility: json['fertility'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      analyzedAt: DateTime.parse(json['analyzedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
}

class NutrientLevels {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;

  NutrientLevels({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
  });

  Map<String, dynamic> toJson() {
    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
    };
  }

  factory NutrientLevels.fromJson(Map<String, dynamic> json) {
    return NutrientLevels(
      nitrogen: (json['nitrogen'] ?? 0.0).toDouble(),
      phosphorus: (json['phosphorus'] ?? 0.0).toDouble(),
      potassium: (json['potassium'] ?? 0.0).toDouble(),
      ph: (json['ph'] ?? 7.0).toDouble(),
    );
  }

  String getNitrogenLevel() {
    if (nitrogen > 60) return 'High';
    if (nitrogen > 30) return 'Medium';
    return 'Low';
  }

  String getPhosphorusLevel() {
    if (phosphorus > 30) return 'High';
    if (phosphorus > 15) return 'Medium';
    return 'Low';
  }

  String getPotassiumLevel() {
    if (potassium > 50) return 'High';
    if (potassium > 25) return 'Medium';
    return 'Low';
  }

  String getPhLevel() {
    if (ph >= 6.0 && ph <= 7.5) return 'Optimal';
    if (ph < 6.0) return 'Acidic';
    return 'Alkaline';
  }
}

class MLPredictionHistory {
  final List<CropPrediction> cropPredictions;
  final List<SoilAnalysis> soilAnalyses;
  final DateTime lastUpdated;

  MLPredictionHistory({
    required this.cropPredictions,
    required this.soilAnalyses,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'cropPredictions': cropPredictions.map((p) => p.toJson()).toList(),
      'soilAnalyses': soilAnalyses.map((s) => s.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory MLPredictionHistory.fromJson(Map<String, dynamic> json) {
    return MLPredictionHistory(
      cropPredictions: (json['cropPredictions'] as List<dynamic>?)
          ?.map((p) => CropPrediction.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      soilAnalyses: (json['soilAnalyses'] as List<dynamic>?)
          ?.map((s) => SoilAnalysis.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Helper methods
  CropPrediction? get latestCropPrediction => 
      cropPredictions.isNotEmpty ? cropPredictions.last : null;

  SoilAnalysis? get latestSoilAnalysis => 
      soilAnalyses.isNotEmpty ? soilAnalyses.last : null;

  int get totalPredictions => cropPredictions.length + soilAnalyses.length;

  bool get hasData => cropPredictions.isNotEmpty || soilAnalyses.isNotEmpty;

  // Get predictions from a specific date range
  List<CropPrediction> getCropPredictionsInRange(DateTime start, DateTime end) {
    return cropPredictions.where((prediction) =>
        prediction.predictedAt.isAfter(start) && prediction.predictedAt.isBefore(end)
    ).toList();
  }

  List<SoilAnalysis> getSoilAnalysesInRange(DateTime start, DateTime end) {
    return soilAnalyses.where((analysis) =>
        analysis.analyzedAt.isAfter(start) && analysis.analyzedAt.isBefore(end)
    ).toList();
  }
}

// Additional utility classes for ML predictions
class PredictionRequest {
  final Map<String, dynamic> inputData;
  final String predictionType; // 'crop' or 'soil'
  final String location;
  final DateTime requestedAt;

  PredictionRequest({
    required this.inputData,
    required this.predictionType,
    required this.location,
    required this.requestedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'inputData': inputData,
      'predictionType': predictionType,
      'location': location,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }

  factory PredictionRequest.fromJson(Map<String, dynamic> json) {
    return PredictionRequest(
      inputData: Map<String, dynamic>.from(json['inputData'] ?? {}),
      predictionType: json['predictionType'] ?? '',
      location: json['location'] ?? '',
      requestedAt: DateTime.parse(json['requestedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class MLModelInfo {
  final String modelId;
  final String modelName;
  final String version;
  final double accuracy;
  final DateTime trainedAt;
  final String description;

  MLModelInfo({
    required this.modelId,
    required this.modelName,
    required this.version,
    required this.accuracy,
    required this.trainedAt,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'modelName': modelName,
      'version': version,
      'accuracy': accuracy,
      'trainedAt': trainedAt.toIso8601String(),
      'description': description,
    };
  }

  factory MLModelInfo.fromJson(Map<String, dynamic> json) {
    return MLModelInfo(
      modelId: json['modelId'] ?? '',
      modelName: json['modelName'] ?? '',
      version: json['version'] ?? '',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      trainedAt: DateTime.parse(json['trainedAt'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
    );
  }

  String get accuracyPercentage => '${(accuracy * 100).toStringAsFixed(1)}%';
}