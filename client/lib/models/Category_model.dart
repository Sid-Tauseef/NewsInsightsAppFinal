class Category {
  final String id; // Required ID for the category
  final String name; // Holds the name of the category
  final String image; // Holds the image path
  bool isSelected; // Tracks if the category is selected

  Category({
    required this.id,
    required this.name,
    required this.image,
    this.isSelected = false, // Default to false
  }); // Constructor
}
