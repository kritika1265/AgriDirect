// lib/services/ml/disease_detector.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'tflite_helper.dart';

class DiseaseDetector {
  static final DiseaseDetector _instance = DiseaseDetector._internal();
  factory DiseaseDetector() => _instance;
  DiseaseDetector._internal();

  static const String _modelName = 'disease_detector';
  static const String _modelPath = 'assets/models/plant_disease_model.tflite';
  static const String _labelsPath = 'assets/models/disease_labels.txt';
  static const int _inputSize = 224;

  final TFLiteHelper _tfliteHelper = TFLiteHelper();
  bool _isInitialized = false;

  /// Initialize the disease detection model
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final success = await _tfliteHelper.loadModel(
        _modelName,
        _modelPath,
        labelsPath: _labelsPath,
      );
      
      _isInitialized = success;
      return success;
    } catch (e) {
      print('Error initializing disease detector: $e');
      return false;
    }
  }

  /// Detect diseases in plant image
  Future<DiseaseDetectionResult> detectDisease(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Disease detector not initialized');
    }

    try {
      // Load and preprocess image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Could not decode image');
      }

      // Preprocess image for the model
      final input = _tfliteHelper.preprocessImage(
        image,
        inputWidth: _inputSize,
        inputHeight: _inputSize,
        normalize: true,
        mean: 127.5,
        std: 127.5,
      );

      // Run inference
      final output = _tfliteHelper.runInference(
        _modelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      // Apply softmax to get probabilities
      final probabilities = _tfliteHelper.applySoftmax(output[0]);

      // Get top predictions
      final predictions = _tfliteHelper.getTopPredictions(
        probabilities,
        _modelName,
        topK: 3,
        threshold: 0.05,
      );

      return DiseaseDetectionResult(
        isHealthy: _isHealthyPlant(predictions),
        topPrediction: predictions.isNotEmpty ? predictions.first : null,
        allPredictions: predictions,
        confidence: predictions.isNotEmpty ? predictions.first.confidence : 0.0,
        processingTime: DateTime.now(),
      );

    } catch (e) {
      print('Error detecting disease: $e');
      return DiseaseDetectionResult(
        isHealthy: false,
        topPrediction: null,
        allPredictions: [],
        confidence: 0.0,
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Batch process multiple images
  Future<List<DiseaseDetectionResult>> detectDiseaseBatch(List<String> imagePaths) async {
    final results = <DiseaseDetectionResult>[];
    
    for (final imagePath in imagePaths) {
      final result = await detectDisease(imagePath);
      results.add(result);
    }
    
    return results;
  }

  /// Check if the plant is healthy based on predictions
  bool _isHealthyPlant(List<Prediction> predictions) {
    if (predictions.isEmpty) return false;
    
    final topPrediction = predictions.first;
    return topPrediction.label.toLowerCase().contains('healthy') ||
           topPrediction.label.toLowerCase().contains('normal');
  }

  /// Get disease severity based on confidence
  DiseaseSeverity getDiseaseSeverity(double confidence) {
    if (confidence < 0.3) return DiseaseSeverity.uncertain;
    if (confidence < 0.6) return DiseaseSeverity.mild;
    if (confidence < 0.8) return DiseaseSeverity.moderate;
    return DiseaseSeverity.severe;
  }

  /// Get treatment recommendations based on disease
  List<String> getTreatmentRecommendations(String diseaseLabel) {
    final disease = diseaseLabel.toLowerCase();
    
    // Basic treatment recommendations (expand based on your disease categories)
    final treatments = <String, List<String>>{
      'bacterial_spot': [
        'Apply copper-based fungicide',
        'Improve air circulation',
        'Avoid overhead watering',
        'Remove infected leaves'
      ],
      'early_blight': [
        'Apply preventive fungicide',
        'Ensure proper spacing between plants',
        'Water at soil level',
        'Remove plant debris'
      ],
      'late_blight': [
        'Apply systemic fungicide immediately',
        'Improve drainage',
        'Avoid overhead irrigation',
        'Destroy infected plants'
      ],
      'leaf_mold': [
        'Increase ventilation',
        'Reduce humidity',
        'Apply appropriate fungicide',
        'Remove lower leaves'
      ],
      'powdery_mildew': [
        'Apply sulfur or potassium bicarbonate',
        'Improve air circulation',
        'Avoid overhead watering',
        'Prune affected areas'
      ],
    };

    // Find matching disease
    for (final key in treatments.keys) {
      if (disease.contains(key.replaceAll('_', ' ')) || 
          disease.contains(key.replaceAll('_', ''))) {
        return treatments[key]!;
      }
    }

    // Default recommendations
    return [
      'Consult with local agricultural extension office',
      'Improve plant hygiene',
      'Monitor plant regularly',
      'Apply appropriate treatment based on symptoms'
    ];
  }

  /// Get prevention tips
  List<String> getPreventionTips() {
    return [
      'Plant disease-resistant varieties',
      'Maintain proper plant spacing',
      'Ensure good air circulation',
      'Water at soil level, not on leaves',
      'Remove plant debris regularly',
      'Rotate crops annually',
      'Monitor plants regularly for early detection',
      'Maintain soil health with organic matter',
    ];
  }

  /// Dispose resources
  void dispose() {
    _tfliteHelper.disposeModel(_modelName);
    _isInitialized = false;
  }
}

class DiseaseDetectionResult {
  final bool isHealthy;
  final Prediction? topPrediction;
  final List<Prediction> allPredictions;
  final double confidence;
  final DateTime processingTime;
  final String? error;

  DiseaseDetectionResult({
    required this.isHealthy,
    required this.topPrediction,
    required this.allPredictions,
    required this.confidence,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;
  
  String get diseaseLabel => topPrediction?.label ?? 'Unknown';
  
  DiseaseSeverity get severity {
    return DiseaseDetector().getDiseaseSeverity(confidence);
  }

  List<String> get treatmentRecommendations {
    if (isHealthy) return ['Plant appears healthy! Continue good care practices.'];
    return DiseaseDetector().getTreatmentRecommendations(diseaseLabel);
  }

  Map<String, dynamic> toJson() => {
    'isHealthy': isHealthy,
    'diseaseLabel': diseaseLabel,
    'confidence': confidence,
    'severity': severity.toString(),
    'predictions': allPredictions.map((p) => p.toJson()).toList(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };

  @override
  String toString() {
    if (hasError) return 'DiseaseDetectionResult(error: $error)';
    return 'DiseaseDetectionResult(healthy: $isHealthy, disease: $diseaseLabel, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

enum DiseaseSeverity {
  uncertain,
  mild,
  moderate,
  severe,
}

extension DiseaseSeverityExtension on DiseaseSeverity {
  String get displayName {
    switch (this) {
      case DiseaseSeverity.uncertain:
        return 'Uncertain';
      case DiseaseSeverity.mild:
        return 'Mild';
      case DiseaseSeverity.moderate:
        return 'Moderate';
      case DiseaseSeverity.severe:
        return 'Severe';
    }
  }

  String get description {
    switch (this) {
      case DiseaseSeverity.uncertain:
        return 'Prediction confidence is low. Consider retaking photo or consulting expert.';
      case DiseaseSeverity.mild:
        return 'Early stage disease detected. Early intervention recommended.';
      case DiseaseSeverity.moderate:
        return 'Moderate disease symptoms. Treatment should be applied soon.';
      case DiseaseSeverity.severe:
        return 'Advanced disease symptoms. Immediate treatment required.';
    }
  }
}