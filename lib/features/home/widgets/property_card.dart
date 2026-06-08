import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/property_model.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../property_details/screens/property_details_screen.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../utils/guest_checker.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // NOTE: OpenContainer must not rebuild while its open/close transition is
    // running, otherwise the framework throws "'!_dirty': is not true".
    // Scope the AuthProvider/FavoritesProvider listening to small Selectors
    // (passed as `child`) so OpenContainer itself is built only once.
    return GestureDetector(
      onTap: () {
        if (!GuestChecker.check(context)) return;
      },
      child: Selector<AuthProvider, bool>(
        selector: (_, auth) => auth.isGuest,
        builder: (context, isGuest, child) =>
            AbsorbPointer(absorbing: isGuest, child: child),
        child: OpenContainer(
          transitionType: ContainerTransitionType.fade,
          transitionDuration: const Duration(milliseconds: 500),
          closedColor: property.isHotelApartment
              ? (isDark ? const Color(0xFF141416) : Colors.white)
              : (Theme.of(context).cardTheme.color ?? Colors.white),
          closedElevation: isDark ? 0 : 4,
          openElevation: 0, // Flat during transition
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: property.isHotelApartment
                ? const BorderSide(color: Color(0xFFDFBA6B), width: 1.5)
                : (isDark
                      ? const BorderSide(color: Color(0xFF2A3038))
                      : BorderSide.none),
          ),
          openBuilder: (context, _) =>
              PropertyDetailsScreen(property: property),
          closedBuilder: (context, openContainer) {
            return Container(
              width: 206, // Made wider as requested
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: property.isHotelApartment
                    ? (isDark ? const Color(0xFF141416) : Colors.white)
                    : Theme.of(context).cardTheme.color,
                // Border handled by Shape
                // Shadow handled by OpenContainer elevation
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          Hero(
                            tag: 'property_image_${property.id}',
                            child:
                                property.imageUrl.startsWith('http') ||
                                    property.imageUrl.startsWith('assets')
                                ? (property.imageUrl.startsWith('assets')
                                      ? Image.asset(
                                          property.imageUrl,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: property.imageUrl,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: isDark
                                                    ? Colors.grey[800]
                                                    : Colors.grey.shade200,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: isDark
                                                    ? Colors.grey[800]
                                                    : Colors.grey.shade200,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: isDark
                                                        ? Colors.grey[600]
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                        ))
                                : Image.memory(
                                    base64Decode(
                                      property.imageUrl,
                                    ), // Decode Base64
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: isDark
                                                  ? Colors.grey[800]
                                                  : Colors.grey.shade200,
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: isDark
                                                      ? Colors.grey[600]
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Selector<FavoritesProvider, bool>(
                              selector: (_, favs) =>
                                  favs.isFavorite(property.id),
                              builder: (context, isFav, _) => GestureDetector(
                                onTap: () {
                                  if (GuestChecker.check(context)) {
                                    context
                                        .read<FavoritesProvider>()
                                        .toggleFavorite(property);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.5)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 18,
                                    color: isFav ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (property.isHotelApartment)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFDFBA6B),
                                      Color(0xFF9E7D3B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.hotel_rounded,
                                      color: Colors.black,
                                      size: 11,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'فندقية ✨',
                                      style: GoogleFonts.cairo(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    property.localizedTitle(context),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: property.isHotelApartment
                          ? (isDark ? const Color(0xFFF9E8B9) : Colors.black)
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    property.localizedLocation(context),
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: property.isHotelApartment
                          ? (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: property.isHotelApartment
                              ? [
                                  const Color(0xFFF3E5AB),
                                  const Color(0xFFDFBA6B),
                                  const Color(0xFF9E7D3B),
                                ]
                              : [
                                  const Color(0xFF39BB5E),
                                  const Color(0xFF008695),
                                ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ).createShader(bounds),
                        child: Text(
                          '${NumberFormat.decimalPattern().format(property.price)} ${context.loc.currency}',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (property.requiredDeposit != null &&
                          property.requiredDeposit! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${property.requiredDeposit!.toStringAsFixed(0)} ${context.loc.currency}',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
