// lib/services/ml/soil_analyzer.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'tflite_helper.dart';

class SoilAnalyzer {
  static final SoilAnalyzer _instance = SoilAnalyzer._internal();
  factory SoilAnalyzer() => _instance;
  SoilAnalyzer._internal();

  static const String _soilTypeModelName = 'soil_type';
  static const String _nutrientModelName = 'soil_nutrients';
  static const String _moistureModelName = 'soil_moisture';
  static const String _phModelName = 'soil_ph';
  
  static const String _soilTypeModelPath = 'assets/models/soil_type_model.tflite';
  static const String _nutrientModelPath = 'assets/models/soil_nutrient_model.tflite';
  static const String _moistureModelPath = 'assets/models/soil_moisture_model.tflite';
  static const String _phModelPath = 'assets/models/soil_ph_model.tflite';
  
  static const String _soilTypeLabelsPath = 'assets/models/soil_type_labels.txt';
  static const int _inputSize = 224;

  final TFLiteHelper _tfliteHelper = TFLiteHelper();
  bool _isInitialized = false;

  /// Initialize all soil analysis models
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Load soil type model
      final soilTypeSuccess = await _tfliteHelper.loadModel(
        _soilTypeModelName,
        _soilTypeModelPath,
        labelsPath: _soilTypeLabelsPath,
      );

      // Load nutrient analysis model
      final nutrientSuccess = await _tfliteHelper.loadModel(
        _nutrientModelName,
        _nutrientModelPath,
      );

      // Load moisture detection model
      final moistureSuccess = await _tfliteHelper.loadModel(
        _moistureModelName,
        _moistureModelPath,
      );

      // Load pH prediction model
      final phSuccess = await _tfliteHelper.loadModel(
        _phModelName,
        _phModelPath,
      );

