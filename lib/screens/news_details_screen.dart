import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

class NewsDetailsScreen extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailsScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Details'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.image.isNotEmpty)
              Hero(
                tag: article.url,
                child: CachedNetworkImage(
                  imageUrl: article.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, size: 50),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 28, // Increased font size
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16), // Increased spacing
                  Row(
                    children: [
                      Icon(Icons.person, size: 18, color: Colors.blue.shade900),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          article.author,
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 16, // Increased font size
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.blue.shade900),
                      const SizedBox(width: 4),
                      Text(
                        article.getFormattedDate(),
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 16, // Increased font size
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // Increased spacing
                  // Display full content with larger text
                  Text(
                    article.content,
                    style: const TextStyle(
                      fontSize: 18, // Increased font size
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  if (article.source.isNotEmpty) ...[
                    const SizedBox(height: 24), // Increased spacing
                    Text(
                      'Source: ${article.source}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16, // Increased font size
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
