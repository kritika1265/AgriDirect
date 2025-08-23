// services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enhanced authentication service with comprehensive email, phone authentication support
class AuthService {
  // Private constructor for singleton pattern
  AuthService._internal();
  
  /// Factory constructor for singleton pattern
  factory AuthService() => _instance;

  static final AuthService _instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _verificationId;
  int? _resendToken;

  // Getters
  
  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current verification ID for OTP
  String? get verificationId => _verificationId;

  /// Resend token for OTP
  int? get resendToken => _resendToken;

  // Email Authentication Methods

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Email sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Email sign in error: $e');
      throw Exception('Failed to sign in with email: $e');
    }
  }

  /// Register with email and password
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
    bool sendVerification = true,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Send email verification if requested
      if (sendVerification) {
        await userCredential.user?.sendEmailVerification();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Email registration error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Email registration error: $e');
      throw Exception('Failed to register with email: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Password reset error: $e');
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw Exception('No user logged in');
      } else {
        throw Exception('Email already verified');
      }
    } catch (e) {
      debugPrint('Email verification error: $e');
      throw Exception('Failed to send email verification: $e');
    }
  }

  /// Reload current user to get updated verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading user: $e');
      throw Exception('Failed to reload user: $e');
    }
  }

  // Phone Authentication Methods

  /// Send OTP to phone number with enhanced callback support
  Future<void> sendOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(UserCredential)? onAutoVerified,
    int? resendToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _formatPhoneNumber(phoneNumber),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            onAutoVerified?.call(userCredential);
          } catch (e) {
            debugPrint('Auto-verification failed: $e');
            onError('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone verification failed: ${e.code} - ${e.message}');
          onError(_handleAuthException(e).toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('Auto-retrieval timeout for verification ID: $verificationId');
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
      );
    } catch (e) {
      debugPrint('Send OTP error: $e');
      onError('Failed to send OTP: $e');
    }
  }

  /// Legacy sendOTP method for backward compatibility
  Future<void> sendOTPLegacy({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
    required void Function(UserCredential) onAutoVerified,
  }) async {
    await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerified: onAutoVerified,
    );
  }

  /// Verify OTP and sign in
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp.trim(),
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('OTP verification error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('OTP verification error: $e');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  /// Resend OTP using stored phone number and resend token
  Future<void> resendOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      resendToken: _resendToken,
    );
  }

  // Google Sign In Methods - Currently Disabled

  /// Sign in with Google - Requires google_sign_in package
  /// To enable: Add 'google_sign_in: ^6.1.5' to pubspec.yaml
  Future<UserCredential?> signInWithGoogle() async {
    throw UnsupportedError(
      'Google Sign In is not available. Add google_sign_in package to enable this feature.',
    );
  }

  // Account Management Methods

  /// Link email/password to current user account
  Future<UserCredential?> linkEmailToCurrentUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );

      final userCredential = await user.linkWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Link email error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Link email error: $e');
      throw Exception('Failed to link email: $e');
    }
  }

  /// Link phone number to current user account
  Future<UserCredential?> linkPhoneToCurrentUser({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp.trim(),
      );

      final userCredential = await user.linkWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Link phone error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Link phone error: $e');
      throw Exception('Failed to link phone: $e');
    }
  }

  /// Update user profile information
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();
    } catch (e) {
      debugPrint('Update profile error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Change password for email users (requires current password)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No email user logged in');
      }

      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      debugPrint('Change password error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Change password error: $e');
      throw Exception('Failed to change password: $e');
    }
  }

  /// Sign out current user from all providers
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      
      // Clear verification data
      _clearVerificationData();
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Delete current user account permanently
  Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      await user.delete();
      
      // Clear verification data
      _clearVerificationData();
    } on FirebaseAuthException catch (e) {
      debugPrint('Delete account error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Delete account error: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  // Provider Information Methods

  /// Check if user has email/password provider
  bool get hasEmailProvider {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    
    return user.providerData.any(
      (provider) => provider.providerId == 'password',
    );
  }

  /// Check if user has phone provider
  bool get hasPhoneProvider {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    
    return user.providerData.any(
      (provider) => provider.providerId == 'phone',
    );
  }

  /// Check if user has Google provider
  bool get hasGoogleProvider {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    
    return user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );
  }

  /// Get all user's sign-in methods
  List<String> get userSignInMethods {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }
    
    return user.providerData.map((provider) => provider.providerId).toList();
  }

  /// Fetch sign-in methods for a given email (deprecated method)
  @Deprecated('This method is deprecated due to security concerns')
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      // This method is deprecated but kept for compatibility
      // Consider using alternative approaches for checking email existence
      return [];
    } catch (e) {
      debugPrint('Error fetching sign-in methods: $e');
      return [];
    }
  }

  // Validation Methods

  /// Validate email format using comprehensive regex
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  /// Validate phone number format (supports Indian format primarily)
  bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check for valid phone number patterns
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      return RegExp(r'^\+91[6-9]\d{9}$').hasMatch(cleaned);
    }
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return RegExp(r'^91[6-9]\d{9}$').hasMatch(cleaned);
    }
    if (cleaned.length == 10) {
      return RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned);
    }
    
    return false;
  }

  /// Validate password strength (minimum requirements)
  bool isValidPassword(String password) {
    if (password.length < 8) {
      return false;
    }
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasDigits;
  }

  /// Get password strength score (0-5)
  int getPasswordStrength(String password) {
    int score = 0;
    
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (password.length >= 12) score++; // Bonus for longer passwords
    
    return score > 5 ? 5 : score;
  }

  /// Get password strength description
  String getPasswordStrengthText(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Medium';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return 'Very Weak';
    }
  }

  /// Get password strength color for UI
  Color getPasswordStrengthColor(int score) {
    switch (score) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  // Helper Methods

  /// Format phone number to E.164 international format
  String _formatPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If already starts with +91, keep as is
    if (cleaned.startsWith('+91')) {
      return cleaned;
    }
    
    // If starts with 91 and is 12 digits, add +
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    }
    
    // If 10 digits, assume Indian number and add +91
    if (cleaned.length == 10) {
      return '+91$cleaned';
    }
    
    // If starts with +, keep as is (international format)
    if (cleaned.startsWith('+')) {
      return cleaned;
    }
    
    // Default: return as is if no clear pattern
    return cleaned;
  }

  /// Clear verification data
  void _clearVerificationData() {
    _verificationId = null;
    _resendToken = null;
  }

  /// Handle Firebase Auth exceptions and provide user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    final String message;
    
    switch (e.code) {
      // Email/Password errors
      case 'user-not-found':
        message = 'No user found with this email address.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'This email address is already registered.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Please choose a stronger password.';
        break;
      case 'invalid-email':
        message = 'Invalid email address format.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      
      // Phone authentication errors
      case 'invalid-phone-number':
        message = 'Invalid phone number format.';
        break;
      case 'invalid-verification-code':
        message = 'Invalid verification code. Please try again.';
        break;
      case 'invalid-verification-id':
        message = 'Invalid verification ID.';
        break;
      case 'session-expired':
        message = 'Verification session has expired. Please request a new code.';
        break;
      case 'quota-exceeded':
        message = 'SMS quota exceeded. Please try again later.';
        break;
      case 'missing-verification-code':
        message = 'Please enter the verification code.';
        break;
      case 'missing-verification-id':
        message = 'Verification ID is missing.';
        break;
      
      // General errors
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled.';
        break;
      case 'requires-recent-login':
        message = 'Please log in again to perform this action.';
        break;
      case 'credential-already-in-use':
        message = 'This credential is already associated with another account.';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials provided.';
        break;
      case 'account-exists-with-different-credential':
        message = 'An account already exists with a different sign-in method.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection and try again.';
        break;
      
      // Default case
      default:
        message = e.message ?? 'An authentication error occurred.';
        break;
    }
    
    return Exception(message);
  }

  /// Dispose resources and clear data
  void dispose() => _clearVerificationData();
}