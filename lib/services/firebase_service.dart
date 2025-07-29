import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';
import '../models/crop_model.dart';
import '../models/tool_model.dart';
import '../models/rental_model.dart';
import '../models/disease_model.dart';
import '../models/prediction_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

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
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirebaseException('Failed to get current user: ${e.toString()}');
    }
  }

  Future<void> createOrUpdateUser(UserModel userModel) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userModel.id)
          .set(userModel.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw FirebaseException('Failed to create/update user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirebaseException('Failed to get user: ${e.toString()}');
    }
  }

  // Crop Management
  Future<void> saveCropData(CropModel crop) async {
    try {
      await _firestore
          .collection(_cropsCollection)
          .doc(crop.id)
          .set(crop.toMap());
    } catch (e) {
      throw FirebaseException('Failed to save crop data: ${e.toString()}');
    }
  }

  Future<List<CropModel>> getUserCrops(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_cropsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CropModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw FirebaseException('Failed to get user crops: ${e.toString()}');
    }
  }

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
      throw FirebaseException('Failed to update crop status: ${e.toString()}');
    }
  }

  // Disease Detection History
  Future<void> saveDiseaseDetection(DiseaseModel disease) async {
    try {
      await _firestore
          .collection(_diseasesCollection)
          .doc(disease.id)
          .set(disease.toMap());
    } catch (e) {
      throw FirebaseException('Failed to save disease detection: ${e.toString()}');
    }
  }

  Future<List<DiseaseModel>> getUserDiseaseHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_diseasesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('detectedAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => DiseaseModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw FirebaseException('Failed to get disease history: ${e.toString()}');
    }
  }

  // Prediction History
  Future<void> savePredictionResult(PredictionModel prediction) async {
    try {
      await _firestore
          .collection(_predictionsCollection)
          .doc(prediction.id)
          .set(prediction.toMap());
    } catch (e) {
      throw FirebaseException('Failed to save prediction: ${e.toString()}');
    }
  }

  Future<List<PredictionModel>> getUserPredictions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_predictionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      return snapshot.docs
          .map((doc) => PredictionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw FirebaseException('Failed to get predictions: ${e.toString()}');
    }
  }

  // Tool Rental Management
  Future<void> saveToolRental(RentalModel rental) async {
    try {
      await _firestore
          .collection(_rentalsCollection)
          .doc(rental.id)
          .set(rental.toMap());
    } catch (e) {
      throw FirebaseException('Failed to save rental: ${e.toString()}');
    }
  }

  Future<List<RentalModel>> getUserRentals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_rentalsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RentalModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw FirebaseException('Failed to get rentals: ${e.toString()}');
    }
  }

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
      throw FirebaseException('Failed to update rental status: ${e.toString()}');
    }
  }

  // Tools Management
  Future<List<ToolModel>> getAvailableTools({
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
      List<ToolModel> tools = snapshot.docs
          .map((doc) => ToolModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by distance if location is provided
      if (userLocation != null && maxDistance != null) {
        tools = tools.where((tool) {
          if (tool.location != null) {
            final distance = _calculateDistance(
              userLocation.latitude,
              userLocation.longitude,
              tool.location!.latitude,
              tool.location!.longitude,
            );
            return distance <= maxDistance;
          }
          return false;
        }).toList();
      }

      return tools;
    } catch (e) {
      throw FirebaseException('Failed to get available tools: ${e.toString()}');
    }
  }

  // Expert Consultations
  Future<void> bookConsultation({
    required String expertId,
    required String userId,
    required DateTime preferredTime,
    required String query,
  }) async {
    try {
      final consultation = {
        'id': _firestore.collection(_consultationsCollection).doc().id,
        'expertId': expertId,
        'userId': userId,
        'query': query,
        'preferredTime': Timestamp.fromDate(preferredTime),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_consultationsCollection)
          .doc(consultation['id'] as String)
          .set(consultation);
    } catch (e) {
      throw FirebaseException('Failed to book consultation: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getUserConsultations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_consultationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirebaseException('Failed to get consultations: ${e.toString()}');
    }
  }

  // Notifications
  Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .add({
        'userId': userId,
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseException('Failed to save notification: ${e.toString()}');
    }
  }

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
      throw FirebaseException('Failed to get notifications: ${e.toString()}');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw FirebaseException('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Feedback and Reviews
  Future<void> submitFeedback({
    required String userId,
    required String type,
    required String content,
    int? rating,
  }) async {
    try {
      await _firestore
          .collection(_feedbackCollection)
          .add({
        'userId': userId,
        'type': type,
        'content': content,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseException('Failed to submit feedback: ${e.toString()}');
    }
  }

  // File Storage
  Future<String> uploadImage({
    required String filePath,
    required String folderName,
    String? fileName,
  }) async {
    try {
      final file = File(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'image_$timestamp.jpg';
      
      final ref = _storage.ref().child('$folderName/$name');
      final uploadTask = ref.putFile(file);
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw FirebaseException('Failed to upload image: ${e.toString()}');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw FirebaseException('Failed to delete image: ${e.toString()}');
    }
  }

  // Real-time listeners
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList());
  }

  // FCM Token Management
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      throw FirebaseException('Failed to get FCM token: ${e.toString()}');
    }
  }

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
      throw FirebaseException('Failed to update FCM token: ${e.toString()}');
    }
  }

  // Utility methods
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        (lat1 * (3.14159265359 / 180)).cos() * (lat2 * (3.14159265359 / 180)).cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Batch operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final ref = _firestore
            .collection(operation['collection'])
            .doc(operation['docId']);
        
        switch (operation['type']) {
          case 'set':
            batch.set(ref, operation['data']);
            break;
          case 'update':
            batch.update(ref, operation['data']);
            break;
          case 'delete':
            batch.delete(ref);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw FirebaseException('Batch operation failed: ${e.toString()}');
    }
  }
}

class FirebaseException implements Exception {
  final String message;

  FirebaseException(this.message);

  @override
  String toString() => 'FirebaseException: $message';
}