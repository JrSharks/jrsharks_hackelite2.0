import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:3000/api/v1'; // NestJS backend URL

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _getHeaders() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Places API calls
  Future<List<Map<String, dynamic>>> getApprovedPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places?approved=true'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      throw Exception('Error fetching places: $e');
    }
  }

  Future<Map<String, dynamic>> createPlace(
      Map<String, dynamic> placeData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/places'),
        headers: headers,
        body: json.encode(placeData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create place');
      }
    } catch (e) {
      throw Exception('Error creating place: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchPlaces({
    String? query,
    String? category,
    bool? wheelchairAccessible,
    bool? brailleSupport,
    bool? hearingAssistance,
    bool? visualAssistance,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (category != null) {
        queryParams['category'] = category;
      }
      if (wheelchairAccessible != null) {
        queryParams['wheelchair'] = wheelchairAccessible.toString();
      }
      if (brailleSupport != null) {
        queryParams['braille'] = brailleSupport.toString();
      }
      if (hearingAssistance != null) {
        queryParams['hearing'] = hearingAssistance.toString();
      }
      if (visualAssistance != null) {
        queryParams['visual'] = visualAssistance.toString();
      }

      final uri = Uri.parse('$baseUrl/places/search').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search places');
      }
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  Future<Map<String, dynamic>> addReview(
      String placeId, Map<String, dynamic> reviewData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/places/$placeId/reviews'),
        headers: headers,
        body: json.encode(reviewData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to add review');
      }
    } catch (e) {
      throw Exception('Error adding review: $e');
    }
  }

  Future<Map<String, dynamic>> getPlaceById(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places/$placeId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Place not found');
      }
    } catch (e) {
      throw Exception('Error fetching place: $e');
    }
  }

  // User profile API calls
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final user = _auth.currentUser!;

      final response = await http.get(
        Uri.parse('$baseUrl/users/${user.uid}/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final user = _auth.currentUser!;

      final response = await http.patch(
        Uri.parse('$baseUrl/users/${user.uid}/profile'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserSubmissions() async {
    try {
      final headers = await _getHeaders();
      final user = _auth.currentUser!;

      final response = await http.get(
        Uri.parse('$baseUrl/users/${user.uid}/submissions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load user submissions');
      }
    } catch (e) {
      throw Exception('Error fetching user submissions: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserReviews() async {
    try {
      final headers = await _getHeaders();
      final user = _auth.currentUser!;

      final response = await http.get(
        Uri.parse('$baseUrl/users/${user.uid}/reviews'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load user reviews');
      }
    } catch (e) {
      throw Exception('Error fetching user reviews: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 2000,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
      };

      if (category != null) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse('$baseUrl/places/nearby').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load nearby places');
      }
    } catch (e) {
      throw Exception('Error fetching nearby places: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendations() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/places/recommendations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}
