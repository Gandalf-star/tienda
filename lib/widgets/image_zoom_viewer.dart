import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ImageZoomViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageZoomViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  static void show(BuildContext context, List<String> images, {int initialIndex = 0}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => ImageZoomViewer(
          images: images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<ImageZoomViewer> createState() => _ImageZoomViewerState();
}

class _ImageZoomViewerState extends State<ImageZoomViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: Stack(
        children: [
          // Image carousel with zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, index) {
              try {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.memory(
                      base64Decode(widget.images[index]),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              } catch (_) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.white38),
                );
              }
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _buildCircleButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // Page indicator
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _currentIndex ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _currentIndex
                          ? AppTheme.gold
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

          // Counter
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
