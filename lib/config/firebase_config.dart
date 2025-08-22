import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Singleton class to manage all Firebase services
class FirebaseConfig {
  /// Factory constructor that returns the singleton instance
  factory FirebaseConfig() => _instance;
  
  /// Private constructor for singleton pattern
  FirebaseConfig._internal();
  
  static final FirebaseConfig _instance = FirebaseConfig._internal();

  // Firebase service instances - nullable to handle initialization failures
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebaseMessaging? _messaging;
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  // Flag to track if Firebase is initialized
  bool _isInitialized = false;

  /// Firebase Auth instance getter
  FirebaseAuth? get auth => _auth;
  
  /// Firestore instance getter
  FirebaseFirestore? get firestore => _firestore;
  
  /// Storage instance getter
  FirebaseStorage? get storage => _storage;
  
  /// Messaging instance getter
  FirebaseMessaging? get messaging => _messaging;
  
  /// Analytics instance getter
  FirebaseAnalytics? get analytics => _analytics;
  
  /// Crashlytics instance getter
  FirebaseCrashlytics? get crashlytics => _crashlytics;

  /// Check if Firebase is properly initialized
  bool get isInitialized => _isInitialized;

  // Firestore collection names
  /// Users collection name
  static const String usersCollection = 'users';
  
  /// Crops collection name
  static const String cropsCollection = 'crops';
  
  /// Tools collection name
  static const String toolsCollection = 'tools';
  
  /// Rentals collection name
  static const String rentalsCollection = 'rentals';
  
  /// Plant diseases collection name
  static const String diseasesCollection = 'plant_diseases';
  
  /// ML predictions collection name
  static const String predictionsCollection = 'ml_predictions';
  
  /// Weather data collection name
  static const String weatherDataCollection = 'weather_data';
  
  /// News collection name
  static const String newsCollection = 'news_feed';
  
  /// Notifications collection name
  static const String notificationsCollection = 'notifications';
  
  /// Farming tips collection name
  static const String farmingTipsCollection = 'farming_tips';
  
  /// Crop calendar collection name
  static const String cropCalendarCollection = 'crop_calendar';
  
  /// Marketplace collection name
  static const String marketplaceCollection = 'marketplace';
  
  /// Expert consultation collection name
  static const String expertConsultationCollection = 'expert_consultations';

  // Firebase Storage folder paths
  /// Profile images storage path
  static const String profileImagesPath = 'profile_images';
  
  /// Crop images storage path
  static const String cropImagesPath = 'crop_images';
  
  /// Disease images storage path
  static const String diseaseImagesPath = 'disease_images';
  
  /// Tool images storage path
  static const String toolImagesPath = 'tool_images';
  
  /// Marketplace images storage path
  static const String marketplaceImagesPath = 'marketplace_images';
  
  /// Documents storage path
  static const String documentsPath = 'documents';
  
  /// ML models storage path
  static const String mlModelsPath = 'ml_models';

