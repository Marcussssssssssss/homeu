import 'package:flutter/material.dart';

class PropertyImageGallery extends StatefulWidget {
  const PropertyImageGallery({
    super.key,
    required this.imageUrls,
    this.onTap,
    this.limit,
    this.height = 148,
  });

  final List<String> imageUrls;
  final VoidCallback? onTap;
  final int? limit;
  final double height;

  @override
  State<PropertyImageGallery> createState() => _PropertyImageGalleryState();
}

class _PropertyImageGalleryState extends State<PropertyImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PropertyImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls != widget.imageUrls) {
      _currentIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalUrls = widget.imageUrls;

    // Apply specific rules for limited views (Home and Compare)
    if (widget.limit != null && finalUrls.isNotEmpty) {
      if (finalUrls.length >= widget.limit!) {
        finalUrls = finalUrls.take(widget.limit!).toList();
      }
      // If count is 1 or 2 and less than limit, finalUrls remains as is (showing 1 or 2).
    }

    final hasMultiple = finalUrls.length > 1;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          SizedBox(
            height: widget.height,
            child: finalUrls.isEmpty
                ? _buildPlaceholder()
                : (hasMultiple
                    ? PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemCount: finalUrls.length,
                        itemBuilder: (context, index) {
                          return _buildImage(finalUrls[index]);
                        },
                      )
                    : _buildImage(finalUrls.first)),
          ),
          if (hasMultiple)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  finalUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(isLoading: true);
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Failed to load image: $url');
          debugPrint('Error: $error');
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey.withOpacity(0.1),
            Colors.blueGrey.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.apartment_rounded,
                size: 56,
                color: Colors.blueGrey,
              ),
      ),
    );
  }
}
