import 'package:flutter/material.dart';
import 'news_detail.dart';
import 'list_berita.dart';

class NewsView extends StatelessWidget {
  final List<Map<String, dynamic>> newsItems;

  const NewsView({
    Key? key,
    required this.newsItems,
  }) : super(key: key);

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
                    showDialog(
                      context: context,
                      builder: (context) => ListBerita(newsItems: newsItems),
                    );
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
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
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
    'title': 'tungtung sahur',
    'content':
        'Ujian Tahfidz akan dilaksanakan pada tanggal 15-20 Juni 2024. Pastikan siswa sudah mempersiapkan hafalan dengan baik.',
    'date': '10 Mei 2024',
    'image': 'assets/images/shei.png',
  },
  {
    'title': 'A Love Beyond Time',
    'content':
        'Aku mencintaimu setiap detik, setiap menit, setiap hari, dan setiap waktu. Cintaku hadir seperti a never-ending melody yang terus mengalun tanpa henti. Namamu mengalir di setiap tarikan napas, seolah menjadi the rhythm of my soul  Setiap kali aku menatapmu, dunia terasa diam, seakan waktu berhenti hanya untuk kita—frozen in a perfect moment. Kau adalah my constant in the chaos, satu-satunya hal yang tetap ketika segalanya berubah.Cinta ini bukan hanya sekadar rasa, tapi a promise whispered through eternity, yang tak akan pernah hilang, bahkan oleh waktu itu sendiri.',   
    'date': '5 Mei 2024',
    'image': 'assets/images/ily.jpg',
  },
  {
    'title': 'Whispers Between The Stars',
    'content':
        'Dalam sunyi malam, ada bisikan hatiku yang tak pernah sampai padamu, namun selalu hidup di antara bintang. Even when silence surrounds me, your name echoes within. Cintaku bukan teriakan, tapi bisikan halus yang menyelinap lewat angin—a secret the moon keeps for me.',
    'date': '1 Mei 2024',
    'image': 'assets/images/flowers.jpg',
  },
];
