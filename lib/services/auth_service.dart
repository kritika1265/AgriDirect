import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service class for handling Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      // Ensure phone number has country code
      final formattedPhone = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+91$phoneNumber'; // Add your country code

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            onError('Auto verification failed: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          final errorMessage = _getFirebaseAuthErrorMessage(e);
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if needed
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Verify OTP and sign in user
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      // Validate OTP format
      if (otp.isEmpty || otp.length != 6) {
        throw Exception('Invalid OTP format. Please enter 6-digit code.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp.trim(), // Remove any whitespace
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getFirebaseAuthErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Verification failed: ${e.toString()}');
    }
  }

  /// Create user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      final userData = user.toMap();
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(userData, SetOptions(merge: true)); // Use merge to avoid overwriting
    } on FirebaseException catch (e) {
      throw Exception('Failed to create user profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Failed to get user profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(UserModel user) async {
    try {
      if (user.id.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      final userData = user.toMap();
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(userData);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update user profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign out: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Delete current user account and data
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final userId = user.uid;

      // Delete user data from Firestore first
      await _firestore.collection('users').doc(userId).delete();
      
      // Then delete Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please re-authenticate before deleting your account');
      }
      throw Exception('Failed to delete account: ${e.message}');
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete user data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current user ID safely
  String get currentUserId => currentUser?.uid ?? '';

  /// Re-authenticate user with phone credential
  Future<void> reauthenticateWithPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Re-authentication failed: ${e.toString()}');
    }
  }

  /// Helper method to get user-friendly error messages
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is not valid.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please re-authenticate to perform this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  /// Check if phone number is valid format
  bool isValidPhoneNumber(String phoneNumber) {
    // Basic validation - you might want to use a more robust solution
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'\s+'), ''));
  }

  /// Get user's phone number
  String? get currentUserPhoneNumber => currentUser?.phoneNumber;
}