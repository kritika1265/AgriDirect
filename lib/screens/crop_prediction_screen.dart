// lib/screens/crop_prediction_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ml_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../widgets/prediction_result_card.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class CropPredictionScreen extends StatefulWidget {
  const CropPredictionScreen({Key? key}) : super(key: key);

  @override
  State<CropPredictionScreen> createState() => _CropPredictionScreenState();
}

class _CropPredictionScreenState extends State<CropPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();

  String? _selectedSoilType;
  String? _selectedSeason;

  final List<String> _soilTypes = [
    'Sandy',
    'Loamy',
    'Clay',
    'Silt',
    'Peaty',
    'Chalky'
  ];

  final List<String> _seasons = [
    'Spring',
    'Summer',
    'Monsoon',
    'Autumn',
    'Winter'
  ];

  @override
  void dispose() {
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Crop Recommendation',
        showBackButton: true,
      ),
      body: Consumer<MLProvider>(
        builder: (context, mlProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInstructions(),
                  const SizedBox(height: 20),
                  _buildSoilParametersSection(),
                  const SizedBox(height: 20),
                  _buildEnvironmentalSection(),
                  const SizedBox(height: 20),
                  _buildConditionsSection(),
                  const SizedBox(height: 20),
                  _buildPredictButton(mlProvider),
                  const SizedBox(height: 20),
                  if (mlProvider.isLoading)
                    const LoadingWidget(message: 'Analyzing soil and weather data...'),
                  if (mlProvider.lastCropPrediction != null)
                    PredictionResultCard(
                      prediction: mlProvider.lastCropPrediction!,
                      type: 'crop',
                    ),
                ],
              ),
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
              Icon(Icons.lightbulb_outline, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Crop Recommendation System',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your soil and environmental parameters to get personalized crop recommendations based on AI analysis.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilParametersSection() {
    return _buildSection(
      title: 'Soil Parameters',
      icon: Icons.terrain,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _nController,
                label: 'Nitrogen (N)',
                hint: 'mg/kg',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _pController,
                label: 'Phosphorus (P)',
                hint: 'mg/kg',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _kController,
                label: 'Potassium (K)',
                hint: 'mg/kg',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _phController,
                label: 'pH Level',
                hint: '0-14',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  final ph = double.tryParse(value!);
                  if (ph == null) return 'Invalid number';
                  if (ph < 0 || ph > 14) return 'pH must be 0-14';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedSoilType,
          decoration: const InputDecoration(
            labelText: 'Soil Type',
            border: OutlineInputBorder(),
          ),
          items: _soilTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) => setState(() => _selectedSoilType = value),
          validator: (value) => value == null ? 'Please select soil type' : null,
        ),
      ],
    );
  }

  Widget _buildEnvironmentalSection() {
    return _buildSection(
      title: 'Environmental Conditions',
      icon: Icons.wb_sunny,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _temperatureController,
                label: 'Temperature',
                hint: '°C',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _humidityController,
                label: 'Humidity',
                hint: '%',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  final humidity = double.tryParse(value!);
                  if (humidity == null) return 'Invalid number';
                  if (humidity < 0 || humidity > 100) return 'Must be 0-100%';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _rainfallController,
          label: 'Rainfall',
          hint: 'mm',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            if (double.tryParse(value!) == null) return 'Invalid number';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConditionsSection() {
    return _buildSection(
      title: 'Growing Conditions',
      icon: Icons.calendar_today,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedSeason,
          decoration: const InputDecoration(
            labelText: 'Season',
            border: OutlineInputBorder(),
          ),
          items: _seasons.map((season) {
            return DropdownMenuItem(value: season, child: Text(season));
          }).toList(),
          onChanged: (value) => setState(() => _selectedSeason = value),
          validator: (value) => value == null ? 'Please select season' : null,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPredictButton(MLProvider mlProvider) {
    return CustomButton(
      text: 'Get Crop Recommendations',
      onPressed: mlProvider.isLoading ? null : _predictCrop,
      icon: Icons.eco,
      backgroundColor: AppColors.primaryGreen,
      isFullWidth: true,
    );
  }

  Future<void> _predictCrop() async {
    if (!_formKey.currentState!.validate()) return;

    final mlProvider = Provider.of<MLProvider>(context, listen: false);

    final parameters = {
      'nitrogen': double.parse(_nController.text),
      'phosphorus': double.parse(_pController.text),
      'potassium': double.parse(_kController.text),
      'temperature': double.parse(_temperatureController.text),
      'humidity': double.parse(_humidityController.text),
      'ph': double.parse(_phController.text),
      'rainfall': double.parse(_rainfallController.text),
      'soil_type': _selectedSoilType!,
      'season': _selectedSeason!,
    };

    try {
      await mlProvider.predictCrop(parameters);
      if (mlProvider.lastCropPrediction != null) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('Error predicting crop: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prediction Complete'),
        content: const Text('Crop recommendations generated successfully!'),
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