import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/places_service.dart';
import 'add_review_screen.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  late Map<String, dynamic> _place;
  final PageController _photoController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _place = widget.place;
  }

  @override
  Widget build(BuildContext context) {
    final features =
        _place['accessibilityFeatures'] as Map<String, dynamic>? ?? {};
    final reviews = _place['reviews'] as List<dynamic>? ?? [];
    final photos = _place['photos'] as List<dynamic>? ?? [];
    final averageRating = _place['averageRating']?.toDouble() ?? 0.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: photos.isNotEmpty
                  ? _buildPhotoCarousel(photos)
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.place,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _place['name'] ?? 'Unknown Place',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _place['category'] ?? 'General',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (averageRating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Address'),
                      subtitle:
                          Text(_place['address'] ?? 'No address provided'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (_place['description'] != null &&
                      _place['description'].isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(_place['description']),
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
                          const SizedBox(height: 16),
                          _buildAccessibilityGrid(features),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reviews Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reviews (${reviews.length})',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              TextButton(
                                onPressed: _addReview,
                                child: const Text('Add Review'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (reviews.isEmpty)
                            const Center(
                              child: Text(
                                'No reviews yet. Be the first to review!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            ...reviews
                                .take(3)
                                .map((review) => _buildReviewItem(review)),
                          if (reviews.length > 3)
                            TextButton(
                              onPressed: () {
                                // TODO: Show all reviews
                              },
                              child: Text('View all ${reviews.length} reviews'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 100), // Space for floating action button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReview,
        icon: const Icon(Icons.rate_review),
        label: const Text('Add Review'),
      ),
    );
  }

  Widget _buildPhotoCarousel(List<dynamic> photos) {
    return Stack(
      children: [
        PageView.builder(
          controller: _photoController,
          onPageChanged: (index) {
            setState(() {
              _currentPhotoIndex = index;
            });
          },
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(photos[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        if (photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: photos.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPhotoIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAccessibilityGrid(Map<String, dynamic> features) {
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: accessibilityItems.length,
      itemBuilder: (context, index) {
        final item = accessibilityItems[index];
        final isAvailable = features[item['key']] == true;

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isAvailable ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item['icon'] as IconData,
                size: 20,
                color: isAvailable ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isAvailable ? Colors.green.shade700 : Colors.grey,
                    fontWeight:
                        isAvailable ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  (review['userName'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 14,
                            color: index < (review['rating'] ?? 0)
                                ? Colors.amber
                                : Colors.grey.shade300,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          'Accessibility: ${review['accessibilityRating'] ?? 0}/5',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review['comment'] != null && review['comment'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                review['comment'],
                style: const TextStyle(fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  void _addReview() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(placeId: _place['id']),
      ),
    );

    if (result == true) {
      // Refresh place data
      final placesService = Provider.of<PlacesService>(context, listen: false);
      await placesService.loadApprovedPlaces();
      final updatedPlace = placesService.getPlaceById(_place['id']);
      if (updatedPlace != null) {
        setState(() {
          _place = updatedPlace;
        });
      }
    }
  }
}
