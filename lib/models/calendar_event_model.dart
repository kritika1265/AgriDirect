import 'package:equatable/equatable.dart';

/// Calendar event model for agricultural activities
class CalendarEvent extends Equatable {
  /// Creates a calendar event
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.category,
    required this.cropType,
    this.userId,
    this.endDate,
    this.isCompleted = false,
    this.hasReminder = false,
    this.reminderDate,
    this.location,
    this.metadata,
    this.type = EventType.cropActivity,
  });

  /// Creates a calendar event from JSON
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      category: json['category'] as String,
      cropType: json['cropType'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasReminder: json['hasReminder'] as bool? ?? false,
      reminderDate: json['reminderDate'] != null 
          ? DateTime.parse(json['reminderDate'] as String) 
          : null,
      location: json['location'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      type: json['type'] != null 
          ? EventType.values[json['type'] as int]
          : EventType.cropActivity,
    );
  }

  /// Unique identifier for the event
  final String id;
  
  /// User ID who owns this event (for database implementation)
  final String? userId;
  
  /// Title of the event
  final String title;
  
  /// Description of the event
  final String description;
  
  /// Start date and time of the event
  final DateTime startDate;
  
  /// End date and time of the event (optional)
  final DateTime? endDate;
  
  /// Category of the event (e.g., planting, harvesting)
  final String category;
  
  /// Type of crop related to this event
  final String cropType;
  
  /// Whether the event has been completed
  final bool isCompleted;
  
  /// Whether the event has a reminder set
  final bool hasReminder;
  
  /// Date and time for the reminder (if enabled)
  final DateTime? reminderDate;
  
  /// Location where the event takes place
  final String? location;
  
  /// Additional metadata for the event
  final Map<String, dynamic>? metadata;

  /// Event type
  final EventType type;

  /// Convert CalendarEvent to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'category': category,
        'cropType': cropType,
        'isCompleted': isCompleted,
        'hasReminder': hasReminder,
        'reminderDate': reminderDate?.toIso8601String(),
        'location': location,
        'metadata': metadata,
        'type': type.index,
      };

  /// Create a copy of this event with some fields changed
  CalendarEvent copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? cropType,
    bool? isCompleted,
    bool? hasReminder,
    DateTime? reminderDate,
    String? location,
    Map<String, dynamic>? metadata,
    EventType? type,
  }) =>
      CalendarEvent(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        category: category ?? this.category,
        cropType: cropType ?? this.cropType,
        isCompleted: isCompleted ?? this.isCompleted,
        hasReminder: hasReminder ?? this.hasReminder,
        reminderDate: reminderDate ?? this.reminderDate,
        location: location ?? this.location,
        metadata: metadata ?? this.metadata,
        type: type ?? this.type,
      );

  /// Check if this event is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(startDate);
  }

  /// Check if this event is today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(startDate.year, startDate.month, startDate.day);
    return eventDate.isAtSameMomentAs(today);
  }

  /// Check if this event is upcoming (within next 7 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return startDate.isAfter(now) && startDate.isBefore(weekFromNow);
  }

  /// Duration of the event (if end date is provided)
  Duration? get duration {
    if (endDate == null) return null;
    return endDate!.difference(startDate);
  }

  /// Get a human-readable status of the event
  String get status {
    if (isCompleted) {
      return 'Completed';
    }
    if (isOverdue) {
      return 'Overdue';
    }
    if (isToday) {
      return 'Today';
    }
    if (isUpcoming) {
      return 'Upcoming';
    }
    return 'Scheduled';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        startDate,
        endDate,
        category,
        cropType,
        isCompleted,
        hasReminder,
        reminderDate,
        location,
        metadata,
        type,
      ];

  @override
  String toString() =>
      'CalendarEvent(id: $id, userId: $userId, title: $title, startDate: $startDate, category: $category, cropType: $cropType, status: $status)';
}

/// Event types enum
enum EventType {
  /// Crop activity event
  cropActivity,
  /// Custom event
  custom,
  /// Reminder event
  reminder,
  /// Weather event
  weather,
}

/// Extension for EventType display names
extension EventTypeExtension on EventType {
  /// Gets display name for event type
  String get displayName {
    switch (this) {
      case EventType.cropActivity:
        return 'Crop Activity';
      case EventType.custom:
        return 'Custom';
      case EventType.reminder:
        return 'Reminder';
      case EventType.weather:
        return 'Weather';
    }
  }
}