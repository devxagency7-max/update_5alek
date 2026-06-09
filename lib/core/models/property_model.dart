import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

class Property {
  final String id;
  final String title;
  final String titleEn; // Added
  final String location;
  final String locationEn; // Added
  final double price; // Changed to double
  final String imageUrl;
  final String type; // e.g., 'غرفة مفردة'
  final bool isVerified;
  final bool isNew;
  final double rating;
  final List<dynamic> amenities;
  final List<dynamic> rules;
  final String? featuredLabel;
  final String? featuredLabelEn; // Added
  final double? discountPrice;

  // Booking Modes
  final String bookingMode; // 'unit' or 'bed'
  final bool isFullApartmentBooking;
  final int totalBeds;
  final int apartmentRoomsCount;
  final double bedPrice;
  final String? generalRoomType;
  final String? agentName;
  final String? description;
  final String? descriptionEn; // Added
  final String? governorate;
  final String? gender;
  final List<String> paymentMethods;
  final List<dynamic> universities;
  final List<dynamic> nearbyPlaces; // New
  final int bedsCount;
  final int roomsCount;
  final int bathroomsCount;
  final List<String> images;

  final String? videoUrl;
  final List<Map<String, dynamic>> rooms;
  final double? requiredDeposit; // Added
  final double? fixedCommission; // Added
  final bool bookingEnabled; // Added
  final String status; // Added
  final List<String> bookedUnits; // Added for partial booking support
  final bool isHotelApartment;

  // Hotel-specific fields (TAJ HOUSE)
  final String? tier; // 'premium' / 'plus' / 'basic'
  final String? roomType; // 'Single' / 'Double'
  final int? capacity;
  final String? paymentMode; // 'monthly' / 'term'
  final double? termPrice;

  // Helpers
  List<String> get tags => amenities.map((e) => e.toString()).toList();

  Property({
    required this.id,
    required this.title,
    this.titleEn = '',
    required this.location,
    this.locationEn = '',
    required this.price,
    required this.imageUrl,
    required this.type,
    this.isVerified = false,
    this.isNew = false,
    this.rating = 0.0,
    this.amenities = const [],
    this.rules = const [],
    this.universities = const [],
    this.nearbyPlaces = const [],
    this.featuredLabel,
    this.featuredLabelEn,
    this.discountPrice,
    this.agentName,
    this.description,
    this.descriptionEn,
    this.governorate,
    this.gender,
    this.paymentMethods = const [],
    this.bedsCount = 0,
    this.roomsCount = 0,
    this.bathroomsCount = 1,
    this.images = const [],
    this.videoUrl,
    this.rooms = const [],
    this.bookingMode = 'unit',
    this.isFullApartmentBooking = false,
    this.totalBeds = 0,
    this.apartmentRoomsCount = 0,
    this.bedPrice = 0.0,
    this.generalRoomType,
    this.requiredDeposit,
    this.fixedCommission,
    this.bookingEnabled = true,
    this.status = 'approved',
    this.bookedUnits = const [],
    this.isHotelApartment = false,
    this.tier,
    this.roomType,
    this.capacity,
    this.paymentMode,
    this.termPrice,
  });

