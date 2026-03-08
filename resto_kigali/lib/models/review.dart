/// Model class representing a review for a listing
class Review {
  final String id;
  final String listingId;
  final String userId;
  final String userName;
  final String userEmail;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Convert a Firestore document to a Review object
  factory Review.fromFirestore(Map<String, dynamic> data, String docId) {
    return Review(
      id: docId,
      listingId: data['listingId'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      userEmail: data['userEmail'] as String,
      rating: (data['rating'] as num).toDouble(),
      comment: data['comment'] as String,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Review object to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'listingId': listingId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
