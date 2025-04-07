import 'package:flutter/material.dart';
import 'news_detail.dart';

class NewsView extends StatelessWidget {
  final List<Map<String, dynamic>> newsItems;

  const NewsView({
    Key? key,
    required this.newsItems,
  }) : super(key: key);
  //roar
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Berita Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3F7F),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all news page
                  },
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            for (var newsItem in newsItems)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(
                        title: newsItem['title'] ?? '',
                        date: newsItem['date'] ?? '',
                        imageUrl: newsItem['image'] ?? '',
                        content: newsItem['content'] ?? 'No content available',
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add padding around each news image 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              newsItem['image'],
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 6), // Adjusted spacing
                        Text(
                          newsItem['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          newsItem['content'],
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          newsItem['date'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// News data
final List<Map<String, dynamic>> newsItems = [
  {
    'title': 'Jadwal Ujian Tahfidz Semester Genap',
    'content': 'Ujian Tahfidz akan dilaksanakan pada tanggal 15-20 Juni 2024. Pastikan siswa sudah mempersiapkan hafalan dengan baik.',
    'date': '10 Mei 2024',
    'image': 'assets/images/yoga.jpg',
  },
  {
    'title': 'Workshop Metode Menghafal Al-Quran',
    'content': 'Workshop akan diadakan pada hari Sabtu, 25 Mei 2024. Kegiatan ini wajib diikuti oleh seluruh guru tahfidz.',
    'date': '5 Mei 2024',
    'image': 'assets/news2.jpg',
  },
  {
    'title': 'Pengumuman Perlombaan Tahfidz Nasional',
    'content': 'Pendaftaran untuk Perlombaan Tahfidz Nasional telah dibuka. Batas akhir pendaftaran tanggal 30 Mei 2024.',
    'date': '1 Mei 2024',
    'image': 'assets/news3.jpg',
  },
];
