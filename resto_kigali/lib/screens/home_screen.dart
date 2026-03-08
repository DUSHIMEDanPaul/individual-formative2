import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../utils/app_theme.dart';
import 'listing_detail_screen.dart';
import 'map_view_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load listings and bookmarks when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ListingProvider>(context, listen: false);
      provider.fetchListings();
      provider.fetchBookmarkedListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation from home
      child: Scaffold(
        appBar: AppBar(
          title: const Text('resto_kigali'),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Directory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_library_books),
              label: 'My Listings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map View',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Bookmarks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DirectoryScreen();
      case 1:
        return const MyListingsScreen();
      case 2:
        return const MapViewScreen();
      case 3:
        return const BookmarksScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const DirectoryScreen();
    }
  }
}

/// Directory Screen - Browse all listings
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categories = [
      'Restaurant',
      'Café',
      'Fast Food',
      'Bakery',
      'Bar',
      'Buffet',
      'Diner',
      'Picnic Area',
      'Food Stall',
      'Hotel',
    ];
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
        return Icons.coffee;
      case 'Fast Food':
        return Icons.fastfood;
      case 'Bakery':
        return Icons.bakery_dining;
      case 'Bar':
        return Icons.local_bar;
      case 'Buffet':
        return Icons.lunch_dining;
      case 'Diner':
        return Icons.dining;
      case 'Picnic Area':
        return Icons.park;
      case 'Food Stall':
        return Icons.storefront;
      case 'Hotel':
        return Icons.hotel;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingProvider>(
      builder: (context, listingProvider, _) {
        return Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                // Location Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppTheme.accentGold, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Kigali City',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for service',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _selectedCategory = null;
                                      });
                                      listingProvider.fetchListings();
                                    },
                                  ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            if (value.isNotEmpty) {
                              listingProvider.searchListingsByName(value);
                            } else if (_selectedCategory != null) {
                              listingProvider
                                  .fetchListingsByCategory(_selectedCategory!);
                            } else {
                              listingProvider.fetchListings();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Category filter chips
                if (_categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: Icon(Icons.apps,
                                  size: 18,
                                  color: _selectedCategory == null
                                      ? AppTheme.primaryDark
                                      : Colors.white70),
                              label: const Text('All'),
                              selected: _selectedCategory == null,
                              onSelected: (selected) {
                                setState(() => _selectedCategory = null);
                                _searchController.clear();
                                listingProvider.fetchListings();
                              },
                            ),
                          ),
                          ..._categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(_categoryIcon(category),
                                    size: 18,
                                    color: isSelected
                                        ? AppTheme.primaryDark
                                        : Colors.white70),
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() => _selectedCategory = selected ? category : null);
                                  _searchController.clear();
                                  if (selected) {
                                    listingProvider
                                        .fetchListingsByCategory(category);
                                  } else {
                                    listingProvider.fetchListings();
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                // Near You Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Text(
                      'Near You',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall,
                    ),
                  ),
                ),

                // Listings
                if (listingProvider.isLoading)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(height: 60),
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  )
                else if (listingProvider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.error_outline,
                              size: 64, color: AppTheme.accentRed),
                          const SizedBox(height: 16),
                          Text(
                            listingProvider.errorMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => listingProvider.fetchListings(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (listingProvider.listings.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.search_off,
                              size: 64, color: AppTheme.accentGold),
                          const SizedBox(height: 16),
                          const Text(
                            'No listings found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                        final listing = listingProvider.listings[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: _ListingCard(
                            listing: listing,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ListingDetailScreen(listing: listing),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: listingProvider.listings.length,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// My Listings Screen - Manage user's listings
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false)
          .fetchUserListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ListingProvider>(
      builder: (context, authProvider, listingProvider, _) {
        return Column(
          children: [
            // User info card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: AppTheme.cardWhite,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.accentGold,
                        child: Text(
                          authProvider.userDisplayName?.isNotEmpty ?? false
                              ? authProvider.userDisplayName![0]
                                  .toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.userDisplayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.email ?? '',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Create new listing button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addListing');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppTheme.surfaceDark),
                      SizedBox(width: 8),
                      Text(
                        'Create New Listing',
                        style: TextStyle(
                          color: AppTheme.surfaceDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // User listings
            Expanded(
              child: listingProvider.userListings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_outlined,
                              size: 64, color: AppTheme.accentGold),
                          const SizedBox(height: 16),
                          const Text(
                            'No listings yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your first listing to get started',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: listingProvider.userListings.length,
                      itemBuilder: (context, index) {
                        final listing =
                            listingProvider.userListings[index];
                        return _ListingCard(
                          listing: listing,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ListingDetailScreen(listing: listing),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Reusable listing card widget
class _ListingCard extends StatefulWidget {
  final Listing listing;
  final VoidCallback onTap;

  const _ListingCard({
    required this.listing,
    required this.onTap,
  });

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked =
        Provider.of<ListingProvider>(context, listen: false)
            .isBookmarked(widget.listing.id);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppTheme.cardWhite,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardGrey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: widget.listing.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            widget.listing.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                            errorBuilder: (context, error, stackTrace) {
                              return AppTheme.categoryPlaceholder(
                                  widget.listing.category);
                            },
                          ),
                        )
                      : ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: AppTheme.categoryPlaceholder(
                              widget.listing.category),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.listing.category,
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Bookmark button
                Positioned(
                  top: 50,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        if (_isBookmarked) {
                          await Provider.of<ListingProvider>(context,
                                  listen: false)
                              .removeFromBookmarks(widget.listing.id);
                        } else {
                          await Provider.of<ListingProvider>(context,
                                  listen: false)
                              .addToBookmarks(widget.listing.id);
                        }
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppTheme.accentRed,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _isBookmarked ? Icons.favorite : Icons.favorite_border,
                        color: AppTheme.accentGold,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                if (widget.listing.rating > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppTheme.accentGold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            widget.listing.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.listing.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Rating and Review Count
                            if (widget.listing.rating > 0)
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < widget.listing.rating.toInt()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: AppTheme.accentGold,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.listing.rating.toStringAsFixed(1)} (${widget.listing.reviewCount} reviews)',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppTheme.accentGold),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.listing.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.phone,
                          size: 14, color: AppTheme.accentGold),
                      const SizedBox(width: 4),
                      Text(
                        widget.listing.phoneNumber,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bookmarks Screen - View bookmarked/favorite listings
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false)
          .fetchBookmarkedListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingProvider>(
      builder: (context, listingProvider, _) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Favorites',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listingProvider.bookmarkedListings.length} restaurants saved',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Bookmarked listings
            Expanded(
              child: listingProvider.bookmarkedListings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_outline,
                            size: 64,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No saved favorites yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the heart icon on listings to save them',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          listingProvider.bookmarkedListings.length,
                      itemBuilder: (context, index) {
                        final listing =
                            listingProvider.bookmarkedListings[index];
                        return _ListingCard(
                          listing: listing,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ListingDetailScreen(listing: listing),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Add Listing Screen - Create a new restaurant listing
class _AddListingScreen extends StatefulWidget {
  const _AddListingScreen();

  @override
  State<_AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<_AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingProvider>(
      builder: (context, listingProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Add a New Restaurant',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Restaurant Name'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(labelText: 'Website (Optional)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration:
                              const InputDecoration(labelText: 'Latitude'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          decoration:
                              const InputDecoration(labelText: 'Longitude'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                        labelText: 'Image URL (Optional)'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: listingProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                try {
                                  await listingProvider.addListing(
                                    name: _nameController.text,
                                    category: _categoryController.text,
                                    description: _descriptionController.text,
                                    address: _addressController.text,
                                    phoneNumber: _phoneController.text,
                                    website: _websiteController.text.isEmpty
                                        ? null
                                        : _websiteController.text,
                                    latitude: double.parse(
                                        _latitudeController.text),
                                    longitude: double.parse(
                                        _longitudeController.text),
                                    imageUrl: _imageUrlController.text,
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Listing added successfully!'),
                                      ),
                                    );
                                    // Clear form
                                    _nameController.clear();
                                    _categoryController.clear();
                                    _descriptionController.clear();
                                    _addressController.clear();
                                    _phoneController.clear();
                                    _websiteController.clear();
                                    _latitudeController.clear();
                                    _longitudeController.clear();
                                    _imageUrlController.clear();
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
                                }
                              }
                            },
                      child: listingProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Add Listing'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Profile Screen - User profile and their listings
class _ProfileScreen extends StatefulWidget {
  const _ProfileScreen();

  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false)
          .fetchUserListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ListingProvider>(
      builder: (context, authProvider, listingProvider, _) {
        return Column(
          children: [
            // User info card
            if (authProvider.user != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.accentGold,
                          child: Text(
                            authProvider.userDisplayName?.isNotEmpty ?? false
                                ? authProvider.userDisplayName![0]
                                    .toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authProvider.userDisplayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.user?.email ?? '',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (authProvider.userPhoneNumber != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              authProvider.userPhoneNumber ?? '',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            // User listings section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: const Text(
                      'Your Listings',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: listingProvider.userListings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.list,
                                    size: 48, color: AppTheme.accentGold),
                                const SizedBox(height: 16),
                                const Text(
                                  'No listings yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: listingProvider.userListings.length,
                            itemBuilder: (context, index) {
                              final listing =
                                  listingProvider.userListings[index];
                              return Card(
                                child: ListTile(
                                  title: Text(listing.name),
                                  subtitle: Text(listing.category),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: const Text('Edit'),
                                        onTap: () {
                                          // TODO: Implement edit functionality
                                        },
                                      ),
                                      PopupMenuItem(
                                        child: const Text('Delete'),
                                        onTap: () async {
                                          await listingProvider
                                              .deleteListing(listing.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
