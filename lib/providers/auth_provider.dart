// providers/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

/// Authentication status enumeration
enum AuthStatus {
  /// Initial state
  initial,
  /// Loading state
  loading,
  /// User is authenticated
  authenticated,
  /// User is not authenticated
  unauthenticated,
  /// Error state
  error,
}

/// Enhanced authentication provider with email and phone support
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  // State variables
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  String? _verificationId;
  
  // OTP related
  int _otpCountdown = 0;
  bool _canResendOtp = true;

  /// Initialize authentication provider
  AuthProvider() {
    _initializeAuth();
  }

  // Getters
  /// Current authentication status
  AuthStatus get status => _status;
  /// Current user model
  UserModel? get user => _user;
  /// Current error message
  String? get errorMessage => _errorMessage;
  /// Whether provider is loading
  bool get isLoading => _isLoading;
  /// Whether user is authenticated
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  /// Current verification ID for OTP
  String? get verificationId => _verificationId;
  /// OTP countdown timer
  int get otpCountdown => _otpCountdown;
  /// Whether OTP can be resent
  bool get canResendOtp => _canResendOtp;

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await _loadUserData(user);
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
        
        // Update last login time
        await _firebaseService.updateUserData(firebaseUser.uid, {
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
        
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
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Email Authentication Methods

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        // User data will be loaded automatically via auth state listener
        return true;
      }
      
      _setError('Failed to sign in');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register with email and password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    UserType userType = UserType.farmer,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: name,
      );

      if (userCredential?.user != null) {
        // Create user profile with additional data
        final userData = <String, dynamic>{
          'id': userCredential!.user!.uid,
          'email': email,
          'name': name,
          'userType': userType.name,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLoginAt': DateTime.now().toIso8601String(),
          'isVerified': false,
          'phoneNumber': '',
          'language': 'en',
          'notificationsEnabled': true,
          'weatherAlertsEnabled': true,
          'cropRemindersEnabled': true,
          'preferences': <String, dynamic>{},
          'cropTypes': <String>[],
          'serviceCategories': <String>[],
          'businessDocuments': <String>[],
          'verificationStatus': VerificationStatus.pending.name,
          'rating': 0.0,
          'totalTransactions': 0,
          'isActiveVendor': false,
          ...?additionalData,
        };

        await _firebaseService.createUserData(
          userCredential.user!.uid,
          userData,
        );
        
        return true;
      }
      
      _setError('Failed to register');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phone Authentication Methods

  /// Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (String verificationId) {
          _verificationId = verificationId;
          _startOtpCountdown();
          notifyListeners();
        },
        onError: (String error) {
          _setError(error);
        },
        onAutoVerified: (UserCredential userCredential) {
          // Auto verification successful
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

  /// Verify OTP and complete sign in
  Future<bool> verifyOTP({
    required String verificationId,
    required String otp,
    String? name,
    UserType userType = UserType.farmer,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.verifyOTP(
        verificationId: verificationId,
        otp: otp,
      );

      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        // Check if user exists in Firestore
        final existsInFirestore = await _firebaseService.userExists(user.uid);
        
        if (!existsInFirestore) {
          // Create new user profile
          final userData = <String, dynamic>{
            'id': user.uid,
            'phoneNumber': user.phoneNumber ?? '',
            'name': name ?? '',
            'email': '',
            'userType': userType.name,
            'createdAt': DateTime.now().toIso8601String(),
            'lastLoginAt': DateTime.now().toIso8601String(),
            'isVerified': false,
            'language': 'en',
            'notificationsEnabled': true,
            'weatherAlertsEnabled': true,
            'cropRemindersEnabled': true,
            'preferences': <String, dynamic>{},
            'cropTypes': <String>[],
            'serviceCategories': <String>[],
            'businessDocuments': <String>[],
            'verificationStatus': VerificationStatus.pending.name,
            'rating': 0.0,
            'totalTransactions': 0,
            'isActiveVendor': false,
            ...?additionalData,
          };

          await _firebaseService.createUserData(user.uid, userData);
        }
        
        return true;
      }
      
      _setError('Invalid OTP');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend OTP
  Future<bool> resendOTP(String phoneNumber) async {
    if (!_canResendOtp) {
      _setError('Please wait before requesting another OTP');
      return false;
    }

    return sendOTP(phoneNumber);
  }

  // Google Sign In

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        // Check if user exists in Firestore
        final existsInFirestore = await _firebaseService.userExists(user.uid);
        
        if (!existsInFirestore) {
          // Create new user profile
          final userData = <String, dynamic>{
            'id': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'profilePicture': user.photoURL,
            'userType': UserType.farmer.name,
            'createdAt': DateTime.now().toIso8601String(),
            'lastLoginAt': DateTime.now().toIso8601String(),
            'isVerified': user.emailVerified,
            'language': 'en',
            'notificationsEnabled': true,
            'weatherAlertsEnabled': true,
            'cropRemindersEnabled': true,
            'preferences': <String, dynamic>{},
            'cropTypes': <String>[],
            'serviceCategories': <String>[],
            'businessDocuments': <String>[],
            'verificationStatus': VerificationStatus.pending.name,
            'rating': 0.0,
            'totalTransactions': 0,
            'isActiveVendor': false,
          };

          await _firebaseService.createUserData(user.uid, userData);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Account Management

  /// Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      _setLoading(true);
      _clearError();

      // Update Firebase Auth profile if needed
      if (updatedUser.name != _user?.name) {
        await _authService.updateUserProfile(displayName: updatedUser.name);
      }

      // Update Firestore document
      final userData = updatedUser.copyWith(
        updatedAt: DateTime.now(),
      ).toMap();

      await _firebaseService.updateUserData(updatedUser.id, userData);
      
      // Update local user data
      _user = updatedUser.copyWith(updatedAt: DateTime.now());
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update specific user field
  Future<bool> updateUserField(String field, dynamic value) async {
    if (_user == null) {
      _setError('No user logged in');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      var updatedUser = _user!;

      switch (field) {
        case 'name':
          updatedUser = _user!.copyWith(name: value as String);
          break;
        case 'email':
          updatedUser = _user!.copyWith(email: value as String);
          break;
        case 'location':
          updatedUser = _user!.copyWith(location: value as String?);
          break;
        case 'farmSize':
          updatedUser = _user!.copyWith(farmSize: value as String?);
          break;
        case 'cropTypes':
          updatedUser = _user!.copyWith(cropTypes: value as List<String>);
          break;
        case 'experience':
          updatedUser = _user!.copyWith(experience: value as String?);
          break;
        case 'userType':
          updatedUser = _user!.copyWith(userType: value as UserType);
          break;
        case 'businessName':
          updatedUser = _user!.copyWith(businessName: value as String?);
          break;
        case 'businessAddress':
          updatedUser = _user!.copyWith(businessAddress: value as String?);
          break;
        case 'serviceCategories':
          updatedUser = _user!.copyWith(serviceCategories: value as List<String>);
          break;
        default:
          _setError('Unknown field: $field');
          return false;
      }

      return await updateUserProfile(updatedUser);
    } catch (e) {
      _setError('Failed to update $field: $e');
      return false;
    }
  }

  /// Link email to phone account
  Future<bool> linkEmailToAccount({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.linkEmailToCurrentUser(
        email: email,
        password: password,
      );

      if (userCredential != null && _user != null) {
        // Update user email in Firestore
        await updateUserField('email', email);
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Link phone to email account
  Future<bool> linkPhoneToAccount({
    required String verificationId,
    required String otp,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.linkPhoneToCurrentUser(
        verificationId: verificationId,
        otp: otp,
      );

      if (userCredential?.user != null && _user != null) {
        // Update user phone in Firestore
        await updateUserField('phoneNumber', userCredential!.user!.phoneNumber ?? '');
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reload user to get updated verification status
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      
      // Reload user data from Firestore
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _loadUserData(currentUser);
      }
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      
      // Clear local state
      _user = null;
      _verificationId = null;
      _otpCountdown = 0;
      _canResendOtp = true;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _setError('Failed to sign out: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    if (_user == null) {
      _setError('No user logged in');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final userId = _user!.id;

      // Delete user data from Firestore
      await _firebaseService.deleteUserData(userId);

      // Delete Firebase Auth user
      await _authService.deleteUserAccount();

      // Clear local state
      _user = null;
      _verificationId = null;
      _setStatus(AuthStatus.unauthenticated);
      
      return true;
    } catch (e) {
      _setError('Failed to delete account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper Methods

  /// Start OTP countdown timer
  void _startOtpCountdown() {
    _otpCountdown = 60;
    _canResendOtp = false;
    notifyListeners();

    // Start countdown
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      _otpCountdown--;
      notifyListeners();
      
      if (_otpCountdown <= 0) {
        _canResendOtp = true;
        notifyListeners();
        return false;
      }
      
      return true;
    });
  }

  /// Set authentication status
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.initial;
    }
    notifyListeners();
  }

  // Validation Methods

  /// Validate email format
  bool isValidEmail(String email) => _authService.isValidEmail(email);

  /// Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) => _authService.isValidPhoneNumber(phoneNumber);

  /// Validate password strength
  bool isValidPassword(String password) => _authService.isValidPassword(password);

  /// Get password strength score
  int getPasswordStrength(String password) => _authService.getPasswordStrength(password);

  /// Get password strength text
  String getPasswordStrengthText(int score) => _authService.getPasswordStrengthText(score);

  // Provider Methods

  /// Check if user has email provider
  bool get hasEmailProvider => _authService.hasEmailProvider;

  /// Check if user has phone provider
  bool get hasPhoneProvider => _authService.hasPhoneProvider;

  /// Check if user has Google provider
  bool get hasGoogleProvider => _authService.hasGoogleProvider;

  /// Get user's sign-in methods
  List<String> get userSignInMethods => _authService.userSignInMethods;

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}