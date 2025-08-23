// models/user_model.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// User types enumeration
enum UserType {
  farmer,
  vendor,
  seller,
  expert,
  admin,
}

/// User verification status
enum VerificationStatus {
  pending,
  verified,
  rejected,
}

/// Enhanced User model with vendor/seller support
class UserModel {
  final String id;
  final String phoneNumber;
  final String name;
  final String email;
  final String? location;
  final String? farmSize;
  final List<String> cropTypes;
  final String? experience;
  final String? profilePicture;
  final String? imageUrl;
  final bool isVerified;
  final String language;
  final bool notificationsEnabled;
  final bool weatherAlertsEnabled;
  final bool cropRemindersEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> preferences;
  
  // Enhanced fields for vendor/seller functionality
  final UserType userType;
  final String? businessName;
  final String? businessAddress;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessRegistrationNumber;
  final String? taxId;
  final List<String> serviceCategories;
  final String? businessDescription;
  final VerificationStatus verificationStatus;
  final List<String> businessDocuments;
  final double rating;
  final int totalTransactions;
  final bool isActiveVendor;
  final String? bankAccountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? upiId;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.createdAt,
    this.email = '',
    this.location,
    this.farmSize,
    this.cropTypes = const [],
    this.experience,
    this.profilePicture,
    this.imageUrl,
    this.isVerified = false,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.weatherAlertsEnabled = true,
    this.cropRemindersEnabled = true,
    this.updatedAt,
    this.lastLoginAt,
    this.preferences = const {},
    // Enhanced fields
    this.userType = UserType.farmer,
    this.businessName,
    this.businessAddress,
    this.businessPhone,
    this.businessEmail,
    this.businessRegistrationNumber,
    this.taxId,
    this.serviceCategories = const [],
    this.businessDescription,
    this.verificationStatus = VerificationStatus.pending,
    this.businessDocuments = const [],
    this.rating = 0.0,
    this.totalTransactions = 0,
    this.isActiveVendor = false,
    this.bankAccountNumber,
    this.bankName,
    this.ifscCode,
    this.upiId,
  });

  /// Creates a copy of this UserModel with modified fields
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    String? location,
    String? farmSize,
    List<String>? cropTypes,
    String? experience,
    String? profilePicture,
    String? imageUrl,
    bool? isVerified,
    String? language,
    bool? notificationsEnabled,
    bool? weatherAlertsEnabled,
    bool? cropRemindersEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    UserType? userType,
    String? businessName,
    String? businessAddress,
    String? businessPhone,
    String? businessEmail,
    String? businessRegistrationNumber,
    String? taxId,
    List<String>? serviceCategories,
    String? businessDescription,
    VerificationStatus? verificationStatus,
    List<String>? businessDocuments,
    double? rating,
    int? totalTransactions,
    bool? isActiveVendor,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
    String? upiId,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      farmSize: farmSize ?? this.farmSize,
      cropTypes: cropTypes ?? this.cropTypes,
      experience: experience ?? this.experience,
      profilePicture: profilePicture ?? this.profilePicture,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weatherAlertsEnabled: weatherAlertsEnabled ?? this.weatherAlertsEnabled,
      cropRemindersEnabled: cropRemindersEnabled ?? this.cropRemindersEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      userType: userType ?? this.userType,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      businessRegistrationNumber: businessRegistrationNumber ?? this.businessRegistrationNumber,
      taxId: taxId ?? this.taxId,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      businessDescription: businessDescription ?? this.businessDescription,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      businessDocuments: businessDocuments ?? this.businessDocuments,
      rating: rating ?? this.rating,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      isActiveVendor: isActiveVendor ?? this.isActiveVendor,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      upiId: upiId ?? this.upiId,
    );
  }

  /// Converts UserModel to Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'location': location,
      'farmSize': farmSize,
      'cropTypes': cropTypes,
      'experience': experience,
      'profilePicture': profilePicture,
      'imageUrl': imageUrl,
      'isVerified': isVerified,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'weatherAlertsEnabled': weatherAlertsEnabled,
      'cropRemindersEnabled': cropRemindersEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
      'userType': userType.name,
      'businessName': businessName,
      'businessAddress': businessAddress,
      'businessPhone': businessPhone,
      'businessEmail': businessEmail,
      'businessRegistrationNumber': businessRegistrationNumber,
      'taxId': taxId,
      'serviceCategories': serviceCategories,
      'businessDescription': businessDescription,
      'verificationStatus': verificationStatus.name,
      'businessDocuments': businessDocuments,
      'rating': rating,
      'totalTransactions': totalTransactions,
      'isActiveVendor': isActiveVendor,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'ifscCode': ifscCode,
      'upiId': upiId,
    };
  }

  /// Creates UserModel from Map
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
              (map['cropTypes'] as List<dynamic>).map((dynamic x) => x.toString()))
          : <String>[],
      experience: map['experience']?.toString(),
      profilePicture: map['profilePicture']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
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
      userType: _parseUserType(map['userType']?.toString()),
      businessName: map['businessName']?.toString(),
      businessAddress: map['businessAddress']?.toString(),
      businessPhone: map['businessPhone']?.toString(),
      businessEmail: map['businessEmail']?.toString(),
      businessRegistrationNumber: map['businessRegistrationNumber']?.toString(),
      taxId: map['taxId']?.toString(),
      serviceCategories: map['serviceCategories'] != null
          ? List<String>.from(
              (map['serviceCategories'] as List<dynamic>).map((dynamic x) => x.toString()))
          : <String>[],
      businessDescription: map['businessDescription']?.toString(),
      verificationStatus: _parseVerificationStatus(map['verificationStatus']?.toString()),
      businessDocuments: map['businessDocuments'] != null
          ? List<String>.from(
              (map['businessDocuments'] as List<dynamic>).map((dynamic x) => x.toString()))
          : <String>[],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: (map['totalTransactions'] as int?) ?? 0,
      isActiveVendor: (map['isActiveVendor'] as bool?) ?? false,
      bankAccountNumber: map['bankAccountNumber']?.toString(),
      bankName: map['bankName']?.toString(),
      ifscCode: map['ifscCode']?.toString(),
      upiId: map['upiId']?.toString(),
    );
  }

  static UserType _parseUserType(String? value) {
    switch (value) {
      case 'vendor':
        return UserType.vendor;
      case 'seller':
        return UserType.seller;
      case 'expert':
        return UserType.expert;
      case 'admin':
        return UserType.admin;
      default:
        return UserType.farmer;
    }
  }

  static VerificationStatus _parseVerificationStatus(String? value) {
    switch (value) {
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }

  /// Converts UserModel to JSON string
  String toJson() => json.encode(toMap());

  /// Creates UserModel from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phoneNumber: $phoneNumber, email: $email, userType: $userType)';
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
        other.experience == experience &&
        other.profilePicture == profilePicture &&
        other.imageUrl == imageUrl &&
        other.isVerified == isVerified &&
        other.language == language &&
        other.notificationsEnabled == notificationsEnabled &&
        other.weatherAlertsEnabled == weatherAlertsEnabled &&
        other.cropRemindersEnabled == cropRemindersEnabled &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastLoginAt == lastLoginAt &&
        mapEquals(other.preferences, preferences) &&
        other.userType == userType &&
        other.businessName == businessName &&
        other.businessAddress == businessAddress &&
        other.businessPhone == businessPhone &&
        other.businessEmail == businessEmail &&
        other.businessRegistrationNumber == businessRegistrationNumber &&
        other.taxId == taxId &&
        listEquals(other.serviceCategories, serviceCategories) &&
        other.businessDescription == businessDescription &&
        other.verificationStatus == verificationStatus &&
        listEquals(other.businessDocuments, businessDocuments) &&
        other.rating == rating &&
        other.totalTransactions == totalTransactions &&
        other.isActiveVendor == isActiveVendor &&
        other.bankAccountNumber == bankAccountNumber &&
        other.bankName == bankName &&
        other.ifscCode == ifscCode &&
        other.upiId == upiId;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      phoneNumber,
      name,
      email,
      location,
      farmSize,
      Object.hashAll(cropTypes),
      experience,
      profilePicture,
      imageUrl,
      isVerified,
      language,
      notificationsEnabled,
      weatherAlertsEnabled,
      cropRemindersEnabled,
      createdAt,
      updatedAt,
      lastLoginAt,
      Object.hashAll(preferences.entries.map((e) => Object.hash(e.key, e.value))),
      userType,
      businessName,
      businessAddress,
      businessPhone,
      businessEmail,
      businessRegistrationNumber,
      taxId,
      Object.hashAll(serviceCategories),
      businessDescription,
      verificationStatus,
      Object.hashAll(businessDocuments),
      rating,
      totalTransactions,
      isActiveVendor,
      bankAccountNumber,
      bankName,
      ifscCode,
      upiId,
    ]);
  }

  // Utility methods
  bool get isFarmer => userType == UserType.farmer;
  bool get isVendor => userType == UserType.vendor;
  bool get isSeller => userType == UserType.seller;
  bool get isExpert => userType == UserType.expert;
  bool get isAdmin => userType == UserType.admin;
  
  bool get isBusinessUser => isVendor || isSeller;
  bool get hasBusinessInfo => businessName != null && businessName!.isNotEmpty;
  bool get isVerifiedBusiness => verificationStatus == VerificationStatus.verified && isBusinessUser;
  
  String get displayName => name.isNotEmpty ? name : phoneNumber;
  String get businessDisplayName => businessName ?? displayName;
  
  /// Get rating display string
  String get ratingDisplay => rating > 0 ? '${rating.toStringAsFixed(1)} ★' : 'No rating';
  
  /// Check if user can perform business operations
  bool get canDoBusiness => isBusinessUser && isActiveVendor && verificationStatus == VerificationStatus.verified;
}