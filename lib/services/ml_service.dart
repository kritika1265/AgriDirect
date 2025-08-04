// lib/services/ml_service.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/disease_model.dart';
import '../models/prediction_model.dart';

/// Service class for handling machine learning operations
class MLService {
  static const String _diseaseModelPath = 'assets/models/plant_disease_model.tflite';
  static const String _cropModelPath = 'assets/models/crop_recommendation_model.tflite';
  static const String _soilModelPath = 'assets/models/soil_analysis_model.tflite';
  static const String _pestModelPath = 'assets/models/pest_detection_model.tflite';

  static const String _diseaseLabelsPath = 'assets/labels/plant_disease_labels.txt';
  static const String _cropLabelsPath = 'assets/labels/crop_labels.txt';
  static const String _soilLabelsPath = 'assets/labels/soil_labels.txt';
  static const String _pestLabelsPath = 'assets/labels/pest_labels.txt';

  Interpreter? _diseaseInterpreter;
  Interpreter? _cropInterpreter;
  Interpreter? _soilInterpreter;
  Interpreter? _pestInterpreter;

  List<String> _diseaseLabels = [];
  List<String> _cropLabels = [];
  List<String> _soilLabels = [];
  List<String> _pestLabels = [];

  /// Initialize all ML models
  Future<void> initialize() async {
    await _loadDiseaseModel();
    await _loadCropModel();
    await _loadSoilModel();
    await _loadPestModel();
  }

