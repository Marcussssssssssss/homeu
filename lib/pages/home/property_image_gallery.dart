import 'package:flutter/material.dart';

class PropertyImageGallery extends StatefulWidget {
  const PropertyImageGallery({
    super.key,
    required this.colors,
    this.onTap,
  });

  final List<Color> colors;
  final VoidCallback? onTap;

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
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final hasMultiple = colors.isNotEmpty && colors.length > 1;
    final safeColors = colors.isNotEmpty ? colors : [Colors.grey];

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          SizedBox(
            height: 148,
            child: hasMultiple
                ? PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemCount: safeColors.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              safeColors[index].withValues(alpha: 0.9),
                              const Color(0xFFF0F5FF),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.apartment_rounded,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          safeColors.first.withValues(alpha: 0.9),
                          const Color(0xFFF0F5FF),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          if (hasMultiple)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  safeColors.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
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
}


