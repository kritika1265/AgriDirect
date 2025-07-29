class NewsItem {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String source;
  final String category;
  final DateTime publishedAt;
  final String url;
  final List<String> tags;

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

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? '',
      source: json['source'] ?? '',
      category: json['category'] ?? '',
      publishedAt: DateTime.parse(json['published_at'] ?? DateTime.now().toIso8601String()),
      url: json['url'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}