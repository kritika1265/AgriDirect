import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Import the CalendarEvent model from your models directory
// Adjust the import path according to your project structure
import '../models/calendar_event_model.dart';

/// Custom exceptions for better error handling
class StorageException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const StorageException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'StorageException: $message${code != null ? ' (Code: $code)' : ''}';
}

class DatabaseException extends StorageException {
  const DatabaseException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class PreferencesException extends StorageException {
  const PreferencesException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Storage service for handling data persistence
class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  /// Factory constructor returns singleton instance
  factory StorageService() => _instance;
  
  StorageService._internal();

  SharedPreferences? _prefs;
  Database? _database;
  bool _isInitialized = false;
  
  static const String _dbName = 'agridirect.db';
  static const int _dbVersion = 3; // Incremented for improvements
  static const String _calendarEventsKey = 'calendar_events';

  /// Check if storage service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize storage service with better error handling
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _initializePreferences();
      await _initializeDatabase();
      _isInitialized = true;
      debugPrint('StorageService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize StorageService: $e');
      throw StorageException('Failed to initialize storage service', originalError: e);
    }
  }

  /// Ensure service is initialized before operations
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StorageException('StorageService not initialized. Call initialize() first.');
    }
  }

  /// Initialize SharedPreferences with error handling
  Future<void> _initializePreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw PreferencesException('Failed to initialize SharedPreferences', originalError: e);
    }
  }

  /// Initialize SQLite database with improved error handling
  Future<void> _initializeDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, _dbName);

      _database = await openDatabase(
        dbPath,
        version: _dbVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onOpen: (db) async {
          // Enable foreign key constraints
          await db.execute('PRAGMA foreign_keys = ON');
          // Optimize database performance
          await db.execute('PRAGMA journal_mode = WAL');
          await db.execute('PRAGMA synchronous = NORMAL');
          await db.execute('PRAGMA cache_size = 10000');
        },
      );
    } catch (e) {
      throw DatabaseException('Failed to initialize database', originalError: e);
    }
  }

  /// Create database tables with improved schema
  Future<void> _createDatabase(Database db, int version) async {
    // User data table with improved constraints
    await db.execute('''
      CREATE TABLE user_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        location TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Crop records table with foreign key reference
    await db.execute('''
      CREATE TABLE crop_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        crop_name TEXT NOT NULL,
        variety TEXT,
        planting_date TEXT NOT NULL,
        expected_harvest TEXT,
        area REAL CHECK(area > 0),
        status TEXT DEFAULT 'active' CHECK(status IN ('active', 'completed', 'failed')),
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_data (user_id) ON DELETE CASCADE
      )
    ''');

    // Disease detection history with better structure
    await db.execute('''
      CREATE TABLE disease_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        crop_record_id INTEGER,
        crop_name TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        confidence REAL CHECK(confidence >= 0 AND confidence <= 1),
        image_path TEXT,
        detection_date TEXT NOT NULL,
        treatment_applied TEXT,
        treatment_effective BOOLEAN,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_data (user_id) ON DELETE CASCADE,
        FOREIGN KEY (crop_record_id) REFERENCES crop_records (id) ON DELETE SET NULL
      )
    ''');

    // Weather cache table with location indexing
    await db.execute('''
      CREATE TABLE weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location TEXT NOT NULL,
        weather_data TEXT NOT NULL,
        cached_at TEXT NOT NULL,
        expires_at TEXT NOT NULL
      )
    ''');

    // ML predictions cache with better categorization
    await db.execute('''
      CREATE TABLE ml_predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        prediction_type TEXT NOT NULL,
        input_data TEXT NOT NULL,
        result_data TEXT NOT NULL,
        confidence REAL CHECK(confidence >= 0 AND confidence <= 1),
        model_version TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_data (user_id) ON DELETE CASCADE
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Calendar events table with improved constraints
    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        start_date TEXT NOT NULL,
        end_date TEXT,
        category TEXT NOT NULL,
        crop_type TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0 CHECK(is_completed IN (0, 1)),
        has_reminder INTEGER DEFAULT 0 CHECK(has_reminder IN (0, 1)),
        reminder_date TEXT,
        location TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_data (user_id) ON DELETE CASCADE,
        CHECK (end_date IS NULL OR end_date >= start_date),
        CHECK (reminder_date IS NULL OR has_reminder = 1)
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_calendar_user_date ON calendar_events(user_id, start_date)');
    await db.execute('CREATE INDEX idx_calendar_category ON calendar_events(category)');
    await db.execute('CREATE INDEX idx_calendar_upcoming ON calendar_events(start_date, is_completed)');
    await db.execute('CREATE INDEX idx_weather_location ON weather_cache(location, expires_at)');
    await db.execute('CREATE INDEX idx_crop_records_user ON crop_records(user_id, status)');
    await db.execute('CREATE INDEX idx_disease_history_user ON disease_history(user_id, detection_date)');
    await db.execute('CREATE INDEX idx_ml_predictions_user ON ml_predictions(user_id, prediction_type)');
  }

  /// Upgrade database schema with version control
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
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
    
    if (oldVersion < 3) {
      // Add new columns and constraints for version 3
      try {
        // Add missing columns
        await db.execute('ALTER TABLE disease_history ADD COLUMN treatment_effective BOOLEAN');
        await db.execute('ALTER TABLE disease_history ADD COLUMN crop_record_id INTEGER');
        await db.execute('ALTER TABLE disease_history ADD COLUMN created_at TEXT DEFAULT ""');
        await db.execute('ALTER TABLE ml_predictions ADD COLUMN model_version TEXT');
        
        // Update existing records to have created_at
        await db.execute('''
          UPDATE disease_history 
          SET created_at = detection_date 
          WHERE created_at IS NULL OR created_at = ""
        ''');
        
        // Add indexes if they don't exist
        await db.execute('CREATE INDEX IF NOT EXISTS idx_calendar_user_date ON calendar_events(user_id, start_date)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_calendar_upcoming ON calendar_events(start_date, is_completed)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_weather_location ON weather_cache(location, expires_at)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_crop_records_user ON crop_records(user_id, status)');
        
        debugPrint('Database upgrade to version 3 completed successfully');
      } catch (e) {
        debugPrint('Warning: Some upgrade operations failed: $e');
        // Don't throw here as the upgrade might partially succeed
      }
    }
  }

  /// Execute database operation with retry logic and better error handling
  Future<T> _executeDbOperation<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
    _ensureInitialized();
    
    if (_database == null) {
      throw DatabaseException('Database not initialized');
    }
    
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          throw DatabaseException('Database operation failed after $maxRetries attempts', originalError: e);
        }
        
        // Wait before retry with exponential backoff
        await Future.delayed(Duration(milliseconds: 100 * attempts * attempts));
      }
    }
    
    throw DatabaseException('Unexpected error in database operation');
  }

  // ENHANCED CALENDAR EVENTS METHODS (SharedPreferences based)

  /// Get calendar events from storage with improved error handling
  Future<List<CalendarEvent>> getCalendarEvents() async {
    _ensureInitialized();
    
    try {
      final eventsJson = _prefs!.getString(_calendarEventsKey);
      
      if (eventsJson == null || eventsJson.isEmpty) {
        return [];
      }
      
      final eventsList = json.decode(eventsJson) as List<dynamic>;
      return eventsList
          .map<CalendarEvent>((eventJson) => CalendarEvent.fromJson(eventJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading calendar events: $e');
      // Try to recover by clearing corrupted data
      try {
        await _prefs!.remove(_calendarEventsKey);
        debugPrint('Cleared corrupted calendar events data');
      } catch (clearError) {
        debugPrint('Failed to clear corrupted data: $clearError');
      }
      throw PreferencesException('Failed to load calendar events', originalError: e);
    }
  }

  /// Save calendar events to storage with validation
  Future<void> saveCalendarEvents(List<CalendarEvent> events) async {
    _ensureInitialized();
    
    // Validate events before saving
    for (final event in events) {
      _validateCalendarEvent(event);
    }
    
    try {
      if (events.isEmpty) {
        await _prefs!.remove(_calendarEventsKey);
        return;
      }
      
      final eventsJson = json.encode(events.map((event) => event.toJson()).toList());
      final success = await _prefs!.setString(_calendarEventsKey, eventsJson);
      
      if (!success) {
        throw PreferencesException('Failed to save calendar events to preferences');
      }
    } catch (e) {
      debugPrint('Error saving calendar events: $e');
      throw PreferencesException('Failed to save calendar events', originalError: e);
    }
  }

  /// Validate calendar event data
  void _validateCalendarEvent(CalendarEvent event) {
    if (event.id.trim().isEmpty) {
      throw StorageException('Event ID cannot be empty');
    }
    
    if (event.title.trim().isEmpty) {
      throw StorageException('Event title cannot be empty');
    }
    
    if (event.category.trim().isEmpty) {
      throw StorageException('Event category cannot be empty');
    }
    
    if (event.cropType.trim().isEmpty) {
      throw StorageException('Event crop type cannot be empty');
    }
    
    if (event.endDate != null && event.endDate!.isBefore(event.startDate)) {
      throw StorageException('End date cannot be before start date');
    }
    
    if (event.hasReminder && event.reminderDate == null) {
      throw StorageException('Reminder date must be set when reminder is enabled');
    }
  }

  /// Add a single calendar event with comprehensive validation
  Future<void> addCalendarEvent(CalendarEvent event) async {
    _ensureInitialized();
    
    // Validate event
    _validateCalendarEvent(event);
    
    final events = await getCalendarEvents();
    
    // Check for duplicate IDs
    if (events.any((e) => e.id == event.id)) {
      throw StorageException('Event with ID ${event.id} already exists');
    }
    
    events.add(event);
    await saveCalendarEvents(events);
  }

  /// Remove a calendar event by ID with validation
  Future<bool> removeCalendarEvent(String eventId) async {
    _ensureInitialized();
    
    if (eventId.trim().isEmpty) {
      throw StorageException('Event ID cannot be empty');
    }
    
    final events = await getCalendarEvents();
    final initialLength = events.length;
    
    events.removeWhere((event) => event.id == eventId);
    
    if (events.length == initialLength) {
      return false; // Event not found
    }
    
    await saveCalendarEvents(events);
    return true;
  }

  /// Update a calendar event with validation
  Future<bool> updateCalendarEvent(CalendarEvent updatedEvent) async {
    _ensureInitialized();
    
    // Validate updated event
    _validateCalendarEvent(updatedEvent);
    
    final events = await getCalendarEvents();
    final index = events.indexWhere((event) => event.id == updatedEvent.id);
    
    if (index == -1) {
      return false; // Event not found
    }
    
    events[index] = updatedEvent;
    await saveCalendarEvents(events);
    return true;
  }

  /// Get events by date range with validation
  Future<List<CalendarEvent>> getEventsByDateRange(DateTime startDate, DateTime endDate) async {
    if (endDate.isBefore(startDate)) {
      throw StorageException('End date cannot be before start date');
    }
    
    final events = await getCalendarEvents();
    
    return events.where((event) {
      return event.startDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             event.startDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  /// Get events by category
  Future<List<CalendarEvent>> getEventsByCategory(String category) async {
    if (category.trim().isEmpty) {
      throw StorageException('Category cannot be empty');
    }
    
    final events = await getCalendarEvents();
    return events.where((event) => event.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Get events by crop type
  Future<List<CalendarEvent>> getEventsByCropType(String cropType) async {
    if (cropType.trim().isEmpty) {
      throw StorageException('Crop type cannot be empty');
    }
    
    final events = await getCalendarEvents();
    return events.where((event) => event.cropType.toLowerCase() == cropType.toLowerCase()).toList();
  }

  /// Get upcoming events within specified days
  Future<List<CalendarEvent>> getUpcomingEventsFromPrefs({int days = 7}) async {
    if (days < 0) {
      throw StorageException('Days parameter cannot be negative');
    }
    
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    final events = await getCalendarEvents();
    
    return events.where((event) {
      return !event.isCompleted &&
             event.startDate.isAfter(now.subtract(const Duration(hours: 1))) &&
             event.startDate.isBefore(futureDate);
    }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  /// Clear all calendar events
  Future<void> clearCalendarEvents() async {
    _ensureInitialized();
    
    try {
      await _prefs!.remove(_calendarEventsKey);
    } catch (e) {
      throw PreferencesException('Failed to clear calendar events', originalError: e);
    }
  }

  // CALENDAR EVENTS METHODS (Database based - Alternative implementation)

  /// Insert calendar event to database with comprehensive validation
  Future<int> insertCalendarEventToDb(CalendarEvent event) async {
    _validateCalendarEvent(event);
    
    return _executeDbOperation(() async {
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
    });
  }

  /// Get calendar events from database with improved error handling
  Future<List<CalendarEvent>> getCalendarEventsFromDb({String? userId}) async {
    return _executeDbOperation(() async {
      String whereClause = '';
      final whereArgs = <String>[];
      
      if (userId != null && userId.trim().isNotEmpty) {
        whereClause = 'user_id = ?';
        whereArgs.add(userId);
      }
      
      final result = await _database!.query(
        'calendar_events',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'start_date ASC',
      );
      
      return result.map((eventData) => _mapDbRowToCalendarEvent(eventData)).toList();
    });
  }

  /// Helper method to map database row to CalendarEvent
  CalendarEvent _mapDbRowToCalendarEvent(Map<String, dynamic> eventData) {
    return CalendarEvent(
      id: eventData['id'] as String,
      userId: eventData['user_id'] as String?,
      title: eventData['title'] as String,
      description: eventData['description'] as String? ?? '',
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
  }

  /// Update calendar event in database with validation
  Future<int> updateCalendarEventInDb(CalendarEvent event) async {
    _validateCalendarEvent(event);
    
    return _executeDbOperation(() async {
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
    });
  }

  /// Delete calendar event from database with validation
  Future<int> deleteCalendarEventFromDb(String eventId) {
    if (eventId.trim().isEmpty) {
      throw StorageException('Event ID cannot be empty');
    }
    
    return _executeDbOperation(() async {
      return await _database!.delete(
        'calendar_events',
        where: 'id = ?',
        whereArgs: [eventId],
      );
    });
  }

  /// Get upcoming calendar events from database
  Future<List<CalendarEvent>> getUpcomingEvents({String? userId, int days = 7}) async {
    if (days < 0) {
      throw StorageException('Days parameter cannot be negative');
    }
    
    return _executeDbOperation(() async {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));
      
      String whereClause = 'start_date BETWEEN ? AND ? AND is_completed = 0';
      final whereArgs = [now.toIso8601String(), futureDate.toIso8601String()];
      
      if (userId != null && userId.trim().isNotEmpty) {
        whereClause += ' AND user_id = ?';
        whereArgs.add(userId);
      }
      
      final result = await _database!.query(
        'calendar_events',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'start_date ASC',
      );
      
      return result.map((eventData) => _mapDbRowToCalendarEvent(eventData)).toList();
    });
  }

  /// Batch insert calendar events with transaction
  Future<void> batchInsertCalendarEvents(List<CalendarEvent> events) async {
    if (events.isEmpty) return;
    
    // Validate all events first
    for (final event in events) {
      _validateCalendarEvent(event);
    }
    
    return _executeDbOperation(() async {
      await _database!.transaction((txn) async {
        final batch = txn.batch();
        final now = DateTime.now().toIso8601String();
        
        for (final event in events) {
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
          
          batch.insert('calendar_events', eventData,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        
        await batch.commit(noResult: true);
      });
    });
  }

  // SHARED PREFERENCES METHODS with improved error handling

  /// Save string value with validation
  Future<bool> saveString(String key, String value) async {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      throw PreferencesException('Failed to save string value', originalError: e);
    }
  }

  /// Get string value with improved error handling
  String? getString(String key, {String? defaultValue}) {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return _prefs!.getString(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting string value for key $key: $e');
      return defaultValue;
    }
  }

  /// Save integer value
  Future<bool> saveInt(String key, int value) async {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return await _prefs!.setInt(key, value);
    } catch (e) {
      throw PreferencesException('Failed to save integer value', originalError: e);
    }
  }

  /// Get integer value with improved error handling
  int? getInt(String key, {int? defaultValue}) {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return _prefs!.getInt(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting integer value for key $key: $e');
      return defaultValue;
    }
  }

  /// Save double value
  Future<bool> saveDouble(String key, double value) async {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      throw PreferencesException('Failed to save double value', originalError: e);
    }
  }

  /// Get double value with improved error handling
  double? getDouble(String key, {double? defaultValue}) {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return _prefs!.getDouble(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting double value for key $key: $e');
      return defaultValue;
    }
  }

  /// Save boolean value
  Future<bool> saveBool(String key, {required bool value}) async {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      throw PreferencesException('Failed to save boolean value', originalError: e);
    }
  }

  /// Get boolean value with improved error handling
  bool? getBool(String key, {bool? defaultValue}) {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return _prefs!.getBool(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting boolean value for key $key: $e');
      return defaultValue;
    }
  }

  /// Save list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return await _prefs!.setStringList(key, value);
    } catch (e) {
      throw PreferencesException('Failed to save string list', originalError: e);
    }
  }

  /// Get list of strings with improved error handling
  List<String>? getStringList(String key) {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return _prefs!.getStringList(key);
    } catch (e) {
      debugPrint('Error getting string list for key $key: $e');
      return null;
    }
  }

  /// Save object as JSON with validation
  Future<bool> saveObject(String key, Map<String, dynamic> object) async {
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      final jsonString = jsonEncode(object);
      return await saveString(key, jsonString);
    } catch (e) {
      throw PreferencesException('Failed to save object as JSON', originalError: e);
    }
  }

  /// Get object from JSON with improved error handling
  Map<String, dynamic>? getObject(String key) {
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    final jsonString = getString(key);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error decoding JSON for key $key: $e');
        return null;
      }
    }
    return null;
  }

  /// Remove key with validation
  Future<bool> remove(String key) async {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      throw PreferencesException('Key cannot be empty');
    }
    
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      throw PreferencesException('Failed to remove key', originalError: e);
    }
  }

  /// Clear all preferences with confirmation
  Future<bool> clearAll() async {
    _ensureInitialized();
    
    try {
      return await _prefs!.clear();
    } catch (e) {
      throw PreferencesException('Failed to clear all preferences', originalError: e);
    }
  }

  /// Check if key exists
  bool containsKey(String key) {
    _ensureInitialized();
    
    if (key.trim().isEmpty) {
      return false;
    }
    
    try {
      return _prefs!.containsKey(key);
    } catch (e) {
      debugPrint('Error checking if key exists: $e');
      return false;
    }
  }

  /// Get all keys
  Set<String> getAllKeys() {
    _ensureInitialized();
    
    try {
      return _prefs!.getKeys();
    } catch (e) {
      debugPrint('Error getting all keys: $e');
      return <String>{};
    }
  }

  // DATABASE METHODS with improved error handling

  /// Insert user data with validation
  Future<int> insertUserData(Map<String, dynamic> userData) async {
    if (userData['user_id'] == null || userData['user_id'].toString().trim().isEmpty) {
      throw DatabaseException('User ID is required');
    }
    
    if (userData['name'] == null || userData['name'].toString().trim().isEmpty) {
      throw DatabaseException('User name is required');
    }
    
    return _executeDbOperation(() async {
      final now = DateTime.now().toIso8601String();
      userData['created_at'] = now;
      userData['updated_at'] = now;
      
      return await _database!.insert('user_data', userData,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  /// Get user data with improved error handling
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    if (userId.trim().isEmpty) {
      throw DatabaseException('User ID cannot be empty');
    }
    
    return _executeDbOperation(() async {
      final result = await _database!.query(
        'user_data',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      
      return result.isNotEmpty ? result.first : null;
    });
  }

  /// Update user data with validation
  Future<int> updateUserData(String userId, Map<String, dynamic> userData) async {
    if (userId.trim().isEmpty) {
      throw DatabaseException('User ID cannot be empty');
    }
    
    return _executeDbOperation(() async {
      userData['updated_at'] = DateTime.now().toIso8601String();
      
      return await _database!.update(
        'user_data',
        userData,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    });
  }

  /// Insert crop record with validation
  Future<int> insertCropRecord(Map<String, dynamic> cropData) async {
    if (cropData['user_id'] == null || cropData['user_id'].toString().trim().isEmpty) {
      throw DatabaseException('User ID is required');
    }
    
    if (cropData['crop_name'] == null || cropData['crop_name'].toString().trim().isEmpty) {
      throw DatabaseException('Crop name is required');
    }
    
    if (cropData['planting_date'] == null) {
      throw DatabaseException('Planting date is required');
    }
    
    return _executeDbOperation(() async {
      final now = DateTime.now().toIso8601String();
      cropData['created_at'] = now;
      cropData['updated_at'] = now;
      
      return await _database!.insert('crop_records', cropData);
    });
  }

  /// Get crop records for user with improved error handling
  Future<List<Map<String, dynamic>>> getCropRecords(String userId) async {
    if (userId.trim().isEmpty) {
      throw DatabaseException('User ID cannot be empty');
    }
    
    return _executeDbOperation(() async {
      return await _database!.query(
        'crop_records',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    });
  }

  /// Update crop record with validation
  Future<int> updateCropRecord(int recordId, Map<String, dynamic> cropData) async {
    if (recordId <= 0) {
      throw DatabaseException('Invalid record ID');
    }
    
    return _executeDbOperation(() async {
      cropData['updated_at'] = DateTime.now().toIso8601String();
      
      return await _database!.update(
        'crop_records',
        cropData,
        where: 'id = ?',
        whereArgs: [recordId],
      );
    });
  }

  /// Delete crop record with validation
  Future<int> deleteCropRecord(int recordId) async {
    if (recordId <= 0) {
      throw DatabaseException('Invalid record ID');
    }
    
    return _executeDbOperation(() async {
      return await _database!.delete(
        'crop_records',
        where: 'id = ?',
        whereArgs: [recordId],
      );
    });
  }

  /// Insert disease detection history with validation
  Future<int> insertDiseaseHistory(Map<String, dynamic> diseaseData) async {
    if (diseaseData['user_id'] == null || diseaseData['user_id'].toString().trim().isEmpty) {
      throw DatabaseException('User ID is required');
    }
    
    if (diseaseData['crop_name'] == null || diseaseData['crop_name'].toString().trim().isEmpty) {
      throw DatabaseException('Crop name is required');
    }
    
    if (diseaseData['disease_name'] == null || diseaseData['disease_name'].toString().trim().isEmpty) {
      throw DatabaseException('Disease name is required');
    }
    
    return _executeDbOperation(() async {
      final now = DateTime.now().toIso8601String();
      diseaseData['detection_date'] = now;
      diseaseData['created_at'] = now;
      
      return await _database!.insert('disease_history', diseaseData);
    });
  }

  /// Get disease history for user with improved error handling
  Future<List<Map<String, dynamic>>> getDiseaseHistory(String userId, {int? limit}) async {
    if (userId.trim().isEmpty) {
      throw DatabaseException('User ID cannot be empty');
    }
    
    return _executeDbOperation(() async {
      return await _database!.query(
        'disease_history',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'detection_date DESC',
        limit: limit,
      );
    });
  }

  /// Cache weather data with validation
  Future<int> cacheWeatherData(String location, Map<String, dynamic> weatherData) async {
    if (location.trim().isEmpty) {
      throw DatabaseException('Location cannot be empty');
    }
    
    if (weatherData.isEmpty) {
      throw DatabaseException('Weather data cannot be empty');
    }
    
    return _executeDbOperation(() async {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 1));
      
      final cacheData = {
        'location': location,
        'weather_data': jsonEncode(weatherData),
        'cached_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      };
      
      return await _database!.insert('weather_cache', cacheData,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  /// Get cached weather data with improved error handling
  Future<Map<String, dynamic>?> getCachedWeatherData(String location) async {
    if (location.trim().isEmpty) {
      throw DatabaseException('Location cannot be empty');
    }
    
    return _executeDbOperation(() async {
      final now = DateTime.now().toIso8601String();
      
      final result = await _database!.query(
        'weather_cache',
        where: 'location = ? AND expires_at > ?',
        whereArgs: [location, now],
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        try {
          final weatherDataString = result.first['weather_data'] as String;
          return jsonDecode(weatherDataString) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Error decoding cached weather data: $e');
          // Remove corrupted cache entry
          await _database!.delete(
            'weather_cache',
            where: 'location = ?',
            whereArgs: [location],
          );
          return null;
        }
      }
      
      return null;
    });
  }

  /// Cache ML prediction with validation
  Future<int> cacheMlPrediction(Map<String, dynamic> predictionData) async {
    if (predictionData['user_id'] == null || predictionData['user_id'].toString().trim().isEmpty) {
      throw DatabaseException('User ID is required');
    }
    
    if (predictionData['prediction_type'] == null || predictionData['prediction_type'].toString().trim().isEmpty) {
      throw DatabaseException('Prediction type is required');
    }
    
    return _executeDbOperation(() async {
      predictionData['created_at'] = DateTime.now().toIso8601String();
      
      return await _database!.insert('ml_predictions', predictionData);
    });
  }

  /// Get ML prediction history with improved error handling
  Future<List<Map<String, dynamic>>> getMlPredictionHistory(String userId, String predictionType) async {
    if (userId.trim().isEmpty) {
      throw DatabaseException('User ID cannot be empty');
    }
    
    if (predictionType.trim().isEmpty) {
      throw DatabaseException('Prediction type cannot be empty');
    }
    
    return _executeDbOperation(() async {
      return await _database!.query(
        'ml_predictions',
        where: 'user_id = ? AND prediction_type = ?',
        whereArgs: [userId, predictionType],
        orderBy: 'created_at DESC',
        limit: 50,
      );
    });
  }

  /// Save app setting with validation
  Future<int> saveAppSetting(String key, String value) async {
    if (key.trim().isEmpty) {
      throw DatabaseException('Setting key cannot be empty');
    }
    
    return _executeDbOperation(() async {
      final settingData = {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      return await _database!.insert('app_settings', settingData,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  /// Get app setting with improved error handling
  Future<String?> getAppSetting(String key) async {
    if (key.trim().isEmpty) {
      throw DatabaseException('Setting key cannot be empty');
    }
    
    return _executeDbOperation(() async {
      final result = await _database!.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      return result.isNotEmpty ? result.first['value'] as String : null;
    });
  }

  // FILE STORAGE METHODS with improved error handling

  /// Save file to documents directory with validation
  Future<File?> saveFileToDocuments(String fileName, List<int> bytes) async {
    if (fileName.trim().isEmpty) {
      throw StorageException('File name cannot be empty');
    }
    
    if (bytes.isEmpty) {
      throw StorageException('File bytes cannot be empty');
    }
    
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File(path.join(appDocDir.path, fileName));
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error saving file: $e');
      throw StorageException('Failed to save file to documents', originalError: e);
    }
  }

  /// Read file from documents directory with validation
  Future<List<int>?> readFileFromDocuments(String fileName) async {
    if (fileName.trim().isEmpty) {
      throw StorageException('File name cannot be empty');
    }
    
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File(path.join(appDocDir.path, fileName));
      
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading file: $e');
      throw StorageException('Failed to read file from documents', originalError: e);
    }
  }

  /// Delete file from documents directory with validation
  Future<bool> deleteFileFromDocuments(String fileName) async {
    if (fileName.trim().isEmpty) {
      throw StorageException('File name cannot be empty');
    }
    
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File(path.join(appDocDir.path, fileName));
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      throw StorageException('Failed to delete file from documents', originalError: e);
    }
  }

  /// Get app documents directory
  Future<Directory> getDocumentsDirectory() => getApplicationDocumentsDirectory();

  /// Get temporary directory
  Future<Directory> getTempDirectory() => getTemporaryDirectory();

  /// Get cache directory
  Future<Directory?> getCacheDirectory() => getTemporaryDirectory();

  /// Get directory size with improved error handling
  Future<int> getDirectorySize(Directory directory) async {
    var size = 0;
    try {
      if (directory.existsSync()) {
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File) {
            try {
              size += await entity.length();
            } catch (e) {
              debugPrint('Error getting file size for ${entity.path}: $e');
              // Continue with other files
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
      throw StorageException('Failed to calculate directory size', originalError: e);
    }
    return size;
  }

  /// Clear cache with improved error handling
  Future<void> clearCache() async {
    _ensureInitialized();
    
    try {
      // Clear expired weather cache
      final now = DateTime.now().toIso8601String();
      await _executeDbOperation(() async {
        return await _database!.delete(
          'weather_cache',
          where: 'expires_at < ?',
          whereArgs: [now],
        );
      });
      
      // Clear temporary files
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        await for (final entity in tempDir.list()) {
          if (entity is File) {
            try {
              await entity.delete();
            } catch (e) {
              debugPrint('Failed to delete temp file ${entity.path}: $e');
              // Continue with other files
            }
          }
        }
      }
      
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      throw StorageException('Failed to clear cache', originalError: e);
    }
  }

  /// Get storage statistics with comprehensive error handling
  Future<Map<String, dynamic>> getStorageStats() async {
    _ensureInitialized();
    
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();
      
      final documentsSize = await getDirectorySize(appDocDir);
      final tempSize = await getDirectorySize(tempDir);
      
      // Get database size
      final dbPath = path.join(appDocDir.path, _dbName);
      final dbFile = File(dbPath);
      final dbSize = dbFile.existsSync() ? await dbFile.length() : 0;
      
      // Get record counts with error handling for each query
      int cropRecordsCount = 0;
      int diseaseHistoryCount = 0;
      int calendarEventsCount = 0;
      int mlPredictionsCount = 0;
      int weatherCacheCount = 0;
      
      try {
        cropRecordsCount = Sqflite.firstIntValue(
          await _database!.rawQuery('SELECT COUNT(*) FROM crop_records')
        ) ?? 0;
      } catch (e) {
        debugPrint('Error getting crop records count: $e');
      }
      
      try {
        diseaseHistoryCount = Sqflite.firstIntValue(
          await _database!.rawQuery('SELECT COUNT(*) FROM disease_history')
        ) ?? 0;
      } catch (e) {
        debugPrint('Error getting disease history count: $e');
      }

      try {
        calendarEventsCount = Sqflite.firstIntValue(
          await _database!.rawQuery('SELECT COUNT(*) FROM calendar_events')
        ) ?? 0;
      } catch (e) {
        debugPrint('Error getting calendar events count: $e');
      }
      
      try {
        mlPredictionsCount = Sqflite.firstIntValue(
          await _database!.rawQuery('SELECT COUNT(*) FROM ml_predictions')
        ) ?? 0;
      } catch (e) {
        debugPrint('Error getting ML predictions count: $e');
      }
      
      try {
        weatherCacheCount = Sqflite.firstIntValue(
          await _database!.rawQuery('SELECT COUNT(*) FROM weather_cache')
        ) ?? 0;
      } catch (e) {
        debugPrint('Error getting weather cache count: $e');
      }
      
      return {
        'documents_size': documentsSize,
        'temp_size': tempSize,
        'database_size': dbSize,
        'total_size': documentsSize + tempSize,
        'crop_records_count': cropRecordsCount,
        'disease_history_count': diseaseHistoryCount,
        'calendar_events_count': calendarEventsCount,
        'ml_predictions_count': mlPredictionsCount,
        'weather_cache_count': weatherCacheCount,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      throw StorageException('Failed to get storage statistics', originalError: e);
    }
  }

  /// Execute database operation in transaction
  Future<T> executeInTransaction<T>(Future<T> Function(Transaction txn) action) async {
    _ensureInitialized();
    
    if (_database == null) {
      throw DatabaseException('Database not initialized');
    }
    
    try {
      return await _database!.transaction(action);
    } catch (e) {
      throw DatabaseException('Transaction failed', originalError: e);
    }
  }

  /// Export data for backup
  Future<Map<String, dynamic>> exportData({String? userId}) async {
    _ensureInitialized();
    
    final data = <String, dynamic>{};
    
    try {
      // Export calendar events
      final calendarEvents = await getCalendarEventsFromDb(userId: userId);
      data['calendar_events'] = calendarEvents.map((e) => e.toJson()).toList();
      
      // Export other data if userId is provided
      if (userId != null && userId.trim().isNotEmpty) {
        try {
          data['user_data'] = await getUserData(userId);
        } catch (e) {
          debugPrint('Error exporting user data: $e');
          data['user_data'] = null;
        }
        
        try {
          data['crop_records'] = await getCropRecords(userId);
        } catch (e) {
          debugPrint('Error exporting crop records: $e');
          data['crop_records'] = [];
        }
        
        try {
          data['disease_history'] = await getDiseaseHistory(userId);
        } catch (e) {
          debugPrint('Error exporting disease history: $e');
          data['disease_history'] = [];
        }
      }
      
      data['exported_at'] = DateTime.now().toIso8601String();
      data['version'] = _dbVersion;
      
      return data;
    } catch (e) {
      throw StorageException('Failed to export data', originalError: e);
    }
  }

  /// Clear all data with confirmation and transaction support
  Future<void> clearAllData({bool includePreferences = true}) async {
    _ensureInitialized();
    
    try {
      // Clear database tables in transaction
      if (_database != null) {
        await _database!.transaction((txn) async {
          await txn.delete('calendar_events');
          await txn.delete('user_data');
          await txn.delete('crop_records');
          await txn.delete('disease_history');
          await txn.delete('weather_cache');
          await txn.delete('ml_predictions');
          await txn.delete('app_settings');
        });
      }
      
      // Clear preferences if requested
      if (includePreferences && _prefs != null) {
        await _prefs!.clear();
      }
      
      debugPrint('All data cleared successfully');
    } catch (e) {
      throw StorageException('Failed to clear all data', originalError: e);
    }
  }

  /// Database health check
  Future<bool> performHealthCheck() async {
    _ensureInitialized();
    
    try {
      // Check if database is accessible
      if (_database == null) {
        return false;
      }
      
      // Try a simple query
      await _database!.rawQuery('SELECT 1');
      
      // Check if preferences are accessible
      if (_prefs == null) {
        return false;
      }
      
      // Try a simple preferences operation
      await _prefs!.setString('health_check', DateTime.now().toIso8601String());
      await _prefs!.remove('health_check');
      
      return true;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  /// Close database connection safely
  Future<void> close() async {
    try {
      await _database?.close();
      _database = null;
      _prefs = null;
      _isInitialized = false;
      debugPrint('StorageService closed successfully');
    } catch (e) {
      debugPrint('Error closing StorageService: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    close();
  }
}