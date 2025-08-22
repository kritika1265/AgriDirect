// lib/services/firebase_service.dart
// Update your existing firebase_service.dart with storage methods

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';

/// Firebase service class for handling all Firebase operations
class FirebaseService {
  /// Private constructor for singleton pattern
  FirebaseService._internal();

  /// Factory constructor that returns the singleton instance
  factory FirebaseService() => _instance;

  static final FirebaseService _instance = FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _cropsCollection = 'crops';
  static const String _toolsCollection = 'tools';
  static const String _rentalsCollection = 'rentals';
  static const String _diseasesCollection = 'diseases';
  static const String _predictionsCollection = 'predictions';
  static const String _consultationsCollection = 'consultations';
  static const String _feedbackCollection = 'feedback';
  static const String _notificationsCollection = 'notifications';

  // ============= EXISTING USER MANAGEMENT METHODS =============
  // (Keep all your existing methods as they are)

  /// Gets the current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      throw FirebaseServiceException('Failed to get current user: ${e.toString()}');
    }
  }

  // Methods needed by AuthProvider
  /// Gets user data by user ID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      throw FirebaseServiceException('Failed to get user data: ${e.toString()}');
    }
  }
  
  /// Creates user data in Firestore
  Future<void> createUserData(String uid, Map<String, dynamic> userData) async {
    try {
      // Add server timestamp and validation
      final dataWithTimestamp = {
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(dataWithTimestamp, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user data: $e');
      throw FirebaseServiceException('Failed to create user data: ${e.toString()}');
    }
  }

  // ============= NEW FIREBASE STORAGE METHODS =============

  /// Upload disease detection image
  Future<String?> uploadDiseaseImage(File imageFile, String userId) async {
    try {
      final String fileName = 'disease_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('disease_images')
          .child(fileName);

      // Add metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'disease_detection',
        },
      );

      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading disease image: $e');
      throw FirebaseServiceException('Failed to upload disease image: ${e.toString()}');
    }
  }

  /// Upload crop prediction image
  Future<String?> uploadCropImage(File imageFile, String userId) async {
    try {
      final String fileName = 'crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('crop_images')
          .child(fileName);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'crop_prediction',
        },
      );

      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading crop image: $e');
      throw FirebaseServiceException('Failed to upload crop image: ${e.toString()}');
    }
  }

  /// Upload user profile picture
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final Reference ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('profile')
          .child('profile_picture.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'profile_picture',
        },
      );

      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update user profile in Firestore
      await updateUserFields(userId, {'profileImageUrl': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw FirebaseServiceException('Failed to upload profile picture: ${e.toString()}');
    }
  }

  /// Upload tool rental images
  Future<List<String>> uploadToolImages(List<File> imageFiles, String toolId, String userId) async {
    final List<String> downloadUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final String fileName = 'tool_${toolId}_$i.jpg';
        final Reference ref = _storage
            .ref()
            .child('tools')
            .child(toolId)
            .child(fileName);

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'tool_image',
            'toolId': toolId,
          },
        );

        final UploadTask uploadTask = ref.putFile(imageFiles[i], metadata);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading tool image $i: $e');
      }
    }
    
    return downloadUrls;
  }

  /// Upload marketplace product images
  Future<List<String>> uploadMarketplaceImages(List<File> imageFiles, String productId, String userId) async {
    final List<String> downloadUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final String fileName = 'product_${productId}_$i.jpg';
        final Reference ref = _storage
            .ref()
            .child('marketplace')
            .child(productId)
            .child(fileName);

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'marketplace_image',
            'productId': productId,
          },
        );

        final UploadTask uploadTask = ref.putFile(imageFiles[i], metadata);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading marketplace image $i: $e');
      }
    }
    
    return downloadUrls;
  }

  /// Upload with progress tracking
  Future<String?> uploadWithProgress(
    File imageFile, 
    String storagePath,
    Function(double)? onProgress,
    Map<String, String>? customMetadata,
  ) async {
    try {
      final Reference ref = _storage.ref().child(storagePath);
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: customMetadata,
      );
      
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading with progress: $e');
      throw FirebaseServiceException('Failed to upload with progress: ${e.toString()}');
    }
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Get image metadata
  Future<FullMetadata?> getImageMetadata(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      print('Error getting image metadata: $e');
      return null;
    }
  }

  /// Enhanced upload image method (replacing the existing one)
  @override
  Future<String> uploadImage({
    required String filePath,
    required String folderName,
    String? fileName,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final file = File(filePath);
      
      // Check if file exists
      if (!file.existsSync()) {
        throw FirebaseServiceException('File does not exist: $filePath');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'image_$timestamp.jpg';
      
      final ref = _storage.ref().child('$folderName/$name');
      
      // Enhanced metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?customMetadata,
        },
      );
      
      final uploadTask = ref.putFile(file, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw FirebaseServiceException('Failed to upload image: ${e.toString()}');
    }
  }

  // ============= ALL YOUR EXISTING METHODS CONTINUE HERE =============
  // (Keep all your existing crop management, disease detection, etc. methods)

  /// Updates specific user fields (NEW CONVENIENCE METHOD)
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      final updateData = {
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(updateData);
    } catch (e) {
      print('Error updating user fields: $e');
      throw FirebaseServiceException('Failed to update user fields: ${e.toString()}');
    }
  }

  // ... (Continue with all your existing methods)

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * (pi / 180);
}

/// Custom exception class for Firebase service errors
class FirebaseServiceException implements Exception {
  /// Error message
  final String message;
  /// Optional error code
  final String? code;

  /// Creates a Firebase service exception
  FirebaseServiceException(this.message, [this.code]);

  @override
  String toString() => 'FirebaseServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}