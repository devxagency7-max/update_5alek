import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

import '../../../core/models/property_model.dart';
import '../../favorites/providers/favorites_provider.dart';
import 'booking_request_screen.dart';

import '../widgets/property_gallery.dart';
import '../widgets/property_header.dart';
import '../widgets/property_features.dart';
import '../widgets/property_video.dart';
import '../widgets/property_owner.dart';
import '../widgets/property_booking.dart';
import '../widgets/property_description.dart';
import '../widgets/property_actions.dart';
import '../../../utils/guest_checker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/property_details_provider.dart';
import '../../../core/services/ad_service.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Property? property;

  const PropertyDetailsScreen({super.key, this.property});

  @override
  Widget build(BuildContext context) {
    // Handling dummy data if null, purely for UI fallback or testing
    final activeProperty = property ?? _getDummyProperty();

    return ChangeNotifierProvider(
      create: (_) => PropertyDetailsProvider(property: activeProperty),
      child: const _PropertyDetailsContent(),
    );
  }

  Property _getDummyProperty() {
    return Property(
      id: 'default_1',
      title: 'شقة فندقية مودرن - المعادي',
      location: 'المعادي، القاهرة',
      price: 3500, // Changed to double
      imageUrl: 'https://via.placeholder.com/600',
      type: 'شقة',
      description: 'شقة فندقية مميزة بتصميم مودرن في قلب المعادي...',
      rating: 4.8,
      isVerified: true,
      amenities: ['سكن طالبات', 'فايبر سريع', 'مؤثثة', 'مطبخ'],
      gender: 'female',
      paymentMethods: ['monthly', 'term'],
      universities: ['الجامعة الأمريكية'],
      bedsCount: 2,
      roomsCount: 1,
      discountPrice: null,
      bookingMode: 'unit',
      isFullApartmentBooking: false,
      totalBeds: 2,
      apartmentRoomsCount: 1,
      bedPrice: 0.0,
      generalRoomType: '',
      rooms: [
        {'type': 'Single', 'beds': 1, 'price': 2000, 'bedPrice': 2000},
        {'type': 'Double', 'beds': 2, 'price': 2000, 'bedPrice': 1000},
      ],
    );
  }
}

class _PropertyDetailsContent extends StatefulWidget {
  const _PropertyDetailsContent();

  @override
  State<_PropertyDetailsContent> createState() =>
      _PropertyDetailsContentState();
}

class _PropertyDetailsContentState extends State<_PropertyDetailsContent> {
  final GlobalKey _unitSelectionKey = GlobalKey();
  bool _showSelectionError = false;

