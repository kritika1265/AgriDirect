// lib/services/ml/tflite_helper.dart
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// A helper class for managing TensorFlow Lite models in Flutter applications.
/// Provides functionality to load models, preprocess images, run inference, and manage predictions.
class TFLiteHelper {
  /// Private constructor for singleton pattern
  TFLiteHelper._internal();
  
  static final TFLiteHelper _instance = TFLiteHelper._internal();
  
  /// Factory constructor that returns the singleton instance
  factory TFLiteHelper() => _instance;

  final Map<String, Interpreter> _interpreters = {};
  final Map<String, List<String>> _labels = {};

  /// Initialize a TensorFlow Lite model
  Future<bool> loadModel(String modelName, String modelPath, {String? labelsPath}) async {
    try {
      // Load the model
      final modelFile = await _loadModelFile(modelPath);
      final interpreter = Interpreter.fromBuffer(modelFile);
      _interpreters[modelName] = interpreter;

      // Load labels if provided
      if (labelsPath != null) {
        final labels = await _loadLabels(labelsPath);
        _labels[modelName] = labels;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load model file from assets
  Future<Uint8List> _loadModelFile(String modelPath) async {
    final data = await rootBundle.load(modelPath);
    return data.buffer.asUint8List();
  }

  /// Load labels from assets
  Future<List<String>> _loadLabels(String labelsPath) async {
    final data = await rootBundle.loadString(labelsPath);
    return data.split('\n').where((line) => line.isNotEmpty).toList();
  }

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

  /// Run inference on preprocessed input
  List<List<double>> runInference(String modelName, Float32List input, List<int> outputShape) {
    final interpreter = _interpreters[modelName];
    if (interpreter == null) {
      throw Exception('Model $modelName not loaded');
    }

    // Prepare input tensor
    final inputTensor = input.reshape([1, outputShape[1], outputShape[2], 3]);
    
    // Prepare output tensor - ensure it's List<List<double>>
    final outputTensor = List<List<double>>.generate(
      outputShape[0],
      (_) => List<double>.filled(outputShape[1], 0.0),
    );

    // Run inference
    interpreter.run(inputTensor, outputTensor);
    
    return outputTensor;
  }

  /// Get top predictions with confidence scores
  List<Prediction> getTopPredictions(
    List<double> output,
    String modelName, {
    int topK = 5,
    double threshold = 0.1,
  }) {
    final labels = _labels[modelName] ?? [];
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

  /// Dispose specific model
  void disposeModel(String modelName) {
    final interpreter = _interpreters.remove(modelName);
    interpreter?.close();
    _labels.remove(modelName);
  }

  /// Dispose all models
  void disposeAll() {
    for (final interpreter in _interpreters.values) {
      interpreter.close();
    }
    _interpreters.clear();
    _labels.clear();
  }

  /// Get model info
  Map<String, dynamic> getModelInfo(String modelName) {
    final interpreter = _interpreters[modelName];
    if (interpreter == null) {
      return {};
    }

    return {
      'inputShape': interpreter.getInputTensor(0).shape,
      'outputShape': interpreter.getOutputTensor(0).shape,
      'inputType': interpreter.getInputTensor(0).type.toString(),
      'outputType': interpreter.getOutputTensor(0).type.toString(),
      'labelsCount': _labels[modelName]?.length ?? 0,
    };
  }
}

/// Represents a prediction result with label, confidence score, and index
class Prediction {
  /// Constructor for creating a prediction
  Prediction({
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
          List<double>.filled(shape[3], 0.0)
        )
      )
    );

    var index = 0;
    for (var i = 0; i < shape[0]; i++) {
      for (var j = 0; j < shape[1]; j++) {
        for (var k = 0; k < shape[2]; k++) {
          for (var l = 0; l < shape[3]; l++) {
            result[i][j][k][l] = this[index++];
          }
        }
      }
    }

    return result;
  }
}