      _isInitialized = soilTypeSuccess && nutrientSuccess && moistureSuccess && phSuccess;
      return _isInitialized;
    } catch (e) {
      print('Error initializing soil analyzer: $e');
      return false;
    }
  }

  /// Analyze soil type from image
  Future<SoilTypeResult> analyzeSoilType(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Soil analyzer not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _soilTypeModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      final probabilities = _tfliteHelper.applySoftmax(output[0]);
      final predictions = _tfliteHelper.getTopPredictions(
        probabilities,
        _soilTypeModelName,
        topK: 3,
        threshold: 0.1,
      );

      final topPrediction = predictions.isNotEmpty ? predictions.first : null;
      final soilType = topPrediction != null ? _parseSoilType(topPrediction.label) : null;

      return SoilTypeResult(
        soilType: soilType,
        predictions: predictions,
        confidence: topPrediction?.confidence ?? 0.0,
        characteristics: soilType != null ? _getSoilCharacteristics(soilType) : null,
        suitableCrops: soilType != null ? _getSuitableCrops(soilType) : [],
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return SoilTypeResult(
        soilType: null,
        predictions: [],
        confidence: 0.0,
        characteristics: null,
        suitableCrops: [],
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Analyze soil nutrients from image
  Future<NutrientAnalysisResult> analyzeNutrients(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Soil analyzer not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _nutrientModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      // Assuming model outputs NPK levels and other nutrients
      final nutrientLevels = _parseNutrientLevels(output[0]);
      
      return NutrientAnalysisResult(
        nitrogen: nutrientLevels['nitrogen'] ?? 0.0,
        phosphorus: nutrientLevels['phosphorus'] ?? 0.0,
        potassium: nutrientLevels['potassium'] ?? 0.0,
        organicMatter: nutrientLevels['organicMatter'] ?? 0.0,
        calcium: nutrientLevels['calcium'] ?? 0.0,
        magnesium: nutrientLevels['magnesium'] ?? 0.0,
        sulfur: nutrientLevels['sulfur'] ?? 0.0,
        overallNutrientScore: _calculateNutrientScore(nutrientLevels),
        deficiencies: _identifyDeficiencies(nutrientLevels),
        recommendations: _getNutrientRecommendations(nutrientLevels),
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return NutrientAnalysisResult(
        nitrogen: 0.0,
        phosphorus: 0.0,
        potassium: 0.0,
        organicMatter: 0.0,
        calcium: 0.0,
        magnesium: 0.0,
        sulfur: 0.0,
        overallNutrientScore: 0.0,
        deficiencies: [],
        recommendations: [],
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Analyze soil moisture from image
  Future<MoistureAnalysisResult> analyzeMoisture(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Soil analyzer not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _moistureModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      final moisturePercentage = output[0][0] * 100; // Convert to percentage
      final moistureLevel = _categorizeMoistureLevel(moisturePercentage);
      
      return MoistureAnalysisResult(
        moisturePercentage: moisturePercentage,
        moistureLevel: moistureLevel,
        confidence: _calculateMoistureConfidence(output[0]),
        recommendations: _getMoistureRecommendations(moistureLevel, moisturePercentage),
        optimalRange: _getOptimalMoistureRange(),
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return MoistureAnalysisResult(
        moisturePercentage: 0.0,
        moistureLevel: MoistureLevel.unknown,
        confidence: 0.0,
        recommendations: [],
        optimalRange: _getOptimalMoistureRange(),
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Analyze soil pH from image
  Future<PHAnalysisResult> analyzePH(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Soil analyzer not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _phModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      final phValue = output[0][0];
      final phCategory = _categorizePH(phValue);
      
      return PHAnalysisResult(
        phValue: phValue,
        phCategory: phCategory,
        confidence: _calculatePHConfidence(output[0]),
        suitableCrops: _getCropsForPH(phValue),
        amendments: _getPHAmendmentRecommendations(phValue),
        optimalRange: const PHRange(min: 6.0, max: 7.0),
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return PHAnalysisResult(
        phValue: 7.0,
        phCategory: PHCategory.neutral,
        confidence: 0.0,
        suitableCrops: [],
        amendments: [],
        optimalRange: const PHRange(min: 6.0, max: 7.0),
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Comprehensive soil analysis
  Future<ComprehensiveSoilAnalysis> analyzeSoil({
    required String imagePath,
    Map<String, double>? additionalData,
  }) async {
    final soilTypeResult = await analyzeSoilType(imagePath);
    final nutrientResult = await analyzeNutrients(imagePath);
    final moistureResult = await analyzeMoisture(imagePath);
    final phResult = await analyzePH(imagePath);

    final overallScore = _calculateOverallSoilHealth([
      soilTypeResult.confidence,
      nutrientResult.overallNutrientScore,
      moistureResult.confidence,
      phResult.confidence,
    ]);

    return ComprehensiveSoilAnalysis(
      soilTypeResult: soilTypeResult,
      nutrientResult: nutrientResult,
      moistureResult: moistureResult,
      phResult: phResult,
      overallHealthScore: overallScore,
      recommendations: _getOverallRecommendations(
        soilTypeResult, nutrientResult, moistureResult, phResult,
      ),
      suitableCrops: _getCombinedCropRecommendations(
        soilTypeResult, phResult,
      ),
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

  SoilType? _parseSoilType(String typeLabel) {
    final type = typeLabel.toLowerCase();
    if (type.contains('clay')) return SoilType.clay;
    if (type.contains('sand')) return SoilType.sandy;
    if (type.contains('silt')) return SoilType.silty;
    if (type.contains('loam')) return SoilType.loamy;
    if (type.contains('peat')) return SoilType.peaty;
    if (type.contains('chalk')) return SoilType.chalky;
    return null;
  }

  SoilCharacteristics _getSoilCharacteristics(SoilType soilType) {
    switch (soilType) {
      case SoilType.clay:
        return SoilCharacteristics(
          drainage: 'Poor',
          waterRetention: 'High',
          fertility: 'High',
          workability: 'Difficult when wet',
          description: 'Heavy soil that retains moisture but may become waterlogged',
        );
      case SoilType.sandy:
        return SoilCharacteristics(
          drainage: 'Excellent',
          waterRetention: 'Low',
          fertility: 'Low to moderate',
          workability: 'Easy',
          description: 'Light, well-draining soil that warms up quickly',
        );
      case SoilType.silty:
        return SoilCharacteristics(
          drainage: 'Moderate',
          waterRetention: 'High',
          fertility: 'High',
          workability: 'Good when dry',
          description: 'Smooth, fine soil particles with good fertility',
        );
      case SoilType.loamy:
        return SoilCharacteristics(
          drainage: 'Good',
          waterRetention: 'Moderate',
          fertility: 'High',
          workability: 'Excellent',
          description: 'Ideal soil type with balanced properties',
        );
      case SoilType.peaty:
        return SoilCharacteristics(
          drainage: 'Variable',
          waterRetention: 'High',
          fertility: 'High in organic matter',
          workability: 'Good',
          description: 'Rich in organic matter, acidic soil',
        );
      case SoilType.chalky:
        return SoilCharacteristics(
          drainage: 'Good',
          waterRetention: 'Low to moderate',
          fertility: 'Moderate',
          workability: 'Good',
          description: 'Alkaline soil with free-draining properties',
        );
    }
  }

  List<String> _getSuitableCrops(SoilType soilType) {
    switch (soilType) {
      case SoilType.clay:
        return ['Rice', 'Wheat', 'Cabbage', 'Broccoli', 'Brussels sprouts'];
      case SoilType.sandy:
        return ['Carrots', 'Radishes', 'Potatoes', 'Lettuce', 'Strawberries'];
      case SoilType.silty:
        return ['Tomatoes', 'Peppers', 'Corn', 'Squash', 'Cucumbers'];
      case SoilType.loamy:
        return ['Almost all crops', 'Vegetables', 'Fruits', 'Grains', 'Legumes'];
      case SoilType.peaty:
        return ['Blueberries', 'Cranberries', 'Brassicas', 'Root vegetables'];
      case SoilType.chalky:
        return ['Brassicas', 'Spinach', 'Sweet corn', 'Lilacs', 'Clematis'];
    }
  }

  Map<String, double> _parseNutrientLevels(List<double> output) {
    // Assuming model outputs normalized values for different nutrients
    return {
      'nitrogen': output.length > 0 ? output[0] * 100 : 0.0, // N %
      'phosphorus': output.length > 1 ? output[1] * 100 : 0.0, // P ppm
      'potassium': output.length > 2 ? output[2] * 100 : 0.0, // K ppm
      'organicMatter': output.length > 3 ? output[3] * 10 : 0.0, // OM %
      'calcium': output.length > 4 ? output[4] * 1000 : 0.0, // Ca ppm
      'magnesium': output.length > 5 ? output[5] * 500 : 0.0, // Mg ppm
      'sulfur': output.length > 6 ? output[6] * 50 : 0.0, // S ppm
    };
  }

  double _calculateNutrientScore(Map<String, double> nutrients) {
    final scores = <double>[];
    
    // Score each nutrient based on optimal ranges
    scores.add(_scoreNutrient(nutrients['nitrogen']!, 20, 40)); // N optimal 20-40 ppm
    scores.add(_scoreNutrient(nutrients['phosphorus']!, 25, 50)); // P optimal 25-50 ppm
    scores.add(_scoreNutrient(nutrients['potassium']!, 125, 250)); // K optimal 125-250 ppm
    scores.add(_scoreNutrient(nutrients['organicMatter']!, 3, 6)); // OM optimal 3-6%
    
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  double _scoreNutrient(double value, double minOptimal, double maxOptimal) {
    if (value >= minOptimal && value <= maxOptimal) return 1.0;
    if (value < minOptimal) return value / minOptimal;
    return maxOptimal / value;
  }

  List<String> _identifyDeficiencies(Map<String, double> nutrients) {
    final deficiencies = <String>[];
    
    if (nutrients['nitrogen']! < 20) deficiencies.add('Nitrogen deficiency');
    if (nutrients['phosphorus']! < 25) deficiencies.add('Phosphorus deficiency');
    if (nutrients['potassium']! < 125) deficiencies.add('Potassium deficiency');
    if (nutrients['organicMatter']! < 3) deficiencies.add('Low organic matter');
    if (nutrients['calcium']! < 500) deficiencies.add('Calcium deficiency');
    if (nutrients['magnesium']! < 50) deficiencies.add('Magnesium deficiency');
    
    return deficiencies;
  }

  List<String> _getNutrientRecommendations(Map<String, double> nutrients) {
    final recommendations = <String>[];
    
    if (nutrients['nitrogen']! < 20) {
      recommendations.add('Apply nitrogen-rich fertilizer or compost');
    }
    if (nutrients['phosphorus']! < 25) {
      recommendations.add('Add phosphorus fertilizer or bone meal');
    }
    if (nutrients['potassium']! < 125) {
      recommendations.add('Apply potassium sulfate or wood ash');
    }
    if (nutrients['organicMatter']! < 3) {
      recommendations.add('Add compost or well-rotted manure');
    }
    if (nutrients['calcium']! < 500) {
      recommendations.add('Apply lime or gypsum');
    }
    if (nutrients['magnesium']! < 50) {
      recommendations.add('Add Epsom salt or dolomitic lime');
    }
    
    return recommendations.isEmpty ? 
      ['Soil nutrients appear balanced - continue regular monitoring'] : 
      recommendations;
  }

  MoistureLevel _categorizeMoistureLevel(double moisturePercentage) {
    if (moisturePercentage < 20) return MoistureLevel.dry;
    if (moisturePercentage < 40) return MoistureLevel.low;
    if (moisturePercentage < 60) return MoistureLevel.optimal;
    if (moisturePercentage < 80) return MoistureLevel.high;
    return MoistureLevel.saturated;
  }

  double _calculateMoistureConfidence(List<double> output) {
    // Simple confidence calculation based on model certainty
    return output.length > 1 ? 
      1.0 - (output.map((x) => (x - 0.5).abs()).reduce((a, b) => a + b) / output.length) :
      0.8;
  }

  List<String> _getMoistureRecommendations(MoistureLevel level, double percentage) {
    switch (level) {
      case MoistureLevel.dry:
        return [
          'Increase irrigation frequency',
          'Apply mulch to retain moisture',
          'Check irrigation system efficiency',
          'Consider drought-resistant crops'
        ];
      case MoistureLevel.low:
        return [
          'Monitor soil moisture regularly',
          'Increase watering slightly',
          'Add organic matter to improve water retention'
        ];
      case MoistureLevel.optimal:
        return [
          'Maintain current irrigation schedule',
          'Monitor for changes in weather conditions'
        ];
      case MoistureLevel.high:
        return [
          'Reduce irrigation frequency',
          'Improve soil drainage',
          'Monitor for signs of root rot'
        ];
      case MoistureLevel.saturated:
        return [
          'Stop irrigation immediately',
          'Improve drainage system',
          'Check for waterlogging issues',
          'Consider raised beds for future planting'
        ];
      case MoistureLevel.unknown:
        return ['Unable to determine moisture level - manual testing recommended'];
    }
  }

  MoistureRange _getOptimalMoistureRange() {
    return const MoistureRange(min: 40.0, max: 60.0);
  }

  PHCategory _categorizePH(double phValue) {
    if (phValue < 5.5) return PHCategory.veryAcidic;
    if (phValue < 6.0) return PHCategory.acidic;
    if (phValue < 7.0) return PHCategory.slightlyAcidic;
    if (phValue == 7.0) return PHCategory.neutral;
    if (phValue < 7.5) return PHCategory.slightlyAlkaline;
    if (phValue < 8.5) return PHCategory.alkaline;
    return PHCategory.veryAlkaline;
  }

  double _calculatePHConfidence(List<double> output) {
    return output.length > 1 ? 
      1.0 - (output.map((x) => (x - output[0]).abs()).reduce((a, b) => a + b) / output.length) :
      0.8;
  }

  List<String> _getCropsForPH(double phValue) {
    if (phValue < 5.5) {
      return ['Blueberries', 'Cranberries', 'Azaleas', 'Rhododendrons'];
    } else if (phValue < 6.0) {
      return ['Potatoes', 'Sweet potatoes', 'Radishes', 'Parsley'];
    } else if (phValue < 7.0) {
      return ['Tomatoes', 'Carrots', 'Beans', 'Peas', 'Squash'];
    } else if (phValue < 7.5) {
      return ['Most vegetables', 'Corn', 'Lettuce', 'Onions', 'Wheat'];
    } else if (phValue < 8.5) {
      return ['Beets', 'Cabbage', 'Asparagus', 'Spinach'];
    } else {
      return ['Very few crops suitable', 'Consider soil amendment'];
    }
  }

  List<String> _getPHAmendmentRecommendations(double phValue) {
    if (phValue < 5.5) {
      return [
        'Apply agricultural lime to raise pH',
        'Add wood ash in small amounts',
        'Use dolomitic lime for magnesium boost'
      ];
    } else if (phValue > 8.0) {
      return [
        'Apply sulfur to lower pH',
        'Add organic matter like peat moss',
        'Use aluminum sulfate for quick pH reduction'
      ];
    } else if (phValue < 6.0) {
      return [
        'Apply lime gradually to raise pH',
        'Monitor pH changes over time'
      ];
    } else if (phValue > 7.5) {
      return [
        'Apply sulfur or organic matter to lower pH',
        'Avoid alkaline fertilizers'
      ];
    } else {
      return ['pH is in acceptable range for most crops'];
    }
  }

  double _calculateOverallSoilHealth(List<double> scores) {
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  List<String> _getOverallRecommendations(
    SoilTypeResult soilType,
    NutrientAnalysisResult nutrients,
    MoistureAnalysisResult moisture,
    PHAnalysisResult ph,
  ) {
    final recommendations = <String>[];
    
    // Add specific recommendations based on each analysis
    recommendations.addAll(nutrients.recommendations);
    recommendations.addAll(moisture.recommendations);
    recommendations.addAll(ph.amendments);
    
    // Add soil type specific recommendations
    if (soilType.soilType != null) {
      switch (soilType.soilType!) {
        case SoilType.clay:
          recommendations.add('Improve drainage with organic matter');
          recommendations.add('Avoid working soil when wet');
          break;
        case SoilType.sandy:
          recommendations.add('Add organic matter to improve water retention');
          recommendations.add('Apply fertilizers more frequently');
          break;
        case SoilType.silty:
          recommendations.add('Improve drainage to prevent compaction');
          break;
        case SoilType.loamy:
          recommendations.add('Maintain soil structure with organic matter');
          break;
        case SoilType.peaty:
          recommendations.add('Monitor pH regularly');
          recommendations.add('Ensure adequate drainage');
          break;
        case SoilType.chalky:
          recommendations.add('Add organic matter for better structure');
          break;
      }
    }
    
    // Remove duplicates and return
    return recommendations.toSet().toList();
  }

  List<String> _getCombinedCropRecommendations(
    SoilTypeResult soilType,
    PHAnalysisResult ph,
  ) {
    final soilCrops = soilType.suitableCrops.toSet();
    final phCrops = ph.suitableCrops.toSet();
    
    // Return intersection of suitable crops
    return soilCrops.intersection(phCrops).toList();
  }

  /// Dispose resources
  void dispose() {
    _tfliteHelper.disposeModel(_soilTypeModelName);
    _tfliteHelper.disposeModel(_nutrientModelName);
    _tfliteHelper.disposeModel(_moistureModelName);
    _tfliteHelper.disposeModel(_phModelName);
    _isInitialized = false;
  }
}

// Data classes for soil analysis results

class SoilTypeResult {
  final SoilType? soilType;
  final List<Prediction> predictions;
  final double confidence;
  final SoilCharacteristics? characteristics;
  final List<String> suitableCrops;
  final DateTime processingTime;
  final String? error;

  SoilTypeResult({
    required this.soilType,
    required this.predictions,
    required this.confidence,
    required this.characteristics,
    required this.suitableCrops,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'soilType': soilType?.toString(),
    'confidence': confidence,
    'characteristics': characteristics?.toJson(),
    'suitableCrops': suitableCrops,
    'predictions': predictions.map((p) => p.toJson()).toList(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class NutrientAnalysisResult {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double organicMatter;
  final double calcium;
  final double magnesium;
  final double sulfur;
  final double overallNutrientScore;
  final List<String> deficiencies;
  final List<String> recommendations;
  final DateTime processingTime;
  final String? error;

  NutrientAnalysisResult({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.organicMatter,
    required this.calcium,
    required this.magnesium,
    required this.sulfur,
    required this.overallNutrientScore,
    required this.deficiencies,
    required this.recommendations,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'nutrients': {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'organicMatter': organicMatter,
      'calcium': calcium,
      'magnesium': magnesium,
      'sulfur': sulfur,
    },
    'overallScore': overallNutrientScore,
    'deficiencies': deficiencies,
    'recommendations': recommendations,
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class MoistureAnalysisResult {
  final double moisturePercentage;
  final MoistureLevel moistureLevel;
  final double confidence;
  final List<String> recommendations;
  final MoistureRange optimalRange;
  final DateTime processingTime;
  final String? error;

  MoistureAnalysisResult({
    required this.moisturePercentage,
    required this.moistureLevel,
    required this.confidence,
    required this.recommendations,
    required this.optimalRange,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'moisturePercentage': moisturePercentage,
    'moistureLevel': moistureLevel.toString(),
    'confidence': confidence,
    'recommendations': recommendations,
    'optimalRange': optimalRange.toJson(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class PHAnalysisResult {
  final double phValue;
  final PHCategory phCategory;
  final double confidence;
  final List<String> suitableCrops;
  final List<String> amendments;
  final PHRange optimalRange;
  final DateTime processingTime;
  final String? error;

  PHAnalysisResult({
    required this.phValue,
    required this.phCategory,
    required this.confidence,
    required this.suitableCrops,
    required this.amendments,
    required this.optimalRange,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'phValue': phValue,
    'phCategory': phCategory.toString(),
    'confidence': confidence,
    'suitableCrops': suitableCrops,
    'amendments': amendments,
    'optimalRange': optimalRange.toJson(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class ComprehensiveSoilAnalysis {
  final SoilTypeResult soilTypeResult;
  final NutrientAnalysisResult nutrientResult;
  final MoistureAnalysisResult moistureResult;
  final PHAnalysisResult phResult;
  final double overallHealthScore;
  final List<String> recommendations;
  final List<String> suitableCrops;
  final DateTime processingTime;

  ComprehensiveSoilAnalysis({
    required this.soilTypeResult,
    required this.nutrientResult,
    required this.moistureResult,
    required this.phResult,
    required this.overallHealthScore,
    required this.recommendations,
    required this.suitableCrops,
    required this.processingTime,
  });

  bool get hasAnyErrors => 
    soilTypeResult.hasError || 
    nutrientResult.hasError || 
    moistureResult.hasError || 
    phResult.hasError;

  SoilHealthCategory get healthCategory {
    if (overallHealthScore >= 0.8) return SoilHealthCategory.excellent;
    if (overallHealthScore >= 0.6) return SoilHealthCategory.good;
    if (overallHealthScore >= 0.4) return SoilHealthCategory.fair;
    return SoilHealthCategory.poor;
  }

  Map<String, dynamic> toJson() => {
    'soilType': soilTypeResult.toJson(),
    'nutrients': nutrientResult.toJson(),
    'moisture': moistureResult.toJson(),
    'ph': phResult.toJson(),
    'overallHealthScore': overallHealthScore,
    'healthCategory': healthCategory.toString(),
    'recommendations': recommendations,
    'suitableCrops': suitableCrops,
    'processingTime': processingTime.toIso8601String(),
  };
}

// Supporting data classes

class SoilCharacteristics {
  final String drainage;
  final String waterRetention;
  final String fertility;
  final String workability;
  final String description;

  SoilCharacteristics({
    required this.drainage,
    required this.waterRetention,
    required this.fertility,
    required this.workability,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'drainage': drainage,
    'waterRetention': waterRetention,
    'fertility': fertility,
    'workability': workability,
    'description': description,
  };
}

class MoistureRange {
  final double min;
  final double max;

  const MoistureRange({required this.min, required this.max});

  Map<String, dynamic> toJson() => {'min': min, 'max': max};
}

class PHRange {
  final double min;
  final double max;

  const PHRange({required this.min, required this.max});

  Map<String, dynamic> toJson() => {'min': min, 'max': max};
}

// Enums

enum SoilType {
  clay,
  sandy,
  silty,
  loamy,
  peaty,
  chalky,
}

enum MoistureLevel {
  dry,
  low,
  optimal,
  high,
  saturated,
  unknown,
}

enum PHCategory {
  veryAcidic,
  acidic,
  slightlyAcidic,
  neutral,
  slightlyAlkaline,
  alkaline,
  veryAlkaline,
}

enum SoilHealthCategory {
  excellent,
  good,
  fair,
  poor,
}

// Extensions

extension SoilTypeExtension on SoilType {
  String get displayName {
    switch (this) {
      case SoilType.clay:
        return 'Clay';
      case SoilType.sandy:
        return 'Sandy';
      case SoilType.silty:
        return 'Silty';
      case SoilType.loamy:
        return 'Loamy';
      case SoilType.peaty:
        return 'Peaty';
      case SoilType.chalky:
        return 'Chalky';
    }
  }
}

extension MoistureLevelExtension on MoistureLevel {
  String get displayName {
    switch (this) {
      case MoistureLevel.dry:
        return 'Dry';
      case MoistureLevel.low:
        return 'Low';
      case MoistureLevel.optimal:
        return 'Optimal';
      case MoistureLevel.high:
        return 'High';
      case MoistureLevel.saturated:
        return 'Saturated';
      case MoistureLevel.unknown:
        return 'Unknown';
    }
  }
}

extension PHCategoryExtension on PHCategory {
  String get displayName {
    switch (this) {
      case PHCategory.veryAcidic:
        return 'Very Acidic';
      case PHCategory.acidic:
        return 'Acidic';
      case PHCategory.slightlyAcidic:
        return 'Slightly Acidic';
      case PHCategory.neutral:
        return 'Neutral';
      case PHCategory.slightlyAlkaline:
        return 'Slightly Alkaline';
      case PHCategory.alkaline:
        return 'Alkaline';
      case PHCategory.veryAlkaline:
        return 'Very Alkaline';
    }
  }

  String get description {
    switch (this) {
      case PHCategory.veryAcidic:
        return 'pH < 5.5 - Very acidic conditions';
      case PHCategory.acidic:
        return 'pH 5.5-6.0 - Acidic conditions';
      case PHCategory.slightlyAcidic:
        return 'pH 6.0-7.0 - Slightly acidic conditions';
      case PHCategory.neutral:
        return 'pH 7.0 - Neutral conditions';
      case PHCategory.slightlyAlkaline:
        return 'pH 7.0-7.5 - Slightly alkaline conditions';
      case PHCategory.alkaline:
        return 'pH 7.5-8.5 - Alkaline conditions';
      case PHCategory.veryAlkaline:
        return 'pH > 8.5 - Very alkaline conditions';
    }
  }
}