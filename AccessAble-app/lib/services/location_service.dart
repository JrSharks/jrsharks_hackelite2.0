import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializeLocation() async {
    _setLoading(true);
    _clearError();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      _isLocationEnabled = true;
      await getCurrentLocation();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Position?> getCurrentLocation() async {
    if (!_isLocationEnabled) {
      await initializeLocation();
      if (!_isLocationEnabled) return null;
    }

    try {
      _setLoading(true);
      _clearError();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = position;
      _safeNotify();
      return position;
    } catch (e) {
      _setError('Failed to get current location: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return null;
  }

  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotify();
  }

  void _setError(String error) {
    _error = error;
    _safeNotify();
  }

  void _clearError() {
    _error = null;
    _safeNotify();
  }

  void _safeNotify() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }
}