  /// Detect plant disease from image
  Future<DiseaseDetection> detectPlantDisease(File imageFile) async {
    if (_diseaseInterpreter == null) {
      await _loadDiseaseModel();
    }

    try {
      final inputImage = await _preprocessImage(imageFile, 224, 224);
      final output = List.filled(1 * _diseaseLabels.length, 0)
          .reshape<double>([1, _diseaseLabels.length]);
      
      _diseaseInterpreter!.run(inputImage, output);

      final predictions = output[0] as List<double>;
      final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      final confidence = predictions[maxIndex];

      final result = DiseaseDetection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        diseaseName: _diseaseLabels[maxIndex],
        confidence: confidence,
        imagePath: imageFile.path,
        detectedAt: DateTime.now(),
        symptoms: [_getDiseaseSymptoms(_diseaseLabels[maxIndex])],
        treatment: _getDiseaseTreatment(_diseaseLabels[maxIndex]),
        severity: _getDiseaseSeverity(confidence),
      );

      return result;
    } catch (e) {
      throw Exception('Disease detection failed: $e');
    }
  }

  /// Predict suitable crop based on parameters
  Future<CropPrediction> predictCrop(Map<String, dynamic> parameters) async {
    if (_cropInterpreter == null) {
      await _loadCropModel();
    }

    try {
      final inputData = _prepareCropInputData(parameters);
      final output = List.filled(1 * _cropLabels.length, 0)
          .reshape<double>([1, _cropLabels.length]);
      
      _cropInterpreter!.run(inputData, output);

      final predictions = output[0] as List<double>;
      
      // Create multiple recommendations based on top predictions
      final recommendations = _createCropRecommendations(predictions, parameters);

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
    if (_soilInterpreter == null) {
      await _loadSoilModel();
    }

    try {
      final inputData = _prepareSoilInputData(parameters);
      final output = List.filled(1 * _soilLabels.length, 0)
          .reshape<double>([1, _soilLabels.length]);
      
      _soilInterpreter!.run(inputData, output);

      final predictions = output[0] as List<double>;
      final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      final confidence = predictions[maxIndex];

      return SoilAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        soilType: _soilLabels[maxIndex],
        confidence: confidence,
        nutrients: NutrientLevels(
          nitrogen: (parameters['nitrogen'] as num?)?.toDouble() ?? 0.0,
          phosphorus: (parameters['phosphorus'] as num?)?.toDouble() ?? 0.0,
          potassium: (parameters['potassium'] as num?)?.toDouble() ?? 0.0,
          ph: (parameters['ph'] as num?)?.toDouble() ?? 7.0,
        ),
        fertility: _determineFertility(confidence),
        recommendations: _getSoilRecommendations(_soilLabels[maxIndex], parameters),
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Soil analysis failed: $e');
    }
  }

  /// Detect pest from image
  Future<PestDetection> detectPest(File imageFile) async {
    if (_pestInterpreter == null) {
      await _loadPestModel();
    }

    try {
      final inputImage = await _preprocessImage(imageFile, 224, 224);
      final output = List.filled(1 * _pestLabels.length, 0)
          .reshape<double>([1, _pestLabels.length]);
      
      _pestInterpreter!.run(inputImage, output);

      final predictions = output[0] as List<double>;
      final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      final confidence = predictions[maxIndex];

      return PestDetection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pestName: _pestLabels[maxIndex],
        confidence: confidence,
        imagePath: imageFile.path,
        detectedAt: DateTime.now(),
        pestType: _getPestType(_pestLabels[maxIndex]),
        damageLevel: _getDamageLevel(confidence),
        controlMethods: _getControlMethods(_pestLabels[maxIndex]),
        prevention: _getPreventionMethods(_pestLabels[maxIndex]),
      );
    } catch (e) {
      throw Exception('Pest detection failed: $e');
    }
  }

  // Load Models & Labels
  Future<void> _loadDiseaseModel() async {
    _diseaseInterpreter = await Interpreter.fromAsset(_diseaseModelPath);
    _diseaseLabels = await _loadLabels(_diseaseLabelsPath);
  }

  Future<void> _loadCropModel() async {
    _cropInterpreter = await Interpreter.fromAsset(_cropModelPath);
    _cropLabels = await _loadLabels(_cropLabelsPath);
  }

  Future<void> _loadSoilModel() async {
    _soilInterpreter = await Interpreter.fromAsset(_soilModelPath);
    _soilLabels = await _loadLabels(_soilLabelsPath);
  }

  Future<void> _loadPestModel() async {
    _pestInterpreter = await Interpreter.fromAsset(_pestModelPath);
    _pestLabels = await _loadLabels(_pestLabelsPath);
  }

  Future<List<String>> _loadLabels(String path) async {
    final labelData = await rootBundle.loadString(path);
    return labelData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
      File image, int width, int height) async {
    final bytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    final resizedImage = img.copyResize(decodedImage!, width: width, height: height);

    return [
      List.generate(height, (y) {
        return List.generate(width, (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        });
      }),
    ];
  }

  // Input data preparation
  List<List<double>> _prepareCropInputData(Map<String, dynamic> params) => [
        [
          (params['nitrogen'] as num? ?? 0).toDouble(),
          (params['phosphorus'] as num? ?? 0).toDouble(),
          (params['potassium'] as num? ?? 0).toDouble(),
          (params['temperature'] as num? ?? 0).toDouble(),
          (params['humidity'] as num? ?? 0).toDouble(),
          (params['ph'] as num? ?? 0).toDouble(),
          (params['rainfall'] as num? ?? 0).toDouble(),
        ]
      ];

  List<List<double>> _prepareSoilInputData(Map<String, dynamic> params) => [
        [
          (params['ph'] as num? ?? 0).toDouble(),
          (params['moisture'] as num? ?? 0).toDouble(),
          (params['organic_matter'] as num? ?? 0).toDouble(),
        ]
      ];

  // Helper methods for creating recommendations
  List<CropRecommendation> _createCropRecommendations(
      List<double> predictions, Map<String, dynamic> parameters) {
    final recommendations = <CropRecommendation>[];
    
    // Get top 3 predictions
    final indices = List.generate(predictions.length, (i) => i);
    indices.sort((a, b) => predictions[b].compareTo(predictions[a]));
    
    for (int i = 0; i < 3 && i < indices.length; i++) {
      final index = indices[i];
      final confidence = predictions[index];
      final cropName = _cropLabels[index];
      
      recommendations.add(CropRecommendation(
        cropName: cropName,
        confidence: confidence,
        suitabilityScore: confidence * 100,
        expectedYield: _getExpectedYield(cropName, parameters),
        growingPeriod: _getGrowingPeriod(cropName),
        waterRequirement: _getWaterRequirement(cropName),
        tips: _getCropTips(cropName),
      ));
    }
    
    return recommendations;
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
      'tomato': '70-90 days',
    };
    return periods[cropName.toLowerCase()] ?? '90-120 days';
  }

  String _getWaterRequirement(String cropName) {
    final requirements = {
      'rice': 'High (1200-1500mm)',
      'wheat': 'Medium (450-600mm)',
      'corn': 'Medium (500-700mm)',
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
    _diseaseInterpreter?.close();
    _cropInterpreter?.close();
    _soilInterpreter?.close();
    _pestInterpreter?.close();
  }
}