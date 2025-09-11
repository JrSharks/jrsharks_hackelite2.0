import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/places_service.dart';

class AddReviewScreen extends StatefulWidget {
  final String placeId;

  const AddReviewScreen({super.key, required this.placeId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  int _rating = 0;
  int _accessibilityRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
        actions: [
          if (!_isSubmitting)
            TextButton(
              onPressed: _submitReview,
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
                  Text('Submitting your review...'),
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
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Share Your Experience',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Help others by sharing your experience with this place',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Overall Rating
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Rating *',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'How would you rate this place overall?',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _rating = index + 1;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.star,
                                      size: 40,
                                      color: index < _rating
                                          ? Colors.amber
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_rating > 0)
                              Center(
                                child: Text(
                                  _getRatingText(_rating),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Accessibility Rating
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accessibility Rating *',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'How accessible is this place for people with disabilities?',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _accessibilityRating = index + 1;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.accessible,
                                      size: 32,
                                      color: index < _accessibilityRating
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_accessibilityRating > 0)
                              Center(
                                child: Text(
                                  _getAccessibilityRatingText(
                                      _accessibilityRating),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Comment
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Review',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Share details about your experience and any accessibility features you noticed',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Write your review here...',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 6,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please write a review';
                                }
                                if (value.trim().length < 10) {
                                  return 'Please write at least 10 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  color: Colors.blue.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Tips for a helpful review:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Mention specific accessibility features you used\n'
                            '• Describe the entrance and pathways\n'
                            '• Note any barriers or challenges\n'
                            '• Include helpful tips for others',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ],
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
              onPressed: _submitReview,
              icon: const Icon(Icons.send),
              label: const Text('Submit Review'),
              backgroundColor:
                  _rating > 0 && _accessibilityRating > 0 ? null : Colors.grey,
            ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  String _getAccessibilityRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Not Accessible';
      case 2:
        return 'Limited Accessibility';
      case 3:
        return 'Moderately Accessible';
      case 4:
        return 'Very Accessible';
      case 5:
        return 'Fully Accessible';
      default:
        return '';
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an overall rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_accessibilityRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an accessibility rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final placesService = Provider.of<PlacesService>(context, listen: false);

      final result = await placesService.addReview(
        placeId: widget.placeId,
        rating: _rating,
        comment: _commentController.text.trim(),
        accessibilityRating: _accessibilityRating,
      );

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your review!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
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
