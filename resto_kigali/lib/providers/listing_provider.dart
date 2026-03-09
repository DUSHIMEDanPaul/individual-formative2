import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../models/review.dart';

class ListingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<Listing> _listings = [];
  List<Listing> _userListings = [];
  List<Listing> _bookmarkedListings = [];
  List<Review> _reviews = [];
  bool _isLoading = false;
  bool _isLoadingBookmarks = false;
  String? _errorMessage;
  String? _bookmarksErrorMessage;

  // Getters
  List<Listing> get listings => _listings;
  List<Listing> get userListings => _userListings;
  List<Listing> get bookmarkedListings => _bookmarkedListings;
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isLoadingBookmarks => _isLoadingBookmarks;
  String? get errorMessage => _errorMessage;
  String? get bookmarksErrorMessage => _bookmarksErrorMessage;

  /// Fetch all listings from Firestore
  Future<void> fetchListings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('listings').get();

      _listings = snapshot.docs
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch listings: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Fetch listings with a specific category
  Future<void> fetchListingsByCategory(String category) async {
    await fetchListingsByCategories([category]);
  }

  /// Fetch listings matching any of the given categories
  Future<void> fetchListingsByCategories(List<String> categories) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('listings')
          .where('category', whereIn: categories)
          .get();

      _listings = snapshot.docs
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage =
          'Failed to fetch listings for categories: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Fetch listings created by the current user
  Future<void> fetchUserListings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('listings')
          .where('createdBy', isEqualTo: userId)
          .get();

      _userListings = snapshot.docs
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch user listings: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Add a new listing to Firestore
  Future<String> addListing({
    required String name,
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required String imageUrl,
    required String address,
    required String phoneNumber,
    String? website,
    List<String>? amenities,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final listing = Listing(
        id: '', // Firestore will generate the ID
        name: name,
        category: category,
        description: description,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
        address: address,
        phoneNumber: phoneNumber,
        website: website,
        amenities: amenities ?? [],
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('listings')
          .add(listing.toFirestore());

      _isLoading = false;
      notifyListeners();

      return docRef.id;
    } catch (e) {
      _errorMessage = 'Failed to add listing: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing listing
  Future<void> updateListing({
    required String listingId,
    String? name,
    String? category,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? address,
    String? phoneNumber,
    String? website,
    List<String>? amenities,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (category != null) updates['category'] = category;
      if (description != null) updates['description'] = description;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (address != null) updates['address'] = address;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (website != null) updates['website'] = website;
      if (amenities != null) updates['amenities'] = amenities;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('listings').doc(listingId).update(updates);

      // Refresh listings
      await fetchListings();
      await fetchUserListings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update listing: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a listing
  Future<void> deleteListing(String listingId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore.collection('listings').doc(listingId).delete();

      // Refresh listings
      await fetchListings();
      await fetchUserListings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete listing: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Get a single listing by ID
  Future<Listing?> getListingById(String listingId) async {
    try {
      final doc =
          await _firestore.collection('listings').doc(listingId).get();
      if (doc.exists) {
        return Listing.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to fetch listing: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Search listings by name
  Future<void> searchListings(String query) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('listings')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      _listings = snapshot.docs
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search listings: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Search listings by name (case-insensitive)
  Future<void> searchListingsByName(String query) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get all listings and filter locally for case-insensitive search
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('listings').get();

      final lowerQuery = query.toLowerCase();
      _listings = snapshot.docs
          .where((doc) {
            final name = (doc['name'] as String).toLowerCase();
            return name.contains(lowerQuery);
          })
          .map((doc) => Listing.fromFirestore(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search listings: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Get available categories from all listings
  List<String> getAvailableCategories() {
    final categories = <String>{};
    for (final listing in _listings) {
      categories.add(listing.category);
    }
    return categories.toList()..sort();
  }

  /// Fetch categories directly from Firestore
  Future<List<String>> fetchCategories() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('listings').get();
      
      final categoriesSet = <String>{};
      for (final doc in snapshot.docs) {
        final category = doc['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categoriesSet.add(category);
        }
      }
      
      final categories = categoriesSet.toList()..sort();
      return categories;
    } catch (e) {
      _errorMessage = 'Failed to fetch categories: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  /// Fetch bookmarked listings for current user
  Future<void> fetchBookmarkedListings() async {
    try {
      _isLoadingBookmarks = true;
      _bookmarksErrorMessage = null;
      notifyListeners();

      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        _bookmarkedListings = [];
        _isLoadingBookmarks = false;
        notifyListeners();
        return;
      }

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        _bookmarkedListings = [];
        _isLoadingBookmarks = false;
        notifyListeners();
        return;
      }

      final bookmarkedIds = List<String>.from(
          (userDoc.data()?['bookmarkedListings'] as List?) ?? []);

      if (bookmarkedIds.isEmpty) {
        _bookmarkedListings = [];
        _isLoadingBookmarks = false;
        notifyListeners();
        return;
      }

      // Firestore whereIn supports max 30 items — chunk if needed
      final List<Listing> results = [];
      for (int i = 0; i < bookmarkedIds.length; i += 30) {
        final chunk = bookmarkedIds.sublist(
            i, i + 30 > bookmarkedIds.length ? bookmarkedIds.length : i + 30);
        final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('listings')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        results.addAll(snapshot.docs
            .map((doc) => Listing.fromFirestore(doc.data(), doc.id)));
      }

      _bookmarkedListings = results;
      _isLoadingBookmarks = false;
      notifyListeners();
    } catch (e) {
      _bookmarksErrorMessage =
          'Failed to fetch bookmarked listings: ${e.toString()}';
      _isLoadingBookmarks = false;
      notifyListeners();
    }
  }

  /// Add a listing to bookmarks
  Future<void> addToBookmarks(String listingId) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final userDocRef = _firestore.collection('users').doc(userId);

      // Use set with merge so the field is always an array union
      // regardless of whether the document or field already exists
      await userDocRef.set({
        'bookmarkedListings': FieldValue.arrayUnion([listingId]),
      }, SetOptions(merge: true));

      // Refresh bookmarked listings
      await fetchBookmarkedListings();
    } catch (e) {
      _errorMessage = 'Failed to bookmark listing: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a listing from bookmarks
  Future<void> removeFromBookmarks(String listingId) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final userDocRef = _firestore.collection('users').doc(userId);

      await userDocRef.set({
        'bookmarkedListings': FieldValue.arrayRemove([listingId]),
      }, SetOptions(merge: true));

      // Refresh bookmarked listings
      await fetchBookmarkedListings();
    } catch (e) {
      _errorMessage = 'Failed to remove bookmark: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Check if a listing is bookmarked
  bool isBookmarked(String listingId) {
    return _bookmarkedListings.any((listing) => listing.id == listingId);
  }

  /// Fetch reviews for a specific listing
  Future<void> fetchReviews(String listingId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('listings')
          .doc(listingId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      _reviews = snapshot.docs
          .map((doc) => Review.fromFirestore(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch reviews: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Add a review to a listing
  Future<void> addReview(String listingId, Review review) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Add review to subcollection
      await _firestore
          .collection('listings')
          .doc(listingId)
          .collection('reviews')
          .add(review.toFirestore());

      // Update listing's average rating and review count
      final reviewsSnapshot = await _firestore
          .collection('listings')
          .doc(listingId)
          .collection('reviews')
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (final doc in reviewsSnapshot.docs) {
          totalRating += (doc['rating'] as num).toDouble();
        }
        final averageRating = totalRating / reviewsSnapshot.docs.length;

        await _firestore.collection('listings').doc(listingId).update({
          'rating': averageRating,
          'reviewCount': reviewsSnapshot.docs.length,
        });
      }

      // Refresh reviews
      await fetchReviews(listingId);
      // Refresh listings to get updated ratings
      await fetchListings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add review: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Clear all local listings
  void clearListings() {
    _listings = [];
    _userListings = [];
    _reviews = [];
    _errorMessage = null;
    notifyListeners();
  }
}

