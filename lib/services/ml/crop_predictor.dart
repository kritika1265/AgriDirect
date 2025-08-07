// lib/services/ml/crop_predictor.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'tflite_helper.dart';

class CropPredictor {
  static final CropPredictor _instance = CropPredictor._internal();
  factory CropPredictor() => _instance;
  CropPredictor._internal();

  static const String _yieldModelName = 'crop_yield';
  static const String _cropTypeModelName = 'crop_type';
  static const String _growthStageModelName = 'growth_stage';
  
  static const String _yieldModelPath = 'assets/models/crop_yield_model.tflite';
  static const String _cropTypeModelPath = 'assets/models/crop_type_model.tflite';
  static const String _growthStageModelPath = 'assets/models/growth_stage_model.tflite';
  
  static const String _cropTypeLabelsPath = 'assets/models/crop_type_labels.txt';
  static const String _growthStageLabelsPath = 'assets/models/growth_stage_labels.txt';
  
  static const int _inputSize = 224;

  final TFLiteHelper _tfliteHelper = TFLiteHelper();
  bool _isInitialized = false;

  /// Initialize all crop prediction models
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Load crop type identification model
      final cropTypeSuccess = await _tfliteHelper.loadModel(
        _cropTypeModelName,
        _cropTypeModelPath,
        labelsPath: _cropTypeLabelsPath,
      );

      // Load growth stage model
      final growthStageSuccess = await _tfliteHelper.loadModel(
        _growthStageModelName,
        _growthStageModelPath,
        labelsPath: _growthStageLabelsPath,
      );

      // Load yield prediction model
      final yieldSuccess = await _tfliteHelper.loadModel(
        _yieldModelName,
        _yieldModelPath,
      );

