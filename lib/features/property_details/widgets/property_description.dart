import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

class PropertyDescription extends StatelessWidget {
  final String? description;

  const PropertyDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.aboutPlace,
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).cardTheme.color
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              description!,
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
    );
  }
}
