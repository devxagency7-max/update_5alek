import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import '../../../../widgets/property_video_card.dart';

class PropertyVideo extends StatelessWidget {
  final String? videoUrl;

  const PropertyVideo({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null || videoUrl!.isEmpty) return const SizedBox.shrink();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.propertyVideo,
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 15),
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: PropertyVideoCard(videoUrl: videoUrl!),
            ),
          ),
          const SizedBox(height: 30),
        ],
    );
  }
}
