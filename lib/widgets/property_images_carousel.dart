import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../screens/full_screen_image.dart';
import 'property_video_card.dart';

class PropertyImagesCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String? videoUrl;
  final String propertyId;

  const PropertyImagesCarousel({
    super.key,
    required this.imageUrls,
    this.videoUrl,
    required this.propertyId,
  });

  @override
  State<PropertyImagesCarousel> createState() => _PropertyImagesCarouselState();
}

class _PropertyImagesCarouselState extends State<PropertyImagesCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Media List: [...Images, Video (if exists)]
    // Actually, usually video is first or last. Let's put Video LAST as typical in real estate apps,
    // or separate? User said "Carousel item". Let's put it at the end.
    final hasVideo = widget.videoUrl != null && widget.videoUrl!.isNotEmpty;
    final totalItems = widget.imageUrls.length + (hasVideo ? 1 : 0);

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: totalItems,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            // Check if this index is the Video
            // If hasVideo is true, the last index is the video.
            // Index goes from 0 to imageUrls.length (if hasVideo).
            // So if index == imageUrls.length, it's the video.

            if (hasVideo && index == widget.imageUrls.length) {
              return PropertyVideoCard(
                videoUrl: widget.videoUrl!,
                autoPlay:
                    false, // User taps to play usually better for UX in carousel
                looping: true,
              );
            }

            // Otherwise, it's an image
            final imageUrl = widget.imageUrls[index];
            final uniqueTag = 'property_image_${widget.propertyId}_$index';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(
                      images: widget.imageUrls,
                      initialIndex: index,
                      baseHeroTag: 'property_image_${widget.propertyId}',
                    ),
                  ),
                );
              },
              child: Hero(
                tag: uniqueTag,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.grey.shade300,
                    child: Icon(
                      Icons.broken_image,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Gradient Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
        ),

        // Page Indicator
        if (totalItems > 1)
          Positioned(
            bottom: 20,
            left: 20,
            child: AnimatedSmoothIndicator(
              activeIndex: _currentIndex % (totalItems > 5 ? 5 : totalItems),
              count: totalItems > 5 ? 5 : totalItems,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 8,
                activeDotColor: Colors.white,
                dotColor: Colors.white54,
                type: WormType.thin,
              ),
            ),
          ),

        // Image Counter Badge
        Positioned(
          top: 40, // Adjust based on SafeArea usually
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentIndex + 1} / $totalItems',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Navigation Arrows
        if (totalItems > 1) ...[
          // Previous Page (Right Button for RTL)
          if (_currentIndex > 0)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),

          // Next Page (Left Button for RTL)
          if (_currentIndex < totalItems - 1)
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],

        // Property ID Overlay (Bottom Right)
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ' ${widget.propertyId}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
