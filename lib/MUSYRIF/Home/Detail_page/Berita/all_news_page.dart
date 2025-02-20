import 'package:flutter/material.dart';
import 'detail_berita.dart';

class AllNewsPage extends StatelessWidget {
  const AllNewsPage({Key? key}) : super(key: key);

  final List<Map<String, String>> allNewsItems = const [
    {
      'imageUrl': 'https://picsum.photos/200/200',
      'title': 'Judul Berita 1',
      'description': 'Deskripsi lengkap berita 1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      'time': '1j yang lalu',
    },
    {
      'imageUrl': 'https://picsum.photos/200/200',
      'title': 'Judul Berita 2',
      'description': 'Deskripsi lengkap berita 2. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      'time': '2j yang lalu',
    },
    // Add more news items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Berita'),
        backgroundColor: const Color(0xFF2B4BF2),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allNewsItems.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(
                    news: allNewsItems[index],
                    title: allNewsItems[index]['title'] ?? '',
                    description: allNewsItems[index]['description'] ?? '',
                    imageUrl: allNewsItems[index]['imageUrl'] ?? '',
                    time: allNewsItems[index]['time'] ?? '',
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    child: Image.network(
                      allNewsItems[index]['imageUrl']!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allNewsItems[index]['title']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          allNewsItems[index]['description']!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          allNewsItems[index]['time']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
