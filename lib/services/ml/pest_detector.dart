// lib/services/ml/pest_detector.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'tflite_helper.dart';

class PestDetector {
  static final PestDetector _instance = PestDetector._internal();
  factory PestDetector() => _instance;
  PestDetector._internal();

  static const String _pestModelName = 'pest_detector';
  static const String _beneficialModelName = 'beneficial_insects';
  static const String _damageModelName = 'pest_damage';
  
  static const String _pestModelPath = 'assets/models/pest_detection_model.tflite';
  static const String _beneficialModelPath = 'assets/models/beneficial_insects_model.tflite';
  static const String _damageModelPath = 'assets/models/pest_damage_model.tflite';
  
  static const String _pestLabelsPath = 'assets/models/pest_labels.txt';
  static const String _beneficialLabelsPath = 'assets/models/beneficial_labels.txt';
  static const String _damageLabelsPath = 'assets/models/damage_labels.txt';
  
  static const int _inputSize = 224;

  final TFLiteHelper _tfliteHelper = TFLiteHelper();
  bool _isInitialized = false;

  /// Initialize all pest detection models
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Load pest detection model
      final pestSuccess = await _tfliteHelper.loadModel(
        _pestModelName,
        _pestModelPath,
        labelsPath: _pestLabelsPath,
      );

      // Load beneficial insects model
      final beneficialSuccess = await _tfliteHelper.loadModel(
        _beneficialModelName,
        _beneficialModelPath,
        labelsPath: _beneficialLabelsPath,
      );

      // Load pest damage assessment model
      final damageSuccess = await _tfliteHelper.loadModel(
        _damageModelName,
        _damageModelPath,
        labelsPath: _damageLabelsPath,
      );

