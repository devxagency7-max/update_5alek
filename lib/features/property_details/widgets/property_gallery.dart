import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

import '../../../../core/models/property_model.dart';
import '../../../../widgets/property_images_carousel.dart';
import '../providers/property_details_provider.dart';

class PropertyGallery extends StatelessWidget {
  final Property property;
  final VoidCallback onBack;

  const PropertyGallery({
    super.key,
    required this.property,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyDetailsProvider>();
    final contactNumbers = provider.contactNumbers;
    final isLoading = provider.loadingContacts;

    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black.withValues(alpha: 0.4),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 24),
              tooltip: context.isAr ? 'اتصل بنا' : 'Contact Us',
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              itemBuilder: (BuildContext context) {
                final items = <PopupMenuEntry<String>>[];

                // Header item
                items.add(
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.contact_phone_outlined,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.isAr ? 'أرقام التواصل' : 'Contact Numbers',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, thickness: 1),
                      ],
                    ),
                  ),
                );

                if (isLoading) {
                  items.add(
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (contactNumbers.isEmpty) {
                  items.add(
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          context.isAr ? 'لا توجد أرقام متاحة' : 'No numbers available',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  items.addAll(
                    contactNumbers.map((data) {
                      final number = data['number'] as String? ?? '';
                      return PopupMenuItem<String>(
                        value: number,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                number,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Icon(
                                Icons.phone_in_talk_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }

                return items;
              },
              onSelected: (String number) async {
                if (number.isEmpty) return;
                final Uri launchUri = Uri(scheme: 'tel', path: number);
                try {
                  if (await canLaunchUrl(launchUri)) {
                    await launchUrl(launchUri);
                  } else {
                    debugPrint('Could not launch $launchUri');
                  }
                } catch (e) {
                  debugPrint('Error launching dialer: $e');
                }
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: PropertyImagesCarousel(
          imageUrls: property.images.isNotEmpty
              ? property.images
              : [property.imageUrl],
          propertyId: property.id,
        ),
      ),
    );
  }
}
