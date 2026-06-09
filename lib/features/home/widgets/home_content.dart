import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import 'hotel_package_card.dart';

import '../../../core/models/property_model.dart';

import '../../property_details/screens/property_details_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import 'large_property_card.dart';
import 'property_card.dart';
import 'add_property_card.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../screens/university_properties_screen.dart';
import '../screens/taj_house_screen.dart';
import 'taj_house_card.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:motareb/core/services/ad_service.dart';
import '../../../utils/guest_checker.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final TextEditingController _searchController;
  final Map<String, Map<String, dynamic>> _hotelPackagesData = {};
  final Map<String, Property> _hotelRoomsData = {};
  bool _loadingHotelData = true;
  StreamSubscription? _hotelSubscription;
  DateTime? _lastSeenAt;

  static const _hotelDocIds = [
    'taj_house_single_premium',
    'taj_house_single_plus',
    'taj_house_single_basic',
    'taj_house_double_premium',
    'taj_house_double_plus',
    'taj_house_double_basic',
  ];

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<HomeProvider>().searchQuery;
    _searchController = TextEditingController(text: initialQuery);
    _loadHotelPackages();
    _loadLastSeen();
  }

  Future<void> _loadLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('notifications_last_seen_ms');
    if (mounted) {
      setState(() {
        _lastSeenAt = ms != null
            ? DateTime.fromMillisecondsSinceEpoch(ms)
            : DateTime.fromMillisecondsSinceEpoch(0);
      });
    }
  }

  Future<void> _markNotificationsAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt('notifications_last_seen_ms', now.millisecondsSinceEpoch);
    if (mounted) setState(() => _lastSeenAt = now);
  }

  Future<void> _loadHotelPackages() async {
    try {
      final futures = _hotelDocIds.map(
        (id) => FirebaseFirestore.instance
            .collection('hotel_packages')
            .doc(id)
            .get(),
      );
      final docs = await Future.wait(futures);
      for (final doc in docs) {
        if (doc.exists) _hotelPackagesData[doc.id] = doc.data()!;
      }

      _hotelSubscription = FirebaseFirestore.instance
          .collection('hotel_properties')
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          if (_hotelDocIds.contains(doc.id)) {
            _hotelRoomsData[doc.id] = Property.fromMap(doc.data(), doc.id);
          }
        }
        if (mounted) {
          setState(() {
            _loadingHotelData = false;
          });
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingHotelData = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hotelSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access providers
    final authProvider = context.watch<AuthProvider>();
    final homeProvider = context.watch<HomeProvider>();

    if (homeProvider.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.text = '';
    }

    if (homeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<String> categoriesList = [
      context.loc.all,
      context.loc.hotel,
      context.loc.university,
      context.loc.youth,
      context.loc.girls,
      context.loc.bed,
    ];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!homeProvider.isLoadingMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            // Trigger earlier
            context.read<HomeProvider>().loadMoreProperties();
          }
          return true;
        },
        child: RefreshIndicator(
          color: const Color(0xFF008695),
          onRefresh: () async {
            await context.read<HomeProvider>().refreshProperties();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(context, authProvider),
                    const SizedBox(height: 20),
                    _buildSearchBar(context),
                    const SizedBox(height: 16),
                    _buildCategories(context, categoriesList),
                    const SizedBox(height: 16),
                    _buildTajHouseCard(context),
                    const SizedBox(height: 5),
                  ]),
                ),
              ),
              ..._buildContentSlivers(context, homeProvider),
              if (homeProvider.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 130,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(
    BuildContext context,
    HomeProvider homeProvider,
  ) {
    if (homeProvider.error != null) {
      return [
        SliverToBoxAdapter(
          child: Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text('${context.loc.errorOccurred}: ${homeProvider.error}'),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () =>
                      context.read<HomeProvider>().loadMoreProperties(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (homeProvider.allProperties.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Center(child: Text(context.loc.noPropertiesFound)),
        ),
      ];
    }

    // New: Check for empty search results
    final bool isSearchActive = homeProvider.searchQuery.isNotEmpty;
    final selectedIndex = homeProvider.selectedCategoryIndex;

    bool isEmptySearchResult = false;
    if (isSearchActive) {
      if (selectedIndex == 2 && homeProvider.uniqueUniversities.isEmpty) {
        isEmptySearchResult = true;
      } else if ((selectedIndex == 1 || selectedIndex > 2) &&
          homeProvider.filteredByCategory.isEmpty) {
        isEmptySearchResult = true;
      } else if (selectedIndex == 0 &&
          homeProvider.featuredProperties.isEmpty &&
          homeProvider.recentProperties.isEmpty) {
        isEmptySearchResult = true;
      }
    }

    if (isEmptySearchResult) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  context.loc.noSearchResults,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    // 1. Hotel View
    if (selectedIndex == 1) {
      return _buildHotelListSlivers(context);
    }

    // 2. University View
    if (selectedIndex == 2) {
      final universities = homeProvider.uniqueUniversities;

      if (universities.isEmpty) {
        return [
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(context.loc.noUniversitiesFound),
              ),
            ),
          ),
        ];
      }

      return [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final uni = universities[index];
            final uniProperties = homeProvider.getPropertiesForUniversity(uni);
            if (uniProperties.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildSectionTitle(
                    context,
                    ' $uni',
                    context.loc.viewAll,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UniversityPropertiesScreen(
                            universityName: uni,
                            properties: uniProperties,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildFeaturedList(context, uniProperties),
                  const SizedBox(height: 25),
                ],
              ),
            );
          }, childCount: universities.length),
        ),
      ];
    }

    // 3. Filtered View (Youth, Girls, Bed)
    if (selectedIndex > 2) {
      final filtered = homeProvider.filteredByCategory;
      return _buildFilteredListSlivers(context, filtered);
    }

    // 0. Default View (All)
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              _buildSectionTitle(context, context.loc.featuredForYou, ''),
              const SizedBox(height: 15),
              _buildFeaturedList(context, homeProvider.featuredProperties),
              const SizedBox(height: 25),
              _buildSectionTitle(context, context.loc.recentlyAdded, ''),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: _buildRecentlyAddedSliverList(
          context,
          homeProvider.recentProperties,
        ),
      ),
    ];
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  width: 2,
                ),
                boxShadow: Theme.of(context).brightness == Brightness.dark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: authProvider.userData?['photoUrl'] != null
                    ? CachedNetworkImage(
                        imageUrl: authProvider.userData!['photoUrl'],
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 44,
                          height: 44,
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 44,
                          height: 44,
                          color: Colors.grey[100],
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[900]
                            : Colors.grey[100],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.goodMorning,
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${context.loc.welcome} ${authProvider.userData?['name'] ?? context.loc.guest}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .limit(50)
              .snapshots(),
          builder: (context, snapshot) {
            int unreadCount = 0;
            if (snapshot.hasData && _lastSeenAt != null) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final createdAt =
                    (data['createdAt'] as Timestamp?)?.toDate();
                if (createdAt != null && createdAt.isAfter(_lastSeenAt!)) {
                  unreadCount++;
                }
              }
            }
            return GestureDetector(
              onTap: () async {
                await _markNotificationsAsSeen();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/bell.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? []
                  : const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
              border: Theme.of(context).brightness == Brightness.dark
                  ? Border.all(color: Theme.of(context).dividerColor)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.right,
                    onChanged: (value) {
                      context.read<HomeProvider>().setSearchQuery(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: context.loc.searchHint,
                      hintStyle: GoogleFonts.cairo(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context.read<HomeProvider>().setSearchQuery('');
                                context.read<HomeProvider>().setCategoryIndex(
                                  0,
                                );
                                context.read<HomeProvider>().resetFilters();
                                FocusScope.of(context).unfocus();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF008695).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.search_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTajHouseCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const TajHouseScreen(),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      child: const TajHouseCard(),
    );
  }

  Widget _buildCategories(BuildContext context, List<String> categories) {
    return _HomeCategories(categories: categories);
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String action, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (action.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                action,
                style: GoogleFonts.cairo(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedList(BuildContext context, List<Property> properties) {
    final bool isOwner = context.watch<AuthProvider>().isOwner;
    final int extraCount = isOwner ? 1 : 0;

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: properties.length + extraCount,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          if (isOwner && index == 0) {
            return const AddPropertyCard(width: 206);
          }
          final propertyIndex = isOwner ? index - 1 : index;
          return PropertyCard(property: properties[propertyIndex]);
        },
      ),
    );
  }

  Widget _buildRecentlyAddedSliverList(
    BuildContext context,
    List<Property> properties,
  ) {
    final bool isOwner = context.watch<AuthProvider>().isOwner;
    final int extraItems = isOwner ? 1 : 0;
    final totalItems =
        properties.length +
        extraItems +
        ((properties.length + extraItems) ~/ 5);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (isOwner && index == 0) {
          return const AddPropertyCard(height: 100, isHorizontal: false);
        }

        final int adjustedIndex = isOwner ? index - 1 : index;

        if ((adjustedIndex + 1) % 6 == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: AdService().getAdWidget(
              factoryId: 'listTileSmall',
              height: 100,
            ),
          );
        }

        final propertyIndex = adjustedIndex - (adjustedIndex ~/ 6);
        if (propertyIndex < 0 || propertyIndex >= properties.length) {
          return const SizedBox.shrink();
        }

        final property = properties[propertyIndex];
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
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
                closedElevation: isDark ? 0 : 2,
                openElevation: 0,
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: property.isHotelApartment
                      ? const BorderSide(color: Color(0xFFDFBA6B), width: 1.5)
                      : (isDark
                            ? BorderSide(color: Theme.of(context).dividerColor)
                            : BorderSide.none),
                ),
                openBuilder: (context, _) =>
                    PropertyDetailsScreen(property: property),
                closedBuilder: (context, openContainer) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: property.isHotelApartment
                          ? (isDark ? const Color(0xFF141416) : Colors.white)
                          : Theme.of(context).cardTheme.color,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: property.imageUrl,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.bed, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (property.isHotelApartment)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFDFBA6B),
                                        Color(0xFF9E7D3B),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.hotel_rounded,
                                        size: 10,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'شقة فندقية ✨',
                                        style: GoogleFonts.cairo(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (property.isNew)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.loc.newLabel,
                                    style: GoogleFonts.cairo(
                                      color: Colors.green,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              Text(
                                property.localizedTitle(context),
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: property.isHotelApartment
                                      ? (isDark
                                            ? const Color(0xFFF9E8B9)
                                            : Colors.black)
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
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
      }, childCount: totalItems),
    );
  }

  List<Widget> _buildFilteredListSlivers(
    BuildContext context,
    List<Property> properties,
  ) {
    if (properties.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(context.loc.noCategoryProperties),
            ),
          ),
        ),
      ];
    }
    final bool isOwner = context.watch<AuthProvider>().isOwner;
    final int extraCount = isOwner ? 1 : 0;

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (isOwner && index == 0) {
              return const AddPropertyCard(height: 250, isHorizontal: false);
            }
            final propertyIndex = isOwner ? index - 1 : index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: LargePropertyCard(property: properties[propertyIndex]),
            );
          }, childCount: properties.length + extraCount),
        ),
      ),
    ];
  }

  List<Widget> _buildHotelListSlivers(BuildContext context) {
    if (_loadingHotelData) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    final List<({String id, HotelTier tier, String roomType, double fallbackPrice})> tiers = [
      (id: 'taj_house_single_premium', tier: HotelTier.premium, roomType: 'Single', fallbackPrice: 3500.0),
      (id: 'taj_house_single_plus',    tier: HotelTier.plus,    roomType: 'Single', fallbackPrice: 2500.0),
      (id: 'taj_house_single_basic',   tier: HotelTier.basic,   roomType: 'Single', fallbackPrice: 1500.0),
      (id: 'taj_house_double_premium', tier: HotelTier.premium, roomType: 'Double', fallbackPrice: 5000.0),
      (id: 'taj_house_double_plus',    tier: HotelTier.plus,    roomType: 'Double', fallbackPrice: 3500.0),
      (id: 'taj_house_double_basic',   tier: HotelTier.basic,   roomType: 'Double', fallbackPrice: 2500.0),
    ];

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final t = tiers[index];
              final data = _hotelPackagesData[t.id];
              final price = (data?['price'] as num?)?.toDouble() ?? t.fallbackPrice;
              final rawFeatures = data?['features'] as List<dynamic>? ?? [];
              final features = rawFeatures.isNotEmpty
                  ? rawFeatures
                      .map((e) => _localizeFeature(context, e))
                      .where((s) => s.isNotEmpty)
                      .toList()
                  : _fallbackFeatures(context, t.tier);

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: index * 100),
                  child: HotelPackageCard(
                    tier: t.tier,
                    roomType: t.roomType,
                    price: price,
                    features: features,
                    property: _hotelRoomsData[t.id],
                  ),
                ),
              );
            },
            childCount: tiers.length,
          ),
        ),
      ),
    ];
  }

  String _localizeFeature(BuildContext context, dynamic e) {
    if (e is Map) {
      return context.isAr
          ? (e['ar']?.toString() ?? '')
          : (e['en']?.toString() ?? e['ar']?.toString() ?? '');
    }
    final str = e.toString();
    if (!context.isAr) {
      switch (str.trim().toLowerCase()) {
        case 'wifi':
        case 'واى فاى':
        case 'واي فاي':
          return 'WiFi';
        case 'تكييف':
        case 'تكييف مركزي':
        case 'ac':
          return 'AC';
        case 'تلفزيون':
        case 'تليفزيون':
        case 'tv':
          return 'TV';
        case 'ثلاجة':
        case 'ثلاجه':
        case 'fridge':
          return 'Fridge';
        case 'خدمة غرف':
        case 'خدمة الغرف':
        case 'room service':
          return 'Room Service';
        case 'فطار يومي':
        case 'الفطار اليومي':
        case 'فطار':
        case 'daily breakfast':
        case 'breakfast':
          return 'Daily Breakfast';
        case 'مطبخ':
        case 'kitchen':
          return 'Kitchen';
        case 'سكن طالبات':
          return 'Girls Housing';
        case 'سكن طلاب':
          return 'Students Housing';
        case 'مؤثثة':
        case 'مفروشة':
        case 'furnished':
          return 'Furnished';
      }
    }
    return str;
  }

  List<String> _fallbackFeatures(BuildContext context, HotelTier tier) {
    final isAr = context.isAr;
    return switch (tier) {
      HotelTier.premium => isAr
          ? ['WiFi', 'تكييف', 'تلفزيون', 'ثلاجة', 'خدمة غرف', 'فطار يومي']
          : ['WiFi', 'AC', 'TV', 'Fridge', 'Room Service', 'Daily Breakfast'],
      HotelTier.plus => isAr
          ? ['WiFi', 'تكييف', 'تلفزيون', 'ثلاجة']
          : ['WiFi', 'AC', 'TV', 'Fridge'],
      HotelTier.basic => isAr
          ? ['WiFi', 'تكييف']
          : ['WiFi', 'AC'],
    };
  }
}

