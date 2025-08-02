import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

// Import your CalendarEvent model
// import '../models/calendar_event_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  Database? _database;
  
  static const String _dbName = 'agridirect.db';
  static const int _dbVersion = 2; // Incremented version for calendar events table
  static const String _calendarEventsKey = 'calendar_events';

  /// Initialize storage service
  Future<void> initialize() async {
    await _initializePreferences();
    await _initializeDatabase();
  }

  /// Initialize SharedPreferences
  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Initialize SQLite database
  Future<void> _initializeDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String dbPath = path.join(documentsDirectory.path, _dbName);

    _database = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // User data table
    await db.execute('''
      CREATE TABLE user_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE,
        name TEXT,
        phone TEXT,
        location TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Crop records table
    await db.execute('''
      CREATE TABLE crop_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        crop_name TEXT,
        variety TEXT,
        planting_date TEXT,
        expected_harvest TEXT,
        area REAL,
        status TEXT,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Disease detection history
    await db.execute('''
      CREATE TABLE disease_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        crop_name TEXT,
        disease_name TEXT,
        confidence REAL,
        image_path TEXT,
        detection_date TEXT,
        treatment_applied TEXT,
        notes TEXT
      )
    ''');

    // Weather cache table
    await db.execute('''
      CREATE TABLE weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location TEXT,
        weather_data TEXT,
        cached_at TEXT,
        expires_at TEXT
      )
    ''');

    // ML predictions cache
    await db.execute('''
      CREATE TABLE ml_predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        prediction_type TEXT,
        input_data TEXT,
        result_data TEXT,
        confidence REAL,
        created_at TEXT
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT
      )
    ''');

    // Calendar events table
    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        category TEXT NOT NULL,
        crop_type TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        has_reminder INTEGER DEFAULT 0,
        reminder_date TEXT,
        location TEXT,
        metadata TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  /// Upgrade database schema
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    if (oldVersion < 2) {
      // Add calendar events table for version 2
      await db.execute('''
        CREATE TABLE calendar_events (
          id TEXT PRIMARY KEY,
          user_id TEXT,
          title TEXT NOT NULL,
          description TEXT,
          start_date TEXT NOT NULL,
          end_date TEXT,
          category TEXT NOT NULL,
          crop_type TEXT NOT NULL,
          is_completed INTEGER DEFAULT 0,
          has_reminder INTEGER DEFAULT 0,
          reminder_date TEXT,
          location TEXT,
          metadata TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
  }

  // CALENDAR EVENTS METHODS (SharedPreferences based)

  /// Get calendar events from storage
  Future<List<CalendarEvent>> getCalendarEvents() async {
    try {
      final eventsJson = _prefs!.getString(_calendarEventsKey);
      
      if (eventsJson == null) {
        return [];
      }
      
      final List<dynamic> eventsList = json.decode(eventsJson);
      return eventsList
          .map<CalendarEvent>((eventJson) => CalendarEvent.fromJson(eventJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading calendar events: $e');
      return [];
    }
  }

  /// Save calendar events to storage
  Future<void> saveCalendarEvents(List<CalendarEvent> events) async {
    try {
      final eventsJson = json.encode(events.map((event) => event.toJson()).toList());
      await _prefs!.setString(_calendarEventsKey, eventsJson);
    } catch (e) {
      debugPrint('Error saving calendar events: $e');
      throw Exception('Failed to save calendar events');
    }
  }

  /// Add a single calendar event
  Future<void> addCalendarEvent(CalendarEvent event) async {
    final events = await getCalendarEvents();
    events.add(event);
    await saveCalendarEvents(events);
  }

  /// Remove a calendar event by ID
  Future<void> removeCalendarEvent(String eventId) async {
    final events = await getCalendarEvents();
    events.removeWhere((event) => event.id == eventId);
    await saveCalendarEvents(events);
  }

  /// Update a calendar event
  Future<void> updateCalendarEvent(CalendarEvent updatedEvent) async {
    final events = await getCalendarEvents();
    final index = events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      events[index] = updatedEvent;
      await saveCalendarEvents(events);
    }
  }

  /// Clear all calendar events
  Future<void> clearCalendarEvents() async {
    await _prefs!.remove(_calendarEventsKey);
  }

  // CALENDAR EVENTS METHODS (Database based - Alternative implementation)

  /// Insert calendar event to database
  Future<int> insertCalendarEventToDb(CalendarEvent event) async {
    final now = DateTime.now().toIso8601String();
    final eventData = {
      'id': event.id,
      'user_id': event.userId ?? '',
      'title': event.title,
      'description': event.description,
      'start_date': event.startDate.toIso8601String(),
      'end_date': event.endDate?.toIso8601String(),
      'category': event.category,
      'crop_type': event.cropType,
      'is_completed': event.isCompleted ? 1 : 0,
      'has_reminder': event.hasReminder ? 1 : 0,
      'reminder_date': event.reminderDate?.toIso8601String(),
      'location': event.location,
      'metadata': event.metadata != null ? json.encode(event.metadata) : null,
      'created_at': now,
      'updated_at': now,
    };
    
    return await _database!.insert('calendar_events', eventData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get calendar events from database
  Future<List<CalendarEvent>> getCalendarEventsFromDb({String? userId}) async {
    String whereClause = '';
    List<String> whereArgs = [];
    
    if (userId != null) {
      whereClause = 'user_id = ?';
      whereArgs = [userId];
    }
    
    final List<Map<String, dynamic>> result = await _database!.query(
      'calendar_events',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'start_date ASC',
    );
    
    return result.map((eventData) {
      return CalendarEvent(
        id: eventData['id'] as String,
        userId: eventData['user_id'] as String?,
        title: eventData['title'] as String,
        description: eventData['description'] as String,
        startDate: DateTime.parse(eventData['start_date'] as String),
        endDate: eventData['end_date'] != null 
            ? DateTime.parse(eventData['end_date'] as String) 
            : null,
        category: eventData['category'] as String,
        cropType: eventData['crop_type'] as String,
        isCompleted: (eventData['is_completed'] as int) == 1,
        hasReminder: (eventData['has_reminder'] as int) == 1,
        reminderDate: eventData['reminder_date'] != null 
            ? DateTime.parse(eventData['reminder_date'] as String) 
            : null,
        location: eventData['location'] as String?,
        metadata: eventData['metadata'] != null 
            ? json.decode(eventData['metadata'] as String) as Map<String, dynamic>
            : null,
      );
    }).toList();
  }

  /// Update calendar event in database
  Future<int> updateCalendarEventInDb(CalendarEvent event) async {
    final eventData = {
      'title': event.title,
      'description': event.description,
      'start_date': event.startDate.toIso8601String(),
      'end_date': event.endDate?.toIso8601String(),
      'category': event.category,
      'crop_type': event.cropType,
      'is_completed': event.isCompleted ? 1 : 0,
      'has_reminder': event.hasReminder ? 1 : 0,
      'reminder_date': event.reminderDate?.toIso8601String(),
      'location': event.location,
      'metadata': event.metadata != null ? json.encode(event.metadata) : null,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    return await _database!.update(
      'calendar_events',
      eventData,
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Delete calendar event from database
  Future<int> deleteCalendarEventFromDb(String eventId) async {
    return await _database!.delete(
      'calendar_events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  /// Get upcoming calendar events
  Future<List<CalendarEvent>> getUpcomingEvents({String? userId, int days = 7}) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    String whereClause = 'start_date BETWEEN ? AND ? AND is_completed = 0';
    List<String> whereArgs = [now.toIso8601String(), futureDate.toIso8601String()];
    
    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }
    
    final List<Map<String, dynamic>> result = await _database!.query(
      'calendar_events',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'start_date ASC',
    );
    
    return result.map((eventData) {
      return CalendarEvent(
        id: eventData['id'] as String,
        userId: eventData['user_id'] as String?,
        title: eventData['title'] as String,
        description: eventData['description'] as String,
        startDate: DateTime.parse(eventData['start_date'] as String),
        endDate: eventData['end_date'] != null 
            ? DateTime.parse(eventData['end_date'] as String) 
            : null,
        category: eventData['category'] as String,
        cropType: eventData['crop_type'] as String,
        isCompleted: (eventData['is_completed'] as int) == 1,
        hasReminder: (eventData['has_reminder'] as int) == 1,
        reminderDate: eventData['reminder_date'] != null 
            ? DateTime.parse(eventData['reminder_date'] as String) 
            : null,
        location: eventData['location'] as String?,
        metadata: eventData['metadata'] != null 
            ? json.decode(eventData['metadata'] as String) as Map<String, dynamic>
            : null,
      );
    }).toList();
  }

  // SHARED PREFERENCES METHODS

  /// Save string value
  Future<bool> saveString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  /// Get string value
  String? getString(String key, {String? defaultValue}) {
    return _prefs!.getString(key) ?? defaultValue;
  }

  /// Save integer value
  Future<bool> saveInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  /// Get integer value
  int? getInt(String key, {int? defaultValue}) {
    return _prefs!.getInt(key) ?? defaultValue;
  }

  /// Save double value
  Future<bool> saveDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key, {double? defaultValue}) {
    return _prefs!.getDouble(key) ?? defaultValue;
  }

  /// Save boolean value
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  /// Get boolean value
  bool? getBool(String key, {bool? defaultValue}) {
    return _prefs!.getBool(key) ?? defaultValue;
  }

  /// Save list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }

  /// Get list of strings
  List<String>? getStringList(String key) {
    return _prefs!.getStringList(key);
  }

  /// Save object as JSON
  Future<bool> saveObject(String key, Map<String, dynamic> object) async {
    final String jsonString = jsonEncode(object);
    return await saveString(key, jsonString);
  }

  /// Get object from JSON
  Map<String, dynamic>? getObject(String key) {
    final String? jsonString = getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error decoding JSON for key $key: $e');
        return null;
      }
    }
    return null;
  }

  /// Remove key
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  /// Clear all preferences
  Future<bool> clearAll() async {
    return await _prefs!.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }

  /// Get all keys
  Set<String> getAllKeys() {
    return _prefs!.getKeys();
  }

  // DATABASE METHODS

  /// Insert user data
  Future<int> insertUserData(Map<String, dynamic> userData) async {
    final now = DateTime.now().toIso8601String();
    userData['created_at'] = now;
    userData['updated_at'] = now;
    
    return await _database!.insert('user_data', userData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final List<Map<String, dynamic>> result = await _database!.query(
      'user_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    return result.isNotEmpty ? result.first : null;
  }

  /// Update user data
  Future<int> updateUserData(String userId, Map<String, dynamic> userData) async {
    userData['updated_at'] = DateTime.now().toIso8601String();
    
    return await _database!.update(
      'user_data',
      userData,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Insert crop record
  Future<int> insertCropRecord(Map<String, dynamic> cropData) async {
    final now = DateTime.now().toIso8601String();
    cropData['created_at'] = now;
    cropData['updated_at'] = now;
    
    return await _database!.insert('crop_records', cropData);
  }

  /// Get crop records for user
  Future<List<Map<String, dynamic>>> getCropRecords(String userId) async {
    return await _database!.query(
      'crop_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// Update crop record
  Future<int> updateCropRecord(int recordId, Map<String, dynamic> cropData) async {
    cropData['updated_at'] = DateTime.now().toIso8601String();
    
    return await _database!.update(
      'crop_records',
      cropData,
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  /// Delete crop record
  Future<int> deleteCropRecord(int recordId) async {
    return await _database!.delete(
      'crop_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  /// Insert disease detection history
  Future<int> insertDiseaseHistory(Map<String, dynamic> diseaseData) async {
    diseaseData['detection_date'] = DateTime.now().toIso8601String();
    
    return await _database!.insert('disease_history', diseaseData);
  }

  /// Get disease history for user
  Future<List<Map<String, dynamic>>> getDiseaseHistory(String userId, {int? limit}) async {
    return await _database!.query(
      'disease_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'detection_date DESC',
      limit: limit,
    );
  }

  /// Cache weather data
  Future<int> cacheWeatherData(String location, Map<String, dynamic> weatherData) async {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 1)); // Cache for 1 hour
    
    final cacheData = {
      'location': location,
      'weather_data': jsonEncode(weatherData),
      'cached_at': now.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
    
    return await _database!.insert('weather_cache', cacheData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get cached weather data
  Future<Map<String, dynamic>?> getCachedWeatherData(String location) async {
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> result = await _database!.query(
      'weather_cache',
      where: 'location = ? AND expires_at > ?',
      whereArgs: [location, now],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      final weatherDataString = result.first['weather_data'] as String;
      return jsonDecode(weatherDataString) as Map<String, dynamic>;
    }
    
    return null;
  }

  /// Cache ML prediction
  Future<int> cacheMlPrediction(Map<String, dynamic> predictionData) async {
    predictionData['created_at'] = DateTime.now().toIso8601String();
    
    return await _database!.insert('ml_predictions', predictionData);
  }

  /// Get ML prediction history
  Future<List<Map<String, dynamic>>> getMlPredictionHistory(String userId, String predictionType) async {
    return await _database!.query(
      'ml_predictions',
      where: 'user_id = ? AND prediction_type = ?',
      whereArgs: [userId, predictionType],
      orderBy: 'created_at DESC',
      limit: 50,
    );
  }

  /// Save app setting
  Future<int> saveAppSetting(String key, String value) async {
    final settingData = {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    return await _database!.insert('app_settings', settingData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get app setting
  Future<String?> getAppSetting(String key) async {
    final List<Map<String, dynamic>> result = await _database!.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  // FILE STORAGE METHODS

  /// Save file to documents directory
  Future<File?> saveFileToDocuments(String fileName, List<int> bytes) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File file = File(path.join(appDocDir.path, fileName));
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  /// Read file from documents directory
  Future<List<int>?> readFileFromDocuments(String fileName) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File file = File(path.join(appDocDir.path, fileName));
      
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading file: $e');
      return null;
    }
  }

  /// Delete file from documents directory
  Future<bool> deleteFileFromDocuments(String fileName) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File file = File(path.join(appDocDir.path, fileName));
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Get app documents directory
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get temporary directory
  Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get cache directory
  Future<Directory?> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get directory size
  Future<int> getDirectorySize(Directory directory) async {
    int size = 0;
    try {
      if (await directory.exists()) {
        await for (final FileSystemEntity entity in directory.list(recursive: true)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
    }
    return size;
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      // Clear expired weather cache
      final now = DateTime.now().toIso8601String();
      await _database!.delete(
        'weather_cache',
        where: 'expires_at < ?',
        whereArgs: [now],
      );
      
      // Clear temporary files
      final Directory tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final FileSystemEntity entity in tempDir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory tempDir = await getTemporaryDirectory();
      
      final int documentsSize = await getDirectorySize(appDocDir);
      final int tempSize = await getDirectorySize(tempDir);
      
      // Get database size
      final String dbPath = path.join(appDocDir.path, _dbName);
      final File dbFile = File(dbPath);
      final int dbSize = await dbFile.exists() ? await dbFile.length() : 0;
      
      // Get record counts
      final int cropRecordsCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM crop_records')
      ) ?? 0;
      
      final int diseaseHistoryCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM disease_history')
      ) ?? 0;

      final int calendarEventsCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM calendar_events')
      ) ?? 0;
      
      return {
        'documents_size': documentsSize,
        'temp_size': tempSize,
        'database_size': dbSize,
        'total_size': documentsSize + tempSize,
        'crop_records_count': cropRecordsCount,
        'disease_history_count': diseaseHistoryCount,
        'calendar_events_count': calendarEventsCount,
      };
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return {};
    }
  }

  /// Close database connection
  Future<void> close() async {
    await _database?.close();
  }

  /// Dispose resources
  void dispose() {
    close();
  }
}