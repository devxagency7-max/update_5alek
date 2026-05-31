import 'package:flutter/material.dart';
import '../../../../core/models/property_model.dart';

class BookingRequestProvider extends ChangeNotifier {
  final Property property;
  final String selectionDetails;
  final double price;
  final List<String> selections;
  final bool isWhole;
  final int? bedCount;

  BookingRequestProvider({
    required this.property,
    required this.selectionDetails,
    required this.price,
    required this.selections,
    required this.isWhole,
    this.bedCount,
  });

  // State
  // DateTime? _startDate; (Removed)
  // DateTime? _endDate; (Removed)
  // int _totalMonths = 0; (Removed)
  bool _isSubmitting = false;
  String? _error;

  // Getters
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
}
