import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/property_model.dart';
import '../providers/property_details_provider.dart';
import '../../home/providers/home_provider.dart';

import '../../../utils/guest_checker.dart';

class PropertyOwner extends StatelessWidget {
  const PropertyOwner({super.key});

  @override
  Widget build(BuildContext context) {
    // Clean Architecture: Access data from Provider
    final provider = context.watch<PropertyDetailsProvider>();
    final contactNumbers = provider.contactNumbers;
    final isLoading = provider.loadingContacts;

    return Container(
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15),
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
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_in_talk_rounded,
                color: (provider.property.isHotelApartment && provider.property.tier == 'premium')
                    ? Colors.black
                    : Colors.white,
                size: 25,
              ),
            ),
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary,
                ],
              ).createShader(bounds),
              child: Text(
                context.loc.contactUs,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            children: [
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (contactNumbers.isEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: Text(
                        context.loc.noNumbersAvailable,
                        style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    _buildChatButton(context, provider.property),
                  ],
                )
              else
                Column(
                  children: [
                    ...contactNumbers.map((data) {
                      return _buildContactNumberItem(
                        context,
                        data['number'],
                        provider.property,
                      );
                    }),
                    // زرار الشات
                    _buildChatButton(context, provider.property),
                  ],
                ),
            ],
          ),
        ),
    );
  }

  Widget _buildChatButton(BuildContext context, Property property) {
    final tierColors = _getTierGradient(property);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: GestureDetector(
        onTap: () {
          if (!GuestChecker.check(context)) return;
          // الرجوع للـ HomeScreen وفتح تاب الشات (index 2)
          context.read<HomeProvider>().setIndex(2);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: tierColors,
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: tierColors.last.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                context.isAr ? 'تواصل معنا شات' : 'Contact us via Chat',
                style: GoogleFonts.cairo(
                  color: (property.isHotelApartment && property.tier == 'premium')
                      ? Colors.black
                      : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getTierGradient(Property property) {
    if (!property.isHotelApartment) {
      return const [Color(0xFF39BB5E), Color(0xFF008695)];
    }
    return switch (property.tier?.toLowerCase()) {
      'premium' => const [Color(0xFFDFBA6B), Color(0xFF9E7D3B)],
      'plus'    => const [Color(0xFF9CA3AF), Color(0xFF6B7280)],
      'basic'   => const [Color(0xFF39BB5E), Color(0xFF008695)],
      _         => const [Color(0xFF39BB5E), Color(0xFF008695)],
    };
  }

  Widget _buildContactNumberItem(
    BuildContext context,
    String number,
    Property property,
  ) {
    return InkWell(
      onTap: () async {
        if (!GuestChecker.check(context)) return;
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            // Number on the Right (RTL: First element)
            Text(
              number,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            // Icon on the Left (RTL: Last element)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.phone_in_talk_rounded,
                color: (property.isHotelApartment && property.tier == 'premium')
                    ? Colors.black
                    : Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
