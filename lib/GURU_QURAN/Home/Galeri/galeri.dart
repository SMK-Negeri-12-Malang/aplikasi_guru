import 'package:flutter/material.dart';
import 'detail_galeri.dart';

class GalleryView extends StatelessWidget {
  GalleryView({Key? key}) : super(key: key);

  // Gallery images moved from home_quran.dart
  final List<String> _galleryImages = [
    'assets/images/onGlasses.jpg',
    'assets/images/she.jpg',
    'assets/images/beauty.jpg',
    'assets/images/.jpg',
    'assets/images/.jpg',
    'assets/images/.jpg',
  ];

  void _viewGalleryImage(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              child: Image.asset(
                _galleryImages[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child:
                        Icon(Icons.broken_image, size: 100, color: Colors.grey),
                  );
                },
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailGaleri(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DetailGaleri(images: _galleryImages),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Galeri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3F7F),
                  ),
                ),
                TextButton(
                  onPressed: () => _showDetailGaleri(context),
                  child: Text('Lihat Semua'),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _galleryImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _viewGalleryImage(context, index),
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          _galleryImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported,
                                      color: Colors.grey[400], size: 40),
                                  SizedBox(height: 5),
                                  Text(
                                    'No Image',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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
