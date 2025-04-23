import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/constants/config.dart';
import 'package:client/models/ArticlesModel.dart';
import 'package:client/models/Category_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  // State variables
  final List<Category> categories = [
    Category(id: "1", image: "assets/image/index1.jpg", name: 'Health'),
    Category(id: "2", image: "assets/image/index2.jpg", name: 'Politics'),
    Category(id: "3", image: "assets/image/index3.jpg", name: 'Business'),
    Category(id: "4", image: "assets/image/index4.jpg", name: 'Science'),
    Category(id: "5", image: "assets/image/index5.jpg", name: 'Sports'),
    Category(id: "6", image: "assets/image/index6.jpg", name: 'Technology'),
    Category(id: "7", image: "assets/image/index7.jpg", name: 'Nature'),
    Category(id: "8", image: "assets/image/index8.jpg", name: 'Fashion'),
  ];

  List<Category> filteredCategories = [];
  List<Article> newsData = [];
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'Technology';

  @override
  void initState() {
    super.initState();
    filteredCategories = categories;
    fetchData(selectedCategory);
  }

  Future<void> fetchData(String category) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final String apiUrl =
        "https://newsapi.org/v2/everything?q=$category&sources=the-times-of-india&apiKey=${Config.apiKey}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = data['articles'] as List;
        if (mounted) {
          setState(() {
            newsData = articles.map((e) => Article.fromJson(e)).toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load news data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final themeColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Category News',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search categories...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: themeColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.filter_alt_rounded, color: themeColor),
                    onPressed: () {
                      if (searchController.text.isNotEmpty) {
                        fetchData(searchController.text);
                      }
                    },
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    filteredCategories = categories
                        .where((category) => category.name
                            .toLowerCase()
                            .contains(text.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: height * 0.25,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filteredCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.8,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = filteredCategories[index].name;
                    });
                    fetchData(filteredCategories[index].name);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            filteredCategories[index].image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7)
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Text(
                            filteredCategories[index].name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black87,
                                  offset: Offset(2, 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        if (selectedCategory == filteredCategories[index].name)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: themeColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 18),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: themeColor,
                      strokeWidth: 2,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: newsData.length,
                    itemBuilder: (context, index) {
                      final item = newsData[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () async {
                            final url = Uri.tryParse(item.url);
                            if (url != null && await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.urlToImage,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey.shade100,
                                      child: Icon(Icons.image_not_supported,
                                          color: Colors.grey.shade400),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: themeColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Read More',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