  void _onBookNow(BuildContext context, PropertyDetailsProvider provider) {
    if (!GuestChecker.check(context)) return;

    if (!provider.validateBooking()) {
      setState(() {
        _showSelectionError = true;
      });

      // Scroll to unit selection section
      if (_unitSelectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _unitSelectionKey.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.loc.bedsSelectionError,
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 255, 17, 0),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Prepare selection details
    String selectionDetails = '';
    // double totalPrice = 0.0;

    if (provider.isWholeApartment) {
      selectionDetails = context.loc.fullApartment;
      // totalPrice = provider.property.price.toDouble();
    } else {
      if (provider.property.bookingMode == 'bed') {
        selectionDetails = '${provider.selectedBedCount} ${context.loc.beds}';
        // totalPrice = provider.selectedBedCount * provider.property.bedPrice;
      } else {
        // Unit mode
        selectionDetails = provider.selectionLabel ?? '';
      }
    }

    // Proceed to booking
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => BookingRequestScreen(
          property: provider.property,
          selectionDetails: selectionDetails,
          price: provider.selectedPrice,
          selections: provider.selectedUnitKeys.toList(),
          isWhole: provider.isWholeApartment,
          bedCount: provider.property.bookingMode == 'bed'
              ? provider.selectedBedCount
              : null,
        ),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildStudentSection(BuildContext context, String? gender) {
    if (gender == null || gender.isEmpty) return const SizedBox.shrink();

    String label;
    // IconData icon; // Removed
    // Color color; // Removed

    switch (gender.toLowerCase()) {
      case 'male':
        label = context.loc.youth;
        // icon = Icons.male;
        // color = const Color(0xFF1E88E5);
        break;
      case 'female':
        label = context.loc.girls;
        // icon = Icons.female;
        // color = const Color(0xFFE91E63);
        break;
      default:
        label = context.loc.all;
        // icon = Icons.people;
        // color = const Color(0xFF9C27B0);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.school_outlined,
              color: Theme.of(context).colorScheme.secondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              context.loc.students, // Changed from allowedGender
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Used Wrap to match Nearby Universities style container
        Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(icon, color: color, size: 20), // Removed as per request
                  // const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNearbySection(
    BuildContext context,
    String title,
    List<String> items,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                item,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _hotelTierLabel(String? tier) => switch (tier) {
        'premium' => 'EXTRA VIP',
        'plus' => 'VIP',
        'basic' => 'BASIC',
        _ => '',
      };

  Widget _hotelInfoChip(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHotelInfoSection(BuildContext context, Property property) {
    final chips = <Widget>[
      if ((property.tier ?? '').isNotEmpty)
        _hotelInfoChip(
          context,
          context.isAr ? 'الفئة' : 'Category',
          _hotelTierLabel(property.tier),
        ),
      if ((property.roomType ?? '').isNotEmpty)
        _hotelInfoChip(
          context,
          context.isAr ? 'نوع الغرفة' : 'Room Type',
          property.roomType?.toLowerCase() == 'single'
              ? (context.isAr ? 'مفردة' : 'Single')
              : property.roomType?.toLowerCase() == 'double'
                  ? (context.isAr ? 'مزدوجة' : 'Double')
                  : property.roomType!,
        ),
      if (property.capacity != null && property.capacity! > 0)
        _hotelInfoChip(
          context,
          context.isAr ? 'السعة' : 'Capacity',
          context.isAr
              ? '${property.capacity} أشخاص'
              : '${property.capacity} ${property.capacity == 1 ? 'Person' : 'People'}',
        ),
      if ((property.paymentMode ?? '').isNotEmpty)
        _hotelInfoChip(
          context,
          context.isAr ? 'طريقة الدفع' : 'Payment Method',
          property.paymentMode == 'term'
              ? (context.isAr ? 'بالفصل الدراسي' : 'Per Term')
              : (context.isAr ? 'شهري' : 'Monthly'),
        ),
      if (property.paymentMode == 'term' &&
          property.termPrice != null &&
          property.termPrice! > 0)
        _hotelInfoChip(
          context,
          context.isAr ? 'سعر الفصل الدراسي' : 'Term Price',
          '${property.termPrice!.toStringAsFixed(0)} ${context.isAr ? 'ج' : 'EGP'}',
        ),
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.hotel_outlined, color: Theme.of(context).primaryColor, size: 22),
            const SizedBox(width: 10),
            Text(
              context.isAr ? 'تفاصيل غرفة الفندق' : 'Hotel Room Details',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: chips),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access Providers
    final favoritesProvider = context.watch<FavoritesProvider>();
    final detailsProvider = context.watch<PropertyDetailsProvider>();
    final property = detailsProvider.property;

    final isFavorite = favoritesProvider.isFavorite(property.id);

    final colors = _getTierColors(property.tier, property.isHotelApartment);
    final primaryColor = colors.first;
    final secondaryColor = colors.last;

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: primaryColor,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: primaryColor,
          secondary: secondaryColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).colorScheme.secondary,
            onRefresh: () async {
              await context.read<PropertyDetailsProvider>().refreshProperty();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                PropertyGallery(
                  property: property,
                  onBack: () => Navigator.pop(context),
                ),
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // White Body Container
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        transform: Matrix4.translationValues(0, -20, 0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 45, 20, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PropertyHeader(
                                property: property,
                                isFavorite: isFavorite,
                                onToggleFavorite: () {
                                  if (GuestChecker.check(context)) {
                                    favoritesProvider.toggleFavorite(property);
                                  }
                                },
                              ),
                              PropertyFeatures(
                                tags: property.localizedAmenities(context),
                                isHotelApartment: property.isHotelApartment,
                              ),
                              if (property.isHotelApartment) ...[
                                const SizedBox(height: 20),
                                Builder(
                                  builder: (innerContext) =>
                                      _buildHotelInfoSection(innerContext, property),
                                ),
                              ],
                              PropertyVideo(videoUrl: property.videoUrl),
                              const PropertyOwner(), // Internal logic via Provider
                              // ⬇️ Ad Space (Custom or Google Native)
                              AdService().getAdWidget(
                                factoryId: 'listTileSmall',
                                height: 100, // Compact height for detail page
                              ),
                              const SizedBox(height: 20),

                              PropertyBooking(
                                unitSelectionKey: _unitSelectionKey,
                                property: property,
                                selectedBedCount:
                                    detailsProvider.selectedBedCount,
                                onBedCountChanged: (count) {
                                  detailsProvider.setBedCount(count, context);
                                },
                                isWholeApartment:
                                    detailsProvider.isWholeApartment,
                                selectedUnitKeys:
                                    detailsProvider.selectedUnitKeys,
                                showSelectionError: _showSelectionError,
                                onUnitSelectionChanged: (isWhole, key) {
                                  setState(() {
                                    _showSelectionError = false;
                                  });
                                  detailsProvider.toggleUnitSelection(
                                    isWhole,
                                    key,
                                    context,
                                  );
                                },
                              ),
                              PropertyDescription(
                                description: property.localizedDescription(
                                  context,
                                ), // Use localized
                              ),
                              const SizedBox(height: 20),

                              // Student Section (Gender)
                              if (property.gender != null &&
                                  property.gender!.isNotEmpty) ...[
                                Builder(
                                  builder: (innerContext) =>
                                      _buildStudentSection(innerContext, property.gender),
                                ),
                                const SizedBox(height: 20),
                              ],
                              const SizedBox(height: 20),

                              // Nearby Universities Section
                              if (property.universities.isNotEmpty) ...[
                                Builder(
                                  builder: (innerContext) => _buildNearbySection(
                                    innerContext,
                                    context.loc.nearbyUniversities,
                                    property.localizedUniversities(context),
                                    Icons.school_outlined,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Nearby Places Section
                              if (property.nearbyPlaces.isNotEmpty) ...[
                                Builder(
                                  builder: (innerContext) => _buildNearbySection(
                                    innerContext,
                                    context.loc.nearbyPlaces,
                                    property.localizedNearbyPlaces(context),
                                    Icons.place_outlined,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PropertyActions(
            property: property,
            selectedPrice: detailsProvider.selectedPrice,
            selectionLabel: detailsProvider.selectionLabel,
            onBook: () => _onBookNow(context, detailsProvider),
          ),
        ],
      ),
    ) // End of Theme
    );
  }

  List<Color> _getTierColors(String? tier, bool isHotelApartment) {
    if (!isHotelApartment) {
      return const [Color(0xFF39BB5E), Color(0xFF008695)];
    }
    final t = tier?.toLowerCase();
    return switch (t) {
      'premium' => const [Color(0xFFDFBA6B), Color(0xFF9E7D3B)], // Gold
      'plus' => const [Color(0xFF9CA3AF), Color(0xFF6B7280)], // Silver
      'basic' => const [Color(0xFF39BB5E), Color(0xFF008695)], // Green
      _ => const [Color(0xFFDFBA6B), Color(0xFF9E7D3B)], // Default Gold
    };
  }
}
