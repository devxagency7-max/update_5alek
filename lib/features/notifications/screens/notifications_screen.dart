import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:motareb/core/models/property_model.dart';
import 'package:motareb/features/property_details/screens/property_details_screen.dart';

/// Shows the broadcast notifications history sent by the admin to all users.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _onTap(BuildContext context, Map<String, dynamic> data) async {
    final route = data['route'];
    if (route == 'property') {
      final propertyId = data['propertyId'] as String?;
      if (propertyId == null || propertyId.isEmpty) return;

      final doc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .get();
      if (!doc.exists || !context.mounted) return;

      final property = Property.fromMap(doc.data()!, doc.id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isAr ? 'الإشعارات' : 'Notifications',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                isAr ? 'لا توجد إشعارات حتى الآن' : 'No notifications yet',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] as String? ?? '';
              final body = data['body'] as String? ?? '';
              final imageUrl = data['imageUrl'] as String?;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final isTappable = data['route'] == 'property';

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isTappable ? () => _onTap(context, data) : null,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2F3640)
                          : Colors.transparent,
                    ),
                    boxShadow: Theme.of(context).brightness == Brightness.dark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[200],
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported_outlined,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF008695).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active_outlined,
                              color: Color(0xFF008695)),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                            ),
                            if (createdAt != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                DateFormat('yyyy/MM/dd – hh:mm a', isAr ? 'ar' : 'en')
                                    .format(createdAt),
                                style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
