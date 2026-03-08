import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing.dart';
import '../providers/listing_provider.dart';
import '../utils/app_theme.dart';

class EditListingScreen extends StatefulWidget {
  final Listing listing;

  const EditListingScreen({
    super.key,
    required this.listing,
  });

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _websiteController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _imageUrlController;

  String? _selectedCategory;
  List<String> _categories = [];
  List<String> _selectedAmenities = [];
  bool _isLoading = false;

  final List<String> _amenityOptions = [
    'WiFi',
    'Parking',
    'Wheelchair Accessible',
    'Pet Friendly',
    'Outdoor Seating',
    'Air Conditioning',
    'Lunch Special',
    'Delivery Available',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listing.name);
    _addressController = TextEditingController(text: widget.listing.address);
    _phoneController =
        TextEditingController(text: widget.listing.phoneNumber);
    _descriptionController =
        TextEditingController(text: widget.listing.description);
    _websiteController =
        TextEditingController(text: widget.listing.website ?? '');
    _latitudeController =
        TextEditingController(text: widget.listing.latitude.toString());
    _longitudeController =
        TextEditingController(text: widget.listing.longitude.toString());
    _imageUrlController =
        TextEditingController(text: widget.listing.imageUrl);

    // Initialize with default categories
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
    
    // Set current listing category as selected
    _selectedCategory = widget.listing.category;
    
    // If listing category is not in defaults, add it
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!);
      _categories.sort();
    }
    
    _selectedAmenities = List.from(widget.listing.amenities);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() => _isLoading = true);

        final provider = Provider.of<ListingProvider>(context, listen: false);
        await provider.updateListing(
          listingId: widget.listing.id,
          name: _nameController.text.trim(),
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          imageUrl: _imageUrlController.text.trim(),
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          amenities: _selectedAmenities,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          // Provider already refreshes listings internally
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing updated successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Failed to update listing: $e');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.accentRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              const Text(
                'Place / Service Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceDark,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category),
                  hintText: 'Select category',
                ),
                items: _categories
                    .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Address Field
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                minLines: 2,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone Field
              const Text(
                'Contact Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Describe the place/service',
                  prefixIcon: Icon(Icons.description),
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Latitude and Longitude
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latitude',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _latitudeController,
                          decoration: const InputDecoration(
                            hintText: 'Latitude',
                            prefixIcon: Icon(Icons.map),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Required';
                            }
                            try {
                              double.parse(value!);
                              return null;
                            } catch (e) {
                              return 'Invalid number';
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Longitude',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _longitudeController,
                          decoration: const InputDecoration(
                            hintText: 'Longitude',
                            prefixIcon: Icon(Icons.map),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Required';
                            }
                            try {
                              double.parse(value!);
                              return null;
                            } catch (e) {
                              return 'Invalid number';
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Image URL
              const Text(
                'Image URL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  hintText: 'Enter image URL',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 20),

              // Website
              const Text(
                'Website (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  hintText: 'Enter website URL',
                  prefixIcon: Icon(Icons.language),
                ),
              ),
              const SizedBox(height: 20),

              // Amenities Section
              const Text(
                'Amenities',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _amenityOptions
                    .map((amenity) => FilterChip(
                          label: Text(amenity),
                          selected: _selectedAmenities.contains(amenity),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                          backgroundColor: AppTheme.surfaceDark,
                          selectedColor: AppTheme.accentGold,
                          labelStyle: TextStyle(
                            color: _selectedAmenities.contains(amenity)
                                ? AppTheme.surfaceDark
                                : Colors.white,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.surfaceDark,
                            ),
                          ),
                        )
                      : const Text(
                          'Update Listing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.surfaceDark,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Delete Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _showDeleteConfirmation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentRed,
                    side: const BorderSide(color: AppTheme.accentRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete Listing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Delete Listing'),
        content: const Text(
          'Are you sure you want to delete this listing?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteListing();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteListing() async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<ListingProvider>(context, listen: false)
          .deleteListing(widget.listing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to delete listing: $e');
      }
    }
  }
}
