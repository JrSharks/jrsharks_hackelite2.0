import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../places/place_details_screen.dart';
import 'edit_profile_screen.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _userSubmissions = [];
  List<Map<String, dynamic>> _userReviews = [];
  bool _isLoading = true;
  String? _error;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _apiService.getUserProfile();
      final submissions = await _apiService.getUserSubmissions();
      final reviews = await _apiService.getUserReviews();

      setState(() {
        _userProfile = profile;
        _userSubmissions = submissions;
        _userReviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : CustomScrollView(
                  slivers: [
                    _buildProfileHeader(),
                    _buildStatsSection(),
                    _buildTabSection(),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _userProfile?['profileImage'] != null
                        ? NetworkImage(_userProfile!['profileImage'])
                        : null,
                    backgroundColor: Colors.white,
                    child: _userProfile?['profileImage'] == null
                        ? Text(
                            (_userProfile?['fullName'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userProfile?['fullName'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_userProfile?['bio'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _userProfile!['bio'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_userProfile?['location'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _userProfile!['location'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => _navigateToEditProfile(),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Sign Out', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              _showSignOutDialog();
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Places Added',
              '${_userProfile?['contributionCount'] ?? 0}',
              Icons.add_location,
              Colors.blue,
            ),
            _buildStatItem(
              'Reviews',
              '${_userProfile?['reviewCount'] ?? 0}',
              Icons.rate_review,
              Colors.green,
            ),
            _buildStatItem(
              'Member Since',
              _formatMemberSince(_userProfile?['createdAt']),
              Icons.calendar_today,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return SliverFillRemaining(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Places'),
                Tab(text: 'Reviews'),
                Tab(text: 'Activity'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlacesTab(),
                _buildReviewsTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesTab() {
    if (_userSubmissions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No places submitted yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start contributing by adding accessible places!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userSubmissions.length,
      itemBuilder: (context, index) {
        final place = _userSubmissions[index];
        return _buildPlaceCard(place);
      },
    );
  }

  Widget _buildReviewsTab() {
    if (_userReviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Share your experiences by reviewing places!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userReviews.length,
      itemBuilder: (context, index) {
        final review = _userReviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildActivityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Combine and sort places and reviews by date
        ..._buildActivityItems(),
      ],
    );
  }

  List<Widget> _buildActivityItems() {
    final activities = <Map<String, dynamic>>[];

    // Add places
    for (final place in _userSubmissions) {
      activities.add({
        'type': 'place',
        'data': place,
        'date': place['createdAt'],
      });
    }

    // Add reviews
    for (final review in _userReviews) {
      activities.add({
        'type': 'review',
        'data': review,
        'date': review['createdAt'],
      });
    }

    // Sort by date
    activities.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return activities.take(10).map((activity) {
      if (activity['type'] == 'place') {
        return _buildActivityPlaceItem(activity['data']);
      } else {
        return _buildActivityReviewItem(activity['data']);
      }
    }).toList();
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    final isApproved = place['isApproved'] ?? false;

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
                    child: Text(
                      place['name'] ?? 'Unknown Place',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isApproved ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isApproved ? 'Approved' : 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                place['category'] ?? 'General',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (place['description'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    place['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review['placeName'] ?? 'Unknown Place',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 16,
                      color: index < (review['rating'] ?? 0)
                          ? Colors.amber
                          : Colors.grey.shade300,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review['comment'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Accessibility: ${review['accessibilityRating'] ?? 0}/5',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPlaceItem(Map<String, dynamic> place) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.add_location, color: Colors.blue),
      ),
      title: Text('Added ${place['name']}'),
      subtitle: Text(_formatDate(place['createdAt'])),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _navigateToPlaceDetails(place),
    );
  }

  Widget _buildActivityReviewItem(Map<String, dynamic> review) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Icon(Icons.rate_review, color: Colors.green),
      ),
      title: Text('Reviewed ${review['placeName']}'),
      subtitle: Text(_formatDate(review['createdAt'])),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber, size: 16),
          Text('${review['rating']}'),
        ],
      ),
    );
  }

  void _navigateToPlaceDetails(Map<String, dynamic> place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailsScreen(place: place),
      ),
    );
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userProfile: _userProfile!),
      ),
    );

    if (result == true) {
      _loadUserData(); // Refresh profile data
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthService>(context, listen: false).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  String _formatMemberSince(dynamic date) {
    if (date == null) return '2024';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.year}';
    } catch (e) {
      return '2024';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.parse(date.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
