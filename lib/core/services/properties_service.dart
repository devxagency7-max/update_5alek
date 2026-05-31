import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';

class PropertiesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Property>> getPropertiesStream({int limit = 10}) {
    return _firestore
        .collection('properties')
        .where(
          'status',
          whereIn: [
            'approved',
            'available',
            'reserved',
            'sold',
            'paying_remaining',
          ],
        )
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Property.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPropertiesPage({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('properties')
        .where(
          'status',
          whereIn: [
            'approved',
            'available',
            'reserved',
            'sold',
            'paying_remaining',
          ],
        )
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  Future<List<Property>> getFeaturedProperties() async {
    // Logic for featured properties (e.g., highly rated or specific flag)
    // For now, returning top rated
    final snapshot = await _firestore
        .collection('properties')
        .where(
          'status',
          whereIn: ['approved', 'reserved', 'sold', 'paying_remaining'],
        )
        .orderBy('rating', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) {
      return Property.fromMap(doc.data(), doc.id);
    }).toList();
  }
}
