// providers/auth_provider.dart
import 'dart:async';
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
  Timer? _otpTimer;
  int _otpCountdown = 0;
  bool _canResendOtp = true;

  // Stream subscription
  StreamSubscription<User?>? _authStateSubscription;

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
    _authStateSubscription = _authService.authStateChanges.listen((User? user) async {
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
        // Create new user profile for existing Firebase Auth users
        _user = UserModel(
          id: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          profilePicture: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isVerified: firebaseUser.emailVerified,
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
      _setError(_getAuthErrorMessage(e));
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
        // Send email verification
        await userCredential!.user!.sendEmailVerification();

        // Create user profile with additional data
        final userData = UserModel(
          id: userCredential.user!.uid,
          email: email,
          name: name,
          phoneNumber: '',
          userType: userType,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isVerified: false, // Email verification required
          language: 'en',
          notificationsEnabled: true,
          weatherAlertsEnabled: true,
          cropRemindersEnabled: true,
          preferences: {},
          cropTypes: (additionalData?['cropTypes'] as List<dynamic>?)?.cast<String>() ?? [],
          serviceCategories: (additionalData?['serviceCategories'] as List<dynamic>?)?.cast<String>() ?? [],
          businessDocuments: [],
          verificationStatus: VerificationStatus.pending,
          rating: 0,
          totalTransactions: 0,
          isActiveVendor: false,
          // Additional fields from additionalData
          location: additionalData?['location'] as String?,
          farmSize: additionalData?['farmSize'] as String?,
          experience: additionalData?['experience'] as String?,
          businessName: additionalData?['businessName'] as String?,
          businessAddress: additionalData?['businessAddress'] as String?,
          businessPhone: additionalData?['businessPhone'] as String?,
          businessEmail: additionalData?['businessEmail'] as String?,
          businessRegistrationNumber: additionalData?['businessRegistrationNumber'] as String?,
          businessDescription: additionalData?['businessDescription'] as String?,
        );

        await _firebaseService.createUserData(
          userCredential.user!.uid,
          userData.toMap(),
        );
        
        return true;
      }
      
      _setError('Failed to register');
      return false;
    } catch (e) {
      _setError(_getAuthErrorMessage(e));
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
      _setError(_getAuthErrorMessage(e));
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

      final completePhoneNumber = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

      await _authService.sendOTP(
        phoneNumber: completePhoneNumber,
        onCodeSent: (String verificationId) {
          _verificationId = verificationId;
          _startOtpTimer();
        },
        onError: (String error) {
          _setError(error);
        },
        onAutoVerified: (UserCredential userCredential) {
          // Auto verification successful - will be handled by auth state listener
        },
      );
      
      return true;
    } catch (e) {
      _setError(_getAuthErrorMessage(e));
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
          final userData = UserModel(
            id: user.uid,
            phoneNumber: user.phoneNumber ?? '',
            name: name ?? '',
            email: '',
            userType: userType,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            isVerified: true, // Phone is verified
            language: 'en',
            notificationsEnabled: true,
            weatherAlertsEnabled: true,
            cropRemindersEnabled: true,
            preferences: {},
            cropTypes: (additionalData?['cropTypes'] as List<dynamic>?)?.cast<String>() ?? [],
            serviceCategories: (additionalData?['serviceCategories'] as List<dynamic>?)?.cast<String>() ?? [],
            businessDocuments: [],
            verificationStatus: VerificationStatus.pending,
            rating: 0,
            totalTransactions: 0,
            isActiveVendor: false,
            // Additional fields from additionalData
            location: additionalData?['location'] as String?,
            farmSize: additionalData?['farmSize'] as String?,
            experience: additionalData?['experience'] as String?,
            businessName: additionalData?['businessName'] as String?,
            businessAddress: additionalData?['businessAddress'] as String?,
            businessPhone: additionalData?['businessPhone'] as String?,
            businessEmail: additionalData?['businessEmail'] as String?,
            businessRegistrationNumber: additionalData?['businessRegistrationNumber'] as String?,
            businessDescription: additionalData?['businessDescription'] as String?,
          );

          await _firebaseService.createUserData(user.uid, userData.toMap());
        }
        
        _stopOtpTimer();
        return true;
      }
      
      _setError('Invalid OTP');
      return false;
    } catch (e) {
      _setError(_getAuthErrorMessage(e));
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
          final userData = UserModel(
            id: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phoneNumber: user.phoneNumber ?? '',
            profilePicture: user.photoURL,
            userType: UserType.farmer,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            isVerified: user.emailVerified,
            language: 'en',
            notificationsEnabled: true,
            weatherAlertsEnabled: true,
            cropRemindersEnabled: true,
            preferences: {},
            cropTypes: [],
            serviceCategories: [],
            businessDocuments: [],
            verificationStatus: VerificationStatus.pending,
            rating: 0,
            totalTransactions: 0,
            isActiveVendor: false,
          );

          await _firebaseService.createUserData(user.uid, userData.toMap());
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(_getAuthErrorMessage(e));
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
        case 'profilePicture':
          updatedUser = _user!.copyWith(profilePicture: value as String?);
          break;
        case 'notificationsEnabled':
          updatedUser = _user!.copyWith(notificationsEnabled: value as bool);
          break;
        case 'weatherAlertsEnabled':
          updatedUser = _user!.copyWith(weatherAlertsEnabled: value as bool);
          break;
        case 'cropRemindersEnabled':
          updatedUser = _user!.copyWith(cropRemindersEnabled: value as bool);
          break;
        case 'language':
          updatedUser = _user!.copyWith(language: value as String);
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
      _setError(_getAuthErrorMessage(e));
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
      _setError(_getAuthErrorMessage(e));
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
      _setError(_getAuthErrorMessage(e));
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
      _setError(_getAuthErrorMessage(e));
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
      _stopOtpTimer();
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
  void _startOtpTimer() {
    _otpCountdown = 60;
    _canResendOtp = false;
    notifyListeners();

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _otpCountdown--;
      if (_otpCountdown <= 0) {
        _canResendOtp = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  /// Stop OTP countdown timer
  void _stopOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
    _canResendOtp = true;
    _otpCountdown = 0;
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

  /// Get user-friendly error messages
  String _getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Try again later.';
        case 'invalid-phone-number':
          return 'The phone number is not valid.';
        case 'invalid-verification-code':
          return 'The verification code is invalid.';
        case 'invalid-verification-id':
          return 'The verification ID is invalid.';
        case 'credential-already-in-use':
          return 'This credential is already associated with a different user account.';
        case 'provider-already-linked':
          return 'This account is already linked with this provider.';
        case 'requires-recent-login':
          return 'This operation requires recent authentication. Please log in again.';
        default:
          return error.message ?? 'An unknown error occurred.';
      }
    }
    return error.toString();
  }

  // Validation Methods

  /// Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number format (Indian)
  bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phoneNumber);
  }

  /// Validate password strength
  bool isValidPassword(String password) =>
      password.length >= 8 &&
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]')) &&
      password.contains(RegExp(r'[0-9]'));

  /// Get password strength score (0-5)
  int getPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  /// Get password strength text
  String getPasswordStrengthText(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Very Weak';
    }
  }

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
    _authStateSubscription?.cancel();
    _stopOtpTimer();
    _authService.dispose();
    super.dispose();
  }
}