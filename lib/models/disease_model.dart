// lib/models/disease_model.dart

/// Represents a disease detection result with associated metadata
class DiseaseDetection {
  /// Unique identifier for the detection
  final String id;
  
  /// Name of the detected disease
  final String diseaseName;
  
  /// Confidence level of the detection (0.0 to 1.0)
  final double confidence;
  
  /// Path to the analyzed image
  final String imagePath;
  
  /// Timestamp when the detection was performed
  final DateTime detectedAt;
  
  /// List of symptoms associated with the disease
  final List<String> symptoms;
  
  /// Recommended treatment for the disease
  final String treatment;
  
  /// Severity level of the disease
  final String severity;

  /// Creates a new DiseaseDetection instance
  DiseaseDetection({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.imagePath,
    required this.detectedAt,
    required this.symptoms,
    required this.treatment,
    required this.severity,
  });

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'diseaseName': diseaseName,
    'confidence': confidence,
    'imagePath': imagePath,
    'detectedAt': detectedAt.toIso8601String(),
    'symptoms': symptoms,
    'treatment': treatment,
    'severity': severity,
  };

  /// Creates a DiseaseDetection instance from a JSON map
  factory DiseaseDetection.fromJson(Map<String, dynamic> json) => DiseaseDetection(
    id: json['id']?.toString() ?? '',
    diseaseName: json['diseaseName']?.toString() ?? '',
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    imagePath: json['imagePath']?.toString() ?? '',
    detectedAt: json['detectedAt'] != null 
        ? DateTime.parse(json['detectedAt'].toString()) 
        : DateTime.now(),
    symptoms: (json['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
    treatment: json['treatment']?.toString() ?? '',
    severity: json['severity']?.toString() ?? 'Unknown',
  );

  /// Creates a copy of this instance with optional parameter overrides
  DiseaseDetection copyWith({
    String? id,
    String? diseaseName,
    double? confidence,
    String? imagePath,
    DateTime? detectedAt,
    List<String>? symptoms,
    String? treatment,
    String? severity,
  }) => DiseaseDetection(
    id: id ?? this.id,
    diseaseName: diseaseName ?? this.diseaseName,
    confidence: confidence ?? this.confidence,
    imagePath: imagePath ?? this.imagePath,
    detectedAt: detectedAt ?? this.detectedAt,
    symptoms: symptoms ?? this.symptoms,
    treatment: treatment ?? this.treatment,
    severity: severity ?? this.severity,
  );

  @override
  String toString() => 'DiseaseDetection(id: $id, diseaseName: $diseaseName, confidence: $confidence, severity: $severity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiseaseDetection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Represents a pest detection result with associated metadata
class PestDetection {
  /// Unique identifier for the detection
  final String id;
  
  /// Name of the detected pest
  final String pestName;
  
  /// Confidence level of the detection (0.0 to 1.0)
  final double confidence;
  
  /// Path to the analyzed image
  final String imagePath;
  
  /// Timestamp when the detection was performed
  final DateTime detectedAt;
  
  /// Type/category of the pest
  final String pestType;
  
  /// Level of damage caused by the pest
  final String damageLevel;
  
  /// List of control methods for the pest
  final List<String> controlMethods;
  
  /// List of prevention measures
  final List<String> prevention;

  /// Creates a new PestDetection instance
  PestDetection({
    required this.id,
    required this.pestName,
    required this.confidence,
    required this.imagePath,
    required this.detectedAt,
    required this.pestType,
    required this.damageLevel,
    required this.controlMethods,
    required this.prevention,
  });

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'pestName': pestName,
    'confidence': confidence,
    'imagePath': imagePath,
    'detectedAt': detectedAt.toIso8601String(),
    'pestType': pestType,
    'damageLevel': damageLevel,
    'controlMethods': controlMethods,
    'prevention': prevention,
  };

  /// Creates a PestDetection instance from a JSON map
  factory PestDetection.fromJson(Map<String, dynamic> json) => PestDetection(
    id: json['id']?.toString() ?? '',
    pestName: json['pestName']?.toString() ?? '',
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    imagePath: json['imagePath']?.toString() ?? '',
    detectedAt: json['detectedAt'] != null 
        ? DateTime.parse(json['detectedAt'].toString()) 
        : DateTime.now(),
    pestType: json['pestType']?.toString() ?? '',
    damageLevel: json['damageLevel']?.toString() ?? 'Unknown',
    controlMethods: (json['controlMethods'] as List<dynamic>?)?.cast<String>() ?? [],
    prevention: (json['prevention'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  /// Creates a copy of this instance with optional parameter overrides
  PestDetection copyWith({
    String? id,
    String? pestName,
    double? confidence,
    String? imagePath,
    DateTime? detectedAt,
    String? pestType,
    String? damageLevel,
    List<String>? controlMethods,
    List<String>? prevention,
  }) => PestDetection(
    id: id ?? this.id,
    pestName: pestName ?? this.pestName,
    confidence: confidence ?? this.confidence,
    imagePath: imagePath ?? this.imagePath,
    detectedAt: detectedAt ?? this.detectedAt,
    pestType: pestType ?? this.pestType,
    damageLevel: damageLevel ?? this.damageLevel,
    controlMethods: controlMethods ?? this.controlMethods,
    prevention: prevention ?? this.prevention,
  );

  @override
  String toString() => 'PestDetection(id: $id, pestName: $pestName, confidence: $confidence, damageLevel: $damageLevel)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PestDetection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}