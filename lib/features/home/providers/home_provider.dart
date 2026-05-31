import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/property_model.dart';
import '../../../core/services/properties_service.dart';

class HomeProvider extends ChangeNotifier {
  final PropertiesService _propertiesService = PropertiesService();

  static const _cacheKey = 'cached_properties';

  // Data State
  List<Property> _allProperties = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  bool _hasMore = true;

  // UI State
  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;

  // Getters
  List<Property> get allProperties => _allProperties;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  bool get hasMore => _hasMore;

  HomeProvider() {
    _loadProperties();
  }

  void _loadProperties() {
    loadInitialProperties();
  }

  Future<void> loadInitialProperties() async {
    _isLoading = true;
    _error = null;
    _hasMore = true;
    _lastDocument = null;
    notifyListeners();

    // Load from cache first for fast UI startup
    await _loadFromCache();

    try {
      final snapshot = await _propertiesService.getPropertiesPage(limit: 10);
      final properties = snapshot.docs.map((doc) {
        return Property.fromMap(doc.data(), doc.id);
      }).toList();

      _allProperties = properties;
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }
      _hasMore = properties.length >= 10;
      _isLoading = false;
      notifyListeners();

      // Save first page to cache
      await _saveToCache(properties);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        final List decoded = jsonDecode(cached);
        _allProperties = decoded
            .map((e) => Property.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveToCache(List<Property> properties) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(properties.map((p) => p.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> loadMoreProperties() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _propertiesService.getPropertiesPage(
        limit: 10,
        startAfter: _lastDocument,
      );

      final properties = snapshot.docs.map((doc) {
        return Property.fromMap(doc.data(), doc.id);
      }).toList();

      if (properties.isNotEmpty) {
        _allProperties.addAll(properties);
        _lastDocument = snapshot.docs.last;
      }
      _hasMore = properties.length >= 10;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshProperties() async {
    resetFilters();
    await loadInitialProperties();
  }

  // Navigation
  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void setCategoryIndex(int index) {
    if (_selectedCategoryIndex != index) {
      _selectedCategoryIndex = index;
      notifyListeners();
    }
  }

  // Business Logic: Filtering & Sorting
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 100000);
  List<String> _filterHousingTypes = [];
  List<String> _filterGenders = [];

  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  List<String> get filterHousingTypes => _filterHousingTypes;
  List<String> get filterGenders => _filterGenders;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void applyFilters({
    required RangeValues priceRange,
    required List<String> housingTypes,
    required List<String> genders,
  }) {
    _priceRange = priceRange;
    _filterHousingTypes = housingTypes;
    _filterGenders = genders;
    notifyListeners();
  }

  void resetFilters() {
    _priceRange = const RangeValues(0, 100000);
    _filterHousingTypes = [];
    _filterGenders = [];
    _searchQuery = '';
    notifyListeners();
  }

  List<Property> _sortHotelFirst(List<Property> list) {
    final hotels = list.where((p) => p.isHotelApartment).toList();
    final others = list.where((p) => !p.isHotelApartment).toList();
    return [...hotels, ...others];
  }

  List<Property> get filteredProperties {
    return _sortHotelFirst(_applyFullFilters(_allProperties));
  }

  List<Property> get featuredProperties {
    var list = _applySearchOnly(_allProperties);
    final featured = list.where((p) => p.rating >= 4.5).toList();
    return _sortHotelFirst(
      featured.isNotEmpty ? featured : list.take(5).toList(),
    );
  }

  List<Property> get recentProperties {
    return _sortHotelFirst(_applySearchOnly(_allProperties));
  }

  // Used for Home Screen: Only applies Text Search
  List<Property> _applySearchOnly(List<Property> properties) {
    if (_searchQuery.isEmpty) return properties;

    final query = _searchQuery.toLowerCase();
    return properties.where((p) {
      final universityMatches = p.universities.any((u) {
        if (u is Map) {
          return (u['ar']?.toString().toLowerCase().contains(query) ?? false) ||
              (u['en']?.toString().toLowerCase().contains(query) ?? false);
        }
        return u.toString().toLowerCase().contains(query);
      });

      final tagMatches = p.amenities.any((t) {
        if (t is Map) {
          return (t['ar']?.toString().toLowerCase().contains(query) ?? false) ||
              (t['en']?.toString().toLowerCase().contains(query) ?? false);
        }
        return t.toString().toLowerCase().contains(query);
      });

      final hotelMatches =
          p.isHotelApartment &&
          (query.contains('فندق') ||
              query.contains('hotel') ||
              query.contains('فندقيه') ||
              query.contains('فندقية'));

      return p.title.toLowerCase().contains(query) ||
          p.location.toLowerCase().contains(query) ||
          universityMatches ||
          tagMatches ||
          hotelMatches;
    }).toList();
  }

  // Used for Search Screen: Applies Search + Advanced Filters
  List<Property> _applyFullFilters(List<Property> properties) {
    return properties.where((p) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final universityMatches = p.universities.any((u) {
          if (u is Map) {
            return (u['ar']?.toString().toLowerCase().contains(query) ??
                    false) ||
                (u['en']?.toString().toLowerCase().contains(query) ?? false);
          }
          return u.toString().toLowerCase().contains(query);
        });

        final tagMatches = p.amenities.any((t) {
          if (t is Map) {
            return (t['ar']?.toString().toLowerCase().contains(query) ??
                    false) ||
                (t['en']?.toString().toLowerCase().contains(query) ?? false);
          }
          return t.toString().toLowerCase().contains(query);
        });

        final hotelMatches =
            p.isHotelApartment &&
            (query.contains('فندق') ||
                query.contains('hotel') ||
                query.contains('فندقيه') ||
                query.contains('فندقية'));

        final matchesSearch =
            p.title.toLowerCase().contains(query) ||
            p.location.toLowerCase().contains(query) ||
            universityMatches ||
            tagMatches ||
            hotelMatches;
        if (!matchesSearch) return false;
      }

      // 2. Price Range
      // Assuming price format is "2000 ج.م" or similar
      try {
        // Remove non-numeric characters except dot
        // String priceString = p.price.replaceAll(RegExp(r'[^0-9.]'), '');
        double price = p.price;
        if (price < _priceRange.start || price > _priceRange.end) {
          return false;
        }
      } catch (e) {
        // If parsing fails, ignore price filter or exclude? currently ignoring
      }

      // 3. Housing Type
      // 'Bed' -> 'سرير'
      // 'Apartment' -> 'شقة' (or 'شقه كامله')
      // 'Room' -> 'غرفة' (or 'متقسمه')
      if (_filterHousingTypes.isNotEmpty) {
        bool matchesType = false;
        // Check exact matches or mapped values
        // You might need to adjust these strings based on your actual data
        for (var type in _filterHousingTypes) {
          if (type == 'Bed' &&
              (p.type.contains('سرير') || p.bookingMode == 'bed')) {
            matchesType = true;
          }
          if (type == 'Apartment' &&
              (p.type.contains('شقة') || p.isFullApartmentBooking)) {
            matchesType = true;
          }
          if (type == 'Room' &&
              (p.type.contains('غرفة') || p.generalRoomType != null)) {
            matchesType = true;
          }
        }
        if (!matchesType) return false;
      }

      // 4. Gender
      if (_filterGenders.isNotEmpty) {
        bool matchesGender = false;
        // Assuming p.gender is 'male', 'female', or null/mixed
        // Adjust based on your actual data values
        String? propGender = p.gender?.toLowerCase();

        if (_filterGenders.contains('Male') &&
            (propGender == 'male' ||
                propGender == 'both' ||
                p.tags.contains('شباب') ||
                p.tags.contains('ذكور'))) {
          matchesGender = true;
        }
        if (_filterGenders.contains('Female') &&
            (propGender == 'female' ||
                propGender == 'both' ||
                p.tags.contains('بنات') ||
                p.tags.contains('إناث'))) {
          matchesGender = true;
        }
        // If property has no gender specified, deciding whether to show it.
        // Usually assume mixed or show all? strictly filtering:
        if (propGender == null && !matchesGender) {
          // Check headers/tags if not in gender field
          if (_filterGenders.contains('Male') && p.title.contains('شباب')) {
            matchesGender = true;
          }
          if (_filterGenders.contains('Female') && p.title.contains('بنات')) {
            matchesGender = true;
          }
        }

        if (!matchesGender) return false;
      }

      return true;
    }).toList();
  }

  List<String> get uniqueUniversities {
    final Set<String> allUniversities = {};
    for (var p in _applySearchOnly(_allProperties)) {
      for (var u in p.universities) {
        if (u is Map) {
          allUniversities.add(u['ar']?.toString() ?? '');
        } else {
          allUniversities.add(u.toString());
        }
      }
    }
    return allUniversities.where((s) => s.isNotEmpty).toList()..sort();
  }

  List<Property> getPropertiesForUniversity(String universityName) {
    final list = _applySearchOnly(_allProperties).where((p) {
      return p.universities.any((u) {
        if (u is Map) return u['ar'] == universityName;
        return u.toString() == universityName;
      });
    }).toList();
    return _sortHotelFirst(list);
  }

  List<Property> get filteredByCategory {
    final base = _applySearchOnly(_allProperties);
    switch (_selectedCategoryIndex) {
      case 1: // فندقي
        return base.where((p) => p.isHotelApartment).toList();
      case 3: // شباب
        return base.where((p) {
          final g = p.gender?.toLowerCase();
          return g == 'male' ||
              p.tags.contains('شباب') ||
              p.tags.contains('ذكور');
        }).toList();
      case 4: // بنات
        return base.where((p) {
          final g = p.gender?.toLowerCase();
          return g == 'female' ||
              p.tags.contains('بنات') ||
              p.tags.contains('إناث');
        }).toList();
      case 5: // سرير
        return base
            .where((p) => p.type == 'سرير' || p.bookingMode == 'bed')
            .toList();
      default:
        return _sortHotelFirst(base);
    }
  }
}
