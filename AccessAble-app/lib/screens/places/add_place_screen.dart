import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/places_service.dart';
import '../../services/location_service.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedCategory;
  LatLng? _selectedLocation;
  final List<XFile> _selectedPhotos = [];
  bool _isSubmitting = false;

  final Map<String, bool> _accessibilityFeatures = {
    'wheelchairAccessible': false,
    'brailleSupport': false,
    'hearingAssistance': false,
    'visualAssistance': false,
    'accessibleParking': false,
    'accessibleRestroom': false,
    'elevatorAccess': false,
    'rampAccess': false,
  };

  final List<String> _categories = [
    'Restaurant',
    'Hotel',
    'Shopping',
    'Healthcare',
    'Education',
    'Transportation',
    'Entertainment',
    'Public Service',
    'Recreation',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place'),
        actions: [
          if (!_isSubmitting)
            TextButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
        ],
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Submitting your place...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Place Name *',
                                hintText: 'Enter the name of the place',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a place name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category *',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText:
                                    'Describe this place and its accessibility features',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Address *',
                                hintText: 'Enter the full address',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.my_location),
                                  onPressed: _getCurrentLocation,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _selectLocationOnMap,
                              icon: const Icon(Icons.map),
                              label: Text(
                                _selectedLocation != null
                                    ? 'Location Selected'
                                    : 'Select Location on Map',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedLocation != null
                                    ? Colors.green
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Photos
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photos',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _buildPhotoSection(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Accessibility Features
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accessibility Features',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Select all accessibility features available at this place:',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            _buildAccessibilityFeatures(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for submit button
                  ],
                ),
              ),
            ),
      floatingActionButton: _isSubmitting
          ? null
          : FloatingActionButton.extended(
              onPressed: _submitForm,
              icon: const Icon(Icons.send),
              label: const Text('Submit Place'),
            ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        if (_selectedPhotos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedPhotos.length) {
                  return _buildAddPhotoCard();
                }
                return _buildPhotoCard(_selectedPhotos[index], index);
              },
            ),
          )
        else
          _buildAddPhotoCard(),
      ],
    );
  }

  Widget _buildAddPhotoCard() {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: _addPhotos,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.grey.shade300, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
              SizedBox(height: 4),
              Text(
                'Add Photos',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(XFile photo, int index) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(photo.path,
                width: 100,
                height: 100,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) {
              return const Center(child: Icon(Icons.image_not_supported));
            }),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityFeatures() {
    final accessibilityItems = [
      {
        'key': 'wheelchairAccessible',
        'label': 'Wheelchair Accessible',
        'icon': Icons.accessible
      },
      {
        'key': 'brailleSupport',
        'label': 'Braille Support',
        'icon': Icons.touch_app
      },
      {
        'key': 'hearingAssistance',
        'label': 'Hearing Assistance',
        'icon': Icons.hearing
      },
      {
        'key': 'visualAssistance',
        'label': 'Visual Assistance',
        'icon': Icons.visibility
      },
      {
        'key': 'accessibleParking',
        'label': 'Accessible Parking',
        'icon': Icons.local_parking
      },
      {
        'key': 'accessibleRestroom',
        'label': 'Accessible Restroom',
        'icon': Icons.wc
      },
      {
        'key': 'elevatorAccess',
        'label': 'Elevator Access',
        'icon': Icons.elevator
      },
      {'key': 'rampAccess', 'label': 'Ramp Access', 'icon': Icons.ramp_right},
    ];

    return Column(
      children: accessibilityItems.map((item) {
        final key = item['key'] as String;
        return CheckboxListTile(
          title: Row(
            children: [
              Icon(item['icon'] as IconData, size: 20),
              const SizedBox(width: 8),
              Text(item['label'] as String),
            ],
          ),
          value: _accessibilityFeatures[key] ?? false,
          onChanged: (value) {
            setState(() {
              _accessibilityFeatures[key] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Future<void> _getCurrentLocation() async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final position = await locationService.getCurrentLocation();

    if (position != null) {
      final address = await locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address != null && mounted) {
        setState(() {
          _addressController.text = address;
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not resolve address. Location selected.'),
          ),
        );
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });
      }
    }
  }

  void _selectLocationOnMap() {
    // Show dialog to manually enter coordinates or use current location
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: const Text(
          'For now, we\'ll use your current location. In a future update, you\'ll be able to select a precise location on the map.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _getCurrentLocation();
            },
            child: const Text('Use Current Location'),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhotos() async {
    final placesService = Provider.of<PlacesService>(context, listen: false);
    final photos =
        await placesService.pickImages(maxImages: 5 - _selectedPhotos.length);

    if (photos != null) {
      setState(() {
        _selectedPhotos.addAll(photos);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final placesService = Provider.of<PlacesService>(context, listen: false);

      final result = await placesService.createPlace(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        address: _addressController.text.trim(),
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        accessibilityFeatures: _accessibilityFeatures,
        photos: _selectedPhotos,
      );

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Place submitted successfully! It will be reviewed before appearing on the map.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Failed to submit place');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting place: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
