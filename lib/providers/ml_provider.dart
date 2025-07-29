// lib/providers/ml_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/disease_model.dart';
import '../models/prediction_model.dart';
import '../services/ml_service.dart';

class MLProvider with ChangeNotifier {
  final MLService _mlService = MLService();
  
  bool _isLoading = false;
  String? _error;
  DiseaseDetection? _lastDiseaseDetection;
  CropPrediction? _lastCropPrediction;
  SoilAnalysis? _lastSoilAnalysis;
  PestDetection? _lastPestDetection;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  DiseaseDetection? get lastDiseaseDetection => _lastDiseaseDetection;
  CropPrediction? get lastCropPrediction => _lastCropPrediction;
  SoilAnalysis? get lastSoilAnalysis => _lastSoilAnalysis;
  PestDetection? get lastPestDetection => _lastPestDetection;

  // Disease Detection
  Future<void> detectDisease(File imageFile) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _mlService.detectPlantDisease(imageFile);
      _lastDiseaseDetection = result;
      notifyListeners();
    } catch (e) {
      _setError('Failed to detect disease: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Crop Prediction
  Future<void> predictCrop(Map<String, dynamic> parameters) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _mlService.predictCrop(parameters);
      _lastCropPrediction = result;
      notifyListeners();
    } catch (e) {
      _setError('Failed to predict crop: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Soil Analysis
  Future<void> analyzeSoil(Map<String, dynamic> parameters) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _mlService.analyzeSoil(parameters);
      _lastSoilAnalysis = result;
      notifyListeners();
    } catch (e) {
      _setError('Failed to analyze soil: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Pest Detection
  Future<void> detectPest(File imageFile) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _mlService.detectPest(imageFile);
      _lastPestDetection = result;
      notifyListeners();
    } catch (e) {
      _setError('Failed to detect pest: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get Disease History
  Future<List<DiseaseDetection>> getDiseaseHistory() async {
    try {
      return await _mlService.getDiseaseHistory();
    } catch (e) {
      _setError('Failed to load disease history: $e');
      return [];
    }
  }

  // Get Crop Prediction History
  Future<List<CropPrediction>> getCropPredictionHistory() async {
    try {
      return await _mlService.getCropPredictionHistory();
    } catch (e) {
      _setError('Failed to load crop prediction history: $e');
      return [];
    }
  }

  // Clear all data
  void clearAllData() {
    _lastDiseaseDetection = null;
    _lastCropPrediction = null;
    _lastSoilAnalysis = null;
    _lastPestDetection = null;
    _clearError();
    notifyListeners();
  }

  // Clear specific prediction
  void clearDiseaseDetection() {
    _lastDiseaseDetection = null;
    notifyListeners();
  }

  void clearCropPrediction() {
    _lastCropPrediction = null;
    notifyListeners();
  }

  void clearSoilAnalysis() {
    _lastSoilAnalysis = null;
    notifyListeners();
  }

  void clearPestDetection() {
    _lastPestDetection = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }
}