import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Singleton class to manage all Firebase services
class FirebaseConfig {
  static final FirebaseConfig _instance = FirebaseConfig._internal();
  factory FirebaseConfig() => _instance;
  FirebaseConfig._internal();

  // Firebase service instances
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;
  late FirebaseMessaging _messaging;
  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;

  // Getters for external access
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  FirebaseMessaging get messaging => _messaging;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String cropsCollection = 'crops';
  static const String toolsCollection = 'tools';
  static const String rentalsCollection = 'rentals';
  static const String diseasesCollection = 'plant_diseases';
  static const String predictionsCollection = 'ml_predictions';
  static const String weatherDataCollection = 'weather_data';
  static const String newsCollection = 'news_feed';
  static const String notificationsCollection = 'notifications';
  static const String farmingTipsCollection = 'farming_tips';
  static const String cropCalendarCollection = 'crop_calendar';
  static const String marketplaceCollection = 'marketplace';
  static const String expertConsultationCollection = 'expert_consultations';

  // Firebase Storage folder paths
  static const String profileImagesPath = 'profile_images';
  static const String cropImagesPath = 'crop_images';
  static const String diseaseImagesPath = 'disease_images';
  static const String toolImagesPath = 'tool_images';
  static const String marketplaceImagesPath = 'marketplace_images';
  static const String documentsPath = 'documents';
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
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      await _configureMessaging();
      await _configureAnalytics();
      await _configureCrashlytics();

      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Configure push notifications (FCM)
  Future<void> _configureMessaging() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');

        String? token = await _messaging.getToken();
        print('FCM Token: $token');

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Received foreground message: ${message.messageId}');
        });

        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('Message clicked: ${message.messageId}');
        });
      } else {
        print('User declined or has not accepted notification permission');
      }
    } catch (e) {
      print('Error configuring Firebase Messaging: $e');
    }
  }

  /// Enable and customize Firebase Analytics
  Future<void> _configureAnalytics() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _analytics.setUserProperty(name: 'app_type', value: 'agriculture');
      print('Firebase Analytics configured');
    } catch (e) {
      print('Error configuring Firebase Analytics: $e');
    }
  }

  /// Enable Firebase Crashlytics for error tracking
  Future<void> _configureCrashlytics() async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      print('Firebase Crashlytics configured');
    } catch (e) {
      print('Error configuring Firebase Crashlytics: $e');
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
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Get document reference of a specific user
  DocumentReference getUserDocument(String userId) {
    return _firestore.collection(usersCollection).doc(userId);
  }

  /// Get a Firestore collection by name
  CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }

  /// Get a reference to a storage path
  Reference getStorageReference(String path) {
    return _storage.ref().child(path);
  }

  /// Upload a file and return the download URL
  Future<String> uploadFile(String path, dynamic file) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      await ref.delete();
      print('File deleted successfully');
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  /// Log a custom event to Firebase Analytics
  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) async {
    try {
      await _analytics.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  /// Log a screen view to Firebase Analytics
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }

  /// Report a caught error to Crashlytics
  Future<void> recordError(dynamic exception, StackTrace? stackTrace) async {
    try {
      await _crashlytics.recordError(exception, stackTrace);
    } catch (e) {
      print('Error recording error: $e');
    }
  }

  /// Set the user identifier for Crashlytics tracking
  Future<void> setUserIdentifier(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      print('Error setting user identifier: $e');
    }
  }

  // Environment-specific Firebase configs
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  static String get environment => _isProduction ? 'production' : 'development';

  static String get databaseUrl => _isProduction
      ? 'https://agridirect-prod.firebaseio.com'
      : 'https://agridirect-dev.firebaseio.com';

  static String get storageBucket => _isProduction
      ? 'agridirect-prod.appspot.com'
      : 'agridirect-dev.appspot.com';
}

/// Background FCM message handler (must be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

/// Constants used across the app
class FirebaseConstants {
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxFileUploadSize = 10 * 1024 * 1024; // 10MB

  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> supportedDocumentFormats = ['pdf', 'doc', 'docx'];

  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
