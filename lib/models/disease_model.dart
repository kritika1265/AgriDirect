// lib/models/disease_model.dart
class DiseaseDetection {
  final String id;
  final String diseaseName;
  final double confidence;
  final String imagePath;
  final DateTime detectedAt;
  final List<String> symptoms;
  final String treatment;
  final String severity;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'imagePath': imagePath,
      'detectedAt': detectedAt.toIso8601String(),
      'symptoms': symptoms,
      'treatment': treatment,
      'severity': severity,
    };
  }

  factory DiseaseDetection.fromJson(Map<String, dynamic> json) {
    return DiseaseDetection(
      id: json['id'] ?? '',
      diseaseName: json['diseaseName'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imagePath: json['imagePath'] ?? '',
      detectedAt: DateTime.parse(json['detectedAt'] ?? DateTime.now().toIso8601String()),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      treatment: json['treatment'] ?? '',
      severity: json['severity'] ?? 'Unknown',
    );
  }

  DiseaseDetection copyWith({
    String? id,
    String? diseaseName,
    double? confidence,
    String? imagePath,
    DateTime? detectedAt,
    List<String>? symptoms,
    String? treatment,
    String? severity,
  }) {
    return DiseaseDetection(
      id: id ?? this.id,
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath ?? this.imagePath,
      detectedAt: detectedAt ?? this.detectedAt,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      severity: severity ?? this.severity,
    );
  }

  @override
  String toString() {
    return 'DiseaseDetection(id: $id, diseaseName: $diseaseName, confidence: $confidence, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiseaseDetection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PestDetection {
  final String id;
  final String pestName;
  final double confidence;
  final String imagePath;
  final DateTime detectedAt;
  final String pestType;
  final String damageLevel;
  final List<String> controlMethods;
  final List<String> prevention;

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

  Map<String, dynamic> toJson() {
    return {
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
  }

  factory PestDetection.fromJson(Map<String, dynamic> json) {
    return PestDetection(
      id: json['id'] ?? '',
      pestName: json['pestName'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imagePath: json['imagePath'] ?? '',
      detectedAt: DateTime.parse(json['detectedAt'] ?? DateTime.now().toIso8601String()),
      pestType: json['pestType'] ?? '',
      damageLevel: json['damageLevel'] ?? 'Unknown',
      controlMethods: List<String>.from(json['controlMethods'] ?? []),
      prevention: List<String>.from(json['prevention'] ?? []),
    );
  }

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
  }) {
    return PestDetection(
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
  }

  @override
  String toString() {
    return 'PestDetection(id: $id, pestName: $pestName, confidence: $confidence, damageLevel: $damageLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PestDetection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}