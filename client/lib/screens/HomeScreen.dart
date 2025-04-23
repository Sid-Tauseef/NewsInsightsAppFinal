import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/constants/config.dart';
import 'package:client/providers/likedArticleProvider.dart';
import 'package:client/models/ArticlesModel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer package for loading effect

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<String> categories = ['Technology', 'Science', 'Sports', 'Politics'];
  final String apiUrl =
      "https://newsapi.org/v2/everything?sources=the-times-of-india&apiKey=${Config.apiKey}";
  List<Article> newsData = [];
  List<Article> newsEver = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchRandomNews();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = data['articles'] as List;
        if (mounted) {
          setState(() {
            newsData = articles.map((e) => Article.fromJson(e)).toList();
          });
        }
      } else {
        throw Exception('Failed to load news data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String getRandomCategory() {
    final random = Random();
    return categories[random.nextInt(categories.length)];
  }

  Future<void> fetchRandomNews() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      final randomCategory = getRandomCategory();
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            newsEver = (data['articles'] as List)
                .map((e) => Article.fromJson(e))
                .toList()
                .cast<Article>();
            Provider.of<LikedArticlesProvider>(context, listen: false)
                .initLikedStates(newsEver.length);
          });
        }
      } else {
        throw Exception('Failed to fetch random news');
      }
    } catch (error) {
      print('Error fetching random news: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top News',
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
        elevation: 8,
        shadowColor: Colors.black45,
      ),
      body: Container(
        width: width,
        height: height,
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
        child: isLoading
            ? _buildShimmerLoading(width, height)
            : newsEver.isEmpty
                ? const Center(
                    child: Text(
                      'No news available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchRandomNews,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: newsEver.length,
                      itemBuilder: (context, index) {
                        final item = newsEver[index];
                        return _buildNewsCard(item, index, context);
                      },
                    ),
                  ),
      ),
    );
  }

  // Shimmer loading effect
  Widget _buildShimmerLoading(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Placeholder items
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
                width: width,
                color: Colors.white, // Placeholder color
              ),
            ),
          );
        },
      ),
    );
  }

  // News card widget
// Modified News Card Widget with improved styling
  Widget _buildNewsCard(Article item, int index, BuildContext context) {
    return InkWell(
      onTap: () async {
        final url = Uri.tryParse(item.url);
        if (url != null && await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          print("Invalid URL: ${item.url}");
        }
      },
      child: Card(
        elevation: 6,
        color: Colors.white, // Set card background to pure white
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                item.urlToImage,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: Colors.purple,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image,
                        size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          item.publishedAt,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Consumer<LikedArticlesProvider>(
                        builder: (context, provider, child) {
                          return IconButton(
                            icon: Icon(
                              provider.isItemLiked(index)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: provider.isItemLiked(index)
                                  ? Colors.red
                                  : Colors.grey[600],
                              size: 28,
                            ),
                            onPressed: () {
                              provider.toggleItemLiked(index, item);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
