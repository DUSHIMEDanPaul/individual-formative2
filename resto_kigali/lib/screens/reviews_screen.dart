import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../utils/app_theme.dart';

class ReviewsScreen extends StatefulWidget {
  final Listing listing;

  const ReviewsScreen({
    super.key,
    required this.listing,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 5.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load reviews when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false)
          .fetchReviews(widget.listing.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final review = Review(
        id: '', // Firestore will generate the ID
        listingId: widget.listing.id,
        userId: user.uid,
        userName: authProvider.userDisplayName ?? 'Anonymous',
        userEmail: user.email ?? '',
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await Provider.of<ListingProvider>(context, listen: false)
          .addReview(widget.listing.id, review);

      _commentController.clear();
      setState(() => _selectedRating = 5.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: AppTheme.accentGold,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        elevation: 0,
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, _) {
          return CustomScrollView(
            slivers: [
              // Rating Summary Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'A.V. B rating',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.listing.rating
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index <
                                            widget.listing.rating
                                                .toInt()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: AppTheme.accentGold,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.listing.reviewCount} reviews',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Add Review Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rate this service',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Rating selector
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          5,
                          (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRating = (index + 1).toDouble();
                              });
                            },
                            child: Icon(
                              index < _selectedRating.toInt()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: AppTheme.accentGold,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Comment input
                      TextField(
                        controller: _commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Share your experience...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isSubmitting ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGold,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Submit Review',
                                  style: TextStyle(
                                    color: AppTheme.primaryDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Reviews List
              if (listingProvider.reviews.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Icon(Icons.rate_review_outlined,
                            size: 64,
                            color: AppTheme.accentGold),
                        const SizedBox(height: 16),
                        const Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Be the first to review this place',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final review =
                          listingProvider.reviews[index];
                      return _ReviewCard(review: review);
                    },
                    childCount: listingProvider.reviews.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Review card widget
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      review.userEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating.toInt()
                        ? Icons.star
                        : Icons.star_border,
                    color: AppTheme.accentGold,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Comment
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          // Date
          Text(
            _formatDate(review.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return '1d ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
