import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/property_model.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

class PropertyDetailsProvider extends ChangeNotifier {
  Property _property;
  Property get property => _property;

  // Selected State
  double _selectedPrice = 0.0;
  String? _selectionLabel;
  bool _isWholeApartment = false;
  final Set<String> _selectedUnitKeys =
      {}; // Keys: "r{idx}" or "r{idx}_b{bIdx}"
  int _selectedBedCount = 1;

  // Contact State
  bool _loadingContacts = true;
  List<Map<String, dynamic>> _contactNumbers = [];
  String? _error;

  PropertyDetailsProvider({required Property property}) : _property = property {
    _init();
    _fetchContactNumbers();
  }

  // Getters
  double get selectedPrice => _selectedPrice;
  String? get selectionLabel => _selectionLabel;
  bool get isWholeApartment => _isWholeApartment;
  Set<String> get selectedUnitKeys => _selectedUnitKeys;
  int get selectedBedCount => _selectedBedCount;

  bool get loadingContacts => _loadingContacts;
  List<Map<String, dynamic>> get contactNumbers => _contactNumbers;
  String? get error => _error;

  void _init() {
    // Initialize defaults based on property mode
    if (property.bookingMode == 'unit' &&
        property.isFullApartmentBooking &&
        property.bookedUnits.isEmpty) {
      _isWholeApartment = true;
    }

    // Initial calculation (requires context for label usually, will use default/setter)
    _calculatePrice();
  }

  StreamSubscription? _contactSubscription;

