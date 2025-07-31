/// A model class representing a news item with all relevant information
class NewsItem {
  /// Unique identifier for the news item
  final String id;
  
  /// Title of the news article
  final String title;
  
  /// Brief description of the news article
  final String description;
  
  /// Full content of the news article
  final String content;
  
  /// URL of the image associated with the news article
  final String imageUrl;
  
  /// Source publication of the news article
  final String source;
  
  /// Category classification of the news article
  final String category;
  
  /// Publication date and time of the news article
  final DateTime publishedAt;
  
  /// URL link to the original news article
  final String url;
  
  /// List of tags associated with the news article
  final List<String> tags;

  /// Creates a new NewsItem instance
  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.publishedAt,
    required this.url,
    required this.tags,
  });

  /// Creates a NewsItem from a JSON map
  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
    id: (json['id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    content: (json['content'] ?? '').toString(),
    imageUrl: (json['image_url'] ?? '').toString(),
    source: (json['source'] ?? '').toString(),
    category: (json['category'] ?? '').toString(),
    publishedAt: json['published_at'] != null 
        ? DateTime.parse(json['published_at'].toString())
        : DateTime.now(),
    url: (json['url'] ?? '').toString(),
    tags: (json['tags'] as List<dynamic>?)
        ?.map((tag) => tag.toString())
        .toList() ?? <String>[],
  );
}