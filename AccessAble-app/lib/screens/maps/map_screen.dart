import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';
import '../../services/places_service.dart';
import '../places/place_details_screen.dart';
import '../places/accessibility_filters_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  LatLng _initialPosition =
      const LatLng(37.7749, -122.4194); // San Francisco default
  bool _isLoading = true;
  Map<String, bool> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final placesService = Provider.of<PlacesService>(context, listen: false);

    // Initialize location
    await locationService.initializeLocation();
    if (locationService.currentPosition != null) {
      _initialPosition = LatLng(
        locationService.currentPosition!.latitude,
        locationService.currentPosition!.longitude,
      );
    }

    // Load places
    await placesService.loadApprovedPlaces();
    _updateMarkers();

    if (mounted) {
    setState(() {
      _isLoading = false;
    });
    }
  }

  void _updateMarkers() {
    final placesService = Provider.of<PlacesService>(context, listen: false);
    final places = placesService.places;

    _markers = places.where((place) {
      // Apply accessibility filters
      if (_activeFilters.isNotEmpty) {
        final features =
            place['accessibilityFeatures'] as Map<String, dynamic>? ?? {};
        return _activeFilters.entries.every((filter) {
          if (!filter.value) return true; // Filter not active
          return features[filter.key] == true;
        });
      }
      return true;
    }).map((place) {
      final coordinates = place['coordinates'] as Map<String, dynamic>;
      return Marker(
        point: LatLng(
          coordinates['latitude']?.toDouble() ?? 0.0,
          coordinates['longitude']?.toDouble() ?? 0.0,
        ),
        child: GestureDetector(
          onTap: () => _showPlaceDetails(place),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _getMarkerColor(place), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.place,
              color: _getMarkerColor(place),
              size: 30,
            ),
          ),
        ),
      );
    }).toList();

    setState(() {});
  }

  Color _getMarkerColor(Map<String, dynamic> place) {
    final features =
        place['accessibilityFeatures'] as Map<String, dynamic>? ?? {};

    // Green for fully accessible
    if (features['wheelchairAccessible'] == true &&
        features['accessibleRestroom'] == true) {
      return Colors.green;
    }

    // Orange for partially accessible
    if (features.values.any((value) => value == true)) {
      return Colors.orange;
    }

    // Red for limited accessibility
    return Colors.red;
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    // Show bottom sheet with place details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Place info
              Text(
                place['name'] ?? 'Unknown Place',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                place['category'] ?? 'General',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                place['address'] ?? 'No address provided',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Accessibility features
              const Text(
                'Accessibility Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildAccessibilityChips(
                  place['accessibilityFeatures'] as Map<String, dynamic>? ??
                      {}),

              const Spacer(),

              // View details button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailsScreen(place: place),
                      ),
                    );
                  },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibilityChips(Map<String, dynamic> features) {
    final availableFeatures = features.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (availableFeatures.isEmpty) {
      return const Text('No accessibility information available');
    }

    final featureNames = {
      'wheelchairAccessible': 'Wheelchair',
      'brailleSupport': 'Braille',
      'hearingAssistance': 'Hearing',
      'visualAssistance': 'Visual',
      'accessibleParking': 'Parking',
      'accessibleRestroom': 'Restroom',
      'elevatorAccess': 'Elevator',
      'rampAccess': 'Ramp',
    };

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: availableFeatures.take(4).map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            featureNames[feature] ?? feature,
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAccessibilityFilters() async {
    final result = await Navigator.of(context).push<Map<String, bool>>(
      MaterialPageRoute(
        builder: (context) => AccessibilityFiltersScreen(
          initialFilters: _activeFilters,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _activeFilters = result;
      });
      _updateMarkers();
    }
  }

  Future<void> _goToCurrentLocation() async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final position = await locationService.getCurrentLocation();

    if (position != null) {
      final newCenter = LatLng(position.latitude, position.longitude);
      _mapController.move(newCenter, 15.0);
      setState(() {
        _initialPosition = newCenter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AccessAble Map'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _activeFilters.isNotEmpty ? Colors.yellow : Colors.white,
            ),
            onPressed: _showAccessibilityFilters,
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<PlacesService>(
              builder: (context, placesService, child) {
                if (placesService.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading places',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          placesService.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            placesService.clearError();
                            _initializeMap();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: 14.0,
                    onTap: (tapPosition, point) {
                      // Handle map tap if needed
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.accessable_app',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: _markers,
                    ),
                    // Current location marker
                    if (Provider.of<LocationService>(context).currentPosition !=
                        null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              Provider.of<LocationService>(context)
                                  .currentPosition!
                                  .latitude,
                              Provider.of<LocationService>(context)
                                  .currentPosition!
                                  .longitude,
                            ),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
      floatingActionButton: _activeFilters.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _activeFilters.clear();
                });
                _updateMarkers();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }
}
