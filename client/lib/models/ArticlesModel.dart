import 'package:intl/intl.dart';

class Article {
  final String sourceName;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;
  final String? category;
  bool isLiked;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.author,
    required this.publishedAt,
    required this.sourceName,
    required this.urlToImage,
    required this.content,
    this.category,
    this.isLiked = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    String dateString = json['publishedAt'] ?? '';
    DateTime dateTime = dateString.isNotEmpty ? DateTime.parse(dateString) : DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

    const String defaultImageUrl =
        'https://play-lh.googleusercontent.com/8LYEbSl48gJoUVGDUyqO5A0xKlcbm2b39S32xvm_h-8BueclJnZlspfkZmrXNFX2XQ';

    return Article(
      description: json['description'] ?? 'No Description',
      title: json['title'] ?? 'No Title',
      url: json['url'] ?? '#',
      author: json['author'] ?? 'Unknown Author',
      publishedAt: formattedDate,
      sourceName: json['source']['name'] ?? 'Unknown Source', // Corrected
      urlToImage: json['urlToImage']?.toString() ?? defaultImageUrl,
      content: json['content'] ?? 'No Content',
      category: json['category'] ?? 'general',
      isLiked: false,
    );
  }
}