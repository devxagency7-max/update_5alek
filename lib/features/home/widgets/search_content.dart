import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/services/ad_service.dart';
import 'package:motareb/features/home/screens/filter_screen.dart';

// import '../../../screens/filter_screen.dart';

import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import 'large_property_card.dart';
import 'add_property_card.dart';
import '../../auth/providers/auth_provider.dart';

import 'package:motareb/core/extensions/loc_extension.dart';

class SearchContent extends StatelessWidget {
  const SearchContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Access provider
    final homeProvider = context.watch<HomeProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // Header - Fixed at top
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.availableApartments,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      context.loc.propertiesCount(
                        homeProvider.allProperties.length,
                      ),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FilterScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF39BB5E).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          context.loc.filter,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: Builder(
              builder: (context) {
                if (homeProvider.isLoading &&
                    homeProvider.allProperties.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (homeProvider.error != null) {
                  return Center(
                    child: Text(
                      '${context.loc.errorLoadingData}: ${homeProvider.error}',
                      style: GoogleFonts.cairo(color: Colors.red),
                    ),
                  );
                }

                final properties = homeProvider.filteredProperties;

                if (properties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          // Context is available here
                          // You might want to add a localized string "No properties match your filter"
                          // reusing generic 'noPropertiesAvailable' for now or a custom message
                          context.loc.noPropertiesAvailable,
                          style: GoogleFonts.cairo(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        if (homeProvider.filterHousingTypes.isNotEmpty ||
                            homeProvider.filterGenders.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              homeProvider.resetFilters();
                            },
                            child: Text(
                              context
                                  .loc
                                  .reset, // Ensure this exists or use 'Reset'
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF39BB5E),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                final bool isOwner = context.watch<AuthProvider>().isOwner;
                final int extraItemsCount = isOwner ? 1 : 0;
                final int baseCount = properties.length + extraItemsCount;
                final totalItems = baseCount + (baseCount ~/ 3);

                return RefreshIndicator(
                  color: const Color(0xFF008695),
                  onRefresh: () async {
                    await context.read<HomeProvider>().refreshProperties();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 130,
                    ),
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      if (isOwner && index == 0) {
                        return const AddPropertyCard(
                          height: 250,
                          isHorizontal: false,
                        );
                      }

                      final int adjustedIndex = isOwner ? index - 1 : index;

                      // Ad position: Every 4th item
                      if ((adjustedIndex + 1) % 4 == 0) {
                        return AdService().getAdWidget(
                          factoryId: 'listTileLarge',
                          height: 300,
                        );
                      }

                      // Calculate actual property index
                      final propertyIndex =
                          adjustedIndex - (adjustedIndex ~/ 4);

                      if (propertyIndex < 0 ||
                          propertyIndex >= properties.length) {
                        return const SizedBox.shrink();
                      }

                      return LargePropertyCard(
                        property: properties[propertyIndex],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
