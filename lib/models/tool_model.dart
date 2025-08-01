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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      location: json['location']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      ownerName: json['ownerName']?.toString() ?? '',
      ownerPhone: json['ownerPhone']?.toString() ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
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

  ToolModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? pricePerDay,
    String? location,
    String? imageUrl,
    String? ownerName,
    String? ownerPhone,
    bool? isAvailable,
    double? rating,
    int? totalRatings,
  }) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
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
      id: json['id']?.toString() ?? '',
      toolId: json['toolId']?.toString() ?? '',
      toolName: json['toolName']?.toString() ?? '',
      ownerName: json['ownerName']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: _parseRentalStatus(json['status']?.toString()),
      location: json['location']?.toString() ?? '',
    );
  }

  static RentalStatus _parseRentalStatus(String? statusString) {
    if (statusString == null) return RentalStatus.pending;
    
    try {
      return RentalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusString.toLowerCase(),
      );
    } catch (e) {
      return RentalStatus.pending;
    }
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

  RentalModel copyWith({
    String? id,
    String? toolId,
    String? toolName,
    String? ownerName,
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmount,
    RentalStatus? status,
    String? location,
  }) {
    return RentalModel(
      id: id ?? this.id,
      toolId: toolId ?? this.toolId,
      toolName: toolName ?? this.toolName,
      ownerName: ownerName ?? this.ownerName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      location: location ?? this.location,
    );
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? '') ?? DateTime.now(),
      source: json['source']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      isBookmarked: json['isBookmarked'] as bool? ?? false,
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: _parseNotificationType(json['type']?.toString()),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  static NotificationType _parseNotificationType(String? typeString) {
    if (typeString == null) return NotificationType.system;
    
    try {
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString.toLowerCase(),
      );
    } catch (e) {
      return NotificationType.system;
    }
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