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

  // User Management
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

  /// Updates user data in Firestore (NEW METHOD)
  Future<void> updateUserData(String uid, Map<String, dynamic> userData) async {
    try {
      // Add server timestamp for updates
      final dataWithTimestamp = {
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(dataWithTimestamp);
    } catch (e) {
      print('Error updating user data: $e');
      // If document doesn't exist, create it instead
      if (e.toString().contains('No document to update')) {
        await createUserData(uid, userData);
      } else {
        throw FirebaseServiceException('Failed to update user data: ${e.toString()}');
      }
    }
  }

  /// Updates user profile using UserModel (NEW CONVENIENCE METHOD)
  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      final userMap = userModel.toMap();
      await updateUserData(userModel.id, userMap);
    } catch (e) {
      print('Error updating user profile: $e');
      throw FirebaseServiceException('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Creates or updates user data
  Future<void> createOrUpdateUser(UserModel userModel) async {
    try {
      final userMap = userModel.toMap();
      userMap['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_usersCollection)
          .doc(userModel.id)
          .set(userMap, SetOptions(merge: true));
    } catch (e) {
      print('Error creating/updating user: $e');
      throw FirebaseServiceException('Failed to create/update user: ${e.toString()}');
    }
  }

  /// Gets user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      throw FirebaseServiceException('Failed to get user: ${e.toString()}');
    }
  }

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

  // Crop Management
  /// Saves crop data to Firestore
  Future<void> saveCropData(Map<String, dynamic> cropData) async {
    try {
      // Ensure required fields and add timestamps
      final dataWithTimestamp = {
        ...cropData,
        'createdAt': cropData['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_cropsCollection)
          .doc(cropData['id'] as String)
          .set(dataWithTimestamp);
    } catch (e) {
      print('Error saving crop data: $e');
      throw FirebaseServiceException('Failed to save crop data: ${e.toString()}');
    }
  }

  /// Gets user's crops
  Future<List<Map<String, dynamic>>> getUserCrops(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_cropsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
            'id': doc.id,
            ...doc.data(),
          })
          .toList();
    } catch (e) {
      print('Error getting user crops: $e');
      // Handle case where index might not exist
      if (e.toString().contains('index')) {
        // Fallback to getting all user crops without ordering
        try {
          final snapshot = await _firestore
              .collection(_cropsCollection)
              .where('userId', isEqualTo: userId)
              .get();

          final crops = snapshot.docs
              .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
              .toList();

          // Sort in memory
          crops.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return crops;
        } catch (fallbackError) {
          throw FirebaseServiceException('Failed to get user crops: ${fallbackError.toString()}');
        }
      }
      throw FirebaseServiceException('Failed to get user crops: ${e.toString()}');
    }
  }

  /// Updates crop status
  Future<void> updateCropStatus(String cropId, String status) async {
    try {
      await _firestore
          .collection(_cropsCollection)
          .doc(cropId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating crop status: $e');
      throw FirebaseServiceException('Failed to update crop status: ${e.toString()}');
    }
  }

  // Disease Detection History
  /// Saves disease detection data
  Future<void> saveDiseaseDetection(Map<String, dynamic> diseaseData) async {
    try {
      final dataWithTimestamp = {
        ...diseaseData,
        'detectedAt': diseaseData['detectedAt'] ?? FieldValue.serverTimestamp(),
        'createdAt': diseaseData['createdAt'] ?? FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_diseasesCollection)
          .doc(diseaseData['id'] as String)
          .set(dataWithTimestamp);
    } catch (e) {
      print('Error saving disease detection: $e');
      throw FirebaseServiceException('Failed to save disease detection: ${e.toString()}');
    }
  }

  /// Gets user's disease detection history
  Future<List<Map<String, dynamic>>> getUserDiseaseHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_diseasesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('detectedAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => {
            'id': doc.id,
            ...doc.data(),
          })
          .toList();
    } catch (e) {
      print('Error getting disease history: $e');
      if (e.toString().contains('index')) {
        // Fallback without ordering
        try {
          final snapshot = await _firestore
              .collection(_diseasesCollection)
              .where('userId', isEqualTo: userId)
              .limit(50)
              .get();

          final diseases = snapshot.docs
              .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
              .toList();

          // Sort in memory
          diseases.sort((a, b) {
            final aTime = a['detectedAt'] as Timestamp?;
            final bTime = b['detectedAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return diseases;
        } catch (fallbackError) {
          throw FirebaseServiceException('Failed to get disease history: ${fallbackError.toString()}');
        }
      }
      throw FirebaseServiceException('Failed to get disease history: ${e.toString()}');
    }
  }

  // Prediction History
  /// Saves prediction result
  Future<void> savePredictionResult(Map<String, dynamic> predictionData) async {
    try {
      final dataWithTimestamp = {
        ...predictionData,
        'createdAt': predictionData['createdAt'] ?? FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_predictionsCollection)
          .doc(predictionData['id'] as String)
          .set(dataWithTimestamp);
    } catch (e) {
      print('Error saving prediction: $e');
      throw FirebaseServiceException('Failed to save prediction: ${e.toString()}');
    }
  }

  /// Gets user's predictions
  Future<List<Map<String, dynamic>>> getUserPredictions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_predictionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      return snapshot.docs
          .map((doc) => {
            'id': doc.id,
            ...doc.data(),
          })
          .toList();
    } catch (e) {
      print('Error getting predictions: $e');
      if (e.toString().contains('index')) {
        try {
          final snapshot = await _firestore
              .collection(_predictionsCollection)
              .where('userId', isEqualTo: userId)
              .limit(30)
              .get();

          final predictions = snapshot.docs
              .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
              .toList();

          predictions.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return predictions;
        } catch (fallbackError) {
          throw FirebaseServiceException('Failed to get predictions: ${fallbackError.toString()}');
        }
      }
      throw FirebaseServiceException('Failed to get predictions: ${e.toString()}');
    }
  }

  // Tool Rental Management
  /// Saves tool rental data
  Future<void> saveToolRental(Map<String, dynamic> rentalData) async {
    try {
      final dataWithTimestamp = {
        ...rentalData,
        'createdAt': rentalData['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_rentalsCollection)
          .doc(rentalData['id'] as String)
          .set(dataWithTimestamp);
    } catch (e) {
      print('Error saving rental: $e');
      throw FirebaseServiceException('Failed to save rental: ${e.toString()}');
    }
  }

  /// Gets user's rentals
  Future<List<Map<String, dynamic>>> getUserRentals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_rentalsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
            'id': doc.id,
            ...doc.data(),
          })
          .toList();
    } catch (e) {
      print('Error getting rentals: $e');
      if (e.toString().contains('index')) {
        try {
          final snapshot = await _firestore
              .collection(_rentalsCollection)
              .where('userId', isEqualTo: userId)
              .get();

          final rentals = snapshot.docs
              .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
              .toList();

          rentals.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return rentals;
        } catch (fallbackError) {
          throw FirebaseServiceException('Failed to get rentals: ${fallbackError.toString()}');
        }
      }
      throw FirebaseServiceException('Failed to get rentals: ${e.toString()}');
    }
  }

  /// Updates rental status
  Future<void> updateRentalStatus(String rentalId, String status) async {
    try {
      await _firestore
          .collection(_rentalsCollection)
          .doc(rentalId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating rental status: $e');
      throw FirebaseServiceException('Failed to update rental status: ${e.toString()}');
    }
  }

  // Tools Management
  /// Gets available tools with optional filters
  Future<List<Map<String, dynamic>>> getAvailableTools({
    String? category,
    double? maxDistance,
    GeoPoint? userLocation,
  }) async {
    try {
      Query query = _firestore
          .collection(_toolsCollection)
          .where('isAvailable', isEqualTo: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      var tools = snapshot.docs
          .map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          })
          .toList();

      // Filter by distance if location is provided
      if (userLocation != null && maxDistance != null) {
        tools = tools.where((tool) {
          final toolLocation = tool['location'] as GeoPoint?;
          if (toolLocation != null) {
            final distance = _calculateDistance(
              userLocation.latitude,
              userLocation.longitude,
              toolLocation.latitude,
              toolLocation.longitude,
            );
            return distance <= maxDistance;
          }
          return false;
        }).toList();
      }

      return tools;
    } catch (e) {
      print('Error getting available tools: $e');
      throw FirebaseServiceException('Failed to get available tools: ${e.toString()}');
    }
  }

  // Expert Consultations
  /// Books a consultation with an expert
  Future<String> bookConsultation({
    required String expertId,
    required String userId,
    required DateTime preferredTime,
    required String query,
  }) async {
    try {
      final docRef = _firestore.collection(_consultationsCollection).doc();
      final consultation = {
        'id': docRef.id,
        'expertId': expertId,
        'userId': userId,
        'query': query,
        'preferredTime': Timestamp.fromDate(preferredTime),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(consultation);
      return docRef.id;
    } catch (e) {
      print('Error booking consultation: $e');
      throw FirebaseServiceException('Failed to book consultation: ${e.toString()}');
    }
  }

  /// Gets user's consultations
  Future<List<Map<String, dynamic>>> getUserConsultations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_consultationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting consultations: $e');
      if (e.toString().contains('index')) {
        try {
          final snapshot = await _firestore
              .collection(_consultationsCollection)
              .where('userId', isEqualTo: userId)
              .get();

          final consultations = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();

          consultations.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return consultations;
        } catch (fallbackError) {
          throw FirebaseServiceException('Failed to get consultations: ${fallbackError.toString()}');
        }
      }
      throw FirebaseServiceException('Failed to get consultations: ${e.toString()}');
    }
  }

  // Notifications
  /// Saves notification to Firestore
  Future<String> saveNotification({
    required String userId,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      final docRef = _firestore.collection(_notificationsCollection).doc();
      await docRef.set({
        'userId': userId,
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error saving notification: $e');
      throw FirebaseServiceException('Failed to save notification: ${e.toString()}');
    }
  }

  /// Gets user's notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      if (e.toString().contains('index')) {
        try {
          final snapshot = await _firestore
              .collection(_notificationsCollection)
              .where('userId', isEqualTo: userId)
              .limit(50)
              .get();

          final notifications = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();

          notifications.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return notifications;
        } catch (fallbackError) {
          throw FirebaseServiceException('Failed to get notifications: ${fallbackError.toString()}');
        }
      }
      throw FirebaseServiceException('Failed to get notifications: ${e.toString()}');
    }
  }

  /// Marks notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      throw FirebaseServiceException('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Feedback and Reviews
  /// Submits feedback
  Future<String> submitFeedback({
    required String userId,
    required String type,
    required String content,
    int? rating,
  }) async {
    try {
      final docRef = _firestore.collection(_feedbackCollection).doc();
      await docRef.set({
        'userId': userId,
        'type': type,
        'content': content,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error submitting feedback: $e');
      throw FirebaseServiceException('Failed to submit feedback: ${e.toString()}');
    }
  }

  // File Storage
  /// Uploads image to Firebase Storage
  Future<String> uploadImage({
    required String filePath,
    required String folderName,
    String? fileName,
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
      
      // Add metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
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

  /// Deletes image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      throw FirebaseServiceException('Failed to delete image: ${e.toString()}');
    }
  }

  // Real-time listeners
  /// Gets user data stream
  Stream<UserModel?> getUserStream(String userId) => _firestore
      .collection(_usersCollection)
      .doc(userId)
      .snapshots()
      .map((doc) {
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!);
        }
        return null;
      })
      .handleError((Object error) {
        print('Error in user stream: $error');
        throw FirebaseServiceException('Failed to get user stream: ${error.toString()}');
      });

  /// Gets notifications stream
  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) => _firestore
      .collection(_notificationsCollection)
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList())
      .handleError((Object error) {
        print('Error in notifications stream: $error');
        throw FirebaseServiceException('Failed to get notifications stream: ${error.toString()}');
      });

  // FCM Token Management
  /// Gets FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      throw FirebaseServiceException('Failed to get FCM token: ${e.toString()}');
    }
  }

  /// Updates user's FCM token
  Future<void> updateUserFCMToken(String userId, String token) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating FCM token: $e');
      throw FirebaseServiceException('Failed to update FCM token: ${e.toString()}');
    }
  }

  // Utility methods
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

  // Batch operations
  /// Performs batch write operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final ref = _firestore
            .collection(operation['collection'] as String)
            .doc(operation['docId'] as String?);
        
        switch (operation['type'] as String) {
          case 'set':
            batch.set(ref, operation['data'] as Map<String, dynamic>);
            break;
          case 'update':
            batch.update(ref, operation['data'] as Map<String, dynamic>);
            break;
          case 'delete':
            batch.delete(ref);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('Batch operation failed: $e');
      throw FirebaseServiceException('Batch operation failed: ${e.toString()}');
    }
  }

  // Connection status
  /// Checks if connected to Firebase
  Future<bool> isConnected() async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Simple read operation to check connectivity
        await transaction.get(_firestore.collection('_connection_test').doc('test'));
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cleanup method
  /// Disposes resources
  Future<void> dispose() async {
    // Clean up any resources if needed
    // This is useful for testing or when you need to reset the service
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