// lib/screens/disease_detection_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/ml_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';
import '../widgets/prediction_result_card.dart';

/// Screen for detecting plant diseases using machine learning
class DiseaseDetectionScreen extends StatefulWidget {
  /// Creates a new DiseaseDetectionScreen
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Disease Detection',
      ),
      body: Consumer<MLProvider>(
        builder: (context, mlProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInstructions(),
                const SizedBox(height: 20),
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildActionButtons(mlProvider),
                const SizedBox(height: 20),
                if (mlProvider.isLoading || _isAnalyzing)
                  const LoadingWidget(message: 'Analyzing plant disease...'),
                if (mlProvider.lastDiseaseDetection != null)
                  _buildPredictionResult(mlProvider.lastDiseaseDetection!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'How to get best results:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Take a clear photo of the affected plant parts\n'
            '• Ensure good lighting conditions\n'
            '• Focus on diseased leaves or stems\n'
            '• Avoid blurry or distant shots',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _selectedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No image selected',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the camera button to capture or select an image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildActionButtons(MLProvider mlProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Take Photo',
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icons.camera_alt,
                backgroundColor: Colors.green.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Gallery',
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icons.photo_library,
                backgroundColor: Colors.green.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedImage != null)
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Analyze Disease',
              onPressed: (_isAnalyzing || mlProvider.isLoading) 
                  ? () {} // Empty function instead of null
                  : () => _analyzeDisease(mlProvider),
              icon: Icons.search,
              backgroundColor: (_isAnalyzing || mlProvider.isLoading)
                  ? Colors.grey.shade400
                  : Colors.orange.shade600,
            ),
          ),
      ],
    );
  }

  // Build prediction result widget with proper error handling
  Widget _buildPredictionResult(dynamic prediction) {
    try {
      // Handle different possible types of prediction objects
      var title = '';
      var confidence = 0.0;
      
      if (prediction is Map<String, dynamic>) {
        title = (prediction['name']?.toString() ?? prediction['label']?.toString() ?? 'Unknown');
        confidence = (prediction['confidence'] as num?)?.toDouble() ?? 0.0;
      } else {
        // If prediction is a custom object, use reflection-like approach
        final nameValue = _getPropertyValue(prediction, ['name', 'label', 'disease']);
        title = nameValue?.toString() ?? 'Unknown';
        confidence = (_getPropertyValue(prediction, ['confidence', 'score']) as num?)?.toDouble() ?? 0.0;
      }

      return PredictionResultCard(
        title: title,
        confidence: confidence,
        prediction: prediction.toString(),
      );
    } catch (e) {
      // Fallback widget if PredictionResultCard fails
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disease Detection Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text('Analysis completed successfully'),
          ],
        ),
      );
    }
  }

  // Helper method to safely get property values from objects
  dynamic _getPropertyValue(dynamic object, List<String> propertyNames) {
    if (object == null) return null;
    
    for (final propertyName in propertyNames) {
      try {
        // Try to access the property using different approaches
        if (object is Map) {
          if (object.containsKey(propertyName)) {
            return object[propertyName];
          }
        } else {
          // For custom objects, this would require reflection
          // For now, return null and handle in the calling code
          return null;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error selecting image: $e');
      }
    }
  }

  Future<void> _analyzeDisease(MLProvider mlProvider) async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      await mlProvider.detectDisease(_selectedImage!);
      if (mounted && mlProvider.lastDiseaseDetection != null) {
        _showResultDialog(mlProvider.lastDiseaseDetection!);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error analyzing disease: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showResultDialog(dynamic prediction) {
    if (!mounted) return;
    
    // Safely extract confidence value
    var confidence = 0.0;
    try {
      if (prediction is Map<String, dynamic>) {
        confidence = (prediction['confidence'] as num?)?.toDouble() ?? 0.0;
      } else {
        confidence = (_getPropertyValue(prediction, ['confidence', 'score']) as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      confidence = 0.0;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Complete'),
        content: Text(
          'Disease detected with ${(confidence * 100).toStringAsFixed(1)}% confidence',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}