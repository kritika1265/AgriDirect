import 'dart:convert';
import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String phoneNumber;
  final String name;
  final String email;
  final String? location;
  final String? farmSize;
  final List<String> cropTypes;
  final String? profilePicture;
  final bool isVerified;
  final String language;
  final bool notificationsEnabled;
  final bool weatherAlertsEnabled;
  final bool cropRemindersEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> preferences;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.email = '',
    this.location,
    this.farmSize,
    this.cropTypes = const [],
    this.profilePicture,
    this.isVerified = false,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.weatherAlertsEnabled = true,
    this.cropRemindersEnabled = true,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.preferences = const {},
  });

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    String? location,
    String? farmSize,
    List<String>? cropTypes,
    String? profilePicture,
    bool? isVerified,
    String? language,
    bool? notificationsEnabled,
    bool? weatherAlertsEnabled,
    bool? cropRemindersEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      farmSize: farmSize ?? this.farmSize,
      cropTypes: cropTypes ?? this.cropTypes,
      profilePicture: profilePicture ?? this.profilePicture,
      isVerified: isVerified ?? this.isVerified,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weatherAlertsEnabled: weatherAlertsEnabled ?? this.weatherAlertsEnabled,
      cropRemindersEnabled: cropRemindersEnabled ?? this.cropRemindersEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'location': location,
      'farmSize': farmSize,
      'cropTypes': cropTypes,
      'profilePicture': profilePicture,
      'isVerified': isVerified,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'weatherAlertsEnabled': weatherAlertsEnabled,
      'cropRemindersEnabled': cropRemindersEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      location: map['location']?.toString(),
      farmSize: map['farmSize']?.toString(),
      cropTypes: map['cropTypes'] != null 
          ? List<String>.from(
              (map['cropTypes'] as List<dynamic>).map((dynamic x) => x.toString())
            )
          : <String>[],
      profilePicture: map['profilePicture']?.toString(),
      isVerified: (map['isVerified'] as bool?) ?? false,
      language: map['language']?.toString() ?? 'en',
      notificationsEnabled: (map['notificationsEnabled'] as bool?) ?? true,
      weatherAlertsEnabled: (map['weatherAlertsEnabled'] as bool?) ?? true,
      cropRemindersEnabled: (map['cropRemindersEnabled'] as bool?) ?? true,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString()) 
          : null,
      lastLoginAt: map['lastLoginAt'] != null 
          ? DateTime.parse(map['lastLoginAt'].toString()) 
          : null,
      preferences: map['preferences'] != null 
          ? Map<String, dynamic>.from(map['preferences'] as Map<String, dynamic>) 
          : <String, dynamic>{},
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => 
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phoneNumber: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
    
    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.name == name &&
        other.email == email &&
        other.location == location &&
        other.farmSize == farmSize &&
        listEquals(other.cropTypes, cropTypes) &&
        other.profilePicture == profilePicture &&
        other.isVerified == isVerified &&
        other.language == language &&
        other.notificationsEnabled == notificationsEnabled &&
        other.weatherAlertsEnabled == weatherAlertsEnabled &&
        other.cropRemindersEnabled == cropRemindersEnabled &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastLoginAt == lastLoginAt &&
        mapEquals(other.preferences, preferences);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      phoneNumber,
      name,
      email,
      location,
      farmSize,
      Object.hashAll(cropTypes),
      profilePicture,
      isVerified,
      language,
      notificationsEnabled,
      weatherAlertsEnabled,
      cropRemindersEnabled,
      createdAt,
      updatedAt,
      lastLoginAt,
      Object.hashAll(preferences.entries.map((e) => Object.hash(e.key, e.value))),
    );
  }
}