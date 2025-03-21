import 'package:flutter/material.dart';

class GaleriDetailPage extends StatefulWidget {
  final String imageUrl;
  final int index;

  const GaleriDetailPage({
    Key? key,
    required this.imageUrl,
    required this.index,
  }) : super(key: key);

  @override
  State<GaleriDetailPage> createState() => _GaleriDetailPageState();
}

class _GaleriDetailPageState extends State<GaleriDetailPage> {
  final TransformationController _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // If already zoomed in, zoom out
      _transformationController.value = Matrix4.identity();
    } else {
      // If zoomed out, zoom in on the double-tap location
      final position = _doubleTapDetails.localPosition;
      // Zoom to 5.0x at the point that was tapped for full zoom
      final newMatrix = Matrix4.identity()
        ..translate(-position.dx * 4.0, -position.dy * 4.0)
        ..scale(5.0);
      _transformationController.value = newMatrix;
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeri ${widget.index + 1}',
        style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2E3F7F),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(100.0), // Increased boundary margin
              minScale: 0.3,
              maxScale: 8.0, // Increased max scale for full zoom
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat gambar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
