// lib/services/ml_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/disease_model.dart';
import '../models/prediction_model.dart';
import '../services/storage_service.dart';

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

  final StorageService _storageService = StorageService();

  // Initialize all models
  Future<void> initialize() async {
    await _loadDiseaseModel();
    await _loadCropModel();
    await _loadSoilModel();
    await _loadPestModel();
  }

  // Disease Detection
  Future<DiseaseDetection> detectPlantDisease(File imageFile) async {
    if (_diseaseInterpreter == null) {
      await _loadDiseaseModel();
    }

    try {
      // Preprocess image
      final inputImage = await _preprocessImage(imageFile, 224, 224);
      
      // Run inference
      final output = List.filled(1 * _diseaseLabels.length, 0.0).reshape([1, _diseaseLabels.length]);
      _diseaseInterpreter!.run(inputImage, output);

      // Process results
      final predictions = output[0] as List<double>;
      final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      final confidence = predictions[maxIndex];

      final result = DiseaseDetection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        diseaseName: _diseaseLabels[maxIndex],
        confidence: confidence,
        imagePath: imageFile.path,
        detectedAt: DateTime.now(),
        symptoms: _getDiseaseSymptoms(_diseaseLabels[maxIndex]),
        treatment: _getDiseaseTreatment(_diseaseLabels[maxIndex]),
        severity: _getDiseaseSeverity(confidence),
      );

      // Save to local storage
      await _storageService.saveDiseaseDetection(result);
      
      return result;
    } catch (e) {
      throw Exception('Disease detection failed: $e');
    }
  }

  // Crop Prediction
  Future<CropPrediction> predictCrop(Map<String, dynamic> parameters) async {
    if (_cropInterpreter == null) {
      await _loadCropModel();
    }

    try {
      // Prepare input data
      final inputData = _prepareCropInputData(parameters);
      
      // Run inference
      final output = List.filled(1 * _cropLabels.length, 0.0).reshape([1, _cropLabels.length]);
      _cropInterpreter!.run(inputData, output);

      // Process results
      final predictions = output[0] as List<double