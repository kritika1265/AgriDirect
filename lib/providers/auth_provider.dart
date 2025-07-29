import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  
  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  
  AuthProvider() {
    _initializeAuth();
  }
  
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
  
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _authService.sendOTP(phoneNumber);
      if (!success) {
        _setError('Failed to send OTP. Please try again.');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> verifyOTP(String otp) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.verifyOTP(otp);
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
  
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }