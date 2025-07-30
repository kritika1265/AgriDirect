import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  Placemark? _currentPlacemark;

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint('Location services are disabled.');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _currentPosition = position;
      return position;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Get cached location if available
  Position? getCachedLocation() {
    return _currentPosition;
  }

  /// Start location tracking
  StreamSubscription<Position>? startLocationTracking({
    required Function(Position) onLocationUpdate,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 10,
  }) {
    try {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          onLocationUpdate(position);
        },
        onError: (error) {
          debugPrint('Location tracking error: $error');
        },
      );

      return _positionStreamSubscription;
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      return null;
    }
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Get address from coordinates (Reverse Geocoding)
  Future<Placemark?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        _currentPlacemark = placemarks.first;
        return placemarks.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address (Forward Geocoding)
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Calculate distance between two points
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

  /// Calculate bearing between two points
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }

  /// Format address from placemark
  String formatAddress(Placemark placemark) {
    List<String> addressParts = [];
    
    if (placemark.name != null && placemark.name!.isNotEmpty) {
      addressParts.add(placemark.name!);
    }
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }
    
    return addressParts.join(', ');
  }

  /// Get current city
  Future<String?> getCurrentCity() async {
    try {
      final Position? position = await getCurrentLocation();
      if (position == null) return null;
      
      final Placemark? placemark = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      return placemark?.locality ?? placemark?.administrativeArea;
    } catch (e) {
      debugPrint('Error getting current city: $e');
      return null;
    }
  }

  /// Get current state/region
  Future<String?> getCurrentState() async {
    try {
      final Position? position = await getCurrentLocation();
      if (position == null) return null;
      
      final Placemark? placemark = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      return placemark?.administrativeArea;
    } catch (e) {
      debugPrint('Error getting current state: $e');
      return null;
    }
  }

  /// Get current country
  Future<String?> getCurrentCountry() async {
    try {
      final Position? position = await getCurrentLocation();
      if (position == null) return null;
      
      final Placemark? placemark = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      return placemark?.country;
    } catch (e) {
      debugPrint('Error getting current country: $e');
      return null;
    }
  }

  /// Check if location is within a specific radius
  bool isLocationWithinRadius(
    double centerLatitude,
    double centerLongitude,
    double targetLatitude,
    double targetLongitude,
    double radiusInMeters,
  ) {
    double distance = calculateDistance(
      centerLatitude,
      centerLongitude,
      targetLatitude,
      targetLongitude,
    );
    return distance <= radiusInMeters;
  }

  /// Get location accuracy description
  String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest (3000m)';
      case LocationAccuracy.low:
        return 'Low (1000m)';
      case LocationAccuracy.medium:
        return 'Medium (100m)';
      case LocationAccuracy.high:
        return 'High (10m)';
      case LocationAccuracy.best:
        return 'Best (3m)';
      case LocationAccuracy.bestForNavigation:
        return 'Best for Navigation';
      default:
        return 'Unknown';
    }
  }

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
  }
}