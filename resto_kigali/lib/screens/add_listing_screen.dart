import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import '../providers/listing_provider.dart';
import '../utils/app_theme.dart';
import 'location_picker_screen.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
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
  final List<String> _selectedAmenities = [];
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
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _descriptionController = TextEditingController();
    _websiteController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _imageUrlController = TextEditingController();

    // Initialize with default categories immediately
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
    
    // Set default selected category to first item
    _selectedCategory = _categories.first;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final provider = Provider.of<ListingProvider>(context, listen: false);
      final fetchedCategories = await provider.fetchCategories();
      
      if (fetchedCategories.isNotEmpty && mounted) {
        setState(() {
          // Merge fetched categories with defaults so no option is lost
          final merged = <String>{..._categories, ...fetchedCategories};
          _categories = merged.toList()..sort();
        });
      }
    } catch (e) {
      // Keep default categories if fetch fails
    }
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
      if (_selectedCategory == null) {
        _showError('Please select a category');
        return;
      }

      try {
        setState(() => _isLoading = true);

        final provider = Provider.of<ListingProvider>(context, listen: false);
        await provider.addListing(
          name: _nameController.text.trim(),
          category: _selectedCategory!,
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          description: _descriptionController.text.trim(),
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          imageUrl: _imageUrlController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          amenities: _selectedAmenities,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          // Refresh provider
          provider.fetchListings();
          provider.fetchUserListings();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing created successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Failed to create listing: $e');
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
        title: const Text('Create New Listing'),
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
                decoration: InputDecoration(
                  hintText: 'Enter name',
                  prefixIcon: Icon(Icons.business, color: AppTheme.accentGold),
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
                key: ValueKey(_categories.length),
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceDark,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.category, color: AppTheme.accentGold),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter address',
                        prefixIcon: Icon(Icons.location_on, color: AppTheme.accentGold),
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
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Tooltip(
                      message: 'Pick location from map',
                      child: IconButton(
                        icon: const Icon(Icons.map),
                        color: AppTheme.accentGold,
                        iconSize: 28,
                        onPressed: () async {
                          final lat = _latitudeController.text.isEmpty
                              ? null
                              : double.tryParse(_latitudeController.text);
                          final lng = _longitudeController.text.isEmpty
                              ? null
                              : double.tryParse(_longitudeController.text);
                          
                          final selectedLocation = await Navigator.push<LatLng>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationPickerScreen(
                                initialLat: lat,
                                initialLng: lng,
                              ),
                            ),
                          );

                          if (selectedLocation != null && mounted) {
                            setState(() {
                              _latitudeController.text = selectedLocation.latitude.toString();
                              _longitudeController.text = selectedLocation.longitude.toString();
                              // Auto-populate address with coordinates as placeholder
                              if (_addressController.text.isEmpty) {
                                _addressController.text = 'Location: ${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}';
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
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
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone, color: AppTheme.accentGold),
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
                decoration: InputDecoration(
                  hintText: 'Enter description',
                  prefixIcon: Icon(Icons.description, color: AppTheme.accentGold),
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
                          decoration: InputDecoration(
                            hintText: 'Latitude',
                            prefixIcon: Icon(Icons.map, color: AppTheme.accentGold),
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
                          decoration: InputDecoration(
                            hintText: 'Longitude',
                            prefixIcon: Icon(Icons.map, color: AppTheme.accentGold),
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
                decoration: InputDecoration(
                  hintText: 'Enter image URL',
                  prefixIcon: Icon(Icons.image, color: AppTheme.accentGold),
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
                decoration: InputDecoration(
                  hintText: 'Enter website URL',
                  prefixIcon: Icon(Icons.language, color: AppTheme.accentGold),
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
                          'Create Listing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.surfaceDark,
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
}