  // Logic: Fetch Contact Numbers (Stream)
  void _fetchContactNumbers() {
    _loadingContacts = true;
    notifyListeners();

    _contactSubscription = FirebaseFirestore.instance
        .collection('contact_numbers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _contactNumbers = snapshot.docs.map((doc) => doc.data()).toList();
            _loadingContacts = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _loadingContacts = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _contactSubscription?.cancel();
    super.dispose();
  }

  // Logic: Calculate Price based on state
  void updatePriceCalculations(BuildContext context) {
    // This public method allows updating label with context context.loc
    _calculatePrice(context: context);
  }

  void _calculatePrice({BuildContext? context}) {
    double base = property.discountPrice ?? property.price;

    // 1. Bed Mode
    if (property.bookingMode == 'bed') {
      _selectedPrice = property.bedPrice * _selectedBedCount;
      if (context != null) {
        _selectionLabel = context.loc.bed;
      }
      notifyListeners();
      return;
    }

    // 2. Unit Mode - Full Apartment Fixed
    if (property.isFullApartmentBooking) {
      _selectedPrice = base;
      if (context != null) {
        _selectionLabel = context.loc.fullApartmentPrice;
      }
      notifyListeners();
      return;
    }

    // 3. Unit Mode - Selection
    if (_isWholeApartment) {
      _selectedPrice = base;
      if (context != null) _selectionLabel = context.loc.fullApartmentPrice;
    } else if (_selectedUnitKeys.isNotEmpty) {
      double total = 0.0;
      final roomCounts = <String, int>{};
      final bedCounts = <String, int>{};

      for (var key in _selectedUnitKeys) {
        final parts = key.split('_');
        final roomIdx = int.parse(parts[0].substring(1));

        if (roomIdx < 0 || roomIdx >= property.rooms.length) continue;

        final room = property.rooms[roomIdx];
        final type = room['type'] ?? 'Room';

        if (parts.length > 1) {
          // Bed selection
          total += (room['bedPrice'] as num?)?.toDouble() ?? 0.0;
          bedCounts[type] = (bedCounts[type] ?? 0) + 1;
        } else {
          // Room selection
          total += (room['price'] as num?)?.toDouble() ?? 0.0;
          roomCounts[type] = (roomCounts[type] ?? 0) + 1;
        }
      }
      _selectedPrice = total;

      if (context != null) {
        final List<String> parts = [];
        roomCounts.forEach((type, cnt) {
          final label = _getRoomLabel(context, type, cnt);
          parts.add(label);
        });
        bedCounts.forEach((type, cnt) {
          final label = _getBedLabel(context, type, cnt);
          parts.add(label);
        });
        _selectionLabel = parts.join(' + ');
      } else {
        _selectionLabel = null;
      }
    } else {
      _selectedPrice = base;
      if (context != null) {
        _selectionLabel = context.loc.apartmentPrice;
      }
    }
    notifyListeners();
  }

  String _getRoomLabel(BuildContext context, String type, int cnt) {
    String typeLabel = type;
    if (type == 'Single') {
      typeLabel = context.loc.single;
    } else if (type == 'Double') {
      typeLabel = context.loc.double;
    } else if (type == 'Triple') {
      typeLabel = context.loc.triple;
    } else if (type == 'Quadruple') {
      typeLabel = context.loc.quadruple;
    }

    if (context.isAr) {
      if (cnt == 1) {
        return '${context.loc.room} $typeLabel';
      }
      if (cnt == 2) {
        return '${context.loc.room}in $typeLabel';
      }
      return '$cnt ${context.loc.rooms} $typeLabel';
    } else {
      return '$cnt $typeLabel Room${cnt > 1 ? 's' : ''}';
    }
  }

  String _getBedLabel(BuildContext context, String type, int cnt) {
    String typeLabel = type;
    if (type == 'Single') {
      typeLabel = context.loc.single;
    } else if (type == 'Double') {
      typeLabel = context.loc.double;
    } else if (type == 'Triple') {
      typeLabel = context.loc.triple;
    } else if (type == 'Quadruple') {
      typeLabel = context.loc.quadruple;
    }

    if (context.isAr) {
      if (cnt == 1) {
        return '${context.loc.bed} ${context.loc.in_} ${context.loc.room} $typeLabel';
      }
      return '$cnt ${context.loc.beds} ${context.loc.in_} ${context.loc.room} $typeLabel';
    } else {
      return '$cnt Bed${cnt > 1 ? 's' : ''} in $typeLabel Room';
    }
  }

  // Logic: Actions
  void setBedCount(int count, BuildContext context) {
    if (count < 1) return;
    if (property.totalBeds > 0 && count > property.totalBeds) return;

    _selectedBedCount = count;
    _calculatePrice(context: context);
  }

  void toggleUnitSelection(bool isWhole, String? key, BuildContext context) {
    if (isWhole) {
      // If units are booked, we cannot select whole apartment
      if (property.bookedUnits.isNotEmpty) return;

      if (_isWholeApartment) {
        _isWholeApartment = false;
      } else {
        _isWholeApartment = true;
        _selectedUnitKeys.clear();
      }
    } else if (key != null) {
      if (_isWholeApartment) {
        _isWholeApartment = false;
        _selectedUnitKeys.clear();
      }

      if (_selectedUnitKeys.contains(key)) {
        _selectedUnitKeys.remove(key);
        // Do not default to whole apartment if units are already booked
        if (_selectedUnitKeys.isEmpty && property.bookedUnits.isEmpty) {
          _isWholeApartment = true;
        }
      } else {
        _selectedUnitKeys.add(key);
      }
    }
    _calculatePrice(context: context);
  }

  bool validateBooking() {
    if (property.bookingMode == 'unit' &&
        !property.isFullApartmentBooking &&
        !_isWholeApartment &&
        _selectedUnitKeys.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> refreshProperty() async {
    _loadingContacts = true;
    _error = null;
    notifyListeners();

    // Re-fetch contact numbers stream
    _fetchContactNumbers();

    try {
      // TAJ HOUSE hotel rooms live in `hotel_properties`, not `properties`.
      final collection =
          _property.isHotelApartment ? 'hotel_properties' : 'properties';
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(_property.id)
          .get();
      if (doc.exists && doc.data() != null) {
        _property = Property.fromMap(doc.data()!, doc.id);
        _calculatePrice();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingContacts = false;
      notifyListeners();
    }
  }
}
