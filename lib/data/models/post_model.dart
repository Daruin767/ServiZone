class Post {
  final String id;
  String title;
  String content;
  String category;
  String author;
  DateTime publishDate;
  bool isPublished;
  bool isFeatured;
  int views;
  int likes;
  String imageUrl;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.publishDate,
    required this.isPublished,
    required this.isFeatured,
    required this.views,
    required this.likes,
    required this.imageUrl,
  });
}