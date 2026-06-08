import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/property_model.dart';

class PropertyHeader extends StatelessWidget {
  final Property property;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const PropertyHeader({
    super.key,
    required this.property,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.localizedTitle(context),
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: property.isHotelApartment
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (property.featuredLabel != null &&
                    property.featuredLabel!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      property.localizedFeaturedLabel(context),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: (property.isHotelApartment && property.tier == 'premium')
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: property.isHotelApartment
                            ? Theme.of(context).primaryColor
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          property.localizedLocation(context),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: property.isHotelApartment
                                ? Colors.grey.shade400
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Favorite Button
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(25),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? Colors.red
                    : (property.isHotelApartment
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.secondary),
                size: 28,
              ),
              onPressed: onToggleFavorite,
            ),
          ),
        ],
    );
  }
}
