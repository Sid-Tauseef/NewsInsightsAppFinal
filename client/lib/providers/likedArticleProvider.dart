import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:client/models/ArticlesModel.dart';
import 'package:client/constants/config.dart';

class LikedArticlesProvider extends ChangeNotifier {
  String? _userEmail; // Email retrieved from SharedPreferences
  final List<String> _likedArticles = [];
  List<bool> _likedStates = [];

  // Constructor to initialize the email
  LikedArticlesProvider() {
    _initializeEmail();
  }

  // Initialize email from SharedPreferences
  Future<void> _initializeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('email');
    print("LikedArticlesProvider initialized with userEmail: $_userEmail");
  }

  // Getter for userEmail
  String? get userEmail => _userEmail;

  // Initialize liked states based on the number of articles
  void initLikedStates(int length) {
    _likedStates = List.filled(length, false);
    notifyListeners();
  }

  // Getter for liked articles
  List<String> get likedArticles => _likedArticles;

  // Add an article to liked list and update the backend
  Future<void> addLikedArticle(String articleTitle, String articleCategory) async {
    if (_userEmail == null) {
      print("User email is not available. Cannot like article.");
      return;
    }

    print("Attempting to like article: $articleTitle");

    if (!_likedArticles.contains(articleTitle)) {
      _likedArticles.add(articleTitle);

      try {
        print("Sending like request to backend...");
        final response = await http.post(
          Uri.parse('${Config.userApiUrl}likeArticle'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": _userEmail,
            "articleTitle": articleTitle,
            "articleCategory": articleCategory,
          }),
        );

        print("Backend response status code: ${response.statusCode}");
        print("Backend response body: ${response.body}");

        if (response.statusCode == 200) {
          print('Article liked successfully');
        } else {
          print('Failed to like article. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error while liking article: $e');
      }
    } else {
      print("Article already liked: $articleTitle");
    }

    notifyListeners();
  }

  // Remove an article from liked list and update the backend
  Future<void> removeLikedArticle(String articleTitle) async {
    if (_userEmail == null) {
      print("User email is not available. Cannot unlike article.");
      return;
    }

    print("Attempting to unlike article: $articleTitle");

    if (_likedArticles.contains(articleTitle)) {
      _likedArticles.remove(articleTitle);

      try {
        print("Sending unlike request to backend...");
        final response = await http.post(
          Uri.parse('${Config.userApiUrl}unlikeArticle'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": _userEmail,
            "articleTitle": articleTitle,
          }),
        );

        print("Backend response status code: ${response.statusCode}");
        print("Backend response body: ${response.body}");

        if (response.statusCode == 200) {
          print('Article unliked successfully');
        } else {
          print('Failed to unlike article. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error while unliking article: $e');
      }
    } else {
      print("Article not found in liked list: $articleTitle");
    }

    notifyListeners();
  }

  // Check if the article is liked
  bool isItemLiked(int index) {
    return _likedStates[index];
  }

  // Toggle the liked state of an article
  void toggleItemLiked(int index, Article article) {
    _likedStates[index] = !_likedStates[index];
    if (_likedStates[index]) {
      addLikedArticle(article.title, article.category ?? 'general');
    } else {
      removeLikedArticle(article.title);
    }
    notifyListeners();
  }
}