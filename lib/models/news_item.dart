/// News item model for agricultural news and updates
class NewsItem {
  /// Creates a news item
  const NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.publishedAt,
    required this.source,
    required this.url,
    required this.tags,
  });

  /// Creates a news item from JSON data
  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id: (json['id'] ?? '') as String,
        title: (json['title'] ?? '') as String,
        description: (json['description'] ?? '') as String,
        content: (json['content'] ?? '') as String,
        category: (json['category'] ?? '') as String,
        imageUrl: (json['imageUrl'] ?? '') as String,
        publishedAt: json['publishedAt'] != null
            ? DateTime.parse(json['publishedAt'] as String)
            : DateTime.now(),
        source: (json['source'] ?? '') as String,
        url: (json['url'] ?? '') as String,
        tags: json['tags'] != null
            ? List<String>.from(json['tags'] as List)
            : <String>[],
      );

  /// Unique identifier for the news item
  final String id;

  /// Title of the news article
  final String title;

  /// Brief description or summary of the news
  final String description;

  /// Full content of the news article
  final String content;

  /// Category of the news (e.g., crops, weather, market)
  final String category;

  /// URL of the associated image
  final String imageUrl;

  /// Date and time when the news was published
  final DateTime publishedAt;

  /// Source of the news article
  final String source;

  /// URL to the full article
  final String url;

  /// Tags associated with the news item
  final List<String> tags;

  /// Converts the news item to JSON format
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'content': content,
        'category': category,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt.toIso8601String(),
        'source': source,
        'url': url,
        'tags': tags,
      };

  /// Creates a copy of this news item with modified fields
  NewsItem copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? category,
    String? imageUrl,
    DateTime? publishedAt,
    String? source,
    String? url,
    List<String>? tags,
  }) =>
      NewsItem(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        content: content ?? this.content,
        category: category ?? this.category,
        imageUrl: imageUrl ?? this.imageUrl,
        publishedAt: publishedAt ?? this.publishedAt,
        source: source ?? this.source,
        url: url ?? this.url,
        tags: tags ?? this.tags,
      );

  /// Checks if the news item has an image
  bool get hasImage => imageUrl.isNotEmpty;

  /// Checks if the news item has tags
  bool get hasTags => tags.isNotEmpty;

  /// Gets the age of the news item in days
  int get ageInDays => DateTime.now().difference(publishedAt).inDays;

  /// Checks if the news item is recent (published within last 7 days)
  bool get isRecent => ageInDays <= 7;

  @override
  String toString() =>
      'NewsItem(id: $id, title: $title, category: $category, publishedAt: $publishedAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}