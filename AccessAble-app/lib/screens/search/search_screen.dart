import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/places_service.dart';
import '../../services/location_service.dart';
import '../places/place_details_screen.dart';
import '../places/accessibility_filters_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _nearbyPlaces = [];
  bool _isSearching = false;
  bool _isLoadingNearby = false;
  String? _selectedCategory;
  Map<String, bool> _accessibilityFilters = {};

  final List<String> _categories = [
    'All Categories',
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
  void initState() {
    super.initState();
    _selectedCategory = 'All Categories';
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadNearbyPlaces();
    await _loadApprovedPlaces();
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() {
      _isLoadingNearby = true;
    });

    try {
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      final position = await locationService.getCurrentLocation();

      if (position != null) {
        final placesService =
            Provider.of<PlacesService>(context, listen: false);
        // For now, we'll use the regular search with location filtering
        await placesService.loadApprovedPlaces();
        setState(() {
          _nearbyPlaces = placesService.places.take(5).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading nearby places: $e');
    } finally {
      setState(() {
        _isLoadingNearby = false;
      });
    }
  }

  Future<void> _loadApprovedPlaces() async {
    final placesService = Provider.of<PlacesService>(context, listen: false);
    await placesService.loadApprovedPlaces();
    setState(() {
      _searchResults = placesService.places;
    });
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    setState(() {
      _isSearching = true;
    });

    try {
      final placesService = Provider.of<PlacesService>(context, listen: false);

      final results = await placesService.searchPlaces(
        query: query.isEmpty ? null : query,
        category:
            _selectedCategory == 'All Categories' ? null : _selectedCategory,
        accessibilityFilters:
            _accessibilityFilters.isEmpty ? null : _accessibilityFilters,
      );

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Places'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for accessible places...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _performSearch(),
                  onChanged: (value) {
                    setState(() {}); // Update UI for clear button
                  },
                ),
                const SizedBox(height: 12),

                // Quick Filters
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category,
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                              _performSearch();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _accessibilityFilters.isNotEmpty
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _accessibilityFilters.isNotEmpty
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _showAccessibilityFilters,
                        icon: Icon(
                          Icons.tune,
                          color: _accessibilityFilters.isNotEmpty
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _searchController.text.isNotEmpty ||
                    _selectedCategory != 'All Categories' ||
                    _accessibilityFilters.isNotEmpty
                ? _buildSearchResults()
                : _buildDiscoverContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nearby Places Section
          Row(
            children: [
              Icon(Icons.near_me, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Nearby Places',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoadingNearby
              ? const Center(child: CircularProgressIndicator())
              : _nearbyPlaces.isEmpty
                  ? const Text('No nearby places found')
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _nearbyPlaces.length,
                        itemBuilder: (context, index) {
                          return _buildNearbyCard(_nearbyPlaces[index]);
                        },
                      ),
                    ),
          const SizedBox(height: 24),

          // Quick Categories
          const Text(
            'Browse by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCategoryGrid(),
          const SizedBox(height: 24),

          // Recently Added
          const Text(
            'Recently Added',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._searchResults.take(3).map((place) => _buildPlaceCard(place)),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Results Count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${_searchResults.length} places found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Results List
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return _buildPlaceCard(_searchResults[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildNearbyCard(Map<String, dynamic> place) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToPlaceDetails(place),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.place, size: 32, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  place['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  place['category'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories =
        _categories.where((cat) => cat != 'All Categories').toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final icons = {
          'Restaurant': Icons.restaurant,
          'Hotel': Icons.hotel,
          'Shopping': Icons.shopping_bag,
          'Healthcare': Icons.local_hospital,
          'Education': Icons.school,
          'Transportation': Icons.directions_bus,
          'Entertainment': Icons.movie,
          'Public Service': Icons.account_balance,
          'Recreation': Icons.park,
          'Other': Icons.more_horiz,
        };

        return Card(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              _performSearch();
            },
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icons[category] ?? Icons.place,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    final features =
        place['accessibilityFeatures'] as Map<String, dynamic>? ?? {};
    final reviews = place['reviews'] as List<dynamic>? ?? [];
    final averageRating = place['averageRating']?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToPlaceDetails(place),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'] ?? 'Unknown Place',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          place['category'] ?? 'General',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (averageRating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (place['description'] != null &&
                  place['description'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    place['description'],
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              _buildAccessibilityChips(features),
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
      return const Text(
        'Accessibility information not available',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No places found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showAccessibilityFilters() async {
    final result = await Navigator.of(context).push<Map<String, bool>>(
      MaterialPageRoute(
        builder: (context) => AccessibilityFiltersScreen(
          initialFilters: _accessibilityFilters,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _accessibilityFilters = result;
      });
      _performSearch();
    }
  }

  void _navigateToPlaceDetails(Map<String, dynamic> place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceDetailsScreen(place: place),
      ),
    );
  }
}
