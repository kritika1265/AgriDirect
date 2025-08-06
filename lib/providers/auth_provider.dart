// All imports must be at the very top of the file
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// auth_service.dart
/// Service class for handling Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sends OTP to the specified phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolve (Android only)
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            onError('Auto-verification failed: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError('Verification failed: ${e.message ?? e.toString()}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Verifies the OTP with the given verification ID
  Future<User?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      return userCredential.user;
    } catch (e) {
      debugPrint('OTP verification failed: ${e.toString()}');
      return null;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
  }

  /// Deletes the current user account from Firebase Auth
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
    _verificationId = null;
  }

  /// Gets the current verification ID
  String? get verificationId => _verificationId;
}

// firebase_service.dart
/// Service class for handling Firebase Firestore operations
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Collection name for user data
  static const String usersCollection = 'users';

  /// Creates or updates user data in Firestore
  Future<void> createUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating user data: ${e.toString()}');
      rethrow;
    }
  }

  /// Updates user data in Firestore
  Future<void> updateUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update(userData);
    } catch (e) {
      debugPrint('Error updating user data: ${e.toString()}');
      rethrow;
    }
  }

  /// Retrieves user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: ${e.toString()}');
      return null;
    }
  }

  /// Deletes user data from Firestore
  Future<void> deleteUserData(String userId) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting user data: ${e.toString()}');
      rethrow;
    }
  }

  /// Checks if user document exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user existence: ${e.toString()}');
      return false;
    }
  }
}

// user_model.dart
/// User model representing a user in the agriculture application
class UserModel {
  /// User's unique identifier
  final String id;
  
  /// User's phone number
  final String phoneNumber;
  
  /// User's display name
  final String name;
  
  /// User's email address
  final String email;
  
  /// User's location/address
  final String? location;
  
  /// Size of user's farm
  final String? farmSize;
  
  /// Types of crops the user grows
  final List<String> cropTypes;
  
  /// User's farming experience level
  final String? experience;
  
  /// Path to user's profile picture (local file)
  final String? profilePicture;
  
  /// URL to user's profile picture (network)
  final String? imageUrl;
  
  /// Whether the user is verified
  final bool isVerified;
  
  /// User's preferred language
  final String language;
  
  /// Whether notifications are enabled
  final bool notificationsEnabled;
  
  /// Whether weather alerts are enabled
  final bool weatherAlertsEnabled;
  
  /// Whether crop reminders are enabled
  final bool cropRemindersEnabled;
  
  /// When the user account was created
  final DateTime createdAt;
  
  /// When the user data was last updated
  final DateTime? updatedAt;
  
  /// When the user last logged in
  final DateTime? lastLoginAt;
  
  /// User preferences as key-value pairs
  final Map<String, dynamic> preferences;