  /// Initializes all Firebase services
  Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        developer.log('⚠️ Firebase not initialized - skipping Firebase services');
        return;
      }

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable offline persistence for Firestore (only for mobile)
      if (!kIsWeb && _firestore != null) {
        try {
          const settings = Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
          _firestore!.settings = settings;
        } catch (e) {
          developer.log('⚠️ Warning: Could not enable Firestore offline persistence: $e');
        }
      }

      await _configureMessaging();
      await _configureAnalytics();
      await _configureCrashlytics();

      _isInitialized = true;
      developer.log('✅ Firebase services initialized successfully');
    } catch (e) {
      developer.log('❌ Error initializing Firebase services: $e');
      // Don't rethrow - app can work without Firebase
      _isInitialized = false;
    }
  }

  /// Configure push notifications (FCM)
  Future<void> _configureMessaging() async {
    if (_messaging == null || kIsWeb) {
      developer.log('⚠️ Skipping FCM configuration (not available or web platform)');
      return;
    }

    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        developer.log('✅ User granted notification permission');

        final token = await _messaging!.getToken();
        developer.log('FCM Token: $token');

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          developer.log('Received foreground message: ${message.messageId}');
        });

        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          developer.log('Message clicked: ${message.messageId}');
        });
      } else {
        developer.log('User declined or has not accepted notification permission');
      }
    } catch (e) {
      developer.log('⚠️ Error configuring Firebase Messaging: $e');
    }
  }

  /// Enable and customize Firebase Analytics
  Future<void> _configureAnalytics() async {
    if (_analytics == null) {
      return;
    }

    try {
      await _analytics!.setAnalyticsCollectionEnabled(true);
      await _analytics!.setUserProperty(name: 'app_type', value: 'agriculture');
      developer.log('✅ Firebase Analytics configured');
    } catch (e) {
      developer.log('⚠️ Error configuring Firebase Analytics: $e');
    }
  }

  /// Enable Firebase Crashlytics for error tracking
  Future<void> _configureCrashlytics() async {
    if (_crashlytics == null || kIsWeb) {
      developer.log('⚠️ Skipping Crashlytics configuration (not available or web platform)');
      return;
    }

    try {
      await _crashlytics!.setCrashlyticsCollectionEnabled(true);
      developer.log('✅ Firebase Crashlytics configured');
    } catch (e) {
      developer.log('⚠️ Error configuring Firebase Crashlytics: $e');
    }
  }

  /// Get the current signed-in user
  User? getCurrentUser() => _auth?.currentUser;

  /// Check if user is signed in
  bool isUserAuthenticated() => _auth?.currentUser != null;

  /// Sign out the current user
  Future<void> signOut() async {
    if (_auth == null) {
      developer.log('⚠️ Firebase Auth not available');
      return;
    }

    try {
      await _auth!.signOut();
      developer.log('✅ User signed out successfully');
    } catch (e) {
      developer.log('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Get document reference of a specific user
  DocumentReference? getUserDocument(String userId) {
    if (_firestore == null) {
      developer.log('⚠️ Firestore not available');
      return null;
    }
    return _firestore!.collection(usersCollection).doc(userId);
  }

  /// Get a Firestore collection by name
  CollectionReference? getCollection(String collectionName) {
    if (_firestore == null) {
      developer.log('⚠️ Firestore not available');
      return null;
    }
    return _firestore!.collection(collectionName);
  }

  /// Get a reference to a storage path
  Reference? getStorageReference(String path) {
    if (_storage == null) {
      developer.log('⚠️ Firebase Storage not available');
      return null;
    }
    return _storage!.ref().child(path);
  }

  /// Upload a file and return the download URL
  Future<String?> uploadFile(String path, File file) async {
    if (_storage == null) {
      developer.log('⚠️ Firebase Storage not available');
      return null;
    }

    try {
      final ref = _storage!.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      developer.log('❌ Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    if (_storage == null) {
      developer.log('⚠️ Firebase Storage not available');
      return;
    }

    try {
      final ref = _storage!.ref().child(path);
      await ref.delete();
      developer.log('✅ File deleted successfully');
    } catch (e) {
      developer.log('❌ Error deleting file: $e');
      rethrow;
    }
  }

  /// Log a custom event to Firebase Analytics
  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) async {
    if (_analytics == null) {
      return;
    }

    try {
      await _analytics!.logEvent(
        name: eventName,
        parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
      );
    } catch (e) {
      developer.log('⚠️ Error logging event: $e');
    }
  }

  /// Log a screen view to Firebase Analytics
  Future<void> logScreenView(String screenName) async {
    if (_analytics == null) {
      return;
    }

    try {
      await _analytics!.logScreenView(screenName: screenName);
    } catch (e) {
      developer.log('⚠️ Error logging screen view: $e');
    }
  }

  /// Report a caught error to Crashlytics
  Future<void> recordError(dynamic exception, StackTrace? stackTrace) async {
    if (_crashlytics == null) {
      return;
    }

    try {
      await _crashlytics!.recordError(exception, stackTrace);
    } catch (e) {
      developer.log('⚠️ Error recording error: $e');
    }
  }

  /// Set the user identifier for Crashlytics tracking
  Future<void> setUserIdentifier(String userId) async {
    if (_crashlytics == null) {
      return;
    }

    try {
      await _crashlytics!.setUserIdentifier(userId);
    } catch (e) {
      developer.log('⚠️ Error setting user identifier: $e');
    }
  }

  /// Get FCM token for push notifications
  Future<String?> getFCMToken() async {
    if (_messaging == null || kIsWeb) {
      return null;
    }
    
    try {
      return await _messaging!.getToken();
    } catch (e) {
      developer.log('⚠️ Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null || kIsWeb) {
      return;
    }
    
    try {
      await _messaging!.subscribeToTopic(topic);
      developer.log('✅ Subscribed to topic: $topic');
    } catch (e) {
      developer.log('⚠️ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null || kIsWeb) {
      return;
    }
    
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      developer.log('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      developer.log('⚠️ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Create a user document after registration
  Future<void> createUserDocument(String userId, Map<String, dynamic> userData) async {
    if (_firestore == null) {
      developer.log('⚠️ Firestore not available');
      return;
    }

    try {
      await _firestore!
          .collection(usersCollection)
          .doc(userId)
          .set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('✅ User document created successfully');
    } catch (e) {
      developer.log('❌ Error creating user document: $e');
      rethrow;
    }
  }

  /// Update user document
  Future<void> updateUserDocument(String userId, Map<String, dynamic> updates) async {
    if (_firestore == null) {
      developer.log('⚠️ Firestore not available');
      return;
    }

    try {
      await _firestore!
          .collection(usersCollection)
          .doc(userId)
          .update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('✅ User document updated successfully');
    } catch (e) {
      developer.log('❌ Error updating user document: $e');
      rethrow;
    }
  }

  /// Get user data stream
  Stream<DocumentSnapshot>? getUserDataStream(String userId) {
    if (_firestore == null) {
      developer.log('⚠️ Firestore not available');
      return null;
    }
    return _firestore!.collection(usersCollection).doc(userId).snapshots();
  }

  /// Upload image with compression and metadata
  Future<String?> uploadImage(String path, File imageFile, {
    Map<String, String>? metadata,
  }) async {
    if (_storage == null) {
      developer.log('⚠️ Firebase Storage not available');
      return null;
    }

    try {
      final ref = _storage!.ref().child(path);
      
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: metadata,
        ),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      developer.log('✅ Image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      developer.log('❌ Error uploading image: $e');
      rethrow;
    }
  }

  /// Batch write operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    if (_firestore == null) {
      developer.log('⚠️ Firestore not available');
      return;
    }

    try {
      final batch = _firestore!.batch();
      
      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String?;
        final data = operation['data'] as Map<String, dynamic>?;
        
        final docRef = docId != null
            ? _firestore!.collection(collection).doc(docId)
            : _firestore!.collection(collection).doc();
        
        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
      developer.log('✅ Batch write completed successfully');
    } catch (e) {
      developer.log('❌ Error in batch write: $e');
      rethrow;
    }
  }

  /// Add document to collection with auto-generated ID
  Future<String?> addDocument(String collection, Map<String, dynamic> data) async {
    if (_firestore == null) {
      developer.log('⚠️ Firestore not available');
      return null;
    }

    try {
      final docRef = await _firestore!.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('✅ Document added successfully');
      return docRef.id;
    } catch (e) {
      developer.log('❌ Error adding document: $e');
      rethrow;
    }
  }

  /// Query documents with pagination
  Query? queryCollection(
    String collection, {
    List<Map<String, dynamic>>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  }) {
    if (_firestore == null) {
      developer.log('⚠️ Firestore not available');
      return null;
    }

    Query query = _firestore!.collection(collection);

    // Apply where clauses
    if (where != null) {
      for (final condition in where) {
        final field = condition['field'] as String;
        final operator = condition['operator'] as String;
        final value = condition['value'];

        switch (operator) {
          case '==':
            query = query.where(field, isEqualTo: value);
            break;
          case '!=':
            query = query.where(field, isNotEqualTo: value);
            break;
          case '>':
            query = query.where(field, isGreaterThan: value);
            break;
          case '>=':
            query = query.where(field, isGreaterThanOrEqualTo: value);
            break;
          case '<':
            query = query.where(field, isLessThan: value);
            break;
          case '<=':
            query = query.where(field, isLessThanOrEqualTo: value);
            break;
          case 'array-contains':
            query = query.where(field, arrayContains: value);
            break;
          case 'in':
            query = query.where(field, whereIn: value as List<Object?>?);
            break;
        }
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply pagination
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }

  // Environment-specific Firebase configs
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  /// Current environment
  static String get environment => _isProduction ? 'production' : 'development';

  /// Database URL based on environment
  static String get databaseUrl => _isProduction
      ? 'https://agridirect-prod.firebaseio.com'
      : 'https://agridirect-dev.firebaseio.com';

  /// Storage bucket based on environment
  static String get storageBucket => _isProduction
      ? 'agridirect-prod.appspot.com'
      : 'agridirect-dev.appspot.com';

  /// Dispose method to clean up resources
  void dispose() {
    // Clean up any listeners or resources if needed
    _isInitialized = false;
    developer.log('🧹 Firebase Config disposed');
  }
}

/// Background FCM message handler (must be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Only initialize if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  developer.log('Handling background message: ${message.messageId}');
}

/// Constants used across the app
class FirebaseConstants {
  /// Maximum retry attempts for operations
  static const int maxRetryAttempts = 3;
  
  /// Delay between retry attempts
  static const Duration retryDelay = Duration(seconds: 2);
  
  /// Network operation timeout
  static const Duration networkTimeout = Duration(seconds: 30);
  
  /// Maximum file upload size (10MB)
  static const int maxFileUploadSize = 10 * 1024 * 1024;

  /// Supported image file formats
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  /// Supported document file formats
  static const List<String> supportedDocumentFormats = ['pdf', 'doc', 'docx'];

  /// Cache expiration duration
  static const Duration cacheExpiration = Duration(hours: 24);
  
  /// Maximum cache size (100MB)
  static const int maxCacheSize = 100 * 1024 * 1024;

  /// Default page size for pagination
  static const int defaultPageSize = 20;
  
  /// Maximum page size for pagination
  static const int maxPageSize = 100;

  /// FCM topic names for agriculture app
  static const String weatherAlertsTopic = 'weather_alerts';
  
  /// Crop updates topic
  static const String cropUpdatesTopic = 'crop_updates';
  
  /// Market prices topic
  static const String marketPricesTopic = 'market_prices';
  
  /// Farming tips topic
  static const String farmingTipsTopic = 'farming_tips';
  
  /// Disease alerts topic
  static const String diseaseAlertsTopic = 'disease_alerts';
  
  /// General news topic
  static const String generalNewsTopic = 'general_news';

  /// Analytics event names
  /// Crop added event
  static const String cropAddedEvent = 'crop_added';
  
  /// Disease detected event
  static const String diseaseDetectedEvent = 'disease_detected';
  
  /// Tool rented event
  static const String toolRentedEvent = 'tool_rented';
  
  /// Marketplace purchase event
  static const String marketplacePurchaseEvent = 'marketplace_purchase';
  
  /// Expert consultation event
  static const String expertConsultationEvent = 'expert_consultation';
  
  /// Weather alert viewed event
  static const String weatherAlertViewedEvent = 'weather_alert_viewed';

  /// User roles
  /// Farmer role
  static const String farmerRole = 'farmer';
  
  /// Expert role
  static const String expertRole = 'expert';
  
  /// Supplier role
  static const String supplierRole = 'supplier';
  
  /// Admin role
  static const String adminRole = 'admin';

  /// Crop categories
  static const List<String> cropCategories = [
    'cereals',
    'vegetables',
    'fruits',
    'pulses',
    'spices',
    'cash_crops',
    'fodder'
  ];

  /// Tool categories
  static const List<String> toolCategories = [
    'plowing',
    'sowing',
    'irrigation',
    'harvesting',
    'processing',
    'transport'
  ];
}

/// Extension methods for Firebase operations
extension FirebaseConfigExtensions on FirebaseConfig {
  /// Check if a specific service is available
  bool isServiceAvailable(String service) {
    switch (service.toLowerCase()) {
      case 'auth':
        return _auth != null;
      case 'firestore':
        return _firestore != null;
      case 'storage':
        return _storage != null;
      case 'messaging':
        return _messaging != null;
      case 'analytics':
        return _analytics != null;
      case 'crashlytics':
        return _crashlytics != null;
      default:
        return false;
    }
  }

  /// Get all available services
  List<String> get availableServices {
    final services = <String>[];
    if (_auth != null) {
      services.add('auth');
    }
    if (_firestore != null) {
      services.add('firestore');
    }
    if (_storage != null) {
      services.add('storage');
    }
    if (_messaging != null) {
      services.add('messaging');
    }
    if (_analytics != null) {
      services.add('analytics');
    }
    if (_crashlytics != null) {
      services.add('crashlytics');
    }
    return services;
  }
}