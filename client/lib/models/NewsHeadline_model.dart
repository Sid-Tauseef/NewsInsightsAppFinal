// ignore_for_file: unused_import, constant_identifier_names

import 'package:flutter/material.dart';
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
    this.isLiked = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    String dateString = json['publishedAt'] ?? '';
    DateTime dateTime = DateTime.tryParse(dateString) ?? DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

    const String defaultImage =
        'https://play-lh.googleusercontent.com/8LYEbSl48gJoUVGDUyqO5A0xKlcbm2b39S32xvm_h-8BueclJnZlspfkZmrXNFX2XQ';

    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      author: json['author'] ?? 'Unknown Author',
      publishedAt: formattedDate,
      sourceName: json['source']['name'] ?? 'Unknown Source',
      urlToImage: json['urlToImage'] ?? defaultImage,
      content: json['content'] ?? 'No Content',
    );
  }
}
