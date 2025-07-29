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
    return {
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
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      location: map['location'],
      farmSize: map['farmSize'],
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      profilePicture: map['profilePicture'],
      isVerified: map['isVerified'] ?? false,
      language: map['language'] ?? 'en',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      weatherAlertsEnabled: map['weatherAlertsEnabled'] ?? true,
      cropRemindersEnabled: map['cropRemindersEnabled'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.parse(map['lastLoginAt']) : null,
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phoneNumber: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}