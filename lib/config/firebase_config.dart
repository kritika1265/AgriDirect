import 'dart:io';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Singleton class to manage all Firebase services
class FirebaseConfig {
  /// Private constructor for singleton pattern
  FirebaseConfig._internal();
  
  /// Factory constructor that returns the singleton instance
  factory FirebaseConfig() => _instance;
  
  static final FirebaseConfig _instance = FirebaseConfig._internal();

  // Firebase service instances
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;
  late FirebaseMessaging _messaging;
  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;

  /// Firebase Auth instance getter
  FirebaseAuth get auth => _auth;
  
  /// Firestore instance getter
  FirebaseFirestore get firestore => _firestore;
  
  /// Storage instance getter
  FirebaseStorage get storage => _storage;
  
  /// Messaging instance getter
  FirebaseMessaging get messaging => _messaging;
  
  /// Analytics instance getter
  FirebaseAnalytics get analytics => _analytics;
  
  /// Crashlytics instance getter
  FirebaseCrashlytics get crashlytics => _crashlytics;

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
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable offline persistence for Firestore
      final settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _firestore.settings = settings;

      await _configureMessaging();
      await _configureAnalytics();
      await _configureCrashlytics();

      developer.log('Firebase initialized successfully');
    } catch (e) {
      developer.log('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Configure push notifications (FCM)
  Future<void> _configureMessaging() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        developer.log('User granted notification permission');

        final token = await _messaging.getToken();
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
      developer.log('Error configuring Firebase Messaging: $e');
    }
  }

  /// Enable and customize Firebase Analytics
  Future<void> _configureAnalytics() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _analytics.setUserProperty(name: 'app_type', value: 'agriculture');
      developer.log('Firebase Analytics configured');
    } catch (e) {
      developer.log('Error configuring Firebase Analytics: $e');
    }
  }

  /// Enable Firebase Crashlytics for error tracking
  Future<void> _configureCrashlytics() async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      developer.log('Firebase Crashlytics configured');
    } catch (e) {
      developer.log('Error configuring Firebase Crashlytics: $e');
    }
  }

  /// Get the current signed-in user
  User? getCurrentUser() => _auth.currentUser;

  /// Check if user is signed in
  bool isUserAuthenticated() => _auth.currentUser != null;

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      developer.log('User signed out successfully');
    } catch (e) {
      developer.log('Error signing out: $e');
      rethrow;
    }
  }

  /// Get document reference of a specific user
  DocumentReference getUserDocument(String userId) =>
      _firestore.collection(usersCollection).doc(userId);

  /// Get a Firestore collection by name
  CollectionReference getCollection(String collectionName) =>
      _firestore.collection(collectionName);

  /// Get a reference to a storage path
  Reference getStorageReference(String path) => _storage.ref().child(path);

  /// Upload a file and return the download URL
  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      developer.log('Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
      developer.log('File deleted successfully');
    } catch (e) {
      developer.log('Error deleting file: $e');
      rethrow;
    }
  }

  /// Log a custom event to Firebase Analytics
  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters == null ? null : Map<String, Object>.from(parameters),
      );
    } catch (e) {
      developer.log('Error logging event: $e');
    }
  }

  /// Log a screen view to Firebase Analytics
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      developer.log('Error logging screen view: $e');
    }
  }

  /// Report a caught error to Crashlytics
  Future<void> recordError(dynamic exception, StackTrace? stackTrace) async {
    try {
      await _crashlytics.recordError(exception, stackTrace);
    } catch (e) {
      developer.log('Error recording error: $e');
    }
  }

  /// Set the user identifier for Crashlytics tracking
  Future<void> setUserIdentifier(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      developer.log('Error setting user identifier: $e');
    }
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
}

/// Background FCM message handler (must be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
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
}