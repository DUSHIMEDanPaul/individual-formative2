/// Model class representing a restaurant listing
class Listing {
  final String id;
  final String name;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String address;
  final String phoneNumber;
  final String? website;
  final List<String> amenities;
  final String createdBy;
  final DateTime createdAt;

  Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.address,
    required this.phoneNumber,
    this.website,
    this.amenities = const [],
    required this.createdBy,
    required this.createdAt,
  });

  /// Convert a Firestore document to a Listing object
  factory Listing.fromFirestore(Map<String, dynamic> data, String docId) {
    return Listing(
      id: docId,
      name: data['name'] as String,
      category: data['category'] as String,
      description: data['description'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      imageUrl: data['imageUrl'] as String,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      address: data['address'] as String,
      phoneNumber: data['phoneNumber'] as String,
      website: data['website'] as String?,
      amenities: List<String>.from(data['amenities'] as List? ?? []),
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert a Listing object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'address': address,
      'phoneNumber': phoneNumber,
      'website': website,
      'amenities': amenities,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  /// Create a copy of this listing with optional field overrides
  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? address,
    String? phoneNumber,
    String? website,
    List<String>? amenities,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      amenities: amenities ?? this.amenities,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
