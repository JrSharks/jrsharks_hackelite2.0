import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  Map<String, bool> _accessibilityPreferences = {};

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.userProfile['fullName'] ?? '';
    _bioController.text = widget.userProfile['bio'] ?? '';
    _locationController.text = widget.userProfile['location'] ?? '';

    final preferences = widget.userProfile['accessibilityPreferences']
            as Map<String, dynamic>? ??
        {};
    _accessibilityPreferences = {
      'wheelchairAccessible': preferences['wheelchairAccessible'] ?? false,
      'brailleSupport': preferences['brailleSupport'] ?? false,
      'hearingAssistance': preferences['hearingAssistance'] ?? false,
      'visualAssistance': preferences['visualAssistance'] ?? false,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                widget.userProfile['profileImage'] != null
                                    ? NetworkImage(
                                        widget.userProfile['profileImage'])
                                    : null,
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: widget.userProfile['profileImage'] == null
                                ? Text(
                                    (_nameController.text.isNotEmpty
                                            ? _nameController.text
                                            : 'U')[0]
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

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
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _bioController,
                              decoration: const InputDecoration(
                                labelText: 'Bio (Optional)',
                                hintText: 'Tell others about yourself...',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info),
                              ),
                              maxLines: 3,
                              maxLength: 150,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location (Optional)',
                                hintText: 'City, Country',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Accessibility Preferences
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accessibility Preferences',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'These preferences help us recommend places that meet your needs.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            _buildAccessibilityOptions(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account Information (Read-only)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Information',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Email'),
                              subtitle: Text(widget.userProfile['email'] ?? ''),
                              contentPadding: EdgeInsets.zero,
                            ),
                            ListTile(
                              leading: const Icon(Icons.badge),
                              title: const Text('Role'),
                              subtitle: Text(widget.userProfile['role']
                                      ?.toString()
                                      .toUpperCase() ??
                                  'USER'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('Member Since'),
                              subtitle: Text(_formatMemberSince(
                                  widget.userProfile['createdAt'])),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
    );
  }

  Widget _buildAccessibilityOptions() {
    final options = [
      {
        'key': 'wheelchairAccessible',
        'label': 'Wheelchair Accessibility',
        'icon': Icons.accessible,
        'description': 'Show places with wheelchair access',
      },
      {
        'key': 'brailleSupport',
        'label': 'Braille Support',
        'icon': Icons.touch_app,
        'description': 'Show places with braille signage',
      },
      {
        'key': 'hearingAssistance',
        'label': 'Hearing Assistance',
        'icon': Icons.hearing,
        'description': 'Show places with hearing loops/support',
      },
      {
        'key': 'visualAssistance',
        'label': 'Visual Assistance',
        'icon': Icons.visibility,
        'description': 'Show places with visual aids',
      },
    ];

    return Column(
      children: options.map((option) {
        final key = option['key'] as String;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SwitchListTile(
            value: _accessibilityPreferences[key] ?? false,
            onChanged: (value) {
              setState(() {
                _accessibilityPreferences[key] = value;
              });
            },
            title: Row(
              children: [
                Icon(option['icon'] as IconData, size: 20),
                const SizedBox(width: 8),
                Text(option['label'] as String),
              ],
            ),
            subtitle: Text(
              option['description'] as String,
              style: const TextStyle(fontSize: 12),
            ),
            activeColor: Theme.of(context).primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = {
        'fullName': _nameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'accessibilityPreferences': _accessibilityPreferences,
      };

      await _apiService.updateUserProfile(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatMemberSince(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(date.toString());
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