class _HomeCategories extends StatefulWidget {
  final List<String> categories;
  const _HomeCategories({required this.categories});

  @override
  State<_HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<_HomeCategories> {
  final ScrollController _scrollController = ScrollController();
  bool _showArrow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScroll());
  }

  void _checkScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final show = maxScroll > 0 && currentScroll < maxScroll - 10;
    if (show != _showArrow) {
      if (mounted) setState(() => _showArrow = show);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            padding: EdgeInsets.only(left: _showArrow ? 30 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final selectedCategoryIndex = context
                  .watch<HomeProvider>()
                  .selectedCategoryIndex;
              final isSelected = index == selectedCategoryIndex;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final isHotel = index == 1; // "فندقي"

              return GestureDetector(
                onTap: () =>
                    context.read<HomeProvider>().setCategoryIndex(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? (isHotel
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFF3E5AB),
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
                                ))
                        : null,
                    color: isSelected
                        ? null
                        : (isHotel
                              ? (isDark
                                    ? const Color(0xFF141416)
                                    : Colors.white)
                              : Theme.of(context).cardTheme.color),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : (isHotel
                              ? Border.all(
                                  color: const Color(0xFFDFBA6B),
                                  width: 1.5,
                                )
                              : Border.all(
                                  color: isDark
                                      ? Theme.of(context).dividerColor
                                      : Colors.grey.shade200,
                                )),
                    boxShadow: isHotel
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFDFBA6B,
                              ).withValues(alpha: isSelected ? 0.4 : 0.1),
                              blurRadius: isSelected ? 10 : 4,
                              spreadRadius: isSelected ? 1 : 0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : (isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF39BB5E,
                                    ).withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isHotel) ...[
                        Icon(
                          Icons.hotel_rounded,
                          size: 15,
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFFDFBA6B),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.categories[index],
                        style: GoogleFonts.cairo(
                          color: isSelected
                              ? (isHotel ? Colors.black : Colors.white)
                              : (isHotel
                                    ? const Color(0xFFDFBA6B)
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_showArrow)
            Positioned(
              left: -5,
              child: IgnorePointer(
                child: Container(
                  height: 40,
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
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Color(0xFF008695),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
