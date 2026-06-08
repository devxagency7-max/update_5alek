import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

class TajHouseCard extends StatelessWidget {
  const TajHouseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEBF0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: isAr
                ? const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
            child: Image.asset(
              'assets/images/TAJ.jpg',
              height: 110,
              width: 130,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TAJ HOUSE',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFF6C1712),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr
                        ? 'فندق طلابي بجوار الجامعه'
                        : 'Student Hotel Near University',
                    style: GoogleFonts.cairo(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