      _isInitialized = cropTypeSuccess && growthStageSuccess && yieldSuccess;
      return _isInitialized;
    } catch (e) {
      print('Error initializing crop predictor: $e');
      return false;
    }
  }

  /// Predict crop type from image
  Future<CropTypeResult> predictCropType(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Crop predictor not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _cropTypeModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      final probabilities = _tfliteHelper.applySoftmax(output[0]);
      final predictions = _tfliteHelper.getTopPredictions(
        probabilities,
        _cropTypeModelName,
        topK: 5,
        threshold: 0.05,
      );

      return CropTypeResult(
        predictions: predictions,
        topPrediction: predictions.isNotEmpty ? predictions.first : null,
        confidence: predictions.isNotEmpty ? predictions.first.confidence : 0.0,
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return CropTypeResult(
        predictions: [],
        topPrediction: null,
        confidence: 0.0,
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Predict growth stage from image
  Future<GrowthStageResult> predictGrowthStage(String imagePath, {String? cropType}) async {
    if (!_isInitialized) {
      throw Exception('Crop predictor not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _growthStageModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      final probabilities = _tfliteHelper.applySoftmax(output[0]);
      final predictions = _tfliteHelper.getTopPredictions(
        probabilities,
        _growthStageModelName,
        topK: 3,
        threshold: 0.1,
      );

      final topPrediction = predictions.isNotEmpty ? predictions.first : null;
      final stage = topPrediction != null ? _parseGrowthStage(topPrediction.label) : null;

      return GrowthStageResult(
        stage: stage,
        predictions: predictions,
        confidence: topPrediction?.confidence ?? 0.0,
        cropType: cropType,
        recommendations: stage != null ? _getStageRecommendations(stage, cropType) : [],
        nextStageInfo: stage != null ? _getNextStageInfo(stage) : null,
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return GrowthStageResult(
        stage: null,
        predictions: [],
        confidence: 0.0,
        cropType: cropType,
        recommendations: [],
        nextStageInfo: null,
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Predict crop yield based on environmental and image data
  Future<YieldPredictionResult> predictYield({
    required String imagePath,
    required Map<String, double> environmentalData,
    String? cropType,
    GrowthStage? currentStage,
  }) async {
    if (!_isInitialized) {
      throw Exception('Crop predictor not initialized');
    }

    try {
      // Prepare input data combining image features and environmental data
      final imageInput = await _preprocessImage(imagePath);
      final combinedInput = _combineInputs(imageInput, environmentalData);
      
      final output = _tfliteHelper.runInference(
        _yieldModelName,
        combinedInput,
        [1, combinedInput.length ~/ 1], // Adjust based on your model
      );

      // Extract yield prediction (assuming model outputs yield in kg/hectare)
      final predictedYield = output[0][0];
      final confidence = _calculateYieldConfidence(output[0]);

      return YieldPredictionResult(
        predictedYield: predictedYield,
        confidence: confidence,
        cropType: cropType,
        currentStage: currentStage,
        environmentalFactors: environmentalData,
        recommendations: _getYieldOptimizationTips(predictedYield, environmentalData),
        expectedHarvestDate: _estimateHarvestDate(currentStage, cropType),
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return YieldPredictionResult(
        predictedYield: 0.0,
        confidence: 0.0,
        cropType: cropType,
        currentStage: currentStage,
        environmentalFactors: environmentalData,
        recommendations: [],
        expectedHarvestDate: null,
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Comprehensive crop analysis combining all predictions
  Future<ComprehensiveCropAnalysis> analyzeCrop({
    required String imagePath,
    required Map<String, double> environmentalData,
  }) async {
    final cropTypeResult = await predictCropType(imagePath);
    final growthStageResult = await predictGrowthStage(
      imagePath, 
      cropType: cropTypeResult.topPrediction?.label,
    );
    final yieldResult = await predictYield(
      imagePath: imagePath,
      environmentalData: environmentalData,
      cropType: cropTypeResult.topPrediction?.label,
      currentStage: growthStageResult.stage,
    );

    return ComprehensiveCropAnalysis(
      cropTypeResult: cropTypeResult,
      growthStageResult: growthStageResult,
      yieldResult: yieldResult,
      overallConfidence: _calculateOverallConfidence([
        cropTypeResult.confidence,
        growthStageResult.confidence,
        yieldResult.confidence,
      ]),
      processingTime: DateTime.now(),
    );
  }

  // Helper methods

  Future<Float32List> _preprocessImage(String imagePath) async {
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Could not decode image');
    }

    return _tfliteHelper.preprocessImage(
      image,
      inputWidth: _inputSize,
      inputHeight: _inputSize,
      normalize: true,
    );
  }

  Float32List _combineInputs(Float32List imageFeatures, Map<String, double> environmentalData) {
    // Combine image features with environmental data
    final envValues = [
      environmentalData['temperature'] ?? 25.0,
      environmentalData['humidity'] ?? 60.0,
      environmentalData['rainfall'] ?? 500.0,
      environmentalData['soilPH'] ?? 6.5,
      environmentalData['soilMoisture'] ?? 40.0,
      environmentalData['sunlightHours'] ?? 8.0,
    ];

    final combinedList = List<double>.from(imageFeatures);
    combinedList.addAll(envValues);
    return Float32List.fromList(combinedList);
  }

  GrowthStage? _parseGrowthStage(String stageLabel) {
    final stage = stageLabel.toLowerCase();
    if (stage.contains('seed') || stage.contains('germination')) return GrowthStage.seedling;
    if (stage.contains('vegetative') || stage.contains('growing')) return GrowthStage.vegetative;
    if (stage.contains('flower') || stage.contains('bloom')) return GrowthStage.flowering;
    if (stage.contains('fruit') || stage.contains('pod')) return GrowthStage.fruiting;
    if (stage.contains('mature') || stage.contains('harvest')) return GrowthStage.mature;
    return null;
  }

  List<String> _getStageRecommendations(GrowthStage stage, String? cropType) {
    switch (stage) {
      case GrowthStage.seedling:
        return [
          'Ensure adequate water supply',
          'Protect from extreme weather',
          'Monitor for early pests',
          'Apply starter fertilizer if needed',
        ];
      case GrowthStage.vegetative:
        return [
          'Apply nitrogen-rich fertilizer',
          'Maintain consistent irrigation',
          'Monitor for nutrient deficiencies',
          'Control weeds',
        ];
      case GrowthStage.flowering:
        return [
          'Reduce nitrogen application',
          'Increase phosphorus and potassium',
          'Ensure good pollination conditions',
          'Monitor for flower drop',
        ];
      case GrowthStage.fruiting:
        return [
          'Maintain consistent soil moisture',
          'Support heavy branches if needed',
          'Monitor fruit development',
          'Prepare for harvest timing',
        ];
      case GrowthStage.mature:
        return [
          'Plan harvest timing',
          'Check crop moisture content',
          'Prepare storage facilities',
          'Monitor weather for harvest window',
        ];
    }
  }

  NextStageInfo? _getNextStageInfo(GrowthStage currentStage) {
    switch (currentStage) {
      case GrowthStage.seedling:
        return NextStageInfo(
          nextStage: GrowthStage.vegetative,
          estimatedDays: 14,
          keyIndicators: ['Increased leaf growth', 'Strong root development'],
        );
      case GrowthStage.vegetative:
        return NextStageInfo(
          nextStage: GrowthStage.flowering,
          estimatedDays: 30,
          keyIndicators: ['Flower buds appearing', 'Reduced vegetative growth'],
        );
      case GrowthStage.flowering:
        return NextStageInfo(
          nextStage: GrowthStage.fruiting,
          estimatedDays: 21,
          keyIndicators: ['Fruit/pod formation', 'Flower drop'],
        );
      case GrowthStage.fruiting:
        return NextStageInfo(
          nextStage: GrowthStage.mature,
          estimatedDays: 45,
          keyIndicators: ['Color change', 'Reduced moisture content'],
        );
      case GrowthStage.mature:
        return null; // Final stage
    }
  }

  double _calculateYieldConfidence(List<double> output) {
    // Calculate confidence based on model variance or uncertainty
    // This is a simplified approach - adjust based on your model's output
    if (output.length > 1) {
      final variance = _calculateVariance(output);
      return 1.0 - (variance / 1000.0).clamp(0.0, 1.0);
    }
    return 0.8; // Default confidence for single output models
  }

  double _calculateVariance(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((x) => (x - mean) * (x - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  List<String> _getYieldOptimizationTips(double predictedYield, Map<String, double> environmentalData) {
    final tips = <String>[];
    
    // Analyze environmental factors and provide recommendations
    final temp = environmentalData['temperature'] ?? 25.0;
    final humidity = environmentalData['humidity'] ?? 60.0;
    final rainfall = environmentalData['rainfall'] ?? 500.0;
    final soilPH = environmentalData['soilPH'] ?? 6.5;
    final soilMoisture = environmentalData['soilMoisture'] ?? 40.0;

    if (temp < 20) {
      tips.add('Consider protecting crops from low temperatures');
    } else if (temp > 35) {
      tips.add('Provide shade or cooling measures during hot weather');
    }

    if (humidity < 40) {
      tips.add('Increase irrigation to maintain soil moisture');
    } else if (humidity > 80) {
      tips.add('Improve ventilation to prevent fungal diseases');
    }

    if (rainfall < 300) {
      tips.add('Implement supplementary irrigation system');
    } else if (rainfall > 800) {
      tips.add('Ensure proper drainage to prevent waterlogging');
    }

    if (soilPH < 6.0) {
      tips.add('Apply lime to increase soil pH');
    } else if (soilPH > 7.5) {
      tips.add('Apply sulfur or organic matter to lower soil pH');
    }

    if (soilMoisture < 30) {
      tips.add('Increase irrigation frequency');
    } else if (soilMoisture > 60) {
      tips.add('Reduce irrigation to prevent root rot');
    }

    // Yield-specific recommendations
    if (predictedYield < 2000) {
      tips.add('Consider soil testing for nutrient deficiencies');
      tips.add('Evaluate seed variety performance');
    } else if (predictedYield > 5000) {
      tips.add('Maintain current practices - excellent conditions');
      tips.add('Document successful practices for future seasons');
    }

    return tips.isEmpty ? ['Continue monitoring crop conditions regularly'] : tips;
  }

  DateTime? _estimateHarvestDate(GrowthStage? currentStage, String? cropType) {
    if (currentStage == null) return null;

    final now = DateTime.now();
    int daysToHarvest;

    switch (currentStage) {
      case GrowthStage.seedling:
        daysToHarvest = _getCropMaturityDays(cropType) - 14;
        break;
      case GrowthStage.vegetative:
        daysToHarvest = _getCropMaturityDays(cropType) - 45;
        break;
      case GrowthStage.flowering:
        daysToHarvest = _getCropMaturityDays(cropType) - 65;
        break;
      case GrowthStage.fruiting:
        daysToHarvest = 45;
        break;
      case GrowthStage.mature:
        daysToHarvest = 7; // Ready for harvest soon
        break;
    }

    return now.add(Duration(days: daysToHarvest));
  }

  int _getCropMaturityDays(String? cropType) {
    if (cropType == null) return 120; // Default

    final maturityDays = {
      'tomato': 120,
      'corn': 100,
      'wheat': 140,
      'rice': 130,
      'soybean': 110,
      'potato': 90,
      'cotton': 180,
      'lettuce': 65,
    };

    return maturityDays[cropType.toLowerCase()] ?? 120;
  }

  double _calculateOverallConfidence(List<double> confidences) {
    if (confidences.isEmpty) return 0.0;
    
    // Weighted average with higher weight for higher confidences
    confidences.sort((a, b) => b.compareTo(a));
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    
    for (int i = 0; i < confidences.length; i++) {
      final weight = 1.0 / (i + 1); // Decreasing weights
      weightedSum += confidences[i] * weight;
      totalWeight += weight;
    }
    
    return weightedSum / totalWeight;
  }

  /// Dispose resources
  void dispose() {
    _tfliteHelper.disposeModel(_cropTypeModelName);
    _tfliteHelper.disposeModel(_growthStageModelName);
    _tfliteHelper.disposeModel(_yieldModelName);
    _isInitialized = false;
  }
}

// Data classes for results

class CropTypeResult {
  final List<Prediction> predictions;
  final Prediction? topPrediction;
  final double confidence;
  final DateTime processingTime;
  final String? error;

  CropTypeResult({
    required this.predictions,
    required this.topPrediction,
    required this.confidence,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;
  String get cropType => topPrediction?.label ?? 'Unknown';

  Map<String, dynamic> toJson() => {
    'cropType': cropType,
    'confidence': confidence,
    'predictions': predictions.map((p) => p.toJson()).toList(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class GrowthStageResult {
  final GrowthStage? stage;
  final List<Prediction> predictions;
  final double confidence;
  final String? cropType;
  final List<String> recommendations;
  final NextStageInfo? nextStageInfo;
  final DateTime processingTime;
  final String? error;

  GrowthStageResult({
    required this.stage,
    required this.predictions,
    required this.confidence,
    required this.cropType,
    required this.recommendations,
    required this.nextStageInfo,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'stage': stage?.toString(),
    'confidence': confidence,
    'cropType': cropType,
    'recommendations': recommendations,
    'nextStageInfo': nextStageInfo?.toJson(),
    'predictions': predictions.map((p) => p.toJson()).toList(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class YieldPredictionResult {
  final double predictedYield; // kg/hectare
  final double confidence;
  final String? cropType;
  final GrowthStage? currentStage;
  final Map<String, double> environmentalFactors;
  final List<String> recommendations;
  final DateTime? expectedHarvestDate;
  final DateTime processingTime;
  final String? error;

  YieldPredictionResult({
    required this.predictedYield,
    required this.confidence,
    required this.cropType,
    required this.currentStage,
    required this.environmentalFactors,
    required this.recommendations,
    required this.expectedHarvestDate,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'predictedYield': predictedYield,
    'confidence': confidence,
    'cropType': cropType,
    'currentStage': currentStage?.toString(),
    'environmentalFactors': environmentalFactors,
    'recommendations': recommendations,
    'expectedHarvestDate': expectedHarvestDate?.toIso8601String(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class ComprehensiveCropAnalysis {
  final CropTypeResult cropTypeResult;
  final GrowthStageResult growthStageResult;
  final YieldPredictionResult yieldResult;
  final double overallConfidence;
  final DateTime processingTime;

  ComprehensiveCropAnalysis({
    required this.cropTypeResult,
    required this.growthStageResult,
    required this.yieldResult,
    required this.overallConfidence,
    required this.processingTime,
  });

  bool get hasAnyErrors => 
    cropTypeResult.hasError || 
    growthStageResult.hasError || 
    yieldResult.hasError;

  Map<String, dynamic> toJson() => {
    'cropType': cropTypeResult.toJson(),
    'growthStage': growthStageResult.toJson(),
    'yieldPrediction': yieldResult.toJson(),
    'overallConfidence': overallConfidence,
    'processingTime': processingTime.toIso8601String(),
  };
}

class NextStageInfo {
  final GrowthStage nextStage;
  final int estimatedDays;
  final List<String> keyIndicators;

  NextStageInfo({
    required this.nextStage,
    required this.estimatedDays,
    required this.keyIndicators,
  });

  Map<String, dynamic> toJson() => {
    'nextStage': nextStage.toString(),
    'estimatedDays': estimatedDays,
    'keyIndicators': keyIndicators,
  };
}

enum GrowthStage {
  seedling,
  vegetative,
  flowering,
  fruiting,
  mature,
}

extension GrowthStageExtension on GrowthStage {
  String get displayName {
    switch (this) {
      case GrowthStage.seedling:
        return 'Seedling';
      case GrowthStage.vegetative:
        return 'Vegetative';
      case GrowthStage.flowering:
        return 'Flowering';
      case GrowthStage.fruiting:
        return 'Fruiting';
      case GrowthStage.mature:
        return 'Mature';
    }
  }

  String get description {
    switch (this) {
      case GrowthStage.seedling:
        return 'Early growth stage with initial leaves developing';
      case GrowthStage.vegetative:
        return 'Active growth phase with leaf and stem development';
      case GrowthStage.flowering:
        return 'Reproductive stage with flower formation';
      case GrowthStage.fruiting:
        return 'Fruit or seed development stage';
      case GrowthStage.mature:
        return 'Ready for harvest';
    }
  }
}