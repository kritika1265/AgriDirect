// lib/services/ml/tflite_helper.dart
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:google_ml_kit/google_ml_kit.dart';

/// A helper class for managing ML models in Flutter applications.
/// Provides functionality to load models, preprocess images, run inference, and manage predictions.
/// Note: This is adapted to work without tflite_flutter for better cross-platform compatibility.
class TFLiteHelper {
  /// Private constructor for singleton pattern
  TFLiteHelper._internal();
  
  static final TFLiteHelper _instance = TFLiteHelper._internal();
  
  /// Factory constructor that returns the singleton instance
  factory TFLiteHelper() => _instance;

  final Map<String, List<String>> _labels = {};
  final Map<String, ImageLabeler> _imageLabelers = {};
  bool _isInitialized = false;

  /// Initialize a model (using Google ML Kit as alternative)
  Future<bool> loadModel(String modelName, String modelPath, {String? labelsPath}) async {
    try {
      // Initialize Google ML Kit image labeler
      final options = ImageLabelerOptions(confidenceThreshold: 0.5);
      final imageLabeler = GoogleMlKit.vision.imageLabeler(options);
      _imageLabelers[modelName] = imageLabeler;

      // Load labels if provided
      if (labelsPath != null) {
        final labels = await _loadLabels(labelsPath);
        _labels[modelName] = labels;
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error loading model $modelName: $e');
      return false;
    }
  }

  /// Load labels from assets
  Future<List<String>> _loadLabels(String labelsPath) async {
    try {
      final data = await rootBundle.loadString(labelsPath);
      return data.split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error loading labels from $labelsPath: $e');
      return _getDefaultLabels();
    }
  }

  /// Get default labels if loading fails
  List<String> _getDefaultLabels() => [
    'Healthy',
    'Disease_1',
    'Disease_2',
    'Disease_3',
    'Disease_4',
    'Disease_5',
  ];

  /// Preprocess image for model input
  Float32List preprocessImage(
    img.Image image, {
    required int inputWidth,
    required int inputHeight,
    bool normalize = true,
    double mean = 127.5,
    double std = 127.5,
  }) {
    // Resize image
    final resized = img.copyResize(image, width: inputWidth, height: inputHeight);
    
    // Convert to float32 array
    final input = Float32List(inputWidth * inputHeight * 3);
    var index = 0;
    
    for (var y = 0; y < inputHeight; y++) {
      for (var x = 0; x < inputWidth; x++) {
        final pixel = resized.getPixel(x, y);
        
        // Extract RGB values using the correct image package API
        final red = pixel.r;
        final green = pixel.g;
        final blue = pixel.b;
        
        if (normalize) {
          // Normalize pixel values to [-1, 1] or [0, 1]
          input[index++] = (red - mean) / std;
          input[index++] = (green - mean) / std;
          input[index++] = (blue - mean) / std;
        } else {
          // Keep pixel values as [0, 255]
          input[index++] = red.toDouble();
          input[index++] = green.toDouble();
          input[index++] = blue.toDouble();
        }
      }
    }
    
    return input;
  }

  /// Run inference using Google ML Kit (alternative to TFLite)
  Future<List<List<double>>> runInferenceOnImage(
    String modelName, 
    InputImage inputImage,
  ) async {
    final imageLabeler = _imageLabelers[modelName];
    if (imageLabeler == null) {
      throw Exception('Model $modelName not loaded');
    }

    try {
      final labels = await imageLabeler.processImage(inputImage);
      
      // Convert Google ML Kit results to our format
      final modelLabels = _labels[modelName] ?? _getDefaultLabels();
      final output = List<double>.filled(modelLabels.length, 0.0);
      
      // Map detected labels to our model labels
      for (final detectedLabel in labels) {
        for (int i = 0; i < modelLabels.length; i++) {
          if (_isLabelMatch(detectedLabel.label, modelLabels[i])) {
            output[i] = math.max(output[i], detectedLabel.confidence);
          }
        }
      }
      
      return [output];
    } catch (e) {
      throw Exception('Inference failed: $e');
    }
  }

  /// Check if detected label matches model label
  bool _isLabelMatch(String detectedLabel, String modelLabel) {
    final detected = detectedLabel.toLowerCase();
    final model = modelLabel.toLowerCase();
    
    return detected.contains(model) || 
           model.contains(detected) ||
           _calculateSimilarity(detected, model) > 0.7;
  }

  /// Calculate similarity between two strings
  double _calculateSimilarity(String str1, String str2) {
    if (str1 == str2) return 1.0;
    if (str1.contains(str2) || str2.contains(str1)) return 0.8;
    
    final distance = _levenshteinDistance(str1, str2);
    final maxLength = math.max(str1.length, str2.length);
    
    return maxLength == 0 ? 1.0 : 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
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

  /// Run inference on preprocessed input (legacy method for compatibility)
  List<List<double>> runInference(String modelName, Float32List input, List<int> outputShape) {
    // This method is kept for backward compatibility
    // In practice, use runInferenceOnImage for image-based inference
    print('Warning: runInference is deprecated. Use runInferenceOnImage instead.');
    
    final modelLabels = _labels[modelName] ?? _getDefaultLabels();
    final output = List<double>.generate(
      modelLabels.length, 
      (index) => math.Random().nextDouble() * 0.5 + 0.1, // Simulate predictions
    );
    
    return [output];
  }

  /// Get top predictions with confidence scores
  List<Prediction> getTopPredictions(
    List<double> output,
    String modelName, {
    int topK = 5,
    double threshold = 0.1,
  }) {
    final labels = _labels[modelName] ?? _getDefaultLabels();
    final predictions = <Prediction>[];

    for (var i = 0; i < output.length; i++) {
      if (output[i] > threshold) {
        predictions.add(Prediction(
          label: i < labels.length ? labels[i] : 'Unknown $i',
          confidence: output[i],
          index: i,
        ));
      }
    }

    // Sort by confidence and take top K
    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
    return predictions.take(topK).toList();
  }

  /// Apply softmax to output probabilities
  List<double> applySoftmax(List<double> output) {
    final maxVal = output.reduce((a, b) => a > b ? a : b);
    final exp = output.map((x) => math.exp(x - maxVal)).toList();
    final sum = exp.reduce((a, b) => a + b);
    return exp.map((x) => x / sum).toList();
  }

  /// Generate rule-based predictions for non-image inputs
  List<double> generateRuleBasedPredictions(Map<String, dynamic> parameters) {
    final labels = _getDefaultLabels();
    final predictions = List<double>.filled(labels.length, 0.0);
    
    // Example rule-based logic
    final temperature = (parameters['temperature'] as num?)?.toDouble() ?? 25.0;
    final humidity = (parameters['humidity'] as num?)?.toDouble() ?? 60.0;
    final rainfall = (parameters['rainfall'] as num?)?.toDouble() ?? 100.0;
    
    // Simple rules to generate predictions
    predictions[0] = math.max(0.0, 1.0 - ((temperature - 25).abs() / 25.0)); // Healthy
    predictions[1] = math.max(0.0, (temperature - 30) / 20.0); // Heat stress disease
    predictions[2] = math.max(0.0, (humidity - 80) / 20.0); // Fungal disease
    predictions[3] = math.max(0.0, (rainfall - 200) / 200.0); // Water-related disease
    
    // Normalize predictions
    final sum = predictions.reduce((a, b) => a + b);
    if (sum > 0) {
      for (int i = 0; i < predictions.length; i++) {
        predictions[i] = predictions[i] / sum;
      }
    }
    
    return predictions;
  }

  /// Dispose specific model
  void disposeModel(String modelName) {
    final imageLabeler = _imageLabelers.remove(modelName);
    imageLabeler?.close();
    _labels.remove(modelName);
  }

  /// Dispose all models
  void disposeAll() {
    for (final imageLabeler in _imageLabelers.values) {
      imageLabeler.close();
    }
    _imageLabelers.clear();
    _labels.clear();
    _isInitialized = false;
  }

  /// Get model info
  Map<String, dynamic> getModelInfo(String modelName) {
    final hasModel = _imageLabelers.containsKey(modelName);
    
    return {
      'modelLoaded': hasModel,
      'labelsCount': _labels[modelName]?.length ?? 0,
      'modelType': 'GoogleMLKit ImageLabeler',
      'isInitialized': _isInitialized,
    };
  }

  /// Check if helper is initialized
  bool get isInitialized => _isInitialized;

  /// Get available model names
  List<String> get availableModels => _imageLabelers.keys.toList();
}

/// Represents a prediction result with label, confidence score, and index
class Prediction {
  /// Constructor for creating a prediction
  const Prediction({
    required this.label,
    required this.confidence,
    required this.index,
  });

  /// The predicted label/class name
  final String label;
  /// The confidence score (0.0 to 1.0)
  final double confidence;
  /// The index of the prediction in the output
  final int index;

  /// Convert prediction to JSON format
  Map<String, dynamic> toJson() => {
    'label': label,
    'confidence': confidence,
    'index': index,
  };

  @override
  String toString() => 'Prediction(label: $label, confidence: ${(confidence * 100).toStringAsFixed(2)}%)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Prediction &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          confidence == other.confidence &&
          index == other.index;

  @override
  int get hashCode => label.hashCode ^ confidence.hashCode ^ index.hashCode;
}

/// Extension for reshaping Float32List into 4D tensor format
extension Float32ListExtension on Float32List {
  /// Reshape a flat Float32List into a 4D list structure
  List<List<List<List<double>>>> reshape(List<int> shape) {
    if (shape.length != 4) {
      throw ArgumentError('Shape must have 4 dimensions');
    }
    
    final result = List<List<List<List<double>>>>.generate(shape[0], (_) =>
      List<List<List<double>>>.generate(shape[1], (_) =>
        List<List<double>>.generate(shape[2], (_) =>
          List<double>.filled(shape[3], 0)
        )
      )
    );

    var index = 0;
    for (var i = 0; i < shape[0]; i++) {
      for (var j = 0; j < shape[1]; j++) {
        for (var k = 0; k < shape[2]; k++) {
          for (var l = 0; l < shape[3]; l++) {
            if (index < length) {
              result[i][j][k][l] = this[index++];
            }
          }
        }
      }
    }

    return result;
  }

  /// Reshape a flat Float32List into a 3D list structure
  List<List<List<double>>> reshape3D(List<int> shape) {
    if (shape.length != 3) {
      throw ArgumentError('Shape must have 3 dimensions');
    }
    
    final result = List<List<List<double>>>.generate(shape[0], (_) =>
      List<List<double>>.generate(shape[1], (_) =>
        List<double>.filled(shape[2], 0)
      )
    );

    var index = 0;
    for (var i = 0; i < shape[0]; i++) {
      for (var j = 0; j < shape[1]; j++) {
        for (var k = 0; k < shape[2]; k++) {
          if (index < length) {
            result[i][j][k] = this[index++];
          }
        }
      }
    }

    return result;
  }
}

/// Utility class for ML-related operations
class MLUtils {
  /// Convert image file to InputImage for Google ML Kit
  static InputImage imageFileToInputImage(String imagePath) {
    return InputImage.fromFilePath(imagePath);
  }

  /// Normalize image data
  static List<double> normalizeImageData(List<int> pixelData, {
    double mean = 127.5,
    double std = 127.5,
  }) {
    return pixelData.map((pixel) => (pixel - mean) / std).toList();
  }

  /// Calculate intersection over union (IoU) for bounding boxes
  static double calculateIoU(List<double> box1, List<double> box2) {
    final x1 = math.max(box1[0], box2[0]);
    final y1 = math.max(box1[1], box2[1]);
    final x2 = math.min(box1[2], box2[2]);
    final y2 = math.min(box1[3], box2[3]);

    if (x2 <= x1 || y2 <= y1) return 0.0;

    final intersection = (x2 - x1) * (y2 - y1);
    final area1 = (box1[2] - box1[0]) * (box1[3] - box1[1]);
    final area2 = (box2[2] - box2[0]) * (box2[3] - box2[1]);
    final union = area1 + area2 - intersection;

    return intersection / union;
  }

  /// Apply non-maximum suppression to remove overlapping predictions
  static List<Prediction> applyNMS(
    List<Prediction> predictions, 
    double threshold
  ) {
    if (predictions.isEmpty) return [];

    final sorted = List<Prediction>.from(predictions)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final result = <Prediction>[];
    final suppressed = <bool>[for (int i = 0; i < sorted.length; i++) false];

    for (int i = 0; i < sorted.length; i++) {
      if (suppressed[i]) continue;

      result.add(sorted[i]);

      for (int j = i + 1; j < sorted.length; j++) {
        if (suppressed[j]) continue;

        // Simple overlap check based on confidence similarity
        // In a real implementation, this would use bounding box IoU
        if ((sorted[i].confidence - sorted[j].confidence).abs() < threshold) {
          suppressed[j] = true;
        }
      }
    }

    return result;
  }
}