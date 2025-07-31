// lib/models/prediction_model.dart

/// Represents a crop prediction with recommendations
class CropPrediction {
  /// Unique identifier for the prediction
  final String id;
  
  /// List of crop recommendations
  final List<CropRecommendation> recommendations;
  
  /// Input parameters used for prediction
  final Map<String, dynamic> inputParameters;
  
  /// When the prediction was made
  final DateTime predictedAt;
  
  /// Season for the prediction
  final String season;
  
  /// Location of the prediction
  final String location;

  /// Creates a new CropPrediction instance
  const CropPrediction({
    required this.id,
    required this.recommendations,
    required this.inputParameters,
    required this.predictedAt,
    required this.season,
    required this.location,
  });

  /// Creates a CropPrediction from JSON data
  factory CropPrediction.fromJson(Map<String, dynamic> json) {
    return CropPrediction(
      id: json['id']?.toString() ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((r) => CropRecommendation.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      inputParameters: json['inputParameters'] is Map
          ? Map<String, dynamic>.from(json['inputParameters'] as Map)
          : {},
      predictedAt: json['predictedAt'] != null 
          ? DateTime.parse(json['predictedAt'].toString())
          : DateTime.now(),
      season: json['season']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }

  /// Converts the prediction to JSON
  Map<String, dynamic> toJson() => {
      'id': id,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'inputParameters': inputParameters,
      'predictedAt': predictedAt.toIso8601String(),
      'season': season,
      'location': location,
    };

  /// Gets the top recommendation
  CropRecommendation? get topRecommendation => 
      recommendations.isNotEmpty ? recommendations.first : null;

  /// Calculates average confidence across all recommendations
  double get averageConfidence => recommendations.isEmpty 
      ? 0.0 
      : recommendations.map((r) => r.confidence).reduce((a, b) => a + b) / recommendations.length;
}

/// Represents a single crop recommendation
class CropRecommendation {
  /// Name of the recommended crop
  final String cropName;
  
  /// Confidence level of the recommendation
  final double confidence;
  
  /// Suitability score for the crop
  final double suitabilityScore;
  
  /// Expected yield information
  final String expectedYield;
  
  /// Growing period information
  final String growingPeriod;
  
  /// Water requirement information
  final String waterRequirement;
  
  /// Growing tips for the crop
  final List<String> tips;

  /// Creates a new CropRecommendation instance
  const CropRecommendation({
    required this.cropName,
    required this.confidence,
    required this.suitabilityScore,
    required this.expectedYield,
    required this.growingPeriod,
    required this.waterRequirement,
    required this.tips,
  });

  /// Creates a CropRecommendation from JSON data
  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      cropName: json['cropName']?.toString() ?? '',
      confidence: double.tryParse(json['confidence']?.toString() ?? '0') ?? 0.0,
      suitabilityScore: double.tryParse(json['suitabilityScore']?.toString() ?? '0') ?? 0.0,
      expectedYield: json['expectedYield']?.toString() ?? '',
      growingPeriod: json['growingPeriod']?.toString() ?? '',
      waterRequirement: json['waterRequirement']?.toString() ?? '',
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  /// Converts the recommendation to JSON
  Map<String, dynamic> toJson() => {
      'cropName': cropName,
      'confidence': confidence,
      'suitabilityScore': suitabilityScore,
      'expectedYield': expectedYield,
      'growingPeriod': growingPeriod,
      'waterRequirement': waterRequirement,
      'tips': tips,
    };

  /// Gets confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
  
  /// Gets suitability as percentage string
  String get suitabilityPercentage => '${suitabilityScore.toStringAsFixed(1)}%';
}

/// Represents soil analysis results
class SoilAnalysis {
  /// Unique identifier for the analysis
  final String id;
  
  /// Type of soil detected
  final String soilType;
  
  /// Confidence level of the analysis
  final double confidence;
  
  /// Nutrient levels in the soil
  final NutrientLevels nutrients;
  
  /// Fertility rating of the soil
  final String fertility;
  
  /// Recommendations based on analysis
  final List<String> recommendations;
  
  /// When the analysis was performed
  final DateTime analyzedAt;

  /// Creates a new SoilAnalysis instance
  const SoilAnalysis({
    required this.id,
    required this.soilType,
    required this.confidence,
    required this.nutrients,
    required this.fertility,
    required this.recommendations,
    required this.analyzedAt,
  });

  /// Creates a SoilAnalysis from JSON data
  factory SoilAnalysis.fromJson(Map<String, dynamic> json) {
    return SoilAnalysis(
      id: json['id']?.toString() ?? '',
      soilType: json['soilType']?.toString() ?? '',
      confidence: double.tryParse(json['confidence']?.toString() ?? '0') ?? 0.0,
      nutrients: json['nutrients'] is Map 
          ? NutrientLevels.fromJson(json['nutrients'] as Map<String, dynamic>) 
          : const NutrientLevels(nitrogen: 0, phosphorus: 0, potassium: 0, ph: 7.0),
      fertility: json['fertility']?.toString() ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      analyzedAt: json['analyzedAt'] != null 
          ? DateTime.parse(json['analyzedAt'].toString())
          : DateTime.now(),
    );
  }

  /// Converts the analysis to JSON
  Map<String, dynamic> toJson() => {
      'id': id,
      'soilType': soilType,
      'confidence': confidence,
      'nutrients': nutrients.toJson(),
      'fertility': fertility,
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
    };

  /// Gets confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
}

/// Represents nutrient levels in soil
class NutrientLevels {
  /// Nitrogen level
  final double nitrogen;
  
  /// Phosphorus level
  final double phosphorus;
  
  /// Potassium level
  final double potassium;
  
  /// pH level
  final double ph;

  /// Creates a new NutrientLevels instance
  const NutrientLevels({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
  });

  /// Creates NutrientLevels from JSON data
  factory NutrientLevels.fromJson(Map<String, dynamic> json) {
    return NutrientLevels(
      nitrogen: double.tryParse(json['nitrogen']?.toString() ?? '0') ?? 0.0,
      phosphorus: double.tryParse(json['phosphorus']?.toString() ?? '0') ?? 0.0,
      potassium: double.tryParse(json['potassium']?.toString() ?? '0') ?? 0.0,
      ph: double.tryParse(json['ph']?.toString() ?? '7') ?? 7.0,
    );
  }

  /// Converts nutrient levels to JSON
  Map<String, dynamic> toJson() => {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
    };

  /// Gets nitrogen level category
  String getNitrogenLevel() {
    if (nitrogen > 60) {
      return 'High';
    }
    if (nitrogen > 30) {
      return 'Medium';
    }
    return 'Low';
  }

  /// Gets phosphorus level category
  String getPhosphorusLevel() {
    if (phosphorus > 30) {
      return 'High';
    }
    if (phosphorus > 15) {
      return 'Medium';
    }
    return 'Low';
  }

  /// Gets potassium level category
  String getPotassiumLevel() {
    if (potassium > 50) {
      return 'High';
    }
    if (potassium > 25) {
      return 'Medium';
    }
    return 'Low';
  }

  /// Gets pH level category
  String getPhLevel() {
    if (ph >= 6.0 && ph <= 7.5) {
      return 'Optimal';
    }
    if (ph < 6.0) {
      return 'Acidic';
    }
    return 'Alkaline';
  }
}

/// Represents ML prediction history
class MLPredictionHistory {
  /// List of crop predictions
  final List<CropPrediction> cropPredictions;
  
  /// List of soil analyses
  final List<SoilAnalysis> soilAnalyses;
  
  /// When the history was last updated
  final DateTime lastUpdated;

  /// Creates a new MLPredictionHistory instance
  const MLPredictionHistory({
    required this.cropPredictions,
    required this.soilAnalyses,
    required this.lastUpdated,
  });

  /// Creates MLPredictionHistory from JSON data
  factory MLPredictionHistory.fromJson(Map<String, dynamic> json) {
    return MLPredictionHistory(
      cropPredictions: (json['cropPredictions'] as List<dynamic>?)
          ?.map((p) => CropPrediction.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      soilAnalyses: (json['soilAnalyses'] as List<dynamic>?)
          ?.map((s) => SoilAnalysis.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'].toString())
          : DateTime.now(),
    );
  }

  /// Converts history to JSON
  Map<String, dynamic> toJson() => {
      'cropPredictions': cropPredictions.map((p) => p.toJson()).toList(),
      'soilAnalyses': soilAnalyses.map((s) => s.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };

  /// Gets the latest crop prediction
  CropPrediction? get latestCropPrediction => 
      cropPredictions.isNotEmpty ? cropPredictions.last : null;

  /// Gets the latest soil analysis
  SoilAnalysis? get latestSoilAnalysis => 
      soilAnalyses.isNotEmpty ? soilAnalyses.last : null;

  /// Gets total number of predictions
  int get totalPredictions => cropPredictions.length + soilAnalyses.length;

  /// Checks if there is any data
  bool get hasData => cropPredictions.isNotEmpty || soilAnalyses.isNotEmpty;

  /// Gets crop predictions within a date range
  List<CropPrediction> getCropPredictionsInRange(DateTime start, DateTime end) =>
      cropPredictions.where((prediction) =>
          prediction.predictedAt.isAfter(start) && prediction.predictedAt.isBefore(end)
      ).toList();

  /// Gets soil analyses within a date range
  List<SoilAnalysis> getSoilAnalysesInRange(DateTime start, DateTime end) =>
      soilAnalyses.where((analysis) =>
          analysis.analyzedAt.isAfter(start) && analysis.analyzedAt.isBefore(end)
      ).toList();
}

/// Represents a prediction request
class PredictionRequest {
  /// Input data for the prediction
  final Map<String, dynamic> inputData;
  
  /// Type of prediction ('crop' or 'soil')
  final String predictionType;
  
  /// Location for the prediction
  final String location;
  
  /// When the prediction was requested
  final DateTime requestedAt;

  /// Creates a new PredictionRequest instance
  const PredictionRequest({
    required this.inputData,
    required this.predictionType,
    required this.location,
    required this.requestedAt,
  });

  /// Creates PredictionRequest from JSON data
  factory PredictionRequest.fromJson(Map<String, dynamic> json) {
    return PredictionRequest(
      inputData: json['inputData'] is Map 
          ? json['inputData'] as Map<String, dynamic>
          : <String, dynamic>{},
      predictionType: json['predictionType']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      requestedAt: json['requestedAt'] != null 
          ? DateTime.parse(json['requestedAt'].toString())
          : DateTime.now(),
    );
  }

  /// Converts request to JSON
  Map<String, dynamic> toJson() => {
      'inputData': inputData,
      'predictionType': predictionType,
      'location': location,
      'requestedAt': requestedAt.toIso8601String(),
    };
}

/// Represents ML model information
class MLModelInfo {
  /// Unique identifier for the model
  final String modelId;
  
  /// Name of the model
  final String modelName;
  
  /// Version of the model
  final String version;
  
  /// Accuracy of the model
  final double accuracy;
  
  /// When the model was trained
  final DateTime trainedAt;
  
  /// Description of the model
  final String description;

  /// Creates a new MLModelInfo instance
  const MLModelInfo({
    required this.modelId,
    required this.modelName,
    required this.version,
    required this.accuracy,
    required this.trainedAt,
    required this.description,
  });

  /// Creates MLModelInfo from JSON data
  factory MLModelInfo.fromJson(Map<String, dynamic> json) {
    return MLModelInfo(
      modelId: json['modelId']?.toString() ?? '',
      modelName: json['modelName']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      accuracy: double.tryParse(json['accuracy']?.toString() ?? '0') ?? 0.0,
      trainedAt: json['trainedAt'] != null 
          ? DateTime.parse(json['trainedAt'].toString())
          : DateTime.now(),
      description: json['description']?.toString() ?? '',
    );
  }

  /// Converts model info to JSON
  Map<String, dynamic> toJson() => {
      'modelId': modelId,
      'modelName': modelName,
      'version': version,
      'accuracy': accuracy,
      'trainedAt': trainedAt.toIso8601String(),
      'description': description,
    };

  /// Gets accuracy as percentage string
  String get accuracyPercentage => '${(accuracy * 100).toStringAsFixed(1)}%';
}