      _isInitialized = pestSuccess && beneficialSuccess && damageSuccess;
      return _isInitialized;
    } catch (e) {
      print('Error initializing pest detector: $e');
      return false;
    }
  }

  /// Detect pests in image
  Future<PestDetectionResult> detectPests(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Pest detector not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _pestModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      final probabilities = _tfliteHelper.applySoftmax(output[0]);
      final predictions = _tfliteHelper.getTopPredictions(
        probabilities,
        _pestModelName,
        topK: 5,
        threshold: 0.05,
      );

      final topPrediction = predictions.isNotEmpty ? predictions.first : null;
      final pestInfo = topPrediction != null ? 
        _getPestInfo(topPrediction.label) : null;

      return PestDetectionResult(
        pestDetected: topPrediction != null && topPrediction.confidence > 0.3,
        pestInfo: pestInfo,
        predictions: predictions,
        confidence: topPrediction?.confidence ?? 0.0,
        riskLevel: _assessRiskLevel(topPrediction),
        treatmentOptions: pestInfo?.treatmentMethods ?? [],
        preventionTips: pestInfo?.preventionMethods ?? [],
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return PestDetectionResult(
        pestDetected: false,
        pestInfo: null,
        predictions: [],
        confidence: 0.0,
        riskLevel: RiskLevel.unknown,
        treatmentOptions: [],
        preventionTips: [],
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Detect beneficial insects
  Future<BeneficialInsectResult> detectBeneficialInsects(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Pest detector not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _beneficialModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      final probabilities = _tfliteHelper.applySoftmax(output[0]);
      final predictions = _tfliteHelper.getTopPredictions(
        probabilities,
        _beneficialModelName,
        topK: 3,
        threshold: 0.1,
      );

      final topPrediction = predictions.isNotEmpty ? predictions.first : null;
      final beneficialInfo = topPrediction != null ? 
        _getBeneficialInsectInfo(topPrediction.label) : null;

      return BeneficialInsectResult(
        beneficialDetected: topPrediction != null && topPrediction.confidence > 0.4,
        insectInfo: beneficialInfo,
        predictions: predictions,
        confidence: topPrediction?.confidence ?? 0.0,
        conservationTips: beneficialInfo?.conservationMethods ?? [],
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return BeneficialInsectResult(
        beneficialDetected: false,
        insectInfo: null,
        predictions: [],
        confidence: 0.0,
        conservationTips: [],
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Assess pest damage
  Future<PestDamageResult> assessDamage(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Pest detector not initialized');
    }

    try {
      final input = await _preprocessImage(imagePath);
      
      final output = _tfliteHelper.runInference(
        _damageModelName,
        input,
        [1, _inputSize, _inputSize, 3],
      );

      final probabilities = _tfliteHelper.applySoftmax(output[0]);
      final predictions = _tfliteHelper.getTopPredictions(
        probabilities,
        _damageModelName,
        topK: 3,
        threshold: 0.1,
      );

      final topPrediction = predictions.isNotEmpty ? predictions.first : null;
      final damageLevel = _categorizeDamageLevel(topPrediction);
      final damageType = _categorizeDamageType(topPrediction?.label);

      return PestDamageResult(
        damageDetected: topPrediction != null && topPrediction.confidence > 0.3,
        damageLevel: damageLevel,
        damageType: damageType,
        predictions: predictions,
        confidence: topPrediction?.confidence ?? 0.0,
        recommendations: _getDamageRecommendations(damageLevel, damageType),
        urgency: _assessUrgency(damageLevel),
        processingTime: DateTime.now(),
      );

    } catch (e) {
      return PestDamageResult(
        damageDetected: false,
        damageLevel: DamageLevel.none,
        damageType: DamageType.unknown,
        predictions: [],
        confidence: 0.0,
        recommendations: [],
        urgency: Urgency.low,
        processingTime: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Comprehensive pest analysis
  Future<ComprehensivePestAnalysis> analyzePests(String imagePath) async {
    final pestResult = await detectPests(imagePath);
    final beneficialResult = await detectBeneficialInsects(imagePath);
    final damageResult = await assessDamage(imagePath);

    final overallRisk = _calculateOverallRisk(pestResult, damageResult);
    final actionPlan = _generateActionPlan(pestResult, beneficialResult, damageResult);

    return ComprehensivePestAnalysis(
      pestResult: pestResult,
      beneficialResult: beneficialResult,
      damageResult: damageResult,
      overallRisk: overallRisk,
      actionPlan: actionPlan,
      integratedRecommendations: _getIntegratedRecommendations(
        pestResult, beneficialResult, damageResult,
      ),
      processingTime: DateTime.now(),
    );
  }

  // Helper methods

  Future<Float32List> _preprocessImage(String imagePath) async {
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Could not decode image');
    }

    return _tfliteHelper.preprocessImage(
      image,
      inputWidth: _inputSize,
      inputHeight: _inputSize,
      normalize: true,
    );
  }

  PestInfo _getPestInfo(String pestLabel) {
    final pest = pestLabel.toLowerCase();
    
    // Comprehensive pest information database
    final pestDatabase = {
      'aphid': PestInfo(
        name: 'Aphids',
        scientificName: 'Aphidoidea',
        description: 'Small, soft-bodied insects that feed on plant sap',
        symptoms: [
          'Yellowing or curling leaves',
          'Stunted plant growth',
          'Sticky honeydew on leaves',
          'Sooty mold growth'
        ],
        lifecycle: 'Complete metamorphosis, 7-10 days per generation',
        hostPlants: ['Most vegetables', 'Fruit trees', 'Ornamental plants'],
        treatmentMethods: [
          'Spray with insecticidal soap',
          'Release ladybugs or lacewings',
          'Use neem oil spray',
          'Apply systemic insecticides if severe'
        ],
        preventionMethods: [
          'Regular inspection of plants',
          'Encourage beneficial insects',
          'Avoid over-fertilization with nitrogen',
          'Use reflective mulches'
        ],
        biologicalControl: ['Ladybugs', 'Lacewings', 'Parasitic wasps'],
        chemicalControl: ['Insecticidal soap', 'Neem oil', 'Pyrethrins'],
        seasonality: 'Most active in spring and fall',
      ),
      'caterpillar': PestInfo(
        name: 'Caterpillars',
        scientificName: 'Lepidoptera larvae',
        description: 'Larval stage of moths and butterflies',
        symptoms: [
          'Chewed leaves with large holes',
          'Defoliation of plants',
          'Frass (droppings) on leaves',
          'Visible caterpillars on plants'
        ],
        lifecycle: 'Complete metamorphosis, 2-6 weeks larval stage',
        hostPlants: ['Wide variety depending on species'],
        treatmentMethods: [
          'Hand picking for small infestations',
          'Bacillus thuringiensis (Bt) spray',
          'Spinosad-based insecticides',
          'Pheromone traps for adults'
        ],
        preventionMethods: [
          'Row covers during egg-laying periods',
          'Regular monitoring',
          'Encourage birds and beneficial insects',
          'Crop rotation'
        ],
        biologicalControl: ['Birds', 'Parasitic wasps', 'Predatory beetles'],
        chemicalControl: ['Bt spray', 'Spinosad', 'Pyrethroid insecticides'],
        seasonality: 'Most active in warm months',
      ),
      'spider_mite': PestInfo(
        name: 'Spider Mites',
        scientificName: 'Tetranychidae',
        description: 'Tiny arachnids that feed on plant cells',
        symptoms: [
          'Fine webbing on leaves',
          'Yellow or bronze stippling on leaves',
          'Leaf drop in severe infestations',
          'Overall plant decline'
        ],
        lifecycle: 'Complete development in 5-20 days depending on temperature',
        hostPlants: ['Most plants, especially in hot, dry conditions'],
        treatmentMethods: [
          'Increase humidity around plants',
          'Miticide sprays',
          'Release predatory mites',
          'Horticultural oil sprays'
        ],
        preventionMethods: [
          'Maintain adequate humidity',
          'Avoid over-fertilization',
          'Regular water spraying',
          'Remove dusty conditions'
        ],
        biologicalControl: ['Predatory mites', 'Ladybugs', 'Thrips'],
        chemicalControl: ['Miticides', 'Horticultural oils', 'Insecticidal soap'],
        seasonality: 'Most problematic in hot, dry weather',
      ),
      'whitefly': PestInfo(
        name: 'Whiteflies',
        scientificName: 'Aleyrodidae',
        description: 'Small, white flying insects that feed on plant sap',
        symptoms: [
          'Yellowing leaves',
          'Sticky honeydew on leaves',
          'Sooty mold growth',
          'White flies when plant is disturbed'
        ],
        lifecycle: 'Complete metamorphosis, 25-30 days',
        hostPlants: ['Tomatoes', 'Peppers', 'Cucumbers', 'Ornamentals'],
        treatmentMethods: [
          'Yellow sticky traps',
          'Insecticidal soap sprays',
          'Vacuum adults in morning',
          'Systemic insecticides for severe cases'
        ],
        preventionMethods: [
          'Quarantine new plants',
          'Use row covers',
          'Reflective mulches',
          'Regular inspection'
        ],
        biologicalControl: ['Encarsia wasps', 'Delphastus beetles'],
        chemicalControl: ['Insecticidal soap', 'Neem oil', 'Systemic insecticides'],
        seasonality: 'Most active in warm weather',
      ),
      'thrips': PestInfo(
        name: 'Thrips',
        scientificName: 'Thysanoptera',
        description: 'Tiny, slender insects that rasp plant surfaces',
        symptoms: [
          'Silver or bronze stippling on leaves',
          'Black specks of excrement',
          'Distorted leaf growth',
          'Flower damage'
        ],
        lifecycle: 'Incomplete metamorphosis, 15-30 days',
        hostPlants: ['Wide variety of plants'],
        treatmentMethods: [
          'Blue sticky traps',
          'Predatory mites release',
          'Insecticidal soap',
          'Systemic insecticides'
        ],
        preventionMethods: [
          'Remove weeds around crops',
          'Use reflective mulches',
          'Screen vents in greenhouses',
          'Regular monitoring'
        ],
        biologicalControl: ['Predatory mites', 'Minute pirate bugs'],
        chemicalControl: ['Insecticidal soap', 'Spinosad', 'Systemic insecticides'],
        seasonality: 'Active throughout growing season',
      ),
    };

    // Find matching pest or return default info
    for (final key in pestDatabase.keys) {
      if (pest.contains(key) || pest.replaceAll('_', ' ').contains(key)) {
        return pestDatabase[key]!;
      }
    }

    // Default pest info for unknown pests
    return PestInfo(
      name: 'Unknown Pest',
      scientificName: 'Species not identified',
      description: 'Pest identification requires further analysis',
      symptoms: ['Visible damage to plant'],
      lifecycle: 'Varies by species',
      hostPlants: ['Multiple host plants possible'],
      treatmentMethods: [
        'Consult with local agricultural extension',
        'Take clear photos for expert identification',
        'Monitor damage patterns'
      ],
      preventionMethods: [
        'Regular plant inspection',
        'Maintain plant health',
        'Practice good garden hygiene'
      ],
      biologicalControl: ['Encourage beneficial insects'],
      chemicalControl: ['Contact local agricultural advisor'],
      seasonality: 'Monitor throughout growing season',
    );
  }

  BeneficialInsectInfo _getBeneficialInsectInfo(String insectLabel) {
    final insect = insectLabel.toLowerCase();
    
    final beneficialDatabase = {
      'ladybug': BeneficialInsectInfo(
        name: 'Ladybugs (Lady Beetles)',
        scientificName: 'Coccinellidae',
        description: 'Beneficial predatory beetles',
        benefits: [
          'Consume 50+ aphids per day',
          'Control soft-bodied pests',
          'Both adults and larvae are predatory'
        ],
        preySpecies: ['Aphids', 'Scale insects', 'Mites', 'Small caterpillars'],
        habitat: ['Gardens', 'Crop fields', 'Orchards'],
        conservationMethods: [
          'Avoid broad-spectrum insecticides',
          'Plant pollen-rich flowers',
          'Provide overwintering sites',
          'Maintain diverse plantings'
        ],
        attractingPlants: ['Dill', 'Fennel', 'Yarrow', 'Sweet alyssum'],
        seasonality: 'Active spring through fall',
      ),
      'lacewing': BeneficialInsectInfo(
        name: 'Green Lacewings',
        scientificName: 'Chrysopidae',
        description: 'Delicate insects with voracious larvae',
        benefits: [
          'Larvae consume hundreds of aphids',
          'Control various soft-bodied pests',
          'Adults also feed on pests and nectar'
        ],
        preySpecies: ['Aphids', 'Thrips', 'Mites', 'Small caterpillars'],
        habitat: ['Gardens', 'Orchards', 'Field crops'],
        conservationMethods: [
          'Provide nectar sources',
          'Avoid pesticide use',
          'Maintain habitat diversity',
          'Use selective pest control'
        ],
        attractingPlants: ['Angelica', 'Coriander', 'Dill', 'Dandelion'],
        seasonality: 'Multiple generations per year',
      ),
      'parasitic_wasp': BeneficialInsectInfo(
        name: 'Parasitic Wasps',
        scientificName: 'Various families',
        description: 'Tiny wasps that parasitize pest insects',
        benefits: [
          'Control caterpillars and aphids',
          'Species-specific pest control',
          'Self-sustaining populations'
        ],
        preySpecies: ['Caterpillars', 'Aphids', 'Whiteflies', 'Scale insects'],
        habitat: ['Diverse agricultural and garden settings'],
        conservationMethods: [
          'Plant nectar-rich flowers',
          'Avoid broad-spectrum insecticides',
          'Maintain habitat corridors',
          'Use selective pest management'
        ],
        attractingPlants: ['Alyssum', 'Buckwheat', 'Parsley', 'Queen Annes lace'],
        seasonality: 'Active throughout growing season',
      ),
    };

    for (final key in beneficialDatabase.keys) {
      if (insect.contains(key) || insect.replaceAll('_', ' ').contains(key)) {
        return beneficialDatabase[key]!;
      }
    }

    return BeneficialInsectInfo(
      name: 'Beneficial Insect',
      scientificName: 'Species not identified',
      description: 'Likely beneficial to garden ecosystem',
      benefits: ['Natural pest control'],
      preySpecies: ['Various pest species'],
      habitat: ['Garden environments'],
      conservationMethods: [
        'Avoid unnecessary pesticide use',
        'Maintain diverse plantings'
      ],
      attractingPlants: ['Native flowering plants'],
      seasonality: 'Varies by species',
    );
  }

  RiskLevel _assessRiskLevel(Prediction? prediction) {
    if (prediction == null) return RiskLevel.low;
    
    final confidence = prediction.confidence;
    final pestName = prediction.label.toLowerCase();
    
    // High-risk pests
    final highRiskPests = ['aphid', 'whitefly', 'spider_mite', 'caterpillar'];
    final isHighRiskPest = highRiskPests.any((pest) => pestName.contains(pest));
    
    if (confidence > 0.8 && isHighRiskPest) return RiskLevel.critical;
    if (confidence > 0.6 && isHighRiskPest) return RiskLevel.high;
    if (confidence > 0.4) return RiskLevel.moderate;
    if (confidence > 0.2) return RiskLevel.low;
    
    return RiskLevel.minimal;
  }

  DamageLevel _categorizeDamageLevel(Prediction? prediction) {
    if (prediction == null || prediction.confidence < 0.3) return DamageLevel.none;
    
    final damageLabel = prediction.label.toLowerCase();
    final confidence = prediction.confidence;
    
    if (damageLabel.contains('severe') || confidence > 0.8) return DamageLevel.severe;
    if (damageLabel.contains('moderate') || confidence > 0.6) return DamageLevel.moderate;
    if (damageLabel.contains('mild') || confidence > 0.4) return DamageLevel.mild;
    
    return DamageLevel.minimal;
  }

  DamageType _categorizeDamageType(String? damageLabel) {
    if (damageLabel == null) return DamageType.unknown;
    
    final damage = damageLabel.toLowerCase();
    
    if (damage.contains('chew') || damage.contains('hole')) return DamageType.chewing;
    if (damage.contains('suck') || damage.contains('yellow')) return DamageType.sucking;
    if (damage.contains('bore') || damage.contains('tunnel')) return DamageType.boring;
    if (damage.contains('gall') || damage.contains('deform')) return DamageType.galling;
    if (damage.contains('mine') || damage.contains('trail')) return DamageType.mining;
    
    return DamageType.general;
  }

  List<String> _getDamageRecommendations(DamageLevel level, DamageType type) {
    final recommendations = <String>[];
    
    // Level-based recommendations
    switch (level) {
      case DamageLevel.none:
        recommendations.add('Continue regular monitoring');
        break;
      case DamageLevel.minimal:
        recommendations.addAll([
          'Increase monitoring frequency',
          'Consider preventive measures'
        ]);
        break;
      case DamageLevel.mild:
        recommendations.addAll([
          'Begin targeted treatment',
          'Monitor spread to other plants',
          'Document damage progression'
        ]);
        break;
      case DamageLevel.moderate:
        recommendations.addAll([
          'Implement immediate treatment',
          'Isolate affected plants if possible',
          'Consider systemic treatments'
        ]);
        break;
      case DamageLevel.severe:
        recommendations.addAll([
          'Emergency treatment required',
          'Consider plant removal if too damaged',
          'Prevent spread to healthy plants'
        ]);
        break;
    }
    
    // Type-based recommendations
    switch (type) {
      case DamageType.chewing:
        recommendations.add('Use contact insecticides or Bt for caterpillars');
        break;
      case DamageType.sucking:
        recommendations.add('Apply systemic insecticides or insecticidal soap');
        break;
      case DamageType.boring:
        recommendations.add('Use systemic insecticides, remove affected parts');
        break;
      case DamageType.galling:
        recommendations.add('Prune affected areas, improve plant vigor');
        break;
      case DamageType.mining:
        recommendations.add('Remove affected leaves, use leaf miners spray');
        break;
      case DamageType.general:
      case DamageType.unknown:
        recommendations.add('Identify pest type for targeted treatment');
        break;
    }
    
    return recommendations;
  }

  Urgency _assessUrgency(DamageLevel level) {
    switch (level) {
      case DamageLevel.none:
      case DamageLevel.minimal:
        return Urgency.low;
      case DamageLevel.mild:
        return Urgency.medium;
      case DamageLevel.moderate:
        return Urgency.high;
      case DamageLevel.severe:
        return Urgency.critical;
    }
  }

  RiskLevel _calculateOverallRisk(PestDetectionResult pest, PestDamageResult damage) {
    final pestRisk = pest.riskLevel;
    final damageRisk = _damageToRiskLevel(damage.damageLevel);
    
    // Take the higher of the two risks
    final riskValues = {
      RiskLevel.minimal: 1,
      RiskLevel.low: 2,
      RiskLevel.moderate: 3,
      RiskLevel.high: 4,
      RiskLevel.critical: 5,
      RiskLevel.unknown: 0,
    };
    
    final maxRisk = [pestRisk, damageRisk]
        .map((r) => riskValues[r] ?? 0)
        .reduce((a, b) => a > b ? a : b);
    
    return riskValues.entries
        .firstWhere((entry) => entry.value == maxRisk)
        .key;
  }

  RiskLevel _damageToRiskLevel(DamageLevel damage) {
    switch (damage) {
      case DamageLevel.none:
        return RiskLevel.minimal;
      case DamageLevel.minimal:
        return RiskLevel.low;
      case DamageLevel.mild:
        return RiskLevel.moderate;
      case DamageLevel.moderate:
        return RiskLevel.high;
      case DamageLevel.severe:
        return RiskLevel.critical;
    }
  }

  ActionPlan _generateActionPlan(
    PestDetectionResult pest,
    BeneficialInsectResult beneficial,
    PestDamageResult damage,
  ) {
    final immediateActions = <String>[];
    final shortTermActions = <String>[];
    final longTermActions = <String>[];
    
    // Immediate actions based on damage urgency
    switch (damage.urgency) {
      case Urgency.critical:
        immediateActions.addAll([
          'Apply emergency treatment within 24 hours',
          'Isolate severely affected plants',
          'Document extent of damage'
        ]);
        break;
      case Urgency.high:
        immediateActions.addAll([
          'Begin treatment within 2-3 days',
          'Monitor spread to adjacent plants'
        ]);
        break;
      case Urgency.medium:
        immediateActions.add('Plan treatment within one week');
        break;
      case Urgency.low:
        immediateActions.add('Continue monitoring');
        break;
    }
    
    // Short-term actions
    if (pest.pestDetected) {
      shortTermActions.addAll(pest.treatmentOptions);
    }
    
    if (beneficial.beneficialDetected) {
      shortTermActions.addAll([
        'Protect beneficial insects during treatment',
        'Use selective pest control methods'
      ]);
    }
    
    // Long-term actions
    longTermActions.addAll([
      'Implement integrated pest management',
      'Monitor for pest resistance',
      'Document treatment effectiveness',
      'Plan preventive measures for next season'
    ]);
    
    return ActionPlan(
      immediateActions: immediateActions,
      shortTermActions: shortTermActions,
      longTermActions: longTermActions,
      timeline: _generateTimeline(damage.urgency),
    );
  }

  String _generateTimeline(Urgency urgency) {
    switch (urgency) {
      case Urgency.critical:
        return 'Immediate action (0-24 hours), followed by weekly monitoring';
      case Urgency.high:
        return 'Action within 2-3 days, monitor every 3 days';
      case Urgency.medium:
        return 'Action within 1 week, monitor weekly';
      case Urgency.low:
        return 'Monitor bi-weekly, action as needed';
    }
  }

  List<String> _getIntegratedRecommendations(
    PestDetectionResult pest,
    BeneficialInsectResult beneficial,
    PestDamageResult damage,
  ) {
    final recommendations = <String>[];
    
    // IPM approach recommendations
    recommendations.addAll([
      'Use Integrated Pest Management (IPM) approach',
      'Monitor pest and beneficial insect populations',
    ]);
    
    // Specific recommendations based on findings
    if (pest.pestDetected && beneficial.beneficialDetected) {
      recommendations.addAll([
        'Use selective treatments to preserve beneficial insects',
        'Consider biological control methods first',
        'Apply treatments during times when beneficials are less active'
      ]);
    }
    
    if (damage.damageLevel != DamageLevel.none) {
      recommendations.addAll([
        'Address underlying plant stress factors',
        'Improve plant health through proper nutrition',
        'Consider resistant varieties for future plantings'
      ]);
    }
    
    // Prevention focus
    recommendations.addAll([
      'Maintain diverse plantings to support beneficial insects',
      'Regular monitoring is key to early detection',
      'Keep detailed records of pest occurrences and treatments'
    ]);
    
    return recommendations;
  }

  /// Dispose resources
  void dispose() {
    _tfliteHelper.disposeModel(_pestModelName);
    _tfliteHelper.disposeModel(_beneficialModelName);
    _tfliteHelper.disposeModel(_damageModelName);
    _isInitialized = false;
  }
}

// Data classes for pest detection results

class PestDetectionResult {
  final bool pestDetected;
  final PestInfo? pestInfo;
  final List<Prediction> predictions;
  final double confidence;
  final RiskLevel riskLevel;
  final List<String> treatmentOptions;
  final List<String> preventionTips;
  final DateTime processingTime;
  final String? error;

  PestDetectionResult({
    required this.pestDetected,
    required this.pestInfo,
    required this.predictions,
    required this.confidence,
    required this.riskLevel,
    required this.treatmentOptions,
    required this.preventionTips,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'pestDetected': pestDetected,
    'pestInfo': pestInfo?.toJson(),
    'confidence': confidence,
    'riskLevel': riskLevel.toString(),
    'treatmentOptions': treatmentOptions,
    'preventionTips': preventionTips,
    'predictions': predictions.map((p) => p.toJson()).toList(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class BeneficialInsectResult {
  final bool beneficialDetected;
  final BeneficialInsectInfo? insectInfo;
  final List<Prediction> predictions;
  final double confidence;
  final List<String> conservationTips;
  final DateTime processingTime;
  final String? error;

  BeneficialInsectResult({
    required this.beneficialDetected,
    required this.insectInfo,
    required this.predictions,
    required this.confidence,
    required this.conservationTips,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'beneficialDetected': beneficialDetected,
    'insectInfo': insectInfo?.toJson(),
    'confidence': confidence,
    'conservationTips': conservationTips,
    'predictions': predictions.map((p) => p.toJson()).toList(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class PestDamageResult {
  final bool damageDetected;
  final DamageLevel damageLevel;
  final DamageType damageType;
  final List<Prediction> predictions;
  final double confidence;
  final List<String> recommendations;
  final Urgency urgency;
  final DateTime processingTime;
  final String? error;

  PestDamageResult({
    required this.damageDetected,
    required this.damageLevel,
    required this.damageType,
    required this.predictions,
    required this.confidence,
    required this.recommendations,
    required this.urgency,
    required this.processingTime,
    this.error,
  });

  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
    'damageDetected': damageDetected,
    'damageLevel': damageLevel.toString(),
    'damageType': damageType.toString(),
    'confidence': confidence,
    'recommendations': recommendations,
    'urgency': urgency.toString(),
    'predictions': predictions.map((p) => p.toJson()).toList(),
    'processingTime': processingTime.toIso8601String(),
    'error': error,
  };
}

class ComprehensivePestAnalysis {
  final PestDetectionResult pestResult;
  final BeneficialInsectResult beneficialResult;
  final PestDamageResult damageResult;
  final RiskLevel overallRisk;
  final ActionPlan actionPlan;
  final List<String> integratedRecommendations;
  final DateTime processingTime;

  ComprehensivePestAnalysis({
    required this.pestResult,
    required this.beneficialResult,
    required this.damageResult,
    required this.overallRisk,
    required this.actionPlan,
    required this.integratedRecommendations,
    required this.processingTime,
  });

  bool get hasAnyErrors => 
    pestResult.hasError || 
    beneficialResult.hasError || 
    damageResult.hasError;

  Map<String, dynamic> toJson() => {
    'pestDetection': pestResult.toJson(),
    'beneficialInsects': beneficialResult.toJson(),
    'damageAssessment': damageResult.toJson(),
    'overallRisk': overallRisk.toString(),
    'actionPlan': actionPlan.toJson(),
    'integratedRecommendations': integratedRecommendations,
    'processingTime': processingTime.toIso8601String(),
  };
}

// Supporting data classes

class PestInfo {
  final String name;
  final String scientificName;
  final String description;
  final List<String> symptoms;
  final String lifecycle;
  final List<String> hostPlants;
  final List<String> treatmentMethods;
  final List<String> preventionMethods;
  final List<String> biologicalControl;
  final List<String> chemicalControl;
  final String seasonality;

  PestInfo({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.symptoms,
    required this.lifecycle,
    required this.hostPlants,
    required this.treatmentMethods,
    required this.preventionMethods,
    required this.biologicalControl,
    required this.chemicalControl,
    required this.seasonality,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'scientificName': scientificName,
    'description': description,
    'symptoms': symptoms,
    'lifecycle': lifecycle,
    'hostPlants': hostPlants,
    'treatmentMethods': treatmentMethods,
    'preventionMethods': preventionMethods,
    'biologicalControl': biologicalControl,
    'chemicalControl': chemicalControl,
    'seasonality': seasonality,
  };
}

class BeneficialInsectInfo {
  final String name;
  final String scientificName;
  final String description;
  final List<String> benefits;
  final List<String> preySpecies;
  final List<String> habitat;
  final List<String> conservationMethods;
  final List<String> attractingPlants;
  final String seasonality;

  BeneficialInsectInfo({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.benefits,
    required this.preySpecies,
    required this.habitat,
    required this.conservationMethods,
    required this.attractingPlants,
    required this.seasonality,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'scientificName': scientificName,
    'description': description,
    'benefits': benefits,
    'preySpecies': preySpecies,
    'habitat': habitat,
    'conservationMethods': conservationMethods,
    'attractingPlants': attractingPlants,
    'seasonality': seasonality,
  };
}

class ActionPlan {
  final List<String> immediateActions;
  final List<String> shortTermActions;
  final List<String> longTermActions;
  final String timeline;

  ActionPlan({
    required this.immediateActions,
    required this.shortTermActions,
    required this.longTermActions,
    required this.timeline,
  });

  Map<String, dynamic> toJson() => {
    'immediateActions': immediateActions,
    'shortTermActions': shortTermActions,
    'longTermActions': longTermActions,
    'timeline': timeline,
  };
}

// Enums

enum RiskLevel {
  minimal,
  low,
  moderate,
  high,
  critical,
  unknown,
}

enum DamageLevel {
  none,
  minimal,
  mild,
  moderate,
  severe,
}

enum DamageType {
  chewing,
  sucking,
  boring,
  galling,
  mining,
  general,
  unknown,
}

enum Urgency {
  low,
  medium,
  high,
  critical,
}

// Extensions

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.minimal:
        return 'Minimal';
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.moderate:
        return 'Moderate';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.critical:
        return 'Critical';
      case RiskLevel.unknown:
        return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case RiskLevel.minimal:
        return 'Very low risk - continue monitoring';
      case RiskLevel.low:
        return 'Low risk - preventive measures recommended';
      case RiskLevel.moderate:
        return 'Moderate risk - consider treatment options';
      case RiskLevel.high:
        return 'High risk - treatment recommended soon';
      case RiskLevel.critical:
        return 'Critical risk - immediate action required';
      case RiskLevel.unknown:
        return 'Risk level could not be determined';
    }
  }
}

extension DamageLevelExtension on DamageLevel {
  String get displayName {
    switch (this) {
      case DamageLevel.none:
        return 'No Damage';
      case DamageLevel.minimal:
        return 'Minimal';
      case DamageLevel.mild:
        return 'Mild';
      case DamageLevel.moderate:
        return 'Moderate';
      case DamageLevel.severe:
        return 'Severe';
    }
  }
}

extension UrgencyExtension on Urgency {
  String get displayName {
    switch (this) {
      case Urgency.low:
        return 'Low';
      case Urgency.medium:
        return 'Medium';
      case Urgency.high:
        return 'High';
      case Urgency.critical:
        return 'Critical';
    }
  }
}