import 'package:equatable/equatable.dart';

class CalendarEvent extends Equatable {
  final String id;
  final String? userId; // Added userId field for database implementation
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String category;
  final String cropType;
  final bool isCompleted;
  final bool hasReminder;
  final DateTime? reminderDate;
  final String? location;
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
    return 'CalendarEvent(id: $id, userId: $userId, title: $title, startDate: $startDate, category: $category, cropType: $cropType)';
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
  other('other');

  const EventCategory(this.value);
  final String value;

  static EventCategory fromString(String value) {
    return EventCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => EventCategory.other,
    );
  }
}