import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/extensions/loc_extension.dart';
import '../../../core/models/property_model.dart';
import '../widgets/taj_house_card.dart';
import '../widgets/hotel_package_card.dart';

class TajHouseScreen extends StatefulWidget {
  const TajHouseScreen({super.key});

  @override
  State<TajHouseScreen> createState() => _TajHouseScreenState();
}

class _TajHouseScreenState extends State<TajHouseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // packageId -> {price, features}
  static final Map<String, Map<String, dynamic>> _packagesData = {};
  // packageId -> full Property (images, description, hotel details...)
  static final Map<String, Property> _roomsData = {};
  static bool _hasLoadedOnce = false;

  StreamSubscription? _roomsSubscription;
  late bool _isLoading;

  static const _docIds = [
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
    _tabController = TabController(length: 2, vsync: this);
    _isLoading = !_hasLoadedOnce; // Show loading spinner only on the first load
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    await _roomsSubscription?.cancel();
    try {
      // Fetch packages in a single query using whereIn
      final packagesSnapshot = await FirebaseFirestore.instance
          .collection('hotel_packages')
          .where(FieldPath.documentId, whereIn: _docIds)
          .get();
      for (final doc in packagesSnapshot.docs) {
        _packagesData[doc.id] = doc.data();
      }

      // Query only the required room properties using whereIn
      _roomsSubscription = FirebaseFirestore.instance
          .collection('hotel_properties')
          .where(FieldPath.documentId, whereIn: _docIds)
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          _roomsData[doc.id] = Property.fromMap(doc.data(), doc.id);
        }
        _hasLoadedOnce = true;
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roomsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'TAJ HOUSE',
          style: GoogleFonts.cinzel(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF6C1712),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TajHouseCard(),
          ),
          const SizedBox(height: 16),
          _buildTabBar(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPackageList(context, 'Single'),
                      _buildPackageList(context, 'Double'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C1712).withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF6C1712),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.cinzel(
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.cinzel(
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6C1712),
        tabs: const [Tab(text: 'SINGLE'), Tab(text: 'DOUBLE')],
      ),
    );
  }

  Widget _buildPackageList(BuildContext context, String roomType) {
    final prefix = 'taj_house_${roomType.toLowerCase()}';
    final tiers = [
      (id: '${prefix}_premium', tier: HotelTier.premium, fallbackPrice: roomType == 'Single' ? 3500.0 : 5000.0),
      (id: '${prefix}_plus',    tier: HotelTier.plus,    fallbackPrice: roomType == 'Single' ? 2500.0 : 3500.0),
      (id: '${prefix}_basic',   tier: HotelTier.basic,   fallbackPrice: roomType == 'Single' ? 1500.0 : 2500.0),
    ];

    return RefreshIndicator(
      color: const Color(0xFF6C1712),
      onRefresh: () async {
        await _loadPackages();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      itemCount: tiers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final t = tiers[index];
        final data = _packagesData[t.id];
        final price = (data?['price'] as num?)?.toDouble() ?? t.fallbackPrice;
        final rawFeatures = data?['features'] as List<dynamic>? ?? [];
        final features = rawFeatures.isNotEmpty
            ? rawFeatures
                .map((e) => _localizeFeature(context, e))
                .where((s) => s.isNotEmpty)
                .toList()
            : _fallbackFeatures(context, t.tier);

        return FadeInDown(
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * 100),
          child: HotelPackageCard(
            tier: t.tier,
            roomType: roomType,
            price: price,
            features: features,
            property: _roomsData[t.id],
          ),
        );
      },
    ),
    );
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
