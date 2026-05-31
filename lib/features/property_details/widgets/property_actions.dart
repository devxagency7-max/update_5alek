import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import '../../../../core/models/property_model.dart';
import '../../../../core/theme/app_theme.dart';

class PropertyActions extends StatelessWidget {
  final Property property;
  final double? selectedPrice;
  final String? selectionLabel;
  final VoidCallback onBook;
  const PropertyActions({
    super.key,
    required this.property,
    required this.selectedPrice,
    required this.selectionLabel,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              Theme.of(context).bottomAppBarTheme.color ??
              Theme.of(context).cardTheme.color,
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      selectionLabel ?? context.loc.price,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${NumberFormat.decimalPattern().format(selectedPrice ?? 0)} ${context.loc.currency}',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: property.isHotelApartment
                          ? const Color(0xFFDFBA6B)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFE6F4F4)
                              : const Color(0xFF008695)),
                    ),
                  ),
                  if (property.discountPrice != null)
                    Text(
                      NumberFormat.decimalPattern().format(property.price),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey.withOpacity(0.6),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!property.bookingEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'الحجز غير متاح حالياً',
                          style: GoogleFonts.cairo(
                            color: Colors.orange.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (property.status == 'pending')
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        context.loc.underReview, // "Under Review"
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else if (property.isFullyBooked)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: property.status == 'sold'
                          ? Colors.red.shade700
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        property.status == 'sold'
                            ? context.loc.sold
                            : context.loc.booked,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      gradient: property.isHotelApartment
                          ? const LinearGradient(
                              colors: [Color(0xFFDFBA6B), Color(0xFF9E7D3B)],
                            )
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: property.isHotelApartment
                              ? const Color(0xFF9E7D3B).withOpacity(0.3)
                              : const Color(0xFF008695).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: onBook,
                      child: Center(
                        child: Text(
                          context.loc.bookNow,
                          style: GoogleFonts.cairo(
                            color: property.isHotelApartment ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
