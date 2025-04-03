class NewsArticle {
  final String title;
  final String description;
  final String content;
  final String image;
  final String url;
  final String publishedAt;
  final String source;
  final String author;

  NewsArticle({
    required this.title,
    required this.description,
    required this.content,
    required this.image,
    required this.url,
    required this.publishedAt,
    required this.source,
    required this.author,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      description: json['description'],
      content: json['content'],
      image: json['image'],
      url: json['url'],
      publishedAt: json['published_at'],
      source: json['source'],
      author: json['author'],
    );
  }

  String getFormattedDate() {
    try {
      // Parse RSS date format (e.g., "Tue, 13 Feb 2024 15:30:00 +0000")
      final date = DateTime.parse(
        publishedAt.replaceFirst(RegExp(r'(\w+,\s)?'), '')
      ).toLocal();
      
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inHours < 24) {
        if (difference.inHours < 1) {
          final minutes = difference.inMinutes;
          return '$minutes minute${minutes == 1 ? '' : 's'} ago';
        }
        final hours = difference.inHours;
        return '$hours hour${hours == 1 ? '' : 's'} ago';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days day${days == 1 ? '' : 's'} ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return publishedAt;
    }
  }
}
