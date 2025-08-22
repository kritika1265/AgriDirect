// lib/services/ml_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:google_ml_kit/google_ml_kit.dart';
import '../models/disease_model.dart';
import '../models/prediction_model.dart';

/// Service class for handling machine learning operations
class MLService {
  static const String _diseaseLabelsPath = 'assets/models/disease_labels.txt';
  static const String _cropLabelsPath = 'assets/models/crop_type_labels.txt';
  static const String _soilLabelsPath = 'assets/models/soil_type_labels.txt';
  static const String _pestLabelsPath = 'assets/models/pest_labels.txt';

  // Google ML Kit components
  late ImageLabeler _imageLabeler;
  late TextRecognizer _textRecognizer;
  
  List<String> _diseaseLabels = [];
  List<String> _cropLabels = [];
  List<String> _soilLabels = [];
  List<String> _pestLabels = [];

  bool _isInitialized = false;

  /// Initialize all ML models
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Google ML Kit components
      _imageLabeler = GoogleMlKit.vision.imageLabeler(
        ImageLabelerOptions(confidenceThreshold: 0.5),
      );
      _textRecognizer = GoogleMlKit.vision.textRecognizer();

      // Load labels
      await _loadAllLabels();
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('ML Service initialization failed: $e');
    }
  }

  /// Detect plant disease from image
  Future<DiseaseDetection> detectPlantDisease(File imageFile) async {
    await _ensureInitialized();

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler.processImage(inputImage);

      if (labels.isEmpty) {
        return _createDefaultDiseaseDetection(imageFile, 'Unknown Disease', 0.0);
      }

      // Find the best matching disease label
      final bestMatch = _findBestDiseaseMatch(labels);
      
      final result = DiseaseDetection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        diseaseName: bestMatch.diseaseName,
        confidence: bestMatch.confidence,
        imagePath: imageFile.path,
        detectedAt: DateTime.now(),
        symptoms: [_getDiseaseSymptoms(bestMatch.diseaseName)],
        treatment: _getDiseaseTreatment(bestMatch.diseaseName),
        severity: _getDiseaseSeverity(bestMatch.confidence),
      );

      return result;
    } catch (e) {
      throw Exception('Disease detection failed: $e');
    }
  }

  /// Predict suitable crop based on parameters
  Future<CropPrediction> predictCrop(Map<String, dynamic> parameters) async {
    await _ensureInitialized();

    try {
      // Use rule-based prediction since we don't have actual ML models
      final recommendations = _generateCropRecommendations(parameters);

      return CropPrediction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recommendations: recommendations,
        inputParameters: parameters,
        predictedAt: DateTime.now(),
        season: _determineSeason(parameters),
        location: parameters['location']?.toString() ?? 'Unknown',
      );
    } catch (e) {
      throw Exception('Crop prediction failed: $e');
    }
  }

  /// Analyze soil conditions
  Future<SoilAnalysis> analyzeSoil(Map<String, dynamic> parameters) async {
    await _ensureInitialized();

    try {
      // Use rule-based analysis
      final soilType = _determineSoilType(parameters);
      final confidence = _calculateSoilConfidence(parameters);

      return SoilAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        soilType: soilType,
        confidence: confidence,
        nutrients: NutrientLevels(
          nitrogen: (parameters['nitrogen'] as num?)?.toDouble() ?? 0.0,
          phosphorus: (parameters['phosphorus'] as num?)?.toDouble() ?? 0.0,
          potassium: (parameters['potassium'] as num?)?.toDouble() ?? 0.0,
          ph: (parameters['ph'] as num?)?.toDouble() ?? 7.0,
        ),
        fertility: _determineFertility(confidence),
        recommendations: _getSoilRecommendations(soilType, parameters),
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Soil analysis failed: $e');
    }
  }

  /// Detect pest from image
  Future<PestDetection> detectPest(File imageFile) async {
    await _ensureInitialized();

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler.processImage(inputImage);

      if (labels.isEmpty) {
        return _createDefaultPestDetection(imageFile, 'Unknown Pest', 0.0);
      }

      // Find the best matching pest label
      final bestMatch = _findBestPestMatch(labels);

      return PestDetection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pestName: bestMatch.pestName,
        confidence: bestMatch.confidence,
        imagePath: imageFile.path,
        detectedAt: DateTime.now(),
        pestType: _getPestType(bestMatch.pestName),
        damageLevel: _getDamageLevel(bestMatch.confidence),
        controlMethods: _getControlMethods(bestMatch.pestName),
        prevention: _getPreventionMethods(bestMatch.pestName),
      );
    } catch (e) {
      throw Exception('Pest detection failed: $e');
    }
  }

  // Private helper methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> _loadAllLabels() async {
    try {
      _diseaseLabels = await _loadLabels(_diseaseLabelsPath);
      _cropLabels = await _loadLabels(_cropLabelsPath);
      _soilLabels = await _loadLabels(_soilLabelsPath);
      _pestLabels = await _loadLabels(_pestLabelsPath);
    } catch (e) {
      // Use default labels if files don't exist
      _useDefaultLabels();
    }
  }

  void _useDefaultLabels() {
    _diseaseLabels = [
      'Healthy',
      'Bacterial Blight',
      'Brown Spot',
      'Leaf Blast',
      'Tungro',
      'Bacterial Leaf Streak',
      'Sheath Blight',
      'Yellow Dwarf',
      'Powdery Mildew',
      'Rust Disease'
    ];

    _cropLabels = [
      'Rice',
      'Wheat',
      'Maize',
      'Cotton',
      'Sugarcane',
      'Soybean',
      'Tomato',
      'Potato',
      'Onion',
      'Groundnut'
    ];

    _soilLabels = [
      'Clay',
      'Sandy',
      'Loamy',
      'Silty',
      'Peaty',
      'Chalky'
    ];

    _pestLabels = [
      'Aphids',
      'Whitefly',
      'Thrips',
      'Spider Mites',
      'Caterpillar',
      'Stem Borer',
      'Leaf Hopper',
      'Scale Insects',
      'Mealybugs',
      'Termites'
    ];
  }

  Future<List<String>> _loadLabels(String path) async {
    try {
      final labelData = await rootBundle.loadString(path);
      return labelData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  ({String diseaseName, double confidence}) _findBestDiseaseMatch(List<ImageLabel> labels) {
    double bestScore = 0.0;
    String bestDisease = 'Healthy';

    for (final label in labels) {
      for (final diseaseLabel in _diseaseLabels) {
        final similarity = _calculateSimilarity(label.label.toLowerCase(), diseaseLabel.toLowerCase());
        final score = similarity * label.confidence;
        
        if (score > bestScore) {
          bestScore = score;
          bestDisease = diseaseLabel;
        }
      }
    }

    return (diseaseName: bestDisease, confidence: bestScore);
  }

  ({String pestName, double confidence}) _findBestPestMatch(List<ImageLabel> labels) {
    double bestScore = 0.0;
    String bestPest = 'Unknown Pest';

    for (final label in labels) {
      for (final pestLabel in _pestLabels) {
        final similarity = _calculateSimilarity(label.label.toLowerCase(), pestLabel.toLowerCase());
        final score = similarity * label.confidence;
        
        if (score > bestScore) {
          bestScore = score;
          bestPest = pestLabel;
        }
      }
    }

    return (pestName: bestPest, confidence: bestScore);
  }

  double _calculateSimilarity(String str1, String str2) {
    if (str1 == str2) return 1.0;
    if (str1.contains(str2) || str2.contains(str1)) return 0.8;
    
    // Simple Levenshtein distance-based similarity
    final distance = _levenshteinDistance(str1, str2);
    final maxLength = math.max(str1.length, str2.length);
    
    return maxLength == 0 ? 1.0 : 1.0 - (distance / maxLength);
  }

  int _levenshteinDistance(String str1, String str2) {
    final matrix = List.generate(
      str1.length + 1,
      (i) => List.filled(str2.length + 1, 0),
    );

    for (int i = 0; i <= str1.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= str2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= str1.length; i++) {
      for (int j = 1; j <= str2.length; j++) {
        final cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce(math.min);
      }
    }

    return matrix[str1.length][str2.length];
  }

  List<CropRecommendation> _generateCropRecommendations(Map<String, dynamic> parameters) {
    final recommendations = <CropRecommendation>[];
    final temperature = (parameters['temperature'] as num?)?.toDouble() ?? 25.0;
    final rainfall = (parameters['rainfall'] as num?)?.toDouble() ?? 100.0;
    final ph = (parameters['ph'] as num?)?.toDouble() ?? 7.0;

    // Rule-based crop recommendations
    final cropScores = <String, double>{};

    for (final crop in _cropLabels) {
      double score = 0.5; // Base score

      // Temperature preference
      switch (crop.toLowerCase()) {
        case 'rice':
          score += temperature > 20 && temperature < 35 ? 0.3 : 0.0;
          score += rainfall > 100 ? 0.2 : 0.0;
          break;
        case 'wheat':
          score += temperature > 10 && temperature < 25 ? 0.3 : 0.0;
          score += rainfall > 50 && rainfall < 150 ? 0.2 : 0.0;
          break;
        case 'maize':
          score += temperature > 15 && temperature < 30 ? 0.3 : 0.0;
          score += rainfall > 75 && rainfall < 200 ? 0.2 : 0.0;
          break;
        default:
          score += 0.1;
      }

      // pH preference
      if (ph >= 6.0 && ph <= 7.5) {
        score += 0.2;
      }

      cropScores[crop] = math.min(score, 1.0);
    }

    // Sort by score and take top 3
    final sortedCrops = cropScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < math.min(3, sortedCrops.length); i++) {
      final entry = sortedCrops[i];
      recommendations.add(CropRecommendation(
        cropName: entry.key,
        confidence: entry.value,
        suitabilityScore: entry.value * 100,
        expectedYield: _getExpectedYield(entry.key, parameters),
        growingPeriod: _getGrowingPeriod(entry.key),
        waterRequirement: _getWaterRequirement(entry.key),
        tips: _getCropTips(entry.key),
      ));
    }

    return recommendations;
  }

  String _determineSoilType(Map<String, dynamic> parameters) {
    final ph = (parameters['ph'] as num?)?.toDouble() ?? 7.0;
    final moisture = (parameters['moisture'] as num?)?.toDouble() ?? 50.0;
    final organicMatter = (parameters['organic_matter'] as num?)?.toDouble() ?? 3.0;

    if (ph < 6.0 && organicMatter > 5.0) return 'Peaty';
    if (ph > 7.5) return 'Chalky';
    if (moisture > 70) return 'Clay';
    if (moisture < 30) return 'Sandy';
    if (organicMatter > 4.0) return 'Loamy';
    return 'Silty';
  }

  double _calculateSoilConfidence(Map<String, dynamic> parameters) {
    final ph = (parameters['ph'] as num?)?.toDouble() ?? 7.0;
    final moisture = (parameters['moisture'] as num?)?.toDouble() ?? 50.0;
    
    double confidence = 0.5;
    
    // pH within normal range increases confidence
    if (ph >= 6.0 && ph <= 8.0) confidence += 0.2;
    
    // Moisture within reasonable range
    if (moisture >= 20 && moisture <= 80) confidence += 0.2;
    
    // Add some randomness to simulate model uncertainty
    confidence += (math.Random().nextDouble() - 0.5) * 0.2;
    
    return math.max(0.0, math.min(1.0, confidence));
  }

  DiseaseDetection _createDefaultDiseaseDetection(File imageFile, String diseaseName, double confidence) {
    return DiseaseDetection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      diseaseName: diseaseName,
      confidence: confidence,
      imagePath: imageFile.path,
      detectedAt: DateTime.now(),
      symptoms: [_getDiseaseSymptoms(diseaseName)],
      treatment: _getDiseaseTreatment(diseaseName),
      severity: _getDiseaseSeverity(confidence),
    );
  }

  PestDetection _createDefaultPestDetection(File imageFile, String pestName, double confidence) {
    return PestDetection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pestName: pestName,
      confidence: confidence,
      imagePath: imageFile.path,
      detectedAt: DateTime.now(),
      pestType: _getPestType(pestName),
      damageLevel: _getDamageLevel(confidence),
      controlMethods: _getControlMethods(pestName),
      prevention: _getPreventionMethods(pestName),
    );
  }

  // Helper methods for additional data
  String _getDiseaseSymptoms(String disease) =>
      'Common symptoms of $disease include leaf discoloration, spots, and wilting.';

  String _getDiseaseTreatment(String disease) =>
      'Standard treatment methods for $disease include proper fungicides and cultural practices.';

  String _getDiseaseSeverity(double confidence) {
    if (confidence > 0.85) return 'High';
    if (confidence > 0.6) return 'Medium';
    return 'Low';
  }

  String _determineSeason(Map<String, dynamic> params) {
    final temperature = (params['temperature'] as num? ?? 20).toDouble();
    final rainfall = (params['rainfall'] as num? ?? 100).toDouble();
    
    if (temperature > 30 && rainfall > 200) {
      return 'Monsoon';
    }
    if (temperature > 25) {
      return 'Summer';
    }
    if (temperature < 15) {
      return 'Winter';
    }
    return 'Spring';
  }

  String _determineFertility(double confidence) {
    if (confidence > 0.8) return 'High';
    if (confidence > 0.6) return 'Medium';
    return 'Low';
  }

  List<String> _getSoilRecommendations(String soilType, Map<String, dynamic> params) => [
        'Maintain optimal pH levels for $soilType soil',
        'Apply organic matter to improve soil structure',
        'Monitor moisture levels regularly',
        'Use appropriate fertilizers based on nutrient analysis',
      ];

  String _getPestType(String pestName) {
    if (pestName.toLowerCase().contains('aphid')) return 'Insect';
    if (pestName.toLowerCase().contains('fungus')) return 'Fungal';
    if (pestName.toLowerCase().contains('mite')) return 'Arachnid';
    return 'Unknown';
  }

  String _getDamageLevel(double confidence) {
    if (confidence > 0.8) return 'High';
    if (confidence > 0.6) return 'Medium';
    return 'Low';
  }

  List<String> _getControlMethods(String pestName) => [
        'Apply appropriate pesticide for $pestName',
        'Use biological control methods',
        'Implement integrated pest management',
        'Remove affected plant parts',
      ];

  List<String> _getPreventionMethods(String pestName) => [
        'Regular monitoring and inspection',
        'Maintain proper plant spacing',
        'Use resistant crop varieties',
        'Practice crop rotation',
      ];

  String _getExpectedYield(String cropName, Map<String, dynamic> parameters) {
    // This would typically be calculated based on the crop and environmental conditions
    return '2-4 tons per hectare';
  }

  String _getGrowingPeriod(String cropName) {
    // This would be based on the specific crop
    final periods = {
      'rice': '120-150 days',
      'wheat': '120-140 days',
      'corn': '90-120 days',
      'maize': '90-120 days',
      'tomato': '70-90 days',
    };
    return periods[cropName.toLowerCase()] ?? '90-120 days';
  }

  String _getWaterRequirement(String cropName) {
    final requirements = {
      'rice': 'High (1200-1500mm)',
      'wheat': 'Medium (450-600mm)',
      'corn': 'Medium (500-700mm)',
      'maize': 'Medium (500-700mm)',
      'tomato': 'Medium (400-600mm)',
    };
    return requirements[cropName.toLowerCase()] ?? 'Medium (500-700mm)';
  }

  List<String> _getCropTips(String cropName) => [
        'Plant $cropName during optimal season for best yield',
        'Ensure proper soil preparation with adequate nutrients',
        'Monitor weather conditions regularly',
        'Apply appropriate fertilizers based on soil test results',
      ];

  /// Dispose resources
  void dispose() {
    if (_isInitialized) {
      _imageLabeler.close();
      _textRecognizer.close();
    }
  }
}