  /// Creates a new UserModel instance
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
  }) =>
      UserModel(
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
      );

  /// Converts UserModel to Map
  Map<String, dynamic> toMap() => <String, dynamic>{
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
      };

  /// Creates UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id']?.toString() ?? '',
        phoneNumber: map['phoneNumber']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        location: map['location']?.toString(),
        farmSize: map['farmSize']?.toString(),
        cropTypes: map['cropTypes'] != null
            ? List<String>.from(
                (map['cropTypes'] as List<dynamic>)
                    .map((dynamic x) => x.toString()))
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
            ? Map<String, dynamic>.from(
                map['preferences'] as Map<String, dynamic>)
            : <String, dynamic>{},
      );

  /// Converts UserModel to JSON string
  String toJson() => json.encode(toMap());

  /// Creates UserModel from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, phoneNumber: $phoneNumber, email: $email)';

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
        mapEquals(other.preferences, preferences);
  }

  @override
  int get hashCode => Object.hash(
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
        Object.hashAll(
            preferences.entries.map((e) => Object.hash(e.key, e.value))),
      );

  // Image handling utility methods

  /// Picks and saves an image from gallery or camera
  static Future<String?> pickAndSaveImage(
      {ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        return null;
      }

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final profileDir = Directory(path.join(directory.path, 'profile_images'));

      // Create directory if it doesn't exist
      if (!profileDir.existsSync()) {
        profileDir.createSync(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(pickedFile.path);
      final fileName = 'profile_$timestamp$extension';
      final savedPath = path.join(profileDir.path, fileName);

      // Read and compress image
      final imageBytes = await File(pickedFile.path).readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return null;
      }

      // Resize image to 300x300 for profile pictures
      final resizedImage = img.copyResize(image, width: 300, height: 300);

      // Save compressed image
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      await File(savedPath).writeAsBytes(compressedBytes);

      return savedPath;
    } catch (e) {
      debugPrint('Error picking and saving image: $e');
      return null;
    }
  }

  /// Deletes an image file
  static Future<bool> deleteImage(String? imagePath) async {
    try {
      if (imagePath == null || imagePath.isEmpty) {
        return true;
      }

      final file = File(imagePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Gets a widget for displaying the profile image
  Widget getProfileImage({double size = 50}) {
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      // Network image
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
        child: Icon(Icons.person, size: size * 0.6),
      );
    } else if (profilePicture != null && profilePicture!.isNotEmpty) {
      // Local file image
      final file = File(profilePicture!);
      return FutureBuilder<bool>(
        future: Future.value(file.existsSync()),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return CircleAvatar(
              radius: size / 2,
              backgroundImage: FileImage(file),
              onBackgroundImageError: (_, __) {},
              child: Icon(Icons.person, size: size * 0.6),
            );
          }
          return CircleAvatar(
            radius: size / 2,
            child: Icon(Icons.person, size: size * 0.6),
          );
        },
      );
    }

    // Default avatar
    return CircleAvatar(
      radius: size / 2,
      child: Icon(Icons.person, size: size * 0.6),
    );
  }
}

// auth_provider.dart
/// Authentication status enumeration for tracking user authentication state
enum AuthStatus {
  /// Initial state when app starts
  initial,

  /// Loading state during authentication operations
  loading,

  /// User is successfully authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// Authentication error occurred
  error,
}

