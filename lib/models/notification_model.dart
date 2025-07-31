/// A model class representing a notification in the application.
class NotificationModel {
  /// Unique identifier for the notification.
  final String id;
  
  /// Title of the notification.
  final String title;
  
  /// Body content of the notification.
  final String body;
  
  /// Type/category of the notification.
  final String type;
  
  /// Additional data associated with the notification.
  final Map<String, dynamic> data;
  
  /// Timestamp when the notification was created.
  final DateTime timestamp;
  
  /// Whether the notification has been read by the user.
  final bool isRead;
  
  /// ID of the user who should receive this notification.
  final String userId;

  /// Creates a new NotificationModel instance.
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.isRead,
    required this.userId,
  });

  /// Creates a NotificationModel instance from a JSON map.
  factory NotificationModel.fromJson(Map<String, dynamic> json) => 
    NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      data: json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      isRead: json['is_read'] == true,
      userId: json['user_id']?.toString() ?? '',
    );
}