  factory Property.fromMap(Map<String, dynamic> map, String documentId) {
    return Property(
      id: documentId,
      title: map['title'] ?? '',
      titleEn: map['titleEn'] ?? map['title'] ?? '',
      bookedUnits:
          (map['bookedUnits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: map['location'] ?? '',
      locationEn: map['locationEn'] ?? map['location'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (map['discountPrice'] as num?)?.toDouble(),
      imageUrl: (map['images'] as List<dynamic>?)?.isNotEmpty == true
          ? (map['images'] as List<dynamic>).first.toString()
          : '',
      type: map['isBed'] == true
          ? 'سرير'
          : map['isRoom'] == true
          ? 'غرفة'
          : 'شقة',
      isVerified: map['isVerified'] ?? false,
      isNew: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate().isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            )
          : false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      amenities:
          map['amenities'] as List<dynamic>? ??
          map['tags'] as List<dynamic>? ??
          [],
      rules: map['rules'] as List<dynamic>? ?? [],
      universities: map['universities'] as List<dynamic>? ?? [],
      nearbyPlaces: map['nearbyPlaces'] as List<dynamic>? ?? [],
      featuredLabel: map['featuredLabel'],
      featuredLabelEn: map['featuredLabelEn'],
      agentName: map['agentName'],
      description: map['description'],
      descriptionEn: map['descriptionEn'],
      governorate: map['governorate'],
      gender: map['gender'],
      paymentMethods:
          (map['paymentMethods'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bedsCount: (map['bedsCount'] as num?)?.toInt() ?? 0,
      roomsCount: (map['roomsCount'] as num?)?.toInt() ?? 0,
      bathroomsCount: (map['bathroomsCount'] as num?)?.toInt() ?? 1,
      images:
          (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      videoUrl: map['videoUrl'],
      rooms:
          (map['rooms'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      bookingMode: map['bookingMode'] ?? 'unit',
      isFullApartmentBooking: map['isFullApartmentBooking'] ?? false,
      totalBeds: (map['totalBeds'] as num?)?.toInt() ?? 0,
      apartmentRoomsCount: (map['apartmentRoomsCount'] as num?)?.toInt() ?? 0,
      bedPrice: (map['bedPrice'] as num?)?.toDouble() ?? 0.0,
      generalRoomType: map['generalRoomType'],
      requiredDeposit: (map['requiredDeposit'] as num?)?.toDouble(),
      fixedCommission: (map['fixedCommission'] as num?)?.toDouble(),
      bookingEnabled: map['bookingEnabled'] ?? true,
      status: map['status'] ?? 'approved',
      isHotelApartment: map['isHotelApartment'] ?? false,
      tier: map['tier'],
      roomType: map['roomType'],
      capacity: (map['capacity'] as num?)?.toInt(),
      paymentMode: map['paymentMode'],
      termPrice: (map['termPrice'] as num?)?.toDouble(),
    );
  }

  // Helpers for Localization
  String localizedTitle(BuildContext context) {
    return context.isAr ? title : (titleEn.isNotEmpty ? titleEn : title);
  }

  String localizedLocation(BuildContext context) {
    return context.isAr
        ? location
        : (locationEn.isNotEmpty ? locationEn : location);
  }

  String localizedDescription(BuildContext context) {
    return context.isAr
        ? (description ?? '')
        : (descriptionEn != null && descriptionEn!.isNotEmpty
              ? descriptionEn!
              : description ?? '');
  }

  String localizedFeaturedLabel(BuildContext context) {
    return context.isAr
        ? (featuredLabel ?? '')
        : (featuredLabelEn != null && featuredLabelEn!.isNotEmpty
              ? featuredLabelEn!
              : featuredLabel ?? '');
  }

  String localizedType(BuildContext context) {
    // Basic mapping for type if strictly defined.
    // Assuming 'type' is stored in Arabic ('سرير', 'غرفة', 'شقة')
    if (context.isAr) return type;
    if (type == 'سرير') return 'Bed';
    if (type == 'غرفة') return 'Room';
    if (type == 'شقة') return 'Apartment';
    return type;
  }

  // Localized List Helper
  List<String> localizedList(BuildContext context, List<dynamic> list) {
    return list
        .map((e) {
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
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // Alias for tags to keep compatibility
  List<String> localizedAmenities(BuildContext context) =>
      localizedList(context, amenities);
  List<String> localizedRules(BuildContext context) =>
      localizedList(context, rules);
  List<String> localizedUniversities(BuildContext context) =>
      localizedList(context, universities);
  List<String> localizedNearbyPlaces(BuildContext context) =>
      localizedList(context, nearbyPlaces);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'titleEn': titleEn,
    'location': location,
    'locationEn': locationEn,
    'price': price,
    'discountPrice': discountPrice,
    'imageUrl': imageUrl,
    'type': type,
    'isVerified': isVerified,
    'isNew': isNew,
    'rating': rating,
    'amenities': amenities,
    'rules': rules,
    'universities': universities,
    'nearbyPlaces': nearbyPlaces,
    'featuredLabel': featuredLabel,
    'featuredLabelEn': featuredLabelEn,
    'agentName': agentName,
    'description': description,
    'descriptionEn': descriptionEn,
    'governorate': governorate,
    'gender': gender,
    'paymentMethods': paymentMethods,
    'bedsCount': bedsCount,
    'roomsCount': roomsCount,
    'bathroomsCount': bathroomsCount,
    'images': images,
    'videoUrl': videoUrl,
    'rooms': rooms,
    'bookingMode': bookingMode,
    'isFullApartmentBooking': isFullApartmentBooking,
    'totalBeds': totalBeds,
    'apartmentRoomsCount': apartmentRoomsCount,
    'bedPrice': bedPrice,
    'generalRoomType': generalRoomType,
    'requiredDeposit': requiredDeposit,
    'fixedCommission': fixedCommission,
    'bookingEnabled': bookingEnabled,
    'status': status,
    'bookedUnits': bookedUnits,
    'isHotelApartment': isHotelApartment,
    'tier': tier,
    'roomType': roomType,
    'capacity': capacity,
    'paymentMode': paymentMode,
    'termPrice': termPrice,
  };

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    titleEn: json['titleEn'] ?? '',
    location: json['location'] ?? '',
    locationEn: json['locationEn'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    discountPrice: (json['discountPrice'] as num?)?.toDouble(),
    imageUrl: json['imageUrl'] ?? '',
    type: json['type'] ?? 'شقة',
    isVerified: json['isVerified'] ?? false,
    isNew: json['isNew'] ?? false,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    amenities: json['amenities'] as List<dynamic>? ?? [],
    rules: json['rules'] as List<dynamic>? ?? [],
    universities: json['universities'] as List<dynamic>? ?? [],
    nearbyPlaces: json['nearbyPlaces'] as List<dynamic>? ?? [],
    featuredLabel: json['featuredLabel'],
    featuredLabelEn: json['featuredLabelEn'],
    agentName: json['agentName'],
    description: json['description'],
    descriptionEn: json['descriptionEn'],
    governorate: json['governorate'],
    gender: json['gender'],
    paymentMethods:
        (json['paymentMethods'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    bedsCount: (json['bedsCount'] as num?)?.toInt() ?? 0,
    roomsCount: (json['roomsCount'] as num?)?.toInt() ?? 0,
    bathroomsCount: (json['bathroomsCount'] as num?)?.toInt() ?? 1,
    images:
        (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
    videoUrl: json['videoUrl'],
    rooms:
        (json['rooms'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [],
    bookingMode: json['bookingMode'] ?? 'unit',
    isFullApartmentBooking: json['isFullApartmentBooking'] ?? false,
    totalBeds: (json['totalBeds'] as num?)?.toInt() ?? 0,
    apartmentRoomsCount: (json['apartmentRoomsCount'] as num?)?.toInt() ?? 0,
    bedPrice: (json['bedPrice'] as num?)?.toDouble() ?? 0.0,
    generalRoomType: json['generalRoomType'],
    requiredDeposit: (json['requiredDeposit'] as num?)?.toDouble(),
    fixedCommission: (json['fixedCommission'] as num?)?.toDouble(),
    bookingEnabled: json['bookingEnabled'] ?? true,
    status: json['status'] ?? 'approved',
    bookedUnits:
        (json['bookedUnits'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    isHotelApartment: json['isHotelApartment'] ?? false,
    tier: json['tier'],
    roomType: json['roomType'],
    capacity: (json['capacity'] as num?)?.toInt(),
    paymentMode: json['paymentMode'],
    termPrice: (json['termPrice'] as num?)?.toDouble(),
  );

  bool get hasAC {
    return amenities.any((a) {
      if (a is String) return a.toLowerCase() == 'ac' || a == 'تكييف';
      if (a is Map) {
        return a['ar'] == 'تكييف' ||
            a['en']?.toString().toLowerCase() == 'air conditioning';
      }
      return false;
    });
  }

  bool get isFullyBooked {
    if (status == 'sold' || status == 'reserved' || status == 'sold_out') return true;

    if (bookingMode == 'bed') {
      return bookedUnits.length >= totalBeds;
    } else {
      // Unit mode
      if (isFullApartmentBooking) {
        return bookedUnits.isNotEmpty;
      }

      // Check if individual rooms are all booked
      if (rooms.isEmpty) return false;

      for (int i = 0; i < rooms.length; i++) {
        final room = rooms[i];
        final roomKey = 'r$i';

        // 1. If the room itself is booked (usually Single rooms)
        if (bookedUnits.contains(roomKey)) {
          continue;
        }

        // 2. If the room is split into beds (Double, Triple, etc.)
        // We check if ALL beds in this room are booked.
        final type = room['type'];
        if (type == 'Single') {
          // Single rooms must have 'r$i' key, which we checked above.
          return false;
        } else {
          // Check all beds
          final beds = (room['beds'] as int?) ?? 1;
          bool allBedsBooked = true;
          for (int b = 0; b < beds; b++) {
            if (!bookedUnits.contains('${roomKey}_b$b')) {
              allBedsBooked = false;
              break;
            }
          }
          if (!allBedsBooked) return false;
        }
      }
      return true;
    }
  }
}
