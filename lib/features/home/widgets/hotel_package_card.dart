import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/property_model.dart';
import '../../property_details/screens/property_details_screen.dart';

enum HotelTier { premium, plus, basic }

class HotelPackageCard extends StatelessWidget {
  final HotelTier tier;
  final String roomType;
  final double price;
  final List<String> features;
  final Property? property;

  const HotelPackageCard({
    super.key,
    required this.tier,
    required this.roomType,
    required this.price,
    required this.features,
    this.property,
  });

  String get _tierLabel => switch (tier) {
        HotelTier.premium => 'EXTRE VIP',
        HotelTier.plus => 'VIP',
        HotelTier.basic => 'BASIC',
      };

  // Plus and Basic colors swapped
  List<Color> get _tierColors => switch (tier) {
        HotelTier.premium => [const Color(0xFFDFBA6B), const Color(0xFF9E7D3B)],
        HotelTier.plus    => [const Color(0xFF9CA3AF), const Color(0xFF6B7280)],
        HotelTier.basic   => [const Color(0xFF39BB5E), const Color(0xFF008695)],
      };

  Color get _borderColor => switch (tier) {
        HotelTier.premium => const Color(0xFFDFBA6B),
        HotelTier.plus    => const Color(0xFF6B7280),
        HotelTier.basic   => const Color(0xFF008695),
      };

  bool get _labelDark => tier == HotelTier.premium;

  bool get _isSoldOut => property?.status == 'sold_out';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContent = _buildCardContent(context, isDark);

    if (property != null) {
      return OpenContainer(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 500),
        closedColor: isDark ? const Color(0xFF1E2329) : Colors.white,
        closedElevation: isDark ? 0 : 4,
        openElevation: 0,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _borderColor, width: 1.5),
        ),
        openBuilder: (context, _) => PropertyDetailsScreen(property: property),
        closedBuilder: (context, _) => cardContent,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2329) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _borderColor.withValues(alpha: isDark ? 0.15 : 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: cardContent,
    );
  }

  Widget _buildCardContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with tier label overlay
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: property?.images.isNotEmpty == true
                  ? Image.network(
                      property!.images.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/TAJ.jpg',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/TAJ.jpg',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            // Dark overlay so label is readable
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
              ),
            ),
            // Sold-out ribbon overlay
            if (_isSoldOut)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.45),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C1712),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'نفذت الغرف',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Tier label — centered at top
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _tierColors),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _tierLabel,
                    style: GoogleFonts.cinzel(
                      color: _labelDark ? Colors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
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
                        LinearGradient(colors: _tierColors).createShader(bounds),
                    child: Text(
                      '${price.toStringAsFixed(0)} ج/شهر',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _tierColors),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      roomType,
                      style: GoogleFonts.cairo(
                        color: _labelDark ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                property?.localizedTitle(context).isNotEmpty == true
                    ? property!.localizedTitle(context)
                    : 'TAJ HOUSE — $roomType $_tierLabel',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF3F4F6) : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: features
                    .map(
                      (f) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _borderColor.withValues(
                            alpha: isDark ? 0.15 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _borderColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