/// Provider class for managing user authentication state and operations
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  String? _verificationId;

  /// Creates a new AuthProvider instance and initializes authentication
  AuthProvider() {
    _initializeAuth();
  }

  // Getters
  
  /// Current authentication status
  AuthStatus get status => _status;
  
  /// Current authenticated user, null if not authenticated
  UserModel? get user => _user;
  
  /// Current error message, null if no error
  String? get errorMessage => _errorMessage;
  
  /// Whether any operation is currently loading
  bool get isLoading => _isLoading;
  
  /// Whether user is currently authenticated
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  
  /// Current verification ID for OTP
  String? get verificationId => _verificationId;

  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user);
      } else {
        _setStatus(AuthStatus.unauthenticated);
        _user = null;
      }
    });
  }

  Future<void> _loadUserData(User firebaseUser) async {
    try {
      _setLoading(true);

      final userData = await _firebaseService.getUserData(firebaseUser.uid);
      if (userData != null) {
        _user = UserModel.fromMap(userData);
        _setStatus(AuthStatus.authenticated);
      } else {
        // Create new user profile
        _user = UserModel(
          id: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          profilePicture: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firebaseService.createUserData(_user!.id, _user!.toMap());
        _setStatus(AuthStatus.authenticated);
      }
    } catch (e) {
      _setError('Failed to load user data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Sends OTP to the specified phone number
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (String verificationId) {
          _verificationId = verificationId;
          notifyListeners();
        },
        onError: (String error) {
          _setError(error);
        },
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verifies the OTP with the given verification ID
  Future<bool> verifyOTP(String verificationId, String otp) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.verifyOTP(
        verificationId: verificationId,
        otp: otp,
      );

      if (user != null) {
        // User data will be loaded automatically via auth state listener
        return true;
      } else {
        _setError('Invalid OTP. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      _verificationId = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes the current user account permanently
  Future<void> deleteAccount() async {
    if (_user == null) {
      throw Exception('No user logged in');
    }

    try {
      _setLoading(true);
      _clearError();

      final userId = _user!.id;

      // Delete user's profile picture if it exists
      if (_user!.profilePicture != null) {
        await UserModel.deleteImage(_user!.profilePicture);
      }

      // Delete user data from Firestore
      await _firebaseService.deleteUserData(userId);

      // Delete user from Firebase Auth
      await _authService.deleteUser();

      // Clear local state
      _user = null;
      _verificationId = null;
      _setStatus(AuthStatus.unauthenticated);

    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      throw Exception('Failed to delete account: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Updates user profile with the provided UserModel
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _isLoading = true;
      notifyListeners();
      _clearError();

      // Add simulation delay for testing (remove in production)
      await Future<void>.delayed(const Duration(seconds: 1));

      // Update user data in Firebase
      final userData = updatedUser.copyWith(updatedAt: DateTime.now()).toMap();

      try {
        // Try to use updateUserData method if it exists
        await _firebaseService.updateUserData(updatedUser.id, userData);
      } catch (e) {
        // Fallback: use createUserData to overwrite the document
        await _firebaseService.createUserData(updatedUser.id, userData);
      }

      // Update local user state
      _user = updatedUser.copyWith(updatedAt: DateTime.now());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _setError('Failed to update user: ${e.toString()}');
      notifyListeners();
      throw Exception('Failed to update user: $e');
    }
  }

  /// Updates a specific field of the current user
  Future<void> updateUserField(String field, dynamic value) async {
    if (_user == null) {
      throw Exception('No user logged in');
    }

    try {
      _setLoading(true);
      _clearError();

      // Create updated user based on field
      var updatedUser = _user!;

      switch (field) {
        case 'name':
          updatedUser = _user!.copyWith(name: value as String);
        case 'email':
          updatedUser = _user!.copyWith(email: value as String);
        case 'location':
          updatedUser = _user!.copyWith(location: value as String?);
        case 'farmSize':
          updatedUser = _user!.copyWith(farmSize: value as String?);
        case 'cropTypes':
          updatedUser = _user!.copyWith(cropTypes: value as List<String>);
        case 'experience':
          updatedUser = _user!.copyWith(experience: value as String?);
        case 'imageUrl':
          updatedUser = _user!.copyWith(imageUrl: value as String?);
        case 'profilePicture':
          updatedUser = _user!.copyWith(profilePicture: value as String?);
        case 'language':
          updatedUser = _user!.copyWith(language: value as String);
        case 'notificationsEnabled':
          updatedUser = _user!.copyWith(notificationsEnabled: value as bool);
        case 'weatherAlertsEnabled':
          updatedUser = _user!.copyWith(weatherAlertsEnabled: value as bool);
        case 'cropRemindersEnabled':
          updatedUser = _user!.copyWith(cropRemindersEnabled: value as bool);
        default:
          throw Exception('Unknown field: $field');
      }

      await updateUser(updatedUser);
    } catch (e) {
      _setError('Failed to update $field: ${e.toString()}');
      throw Exception('Failed to update $field: $e');
    }
  }

  /// Sets the current user (useful for testing or manual user setting)
  void setUser(UserModel user) {
    _user = user;
    _setStatus(AuthStatus.authenticated);
    notifyListeners();
  }

  /// Clears the current user data
  void clearUser() {
    _user = null;
    _verificationId = null;
    _setStatus(AuthStatus.unauthenticated);
    notifyListeners();
  }

  /// Updates user profile picture from image picker
  Future<void> updateProfilePicture(
      {ImageSource source = ImageSource.gallery}) async {
    try {
      _setLoading(true);

      final imagePath = await UserModel.pickAndSaveImage(source: source);
      if (imagePath != null && _user != null) {
        // Delete old image if it exists
        if (_user!.profilePicture != null) {
          await UserModel.deleteImage(_user!.profilePicture);
        }

        // Update user with new image path
        await updateUserField('profilePicture', imagePath);
      }
    } catch (e) {
      _setError('Failed to update profile picture: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.initial;
    }
    notifyListeners();
  }
}