// services/firebase_service.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

/// Comprehensive Firebase service for all Firebase operations
class FirebaseService {
  /// Factory constructor for singleton pattern
  factory FirebaseService() => _instance;

  // Private constructor for singleton pattern
  FirebaseService._internal();

  static final FirebaseService _instance = FirebaseService._internal();

  // Firebase service instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // Removed unused _messaging field
  // final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Collection references - made them instance members with documentation
  /// Users collection name
  String get usersCollectionName => 'users';
  /// Businesses collection name  
  String get businessesCollectionName => 'businesses';
  /// Transactions collection name
  String get transactionsCollectionName => 'transactions';
  /// Crops collection name
  String get cropsCollectionName => 'crops';
  /// Tools collection name
  String get toolsCollectionName => 'tools';
  /// Rentals collection name
  String get rentalsCollectionName => 'rentals';
  /// Diseases collection name
  String get diseasesCollectionName => 'diseases';
  /// Predictions collection name
  String get predictionsCollectionName => 'predictions';
  /// Consultations collection name
  String get consultationsCollectionName => 'consultations';
  /// Feedback collection name
  String get feedbackCollectionName => 'feedback';
  /// Notifications collection name
  String get notificationsCollectionName => 'notifications';

  // ============= AUTHENTICATION & USER MANAGEMENT =============

