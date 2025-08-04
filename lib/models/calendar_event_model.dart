import 'package:equatable/equatable.dart';

/// Calendar event model for agricultural activities
class CalendarEvent extends Equatable {
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

  const CalendarEvent({
    required this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.category,
    required this.cropType,
    this.isCompleted = false,
    this.hasReminder = false,
    this.reminderDate,
    this.location,
    this.metadata,
  });

  /// Create CalendarEvent from JSON
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
    );
  }

  /// Convert CalendarEvent to JSON
  Map<String, dynamic> toJson() {
    return {
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
    };
  }

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
  }) {
    return CalendarEvent(
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
    );
  }

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
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (isToday) return 'Today';
    if (isUpcoming) return 'Upcoming';
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
      ];

  @override
  String toString() {
    return 'CalendarEvent(id: $id, userId: $userId, title: $title, startDate: $startDate, category: $category, cropType: $cropType, status: $status)';
  }
}

/// Enum for common calendar event categories
enum EventCategory {
  planting('planting'),
  harvesting('harvesting'),
  fertilizing('fertilizing'),
  irrigation('irrigation'),
  pestControl('pest_control'),
  soilPreparation('soil_preparation'),
  pruning('pruning'),
  weeding('weeding'),
  monitoring('monitoring'),
  maintenance('maintenance'),
  other('other');

  const EventCategory(this.value);
  final String value;

  /// Convert string to EventCategory
  static EventCategory fromString(String value) {
    return EventCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => EventCategory.other,
    );
  }

  /// Get display name for the category
  String get displayName {
    switch (this) {
      case EventCategory.planting:
        return 'Planting';
      case EventCategory.harvesting:
        return 'Harvesting';
      case EventCategory.fertilizing:
        return 'Fertilizing';
      case EventCategory.irrigation:
        return 'Irrigation';
      case EventCategory.pestControl:
        return 'Pest Control';
      case EventCategory.soilPreparation:
        return 'Soil Preparation';
      case EventCategory.pruning:
        return 'Pruning';
      case EventCategory.weeding:
        return 'Weeding';
      case EventCategory.monitoring:
        return 'Monitoring';
      case EventCategory.maintenance:
        return 'Maintenance';
      case EventCategory.other:
        return 'Other';
    }
  }
}

/// Extension to add utility methods to List<CalendarEvent>
extension CalendarEventListExtension on List<CalendarEvent> {
  /// Filter events by category
  List<CalendarEvent> byCategory(String category) {
    return where((event) => event.category == category).toList();
  }

  /// Filter events by crop type
  List<CalendarEvent> byCropType(String cropType) {
    return where((event) => event.cropType == cropType).toList();
  }

  /// Get only completed events
  List<CalendarEvent> get completed {
    return where((event) => event.isCompleted).toList();
  }

  /// Get only pending events
  List<CalendarEvent> get pending {
    return where((event) => !event.isCompleted).toList();
  }

  /// Get overdue events
  List<CalendarEvent> get overdue {
    return where((event) => event.isOverdue).toList();
  }

  /// Get today's events
  List<CalendarEvent> get today {
    return where((event) => event.isToday).toList();
  }

  /// Get upcoming events
  List<CalendarEvent> get upcoming {
    return where((event) => event.isUpcoming).toList();
  }

  /// Sort events by start date
  List<CalendarEvent> sortedByDate({bool ascending = true}) {
    final sorted = List<CalendarEvent>.from(this);
    sorted.sort((a, b) => ascending 
        ? a.startDate.compareTo(b.startDate)
        : b.startDate.compareTo(a.startDate));
    return sorted;
  }
}