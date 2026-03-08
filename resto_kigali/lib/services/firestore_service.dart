import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ==================== USER METHODS ====================

  /// Create or update user profile in Firestore
  Future<void> createOrUpdateUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String? phoneNumber,
    bool? notificationsEnabled,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'uid': uid,
          'email': email,
          'displayName': displayName,
          'phoneNumber': phoneNumber,
          'notificationsEnabled': notificationsEnabled ?? true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to create/update user profile: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(
    String uid,
    bool notificationsEnabled,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'notificationsEnabled': notificationsEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  /// ==================== LISTING METHODS ====================

  /// Create a new listing
  Future<String> createListing({
    required String name,
    required String category,
    required String address,
    required String phoneNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
    String imageUrl = '',
    String? website,
    List<String> amenities = const [],
  }) async {
    try {
      final docRef = await _firestore.collection('listings').add({
        'name': name,
        'category': category,
        'address': address,
        'phoneNumber': phoneNumber,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'createdBy': createdBy,
        'imageUrl': imageUrl,
        'website': website,
        'amenities': amenities,
        'rating': 0.0,
        'reviewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  /// Get all listings
  Future<List<Listing>> getAllListings() async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listings: $e');
    }
  }

  /// Get listing by ID
  Future<Listing?> getListingById(String id) async {
    try {
      final doc = await _firestore.collection('listings').doc(id).get();
      if (doc.exists) {
        return Listing.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch listing: $e');
    }
  }

  /// Get listings by category
  Future<List<Listing>> getListingsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listings by category: $e');
    }
  }

  /// Search listings by name
  Future<List<Listing>> searchListingsByName(String query) async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      return snapshot.docs
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  /// Get user's listings
  Future<List<Listing>> getUserListings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user listings: $e');
    }
  }

  /// Update listing
  Future<void> updateListing({
    required String id,
    required String name,
    required String category,
    required String address,
    required String phoneNumber,
    required String description,
    required double latitude,
    required double longitude,
    String imageUrl = '',
    String? website,
    List<String> amenities = const [],
  }) async {
    try {
      await _firestore.collection('listings').doc(id).update({
        'name': name,
        'category': category,
        'address': address,
        'phoneNumber': phoneNumber,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
        'website': website,
        'amenities': amenities,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  /// Delete listing
  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection('listings').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  /// Get distinct categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('listings').get();
      final categories =
          snapshot.docs.map((doc) => doc['category'] as String).toSet().toList();
      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Stream listings for real-time updates
  Stream<List<Listing>> streamListings() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream user's listings for real-time updates
  Stream<List<Listing>> streamUserListings(String userId) {
    return _firestore
        .collection('listings')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
