// lib/screens/disease_detection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/ml_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';
import '../widgets/prediction_result_card.dart';
import '../widgets/image_picker_widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

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
        showBackButton: true,
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
                  PredictionResultCard(
                    prediction: mlProvider.lastDiseaseDetection!,
                    type: 'disease',
                  ),
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
        color: AppColors.lightGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'How to get best results:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
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
                backgroundColor: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Gallery',
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icons.photo_library,
                backgroundColor: AppColors.lightGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedImage != null)
          CustomButton(
            text: 'Analyze Disease',
            onPressed: _isAnalyzing ? null : () => _analyzeDisease(mlProvider),
            icon: Icons.search,
            backgroundColor: AppColors.accentOrange,
            isFullWidth: true,
          ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Error selecting image: $e');
    }
  }

  Future<void> _analyzeDisease(MLProvider mlProvider) async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      await mlProvider.detectDisease(_selectedImage!);
      if (mlProvider.lastDiseaseDetection != null) {
        _showResultDialog(mlProvider.lastDiseaseDetection!);
      }
    } catch (e) {
      _showErrorDialog('Error analyzing disease: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showResultDialog(dynamic prediction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Complete'),
        content: Text(
          'Disease detected with ${(prediction.confidence * 100).toStringAsFixed(1)}% confidence',
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
    showDialog(
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