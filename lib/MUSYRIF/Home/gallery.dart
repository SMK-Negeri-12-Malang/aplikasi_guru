import 'dart:async';
import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final List<String> imageUrls = [
    'https://source.unsplash.com/random/400x300?gallery1',
    'https://source.unsplash.com/random/400x300?gallery2',
    'https://source.unsplash.com/random/400x300?gallery3',   'https://source.unsplash.com/random/400x300?gallery4',
    'https://source.unsplash.com/random/400x300?gallery5',
    'https://source.unsplash.com/random/400x300?gallery6',
  ];

  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startImageSlider();
  }

  // Fungsi untuk memulai timer dan mengganti gambar setiap 3 detik
  void _startImageSlider() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % imageUrls.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();  // Membatalkan timer saat halaman dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Menampilkan gambar yang berganti secara otomatis
            Expanded(
              child: PageView.builder(
                itemCount: imageUrls.length,
                controller: PageController(viewportFraction: 1.0),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
