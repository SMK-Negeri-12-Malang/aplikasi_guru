import 'package:flutter/material.dart';

class NewsDetailPagem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final String time;

  const NewsDetailPagem({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2E3F7F),
        title: const Text('Detail Berita',
        style: TextStyle(
          color: Colors.white
        ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description - expanded in detail view
                  Text(
                    // This would normally be a full article content, using description for demo
                    description + '\n\n' + 
                    'Ini adalah deskripsi lengkap dari berita. Biasanya artikel berita akan memiliki konten yang lebih panjang dan detail dari sekadar deskripsi singkat. Artikel ini berisi informasi lengkap tentang kejadian, fakta, serta pendapat dan analisis yang terkait dengan topik berita.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
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
