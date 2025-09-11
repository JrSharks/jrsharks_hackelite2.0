import 'package:flutter/material.dart';

class AccessibilityFiltersScreen extends StatefulWidget {
  final Map<String, bool> initialFilters;

  const AccessibilityFiltersScreen({
    super.key,
    required this.initialFilters,
  });

  @override
  State<AccessibilityFiltersScreen> createState() =>
      _AccessibilityFiltersScreenState();
}

class _AccessibilityFiltersScreenState
    extends State<AccessibilityFiltersScreen> {
  late Map<String, bool> _filters;

  final List<Map<String, dynamic>> _filterOptions = [
    {
      'key': 'wheelchairAccessible',
      'label': 'Wheelchair Accessible',
      'icon': Icons.accessible,
      'description': 'Places with wheelchair ramps and accessible entrances',
    },
    {
      'key': 'brailleSupport',
      'label': 'Braille Support',
      'icon': Icons.touch_app,
      'description': 'Places with braille signage and tactile features',
    },
    {
      'key': 'hearingAssistance',
      'label': 'Hearing Assistance',
      'icon': Icons.hearing,
      'description': 'Places with hearing loops and sign language support',
    },
    {
      'key': 'visualAssistance',
      'label': 'Visual Assistance',
      'icon': Icons.visibility,
      'description': 'Places with large text, high contrast, and audio guides',
    },
    {
      'key': 'accessibleParking',
      'label': 'Accessible Parking',
      'icon': Icons.local_parking,
      'description': 'Places with designated accessible parking spaces',
    },
    {
      'key': 'accessibleRestroom',
      'label': 'Accessible Restroom',
      'icon': Icons.wc,
      'description': 'Places with accessible restroom facilities',
    },
    {
      'key': 'elevatorAccess',
      'label': 'Elevator Access',
      'icon': Icons.elevator,
      'description': 'Multi-level places with elevator access',
    },
    {
      'key': 'rampAccess',
      'label': 'Ramp Access',
      'icon': Icons.ramp_right,
      'description': 'Places with ramp access for mobility aids',
    },
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, bool>.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Filters'),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Icon(
                  Icons.tune,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Find Places That Meet Your Needs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select the accessibility features you need',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Filters List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final key = option['key'] as String;
                final isActive = _filters[key] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isActive ? 4 : 1,
                  child: InkWell(
                    onTap: () => _toggleFilter(key),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: isActive
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              option['icon'] as IconData,
                              color: isActive ? Colors.white : Colors.grey,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['label'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Theme.of(context).primaryColor
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option['description'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isActive,
                            onChanged: (value) => _toggleFilter(key),
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Active Filters Summary
          if (_getActiveFiltersCount() > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_getActiveFiltersCount()} filters active',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _applyFilters,
        icon: const Icon(Icons.check),
        label: Text(
          _getActiveFiltersCount() > 0
              ? 'Apply ${_getActiveFiltersCount()} Filters'
              : 'Show All Places',
        ),
      ),
    );
  }

  void _toggleFilter(String key) {
    setState(() {
      _filters[key] = !(_filters[key] ?? false);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
  }

  int _getActiveFiltersCount() {
    return _filters.values.where((value) => value).length;
  }

  void _applyFilters() {
    Navigator.of(context).pop(_filters);
  }
}
