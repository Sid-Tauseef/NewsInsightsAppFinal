import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client/constants/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/providers/likedArticleProvider.dart';
import 'package:shimmer/shimmer.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  List<Map<String, dynamic>> _recommendedArticles = [];
  bool isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  Future<void> _getRecommendations(BuildContext context) async {
    setState(() {
      isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _recommendedArticles.clear();
    });

    try {
      final email =
          Provider.of<LikedArticlesProvider>(context, listen: false).userEmail;

      final likedResponse = await http.post(
        Uri.parse(Config.getLikedArticles),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );

      if (likedResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch liked articles: ${likedResponse.statusCode}');
      }

      final likedJson = jsonDecode(likedResponse.body);

      if (likedJson['status'] != true ||
          !likedJson.containsKey('data') ||
          !(likedJson['data']['likedArticles'] is List)) {
        throw Exception('Server returned invalid data format');
      }

      final likedArticles =
          List<dynamic>.from(likedJson['data']['likedArticles'] ?? []);

      if (likedArticles.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Like some articles to get recommendations!';
        });
        return;
      }

      // Take the 10 most recent articles (last 10 in the list)
      final topLiked = likedArticles.length > 10
          ? likedArticles.sublist(likedArticles.length - 10)
          : likedArticles;

      final recommendationResponse = await http.post(
        Uri.parse(Config.recommend),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "liked_articles": topLiked
              .map((article) => {
                    "title": article["title"]?.toString() ?? "",
                    "category": article["category"]?.toString() ?? "general"
                  })
              .toList()
        }),
      );

      if (recommendationResponse.statusCode == 200) {
        final recommendations = jsonDecode(recommendationResponse.body);

        if (recommendations is List) {
          final validRecommendations = recommendations
              .where((item) => item is Map<String, dynamic>)
              .cast<Map<String, dynamic>>()
              .toList();

          setState(() {
            _recommendedArticles = validRecommendations;
            if (_recommendedArticles.isEmpty) {
              _hasError = true;
              _errorMessage = 'No recommendations found for your interests';
            }
          });
        } else {
          throw Exception('Invalid recommendations format');
        }
      } else {
        throw Exception(
            'Recommendation API error: ${recommendationResponse.statusCode}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getRecommendations(context);
    });
  }

  String _parsePublishedDate(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) return 'Unknown Date';
    try {
      final dateTime = DateTime.parse(publishedAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown Date';
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recommended News',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade50,
              Colors.blueAccent.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) return _buildShimmerLoading();
    if (_hasError) return _buildErrorWidget();
    if (_recommendedArticles.isEmpty) return _buildEmptyWidget();

    return RefreshIndicator(
      onRefresh: () => _getRecommendations(context),
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _recommendedArticles.length,
        itemBuilder: (context, index) =>
            _buildArticleCard(_recommendedArticles[index]),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    final publishedDate = _parsePublishedDate(article['publishedAt']);
    final imageUrl = article['urlToImage']?.toString() ?? '';
    final title = article['title']?.toString() ?? 'Untitled Article';
    final description = article['description']?.toString() ?? '';
    final source = article['source'] is Map
        ? article['source']['name']?.toString()
        : article['source']?.toString();

    return InkWell(
      onTap: () => _launchURL(article['url']),
      child: Card(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWidget(imageUrl, source),
            _buildArticleContent(title, description, publishedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent(
      String title, String description, String publishedDate) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Text(
            publishedDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl, String? sourceName) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[100],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) =>
                  _buildPlaceholderImage(sourceName),
            )
          : _buildPlaceholderImage(sourceName),
    );
  }

  Widget _buildPlaceholderImage(String? sourceName) {
    return Container(
      height: 200,
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article, size: 50, color: Colors.grey),
            if (sourceName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  sourceName,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                height: 250,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Failed to load recommendations',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No recommendations found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
