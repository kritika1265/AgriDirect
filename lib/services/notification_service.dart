import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// A comprehensive notification service for handling local and push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  /// Factory constructor for singleton pattern
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _localNotifications;
  late FirebaseMessaging _firebaseMessaging;
  
  bool _isInitialized = false;
  String? _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    // Initialize timezone
    tz.initializeTimeZones();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Initialize Firebase messaging
    await _initializeFirebaseMessaging();
    
    _isInitialized = true;
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permission for iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission();
    }

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification tap when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Handling a foreground message: ${message.messageId}');
    
    // Show local notification when app is in foreground
    showNotification(
      id: message.hashCode,
      title: message.notification?.title ?? 'AgriDirect',
      body: message.notification?.body ?? 'You have a new message',
      payload: jsonEncode(message.data),
    );
  }

  /// Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Handling a background message: ${message.messageId}');
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Message clicked: ${message.messageId}');
    // Navigate to specific screen based on message data
    _navigateToScreen(message.data);
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');
    
    if (notificationResponse.payload != null) {
      try {
        final data = jsonDecode(notificationResponse.payload!) as Map<String, dynamic>;
        _navigateToScreen(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Navigate to specific screen based on data
  void _navigateToScreen(Map<String, dynamic> data) {
    // Implement navigation logic based on notification data
    final type = data['type'] as String?;
    
    switch (type) {
      case 'weather_alert':
        // Navigate to weather screen
        break;
      case 'crop_reminder':
        // Navigate to crop calendar
        break;
      case 'disease_alert':
        // Navigate to disease detection
        break;
      case 'marketplace':
        // Navigate to marketplace
        break;
      default:
        // Navigate to home screen
        break;
    }
  }

  /// Show simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'agridirect_channel',
      'AgriDirect Notifications',
      channelDescription: 'General notifications for AgriDirect app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Show notification with custom sound
  Future<void> showNotificationWithSound({
    required int id,
    required String title,
    required String body,
    required String soundFile,
    String? payload,
  }) async {
    final androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'agridirect_sound_channel',
      'AgriDirect Sound Notifications',
      channelDescription: 'Notifications with custom sound',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(soundFile),
    );

    final iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(sound: '$soundFile.aiff');

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'agridirect_scheduled_channel',
      'AgriDirect Scheduled Notifications',
      channelDescription: 'Scheduled notifications for AgriDirect app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // FIXED: Added required parameter
      payload: payload,
    );
  }

  /// Schedule repeating notification
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    const androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'agridirect_repeat_channel',
      'AgriDirect Repeating Notifications',
      channelDescription: 'Repeating notifications for AgriDirect app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Show weather alert notification
  Future<void> showWeatherAlert({
    required String condition,
    required String description,
    required String location,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Weather Alert - $condition',
      body: '$description in $location',
      payload: jsonEncode({
        'type': 'weather_alert',
        'condition': condition,
        'location': location,
      }),
    );
  }

  /// Show crop reminder notification
  Future<void> showCropReminder({
    required String cropName,
    required String task,
    required DateTime dueDate,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Crop Reminder - $cropName',
      body: 'Time to $task (Due: ${dueDate.day}/${dueDate.month})',
      payload: jsonEncode({
        'type': 'crop_reminder',
        'crop': cropName,
        'task': task,
      }),
    );
  }

  /// Show disease alert notification
  Future<void> showDiseaseAlert({
    required String cropName,
    required String diseaseName,
    required double confidence,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Disease Alert - $cropName',
      body: 'Detected: $diseaseName (${(confidence * 100).toStringAsFixed(1)}% confidence)',
      payload: jsonEncode({
        'type': 'disease_alert',
        'crop': cropName,
        'disease': diseaseName,
      }),
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() =>
      _localNotifications.pendingNotificationRequests();

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    } else {
      final settings = await _firebaseMessaging.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status == PermissionStatus.granted;
    } else {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
  }
}