  /// Gets the current authenticated user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(usersCollectionName)
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      throw FirebaseServiceException('Failed to get current user: $e');
    }
  }

  /// Get user data by ID
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data != null ? {'id': userId, ...data} : null;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      throw FirebaseServiceException('Failed to get user data: $e');
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .get();
      
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }

  /// Create user data with enhanced validation
  Future<void> createUserData(String userId, Map<String, dynamic> userData) async {
    try {
      // Validate user data before creating
      if (!validateUserData({...userData, 'id': userId})) {
        throw FirebaseServiceException('Invalid user data provided');
      }

      final dataWithTimestamp = {
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .set(dataWithTimestamp, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating user data: $e');
      throw FirebaseServiceException('Failed to create user data: $e');
    }
  }

  /// Update user data with timestamp
  Future<void> updateUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .update({
            ...userData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error updating user data: $e');
      throw FirebaseServiceException('Failed to update user data: $e');
    }
  }

  /// Update specific user fields
  Future<void> updateUserField(String userId, String field, dynamic value) async {
    try {
      await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .update({
            field: value,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error updating user field: $e');
      throw FirebaseServiceException('Failed to update user field: $e');
    }
  }

  /// Update multiple user fields
  Future<void> updateUserFields(String userId, Map<String, dynamic> fields) async {
    try {
      await updateUserData(userId, fields);
    } catch (e) {
      throw FirebaseServiceException('Failed to update user fields: $e');
    }
  }

  /// Delete user data
  Future<void> deleteUserData(String userId) async {
    try {
      await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      throw FirebaseServiceException('Failed to delete user data: $e');
    }
  }

  // ============= USER QUERIES & SEARCHES =============

  /// Get users by phone number
  Future<List<Map<String, dynamic>>> getUsersByPhoneNumber(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollectionName)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error getting users by phone number: $e');
      throw FirebaseServiceException('Failed to get users by phone number: $e');
    }
  }

  /// Get users by email
  Future<List<Map<String, dynamic>>> getUsersByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollectionName)
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error getting users by email: $e');
      throw FirebaseServiceException('Failed to get users by email: $e');
    }
  }

  /// Get users by type
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollectionName)
          .where('userType', isEqualTo: userType)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error getting users by type: $e');
      throw FirebaseServiceException('Failed to get users by type: $e');
    }
  }

  /// Get verified vendors
  Future<List<Map<String, dynamic>>> getVerifiedVendors() async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollectionName)
          .where('userType', isEqualTo: 'vendor')
          .where('verificationStatus', isEqualTo: 'verified')
          .where('isActiveVendor', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error getting verified vendors: $e');
      throw FirebaseServiceException('Failed to get verified vendors: $e');
    }
  }

  /// Get verified business users (vendors and sellers)
  Future<List<Map<String, dynamic>>> getVerifiedBusinessUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollectionName)
          .where('verificationStatus', isEqualTo: 'verified')
          .where('userType', whereIn: ['vendor', 'seller'])
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error getting verified business users: $e');
      throw FirebaseServiceException('Failed to get verified business users: $e');
    }
  }

  /// Search users by name with enhanced filtering
  Future<List<Map<String, dynamic>>> searchUsersByName(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error searching users by name: $e');
      throw FirebaseServiceException('Failed to search users by name: $e');
    }
  }

  /// Enhanced search users with multiple criteria
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    String? userType,
    int limit = 20,
  }) async {
    try {
      Query baseQuery = _firestore.collection(usersCollectionName);
      
      if (userType != null) {
        baseQuery = baseQuery.where('userType', isEqualTo: userType);
      }
      
      final querySnapshot = await baseQuery.limit(limit).get();
      
      final results = querySnapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
      
      // Client-side filtering for name and business name
      final filteredResults = results.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        final businessName = user['businessName']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || businessName.contains(searchQuery);
      }).toList();
      
      return filteredResults;
    } catch (e) {
      debugPrint('Error searching users: $e');
      throw FirebaseServiceException('Failed to search users: $e');
    }
  }

  /// Get users by service categories
  Future<List<Map<String, dynamic>>> getUsersByCategory({
    required String category,
    String? userType,
    int limit = 20,
  }) async {
    try {
      Query baseQuery = _firestore.collection(usersCollectionName);
      
      if (userType != null) {
        baseQuery = baseQuery.where('userType', isEqualTo: userType);
      }
      
      final querySnapshot = await baseQuery
          .where('serviceCategories', arrayContains: category)
          .where('verificationStatus', isEqualTo: 'verified')
          .where('isActiveVendor', isEqualTo: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error getting users by category: $e');
      throw FirebaseServiceException('Failed to get users by category: $e');
    }
  }

  // ============= PAGINATION & LOCATION QUERIES =============

  /// Get users with pagination
  Future<List<Map<String, dynamic>>> getUsersWithPagination({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? userType,
  }) async {
    try {
      Query query = _firestore
          .collection(usersCollectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (userType != null) {
        query = query.where('userType', isEqualTo: userType);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data()! as Map<String, dynamic>,
                'documentSnapshot': doc,
              })
          .toList();
    } catch (e) {
      debugPrint('Error getting users with pagination: $e');
      throw FirebaseServiceException('Failed to get users with pagination: $e');
    }
  }

  /// Get nearby users with distance calculation
  Future<List<Map<String, dynamic>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? userType,
  }) async {
    try {
      Query query = _firestore.collection(usersCollectionName);

      if (userType != null) {
        query = query.where('userType', isEqualTo: userType);
      }

      final querySnapshot = await query.get();
      final nearbyUsers = <Map<String, dynamic>>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data()! as Map<String, dynamic>;
        final userLat = data['latitude'] as double?;
        final userLng = data['longitude'] as double?;

        if (userLat != null && userLng != null) {
          final distance = _calculateDistance(latitude, longitude, userLat, userLng);

          if (distance <= radiusInKm) {
            nearbyUsers.add({
              'id': doc.id,
              ...data,
              'distance': distance,
            });
          }
        }
      }

      // Sort by distance
      nearbyUsers.sort((a, b) => 
          (a['distance'] as double).compareTo(b['distance'] as double));

      return nearbyUsers;
    } catch (e) {
      debugPrint('Error getting nearby users: $e');
      throw FirebaseServiceException('Failed to get nearby users: $e');
    }
  }

  /// Get users near location (alias for compatibility)
  Future<List<Map<String, dynamic>>> getUsersNearLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? userType,
    int limit = 20,
  }) async {
    final results = await getNearbyUsers(
      latitude: latitude,
      longitude: longitude,
      radiusInKm: radiusKm,
      userType: userType,
    );
    return results.take(limit).toList();
  }

  // ============= BUSINESS OPERATIONS =============

  /// Update user verification status
  Future<void> updateVerificationStatus(
    String userId,
    String verificationStatus, {
    String? rejectionReason,
    String? reason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'verificationStatus': verificationStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }

      if (reason != null) {
        updateData['verificationReason'] = reason;
      }

      // If verified, activate the vendor
      if (verificationStatus == 'verified') {
        updateData['isActiveVendor'] = true;
      }

      await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .update(updateData);
    } catch (e) {
      debugPrint('Error updating verification status: $e');
      throw FirebaseServiceException('Failed to update verification status: $e');
    }
  }

  /// Update user rating
  Future<void> updateUserRating(String userId, double newRating, int totalTransactions) async {
    try {
      await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .update({
        'rating': newRating,
        'totalTransactions': totalTransactions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user rating: $e');
      throw FirebaseServiceException('Failed to update user rating: $e');
    }
  }

  /// Update business rating with total ratings count
  Future<void> updateBusinessRating({
    required String userId,
    required double newRating,
    required int totalRatings,
  }) async {
    try {
      await updateUserData(userId, {
        'rating': newRating,
        'totalRatings': totalRatings,
      });
    } catch (e) {
      throw FirebaseServiceException('Failed to update business rating: $e');
    }
  }

  /// Increment transaction count
  Future<void> incrementTransactionCount(String userId) async {
    try {
      await updateUserData(userId, {
        'totalTransactions': FieldValue.increment(1),
      });
    } catch (e) {
      throw FirebaseServiceException('Failed to increment transaction count: $e');
    }
  }

  /// Add business documents
  Future<void> addBusinessDocuments({
    required String userId,
    required List<String> documentUrls,
  }) async {
    try {
      await updateUserData(userId, {
        'businessDocuments': FieldValue.arrayUnion(documentUrls),
      });
    } catch (e) {
      throw FirebaseServiceException('Failed to add business documents: $e');
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
      throw FirebaseServiceException('Failed to update user preferences: $e');
    }
  }

  /// Update user business information
  Future<void> updateBusinessInfo(
    String userId,
    Map<String, dynamic> businessInfo,
  ) async {
    try {
      final updateData = <String, dynamic>{
        ...businessInfo,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .update(updateData);
    } catch (e) {
      debugPrint('Error updating business info: $e');
      throw FirebaseServiceException('Failed to update business info: $e');
    }
  }

  // ============= VALIDATION & CHECKS =============

  /// Check if phone number is already registered
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      final users = await getUsersByPhoneNumber(phoneNumber);
      return users.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking phone number registration: $e');
      return false;
    }
  }

  /// Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final users = await getUsersByEmail(email);
      return users.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking email registration: $e');
      return false;
    }
  }

  /// Check if user has permission for action
  Future<bool> hasPermission({
    required String userId,
    required String action,
  }) async {
    try {
      final userData = await getUserData(userId);
      if (userData == null) {
        return false;
      }
      
      final userType = userData['userType'] as String?;
      final verificationStatus = userData['verificationStatus'] as String?;
      final isActiveVendor = userData['isActiveVendor'] as bool? ?? false;
      
      switch (action) {
        case 'create_listing':
          return (userType == 'vendor' || userType == 'seller') &&
                 verificationStatus == 'verified' &&
                 isActiveVendor;
        case 'accept_bookings':
          return userType == 'vendor' &&
                 verificationStatus == 'verified' &&
                 isActiveVendor;
        case 'manage_inventory':
          return userType == 'seller' &&
                 verificationStatus == 'verified' &&
                 isActiveVendor;
        case 'admin_access':
          return userType == 'admin';
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Validate user data structure
  bool validateUserData(Map<String, dynamic> userData) {
    // Required fields
    const requiredFields = ['id', 'name', 'userType'];
    
    for (final field in requiredFields) {
      if (!userData.containsKey(field) || userData[field] == null) {
        return false;
      }
    }
    
    // Validate user type
    const validUserTypes = ['farmer', 'vendor', 'seller', 'expert', 'admin'];
    if (!validUserTypes.contains(userData['userType'])) {
      return false;
    }
    
    // Additional validation for business users
    if (['vendor', 'seller'].contains(userData['userType'])) {
      const businessRequiredFields = ['businessName', 'businessAddress', 'serviceCategories'];
      
      for (final field in businessRequiredFields) {
        if (!userData.containsKey(field) || userData[field] == null) {
          return false;
        }
      }
      
      // Validate service categories
      final serviceCategories = userData['serviceCategories'];
      if (serviceCategories is! List || serviceCategories.isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  // ============= FIREBASE STORAGE OPERATIONS =============

  /// Upload disease detection image
  Future<String?> uploadDiseaseImage(File imageFile, String userId) async {
    try {
      final fileName = 'disease_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await _uploadImageWithMetadata(
        imageFile,
        'users/$userId/disease_images/$fileName',
        {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'disease_detection',
        },
      );
    } catch (e) {
      throw FirebaseServiceException('Failed to upload disease image: $e');
    }
  }

  /// Upload crop prediction image
  Future<String?> uploadCropImage(File imageFile, String userId) async {
    try {
      final fileName = 'crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await _uploadImageWithMetadata(
        imageFile,
        'users/$userId/crop_images/$fileName',
        {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'crop_prediction',
        },
      );
    } catch (e) {
      throw FirebaseServiceException('Failed to upload crop image: $e');
    }
  }

  /// Upload user profile picture
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final downloadUrl = await _uploadImageWithMetadata(
        imageFile,
        'users/$userId/profile/profile_picture.jpg',
        {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'profile_picture',
        },
      );
      
      if (downloadUrl != null) {
        // Update user profile in Firestore
        await updateUserFields(userId, {'profileImageUrl': downloadUrl});
      }
      
      return downloadUrl;
    } catch (e) {
      throw FirebaseServiceException('Failed to upload profile picture: $e');
    }
  }

  /// Upload tool rental images
  Future<List<String>> uploadToolImages(List<File> imageFiles, String toolId, String userId) async {
    final downloadUrls = <String>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final fileName = 'tool_${toolId}_$i.jpg';
        final downloadUrl = await _uploadImageWithMetadata(
          imageFiles[i],
          'tools/$toolId/$fileName',
          {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'tool_image',
            'toolId': toolId,
          },
        );
        
        if (downloadUrl != null) {
          downloadUrls.add(downloadUrl);
        }
      } catch (e) {
        debugPrint('Error uploading tool image $i: $e');
      }
    }
    
    return downloadUrls;
  }

  /// Upload marketplace product images
  Future<List<String>> uploadMarketplaceImages(List<File> imageFiles, String productId, String userId) async {
    final downloadUrls = <String>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final fileName = 'product_${productId}_$i.jpg';
        final downloadUrl = await _uploadImageWithMetadata(
          imageFiles[i],
          'marketplace/$productId/$fileName',
          {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'marketplace_image',
            'productId': productId,
          },
        );
        
        if (downloadUrl != null) {
          downloadUrls.add(downloadUrl);
        }
      } catch (e) {
        debugPrint('Error uploading marketplace image $i: $e');
      }
    }
    
    return downloadUrls;
  }

  /// Enhanced upload image method
  Future<String> uploadImage({
    required String filePath,
    required String folderName,
    String? fileName,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final file = File(filePath);
      
      if (!file.existsSync()) {
        throw FirebaseServiceException('File does not exist: $filePath');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'image_$timestamp.jpg';
      
      final downloadUrl = await _uploadImageWithMetadata(
        file,
        '$folderName/$name',
        {
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?customMetadata,
        },
      );
      
      return downloadUrl ?? '';
    } catch (e) {
      throw FirebaseServiceException('Failed to upload image: $e');
    }
  }

  /// Upload with progress tracking
  Future<String?> uploadWithProgress(
    File imageFile, 
    String storagePath,
    void Function(double)? onProgress,
    Map<String, String>? customMetadata,
  ) async {
    try {
      final ref = _storage.ref().child(storagePath);
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: customMetadata,
      );
      
      final uploadTask = ref.putFile(imageFile, metadata);
      
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw FirebaseServiceException('Failed to upload with progress: $e');
    }
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get image metadata
  Future<FullMetadata?> getImageMetadata(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      debugPrint('Error getting image metadata: $e');
      return null;
    }
  }

  // ============= BATCH OPERATIONS =============

  /// Batch update user data
  Future<void> batchUpdateUsers(Map<String, Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();

      updates.forEach((userId, data) {
        final userRef = _firestore
            .collection(usersCollectionName)
            .doc(userId);
        batch.update(userRef, {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error batch updating users: $e');
      throw FirebaseServiceException('Failed to batch update users: $e');
    }
  }

  /// Bulk operations for data migration or admin tasks
  Future<void> bulkUpdateUsers(
    List<String> userIds,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final userRef = _firestore
            .collection(usersCollectionName)
            .doc(userId);
        batch.update(userRef, {
          ...updateData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error bulk updating users: $e');
      throw FirebaseServiceException('Failed to bulk update users: $e');
    }
  }

  // ============= STATISTICS & ANALYTICS =============

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      // Use aggregation queries for better performance
      final farmersSnapshot = await _firestore
          .collection(usersCollectionName)
          .where('userType', isEqualTo: 'farmer')
          .count()
          .get();
      
      final vendorsSnapshot = await _firestore
          .collection(usersCollectionName)
          .where('userType', isEqualTo: 'vendor')
          .count()
          .get();
      
      final sellersSnapshot = await _firestore
          .collection(usersCollectionName)
          .where('userType', isEqualTo: 'seller')
          .count()
          .get();

      final expertsSnapshot = await _firestore
          .collection(usersCollectionName)
          .where('userType', isEqualTo: 'expert')
          .count()
          .get();

      final adminsSnapshot = await _firestore
          .collection(usersCollectionName)
          .where('userType', isEqualTo: 'admin')
          .count()
          .get();
      
      final verifiedSnapshot = await _firestore
          .collection(usersCollectionName)
          .where('verificationStatus', isEqualTo: 'verified')
          .count()
          .get();

      final activeVendorsSnapshot = await _firestore
          .collection(usersCollectionName)
          .where('isActiveVendor', isEqualTo: true)
          .count()
          .get();

      final totalUsersSnapshot = await _firestore
          .collection(usersCollectionName)
          .count()
          .get();

      return {
        'total': totalUsersSnapshot.count,
        'totalFarmers': farmersSnapshot.count,
        'farmers': farmersSnapshot.count, // Legacy compatibility
        'totalVendors': vendorsSnapshot.count,
        'vendors': vendorsSnapshot.count, // Legacy compatibility
        'totalSellers': sellersSnapshot.count,
        'sellers': sellersSnapshot.count, // Legacy compatibility
        'experts': expertsSnapshot.count,
        'admins': adminsSnapshot.count,
        'verified': verifiedSnapshot.count,
        'verifiedBusinesses': verifiedSnapshot.count, // For business context
        'activeVendors': activeVendorsSnapshot.count,
      };
    } catch (e) {
      debugPrint('Error getting user statistics: $e');
      throw FirebaseServiceException('Failed to get user statistics: $e');
    }
  }

  // ============= REAL-TIME OPERATIONS =============

  /// Get user data stream for real-time updates
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream(String userId) {
    return _firestore
        .collection(usersCollectionName)
        .doc(userId)
        .snapshots();
  }

  /// Listen to user data changes with null safety
  Stream<Map<String, dynamic>?> getUserDataStreamSafe(String userId) {
    try {
      return _firestore
          .collection(usersCollectionName)
          .doc(userId)
          .snapshots()
          .map((doc) {
            if (doc.exists) {
              final data = doc.data();
              return data != null ? {'id': userId, ...data} : null;
            }
            return null;
          });
    } catch (e) {
      throw FirebaseServiceException('Failed to get user data stream: $e');
    }
  }

  /// Listen to users by type
  Stream<List<Map<String, dynamic>>> getUsersByTypeStream(String userType) {
    try {
      return _firestore
          .collection(usersCollectionName)
          .where('userType', isEqualTo: userType)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList());
    } catch (e) {
      throw FirebaseServiceException('Failed to get users by type stream: $e');
    }
  }

  /// Listen to pending verification requests
  Stream<List<Map<String, dynamic>>> getPendingVerificationStream() {
    try {
      return _firestore
          .collection(usersCollectionName)
          .where('verificationStatus', isEqualTo: 'pending')
          .where('userType', whereIn: ['vendor', 'seller'])
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList());
    } catch (e) {
      throw FirebaseServiceException('Failed to get pending verification stream: $e');
    }
  }

  // ============= ADMINISTRATIVE OPERATIONS =============

  /// Archive inactive users
  Future<void> archiveInactiveUsers({
    required int inactiveDaysThreshold,
    bool dryRun = true,
  }) async {
    try {
      final cutoffDate = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: inactiveDaysThreshold))
      );

      final querySnapshot = await _firestore
          .collection(usersCollectionName)
          .where('lastLoginAt', isLessThan: cutoffDate)
          .get();

      if (dryRun) {
        debugPrint('Found ${querySnapshot.docs.length} inactive users to archive');
        return;
      }

      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isArchived': true,
          'archivedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('Archived ${querySnapshot.docs.length} inactive users');
    } catch (e) {
      debugPrint('Error archiving inactive users: $e');
      throw FirebaseServiceException('Failed to archive inactive users: $e');
    }
  }

  /// Clean up test or demo data
  Future<void> cleanupTestData({
    List<String>? testUserIds,
    bool deleteTestUsers = false,
  }) async {
    try {
      if (testUserIds == null || testUserIds.isEmpty) {
        debugPrint('No test user IDs provided');
        return;
      }

      if (deleteTestUsers) {
        final batch = _firestore.batch();

        for (final userId in testUserIds) {
          final userRef = _firestore
              .collection(usersCollectionName)
              .doc(userId);
          batch.delete(userRef);
        }

        await batch.commit();
        debugPrint('Deleted ${testUserIds.length} test users');
      } else {
        debugPrint('Test cleanup called but deleteTestUsers is false');
      }
    } catch (e) {
      debugPrint('Error cleaning up test data: $e');
      throw FirebaseServiceException('Failed to cleanup test data: $e');
    }
  }

  /// Clean up expired data
  Future<void> cleanupExpiredData() async {
    try {
      // Delete users who haven't logged in for 2 years
      final twoYearsAgo = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 730))
      );
      
      final expiredUsersSnapshot = await _firestore
          .collection(usersCollectionName)
          .where('lastLoginAt', isLessThan: twoYearsAgo)
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in expiredUsersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      debugPrint('Cleaned up ${expiredUsersSnapshot.docs.length} expired users');
    } catch (e) {
      debugPrint('Error cleaning up expired data: $e');
      throw FirebaseServiceException('Failed to cleanup expired data: $e');
    }
  }

  // ============= UTILITY METHODS =============

  /// Get collection reference for advanced queries
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection(usersCollectionName);

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Private helper method for uploading images with metadata
  Future<String?> _uploadImageWithMetadata(
    File imageFile,
    String storagePath,
    Map<String, String> customMetadata,
  ) async {
    try {
      final ref = _storage.ref().child(storagePath);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: customMetadata,
      );

      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    debugPrint('FirebaseService disposed');
  }
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