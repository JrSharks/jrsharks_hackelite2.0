import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class PlacesService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _userSubmissions = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get places => _places;
  List<Map<String, dynamic>> get userSubmissions => _userSubmissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadApprovedPlaces() async {
    _setLoading(true);
    _clearError();

    try {
      _places = await _apiService.getApprovedPlaces();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> createPlace({
    required String name,
    required String description,
    required String category,
    required String address,
    required double latitude,
    required double longitude,
    required Map<String, bool> accessibilityFeatures,
    List<XFile>? photos,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Upload photos to Firebase Storage and get URLs
      List<String> photoUrls = [];
      if (photos != null && photos.isNotEmpty) {
        // For now, we'll use placeholder URLs or blob paths
        photoUrls = photos.map((xfile) => xfile.path).toList();
      }

      final placeData = {
        'name': name,
        'description': description,
        'category': category,
        'address': address,
        'coordinates': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'accessibilityFeatures': {
          'wheelchairAccessible':
              accessibilityFeatures['wheelchairAccessible'] ?? false,
          'brailleSupport': accessibilityFeatures['brailleSupport'] ?? false,
          'hearingAssistance':
              accessibilityFeatures['hearingAssistance'] ?? false,
          'visualAssistance':
              accessibilityFeatures['visualAssistance'] ?? false,
          'accessibleParking':
              accessibilityFeatures['accessibleParking'] ?? false,
          'accessibleRestroom':
              accessibilityFeatures['accessibleRestroom'] ?? false,
          'elevatorAccess': accessibilityFeatures['elevatorAccess'] ?? false,
          'rampAccess': accessibilityFeatures['rampAccess'] ?? false,
        },
        'photos': photoUrls,
      };

      final result = await _apiService.createPlace(placeData);

      // Refresh user submissions
      await loadUserSubmissions();

      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> searchPlaces({
    String? query,
    String? category,
    Map<String, bool>? accessibilityFilters,
  }) async {
    try {
      return await _apiService.searchPlaces(
        query: query,
        category: category,
        wheelchairAccessible: accessibilityFilters?['wheelchairAccessible'],
        brailleSupport: accessibilityFilters?['brailleSupport'],
        hearingAssistance: accessibilityFilters?['hearingAssistance'],
        visualAssistance: accessibilityFilters?['visualAssistance'],
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  Future<void> loadUserSubmissions() async {
    try {
      _userSubmissions = await _apiService.getUserSubmissions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user submissions: $e');
    }
  }

  Future<Map<String, dynamic>?> addReview({
    required String placeId,
    required int rating,
    required String comment,
    required int accessibilityRating,
  }) async {
    try {
      final reviewData = {
        'rating': rating,
        'comment': comment,
        'accessibilityRating': accessibilityRating,
      };

      final result = await _apiService.addReview(placeId, reviewData);

      // Refresh places to get updated reviews
      await loadApprovedPlaces();

      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<List<XFile>?> pickImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (images.isEmpty) return null;

      final selectedImages = images.take(maxImages).toList();
      return selectedImages;
    } catch (e) {
      _setError('Error picking images: $e');
      return null;
    }
  }

  Future<XFile?> pickSingleImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      return image;
    } catch (e) {
      _setError('Error picking image: $e');
      return null;
    }
  }

  Map<String, dynamic>? getPlaceById(String placeId) {
    try {
      return _places.firstWhere((place) => place['id'] == placeId);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
