import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/property_model.dart';
import '../../property_details/screens/property_details_screen.dart';
import '../../favorites/providers/favorites_provider.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../utils/guest_checker.dart';

class LargePropertyCard extends StatelessWidget {
  final Property property;

  const LargePropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    bool isFav = context.watch<FavoritesProvider>().isFavorite(property.id);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          if (!GuestChecker.check(context)) return;
        },
        child: AbsorbPointer(
          absorbing: context.watch<AuthProvider>().isGuest,
          child: OpenContainer(
            transitionType: ContainerTransitionType.fade,
            transitionDuration: const Duration(milliseconds: 500),
            closedColor: property.isHotelApartment
                ? (isDark ? const Color(0xFF141416) : Colors.white)
                : (Theme.of(context).cardTheme.color ?? Colors.white),
            closedElevation: isDark ? 0 : 4,
            openElevation: 0,
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
                decoration: BoxDecoration(
                  color: property.isHotelApartment
                      ? (isDark ? const Color(0xFF141416) : Colors.white)
                      : Theme.of(context).cardTheme.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: property.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 180,
                              width: double.infinity,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 180,
                              width: double.infinity,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey.shade200,
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[600]
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        if (property.isHotelApartment)
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
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
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.hotel_rounded,
                                    color: Colors.black,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    property.isVerified ? 'فندقية موثقة ✨' : 'شقة فندقية فاخرة ✨',
                                    style: GoogleFonts.cairo(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (property.isVerified)
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF008695),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.loc.verified,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          top: 15,
                          right: 15,
                          child: GestureDetector(
                            onTap: () {
                              if (GuestChecker.check(context)) {
                                context
                                    .read<FavoritesProvider>()
                                    .toggleFavorite(property);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isFav ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          left: 15,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: property.isHotelApartment
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFDFBA6B),
                                            Color(0xFF9E7D3B),
                                          ],
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFF39BB5E),
                                            Color(0xFF008695),
                                          ],
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  property.isFullApartmentBooking
                                      ? context.loc.fullApartment
                                      : (property.bookingMode == 'bed'
                                            ? context.loc.bed
                                            : context.loc.divided),
                                  style: GoogleFonts.cairo(
                                    color: property.isHotelApartment ? Colors.black : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (property.requiredDeposit != null &&
                                  property.requiredDeposit! > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${property.requiredDeposit!.toStringAsFixed(0)} ${context.loc.currency}',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    LinearGradient(
                                      colors: property.isHotelApartment
                                          ? [const Color(0xFFF3E5AB), const Color(0xFFDFBA6B), const Color(0xFF9E7D3B)]
                                          : [const Color(0xFF39BB5E), const Color(0xFF008695)],
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                    ).createShader(bounds),
                                child: Text(
                                  '${NumberFormat.decimalPattern().format(property.price)} ${context.loc.currency}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            property.localizedTitle(context),
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: property.isHotelApartment
                                  ? (isDark ? const Color(0xFFF9E8B9) : Colors.black)
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: property.isHotelApartment ? const Color(0xFFDFBA6B) : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  property.localizedLocation(context),
                                  style: GoogleFonts.cairo(
                                    color: property.isHotelApartment
                                        ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }
}
