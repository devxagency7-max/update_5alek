import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

class PropertyFeatures extends StatefulWidget {
  final List<String> tags;
  final bool isHotelApartment;

  const PropertyFeatures({
    super.key,
    required this.tags,
    this.isHotelApartment = false,
  });

  @override
  State<PropertyFeatures> createState() => _PropertyFeaturesState();
}

class _PropertyFeaturesState extends State<PropertyFeatures> {
  final ScrollController _scrollController = ScrollController();
  bool _showArrow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScroll();
    });
    _scrollController.addListener(_checkScroll);
  }

  void _checkScroll() {
    if (!_scrollController.hasClients) return;

    final bool canScroll = _scrollController.position.maxScrollExtent > 0;
    final bool atEnd =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 20;

    if (mounted) {
      setState(() {
        _showArrow = canScroll && !atEnd;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tags.isEmpty) return const SizedBox.shrink();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.features,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 15),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: 30, // Space for arrow on the left
                  right: 0,
                ),
                child: Row(
                  children: widget.tags.map((tag) {
                    IconData icon = Icons.star_border_rounded;
                    if (tag.toLowerCase().contains('wifi') ||
                        tag.contains('واي')) {
                      icon = Icons.wifi_rounded;
                    }
                    if (tag.toLowerCase().contains('ac') ||
                        tag.contains('تكييف') ||
                        tag.contains('مكيف')) {
                      icon = Icons.ac_unit_rounded;
                    }
                    if (tag.contains('مطبخ')) icon = Icons.kitchen_rounded;
                    if (tag.contains('مؤثثة') || tag.contains('فرش')) {
                      icon = Icons.chair_rounded;
                    }
                    if (tag.contains('أسانسير')) icon = Icons.elevator_rounded;
                    if (tag.contains('أمن')) icon = Icons.security_rounded;
                    if (tag.contains('غسالة')) {
                      icon = Icons.local_laundry_service;
                    }
                    if (tag.contains('تلفزيون') || tag.contains('tv')) {
                      icon = Icons.tv_rounded;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 20,
                      ), // Padding on right for RTL start
                      child: _buildFeatureItem(
                        context,
                        icon,
                        tag,
                        widget.isHotelApartment
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                        widget.isHotelApartment
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_showArrow)
                Positioned(
                  left: -5,
                  child: IgnorePointer(
                    child: Container(
                      height: 50,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor,
                            Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: widget.isHotelApartment
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 25),
        ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    // Logic to handle bilingual labels (e.g. "تكييف / AC" or "AC / تكييف")
    String localizedLabel = label;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (label.contains('/')) {
      final parts = label.split('/');
      if (isAr) {
        // Try to find if any part is Arabic
        localizedLabel = parts
            .firstWhere(
              (p) => p.trim().contains(RegExp(r'[\u0600-\u06FF]')),
              orElse: () => parts[0],
            )
            .trim();
      } else {
        localizedLabel = parts
            .firstWhere(
              (p) => !p.trim().contains(RegExp(r'[\u0600-\u06FF]')),
              orElse: () => parts.length > 1 ? parts[1] : parts[0],
            )
            .trim();
      }
    } else if (label.contains(' - ')) {
      final parts = label.split(' - ');
      if (isAr) {
        localizedLabel = parts[0].trim();
      } else {
        localizedLabel = parts.length > 1 ? parts[1].trim() : parts[0].trim();
      }
    } else if (label.startsWith('{') && label.endsWith('}')) {
      // Logic for map-like strings
      final arMatch = RegExp(r'ar:\s*([^,}]+)').firstMatch(label);
      final enMatch = RegExp(r'en:\s*([^,}]+)').firstMatch(label);
      if (isAr && arMatch != null) {
        localizedLabel = arMatch.group(1)!.trim();
      } else if (!isAr && enMatch != null) {
        localizedLabel = enMatch.group(1)!.trim();
      }
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            shape: BoxShape.circle,
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          localizedLabel,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
