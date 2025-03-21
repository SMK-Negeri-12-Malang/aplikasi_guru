import 'package:aplikasi_guru/MUSYRIF/Home/Detail_page/Berita/all_news_page.dart';
import 'package:flutter/material.dart';
// Add this import for the detail page we'll create
import 'package:aplikasi_guru/MUSYRIF/Home/Laporan/Detail_page/Berita/news_detail_page.dart';

class ActivitySection extends StatelessWidget {
  ActivitySection({Key? key}) : super(key: key);  // Add constructor with optional key

  final List<Map<String, String>> newsItems = [
    {
      'imageUrl': 'https://picsum.photos/200/200', // Example image URL
      'title': 'Judul Berita 1',
      'description': 'Deskripsi singkat berita 1 yang menjelaskan isi berita tersebut',
      'time': '1j yang lalu',
    },
    {
      'imageUrl': 'https://picsum.photos/200/200', // Example image URL
      'title': 'Judul Berita 2',
      'description': 'Deskripsi singkat berita 2 yang menjelaskan isi berita tersebut',
      'time': '2j yang lalu',
    },
    {
      'imageUrl': 'https://picsum.photos/200/200', // Example image URL
      'title': 'Judul Berita 3',
      'description': 'Deskripsi singkat berita 3 yang menjelaskan isi berita tersebut',
      'time': '3j yang lalu',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Berita',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B4BF2),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllNewsPage()),
                  );
                },
                child: const Text('Lihat Semua', 
                style: TextStyle(
                    color: Color(0xFF2B4BF2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPagem(
                        title: newsItems[index]['title'] ?? '',
                        imageUrl: newsItems[index]['imageUrl'] ?? '',
                        description: newsItems[index]['description'] ?? '',
                        time: newsItems[index]['time'] ?? '',
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            newsItems[index]['imageUrl'] ?? '', // Add null check operator
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                newsItems[index]['title'] ?? '', // Add null check operator
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                newsItems[index]['description'] ?? '', // Add null check operator
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                newsItems[index]['time'] ?? '', // Add null check operator
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (index < newsItems.length - 1)
                      const Divider(height: 24, thickness: 0.5),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
