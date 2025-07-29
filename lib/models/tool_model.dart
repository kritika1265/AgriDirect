// lib/models/tool_model.dart
class ToolModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double pricePerDay;
  final String location;
  final String imageUrl;
  final String ownerName;
  final String ownerPhone;
  final bool isAvailable;
  final double rating;
  final int totalRatings;

  ToolModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.pricePerDay,
    required this.location,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerPhone,
    required this.isAvailable,
    required this.rating,
    required this.totalRatings,
  });

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      pricePerDay: json['pricePerDay'].toDouble(),
      location: json['location'],
      imageUrl: json['imageUrl'],
      ownerName: json['ownerName'],
      ownerPhone: json['ownerPhone'],
      isAvailable: json['isAvailable'],
      rating: json['rating'].toDouble(),
      totalRatings: json['totalRatings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'pricePerDay': pricePerDay,
      'location': location,
      'imageUrl': imageUrl,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'isAvailable': isAvailable,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }
}

// lib/models/rental_model.dart
enum RentalStatus { pending, active, completed, cancelled }

class RentalModel {
  final String id;
  final String toolId;
  final String toolName;
  final String ownerName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  RentalStatus status;
  final String location;

  RentalModel({
    required this.id,
    required this.toolId,
    required this.toolName,
    required this.ownerName,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
    required this.location,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'],
      toolId: json['toolId'],
      toolName: json['toolName'],
      ownerName: json['ownerName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalAmount: json['totalAmount'].toDouble(),
      status: RentalStatus.values.firstWhere(
        (e) => e.toString() == 'RentalStatus.${json['status']}',
      ),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toolId': toolId,
      'toolName': toolName,
      'ownerName': ownerName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'location': location,
    };
  }
}

// lib/models/news_model.dart
class NewsModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String imageUrl;
  final DateTime publishedAt;
  final String source;
  final String author;
  final bool isBookmarked;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.publishedAt,
    required this.source,
    required this.author,
    this.isBookmarked = false,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      imageUrl: json['imageUrl'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt']),
      source: json['source'],
      author: json['author'] ?? '',
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'source': source,
      'author': author,
      'isBookmarked': isBookmarked,
    };
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    DateTime? publishedAt,
    String? source,
    String? author,
    bool? isBookmarked,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      source: source ?? this.source,
      author: author ?? this.author,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

// lib/models/notification_model.dart
enum NotificationType { weather, disease, market, reminder, system }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}