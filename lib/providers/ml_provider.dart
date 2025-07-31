// lib/providers/ml_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/disease_model.dart';
import '../models/prediction_model.dart';
import '../services/ml_service.dart';

/// Provider class for managing ML operations and state
class MLProvider with ChangeNotifier {
  final MLService _mlService = MLService();
  
  bool _isLoading = false;
  String? _error;
  DiseaseDetection? _lastDiseaseDetection;
  CropPrediction? _lastCropPrediction;
  SoilAnalysis? _lastSoilAnalysis;
  PestDetection? _lastPestDetection;

  /// Whether an ML operation is currently in progress
  bool get isLoading => _isLoading;
  
  /// Current error message, if any
  String? get error => _error;
  
  /// Last disease detection result
  DiseaseDetection? get lastDiseaseDetection => _lastDiseaseDetection;
  
  /// Last crop prediction result
  CropPrediction? get lastCropPrediction => _lastCropPrediction;
  
  /// Last soil analysis result
  SoilAnalysis? get lastSoilAnalysis => _lastSoilAnalysis;
  
  /// Last pest detection result
  PestDetection? get lastPestDetection => _lastPestDetection;

  /// Detect plant disease from image file
  Future<void> detectDisease(File imageFile) async {
    if (_isLoading) {
      return;
    }
    
    _setLoading(true);
    _clearError();

    try {
      // Validate file exists
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist');
      }

      final result = await _mlService.detectPlantDisease(imageFile);
      _lastDiseaseDetection = result;
    } catch (e) {
      _setError('Failed to detect disease: ${e.toString()}');
      if (kDebugMode) {
        print('Disease detection error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Predict optimal crop based on parameters
  Future<void> predictCrop(Map<String, dynamic> parameters) async {
    if (_isLoading) {
      return;
    }
    
    _setLoading(true);
    _clearError();

    try {
      // Validate parameters
      if (parameters.isEmpty) {
        throw Exception('Parameters cannot be empty');
      }

      final result = await _mlService.predictCrop(parameters);
      _lastCropPrediction = result;
    } catch (e) {
      _setError('Failed to predict crop: ${e.toString()}');
      if (kDebugMode) {
        print('Crop prediction error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Analyze soil conditions (placeholder - implement if MLService supports it)
  Future<void> analyzeSoil(Map<String, dynamic> parameters) async {
    if (_isLoading) {
      return;
    }
    
    _setLoading(true);
    _clearError();

    try {
      // Check if MLService has analyzeSoil method
      // For now, we'll create a placeholder implementation
      _setError('Soil analysis feature not yet implemented in MLService');
      
      // TODO: Implement when MLService.analyzeSoil() is available
      // final result = await _mlService.analyzeSoil(parameters);
      // _lastSoilAnalysis = result;
    } catch (e) {
      _setError('Failed to analyze soil: ${e.toString()}');
      if (kDebugMode) {
        print('Soil analysis error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Detect pests from image (placeholder - implement if MLService supports it)
  Future<void> detectPest(File imageFile) async {
    if (_isLoading) {
      return;
    }
    
    _setLoading(true);
    _clearError();

    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist');
      }

      // TODO: Implement when MLService.detectPest() is available
      _setError('Pest detection feature not yet implemented in MLService');
      
      // final result = await _mlService.detectPest(imageFile);
      // _lastPestDetection = result;
    } catch (e) {
      _setError('Failed to detect pest: ${e.toString()}');
      if (kDebugMode) {
        print('Pest detection error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Get disease detection history (placeholder)
  Future<List<DiseaseDetection>> getDiseaseHistory() async {
    try {
      // TODO: Implement when MLService.getDiseaseHistory() is available
      _setError('Disease history feature not yet implemented');
      return [];
      
      // return await _mlService.getDiseaseHistory() ?? [];
    } catch (e) {
      _setError('Failed to load disease history: ${e.toString()}');
      if (kDebugMode) {
        print('Disease history error: $e');
      }
      return [];
    }
  }

  /// Get crop prediction history (placeholder)
  Future<List<CropPrediction>> getCropPredictionHistory() async {
    try {
      // TODO: Implement when MLService.getCropPredictionHistory() is available
      _setError('Crop prediction history feature not yet implemented');
      return [];
      
      // return await _mlService.getCropPredictionHistory() ?? [];
    } catch (e) {
      _setError('Failed to load crop prediction history: ${e.toString()}');
      if (kDebugMode) {
        print('Crop prediction history error: $e');
      }
      return [];
    }
  }

  /// Get soil analysis history (placeholder)
  Future<List<SoilAnalysis>> getSoilAnalysisHistory() async {
    try {
      // TODO: Implement when MLService supports it
      return [];
    } catch (e) {
      _setError('Failed to load soil analysis history: ${e.toString()}');
      return [];
    }
  }

  /// Get pest detection history (placeholder)
  Future<List<PestDetection>> getPestDetectionHistory() async {
    try {
      // TODO: Implement when MLService supports it
      return [];
    } catch (e) {
      _setError('Failed to load pest detection history: ${e.toString()}');
      return [];
    }
  }

  /// Clear all stored results and errors
  void clearAllData() {
    _lastDiseaseDetection = null;
    _lastCropPrediction = null;
    _lastSoilAnalysis = null;
    _lastPestDetection = null;
    _clearError();
    notifyListeners();
  }

  /// Clear disease detection result
  void clearDiseaseDetection() {
    _lastDiseaseDetection = null;
    notifyListeners();
  }

  /// Clear crop prediction result
  void clearCropPrediction() {
    _lastCropPrediction = null;
    notifyListeners();
  }

  /// Clear soil analysis result
  void clearSoilAnalysis() {
    _lastSoilAnalysis = null;
    notifyListeners();
  }

  /// Clear pest detection result
  void clearPestDetection() {
    _lastPestDetection = null;
    notifyListeners();
  }

  /// Retry the last failed operation
  Future<void> retryLastOperation() async {
    _clearError();
    // Implementation depends on storing last operation details
  }

  /// Check if ML service is available
  Future<bool> isServiceAvailable() async {
    try {
      // Simple check - try to create service instance
      return _mlService != null;
    } catch (e) {
      if (kDebugMode) {
        print('Service availability check error: $e');
      }
      return false;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // MLService disposal will be handled when the method exists
    super.dispose();
  }
}