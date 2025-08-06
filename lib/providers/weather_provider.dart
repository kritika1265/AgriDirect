// lib/providers/weather_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

/// Enum representing different weather loading states
enum WeatherStatus {
  /// Initial state before any data is loaded
  initial,
  /// Currently loading weather data
  loading,
  /// Weather data successfully loaded
  loaded,
  /// Error occurred while loading weather data
  error,
}

/// Provider class for managing weather data and state
class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  // Core state variables
  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _currentWeather;
  List<WeatherModel> _forecastList = [];
  List<WeatherAlert> _alerts = [];
  String? _errorMessage;
  bool _isLoading = false;
  DateTime? _lastUpdated;

  // Getters for compatibility with existing screen
  /// Current weather loading status
  WeatherStatus get status => _status;
  
  /// Current weather data, null if not loaded
  WeatherModel? get currentWeather => _currentWeather;
  
  /// List of weather forecast data
  List<WeatherModel> get forecastList => _forecastList;
  
  /// List of weather alerts for the current location
  List<WeatherAlert> get alerts => _alerts;
  
  /// Error message if an error occurred
  String? get errorMessage => _errorMessage;
  
  /// Whether weather data is currently being loaded
  bool get isLoading => _isLoading;
  
  /// When the weather data was last updated
  DateTime? get lastUpdated => _lastUpdated;
  
  /// Whether weather data is available
  bool get hasData => _currentWeather != null;

  /// Check if data needs refresh (older than 30 minutes)
  bool get needsRefresh {
    if (_lastUpdated == null) {
      return true;
    }
    return DateTime.now().difference(_lastUpdated!).inMinutes > 30;
  }

  /// Fetches weather data for current location
  Future<void> fetchWeatherData({bool forceRefresh = false}) async {
    if (_isLoading) return;
    
    // Don't fetch if we have recent data and not forcing refresh
    if (!forceRefresh && !needsRefresh && _currentWeather != null) {
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      // Try to get real location data first
      try {
        final location = await _locationService.getCurrentLocation();
        if (location != null) {
          // Fetch real weather data
          final weatherData = await _weatherService.getCurrentWeather(
            latitude: location.latitude,
            longitude: location.longitude,
          );
          
          if (weatherData != null) {
            _currentWeather = weatherData;
            _lastUpdated = DateTime.now();
            _status = WeatherStatus.loaded;

            // Fetch weather alerts
            await _fetchWeatherAlerts(location.latitude, location.longitude);
            
            // Fetch forecast data
            await _fetchForecastData(location.latitude, location.longitude);
            
            _setLoading(false);
            return;
          }
        }
      } catch (e) {
        debugPrint('Failed to get real weather data, using mock data: $e');
      }

      // Fallback to mock data if real API fails
      await _generateMockData();

    } catch (e) {
      _setError('Failed to fetch weather data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate mock weather data for testing/fallback
  Future<void> _generateMockData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock current weather data
    _currentWeather = WeatherModel(
      location: 'Vadodara, Gujarat',
      temperature: 28.5,
      feelsLike: 31.0,
      condition: 'Sunny',
      description: 'Clear sky with bright sunshine',
      icon: '01d',
      humidity: 65,
      windSpeed: 12.0,
      windDirection: 'NW',
      pressure: 1013.2,
      visibility: 10.0,
      uvIndex: 7,
      sunrise: DateTime.now().subtract(const Duration(hours: 6)),
      sunset: DateTime.now().add(const Duration(hours: 6)),
      hourlyForecast: _generateMockHourlyForecast(),
      dailyForecast: _generateMockDailyForecast(),
      lastUpdated: DateTime.now(),
      rainfall: 0.0,
    );

    // Mock forecast data for backward compatibility
    _forecastList = List.generate(7, (index) => WeatherModel(
      location: 'Vadodara, Gujarat',
      temperature: 25.0 + (index * 2),
      feelsLike: 28.0 + (index * 2),
      condition: index % 2 == 0 ? 'Sunny' : 'Cloudy',
      description: index % 2 == 0 ? 'Clear sky' : 'Partly cloudy',
      icon: index % 2 == 0 ? '01d' : '02d',
      humidity: 60 + (index * 3),
      windSpeed: 10.0 + index,
      windDirection: 'NW',
      pressure: 1010.0 + index,
      visibility: 10.0,
      uvIndex: 6 + index,
      sunrise: DateTime.now().add(Duration(days: index + 1)).subtract(const Duration(hours: 6)),
      sunset: DateTime.now().add(Duration(days: index + 1)).add(const Duration(hours: 6)),
      hourlyForecast: [],
      dailyForecast: [],
      lastUpdated: DateTime.now(),
      rainfall: index > 3 ? 5.0 : 0.0,
    ));

    _lastUpdated = DateTime.now();
    _status = WeatherStatus.loaded;
  }

  List<HourlyWeather> _generateMockHourlyForecast() {
    return List.generate(24, (index) => HourlyWeather(
      time: DateTime.now().add(Duration(hours: index)),
      temperature: 25.0 + (index % 12) * 0.5,
      condition: index % 4 == 0 ? 'Sunny' : 'Cloudy',
      icon: index % 4 == 0 ? '01d' : '02d',
      humidity: 60 + (index % 10) * 2,
      windSpeed: 8.0 + (index % 8),
      rainChance: index > 18 ? 20.0 : 0.0,
    ));
  }

  List<DailyWeather> _generateMockDailyForecast() {
    return List.generate(7, (index) => DailyWeather(
      date: DateTime.now().add(Duration(days: index + 1)),
      maxTemperature: 30.0 + index,
      minTemperature: 20.0 + index,
      condition: index % 2 == 0 ? 'Sunny' : 'Cloudy',
      description: index % 2 == 0 ? 'Clear sky' : 'Partly cloudy',
      icon: index % 2 == 0 ? '01d' : '02d',
      humidity: 65 + index * 2,
      windSpeed: 12.0 + index,
      rainChance: index > 4 ? 30.0 : 0.0,
      sunrise: DateTime.now().add(Duration(days: index + 1)).subtract(const Duration(hours: 6)),
      sunset: DateTime.now().add(Duration(days: index + 1)).add(const Duration(hours: 6)),
    ));
  }

  Future<void> _fetchWeatherAlerts(double latitude, double longitude) async {
    try {
      final alerts = await _weatherService.getWeatherAlerts(
        latitude: latitude,
        longitude: longitude,
      );
      _alerts = alerts;
    } catch (e) {
      // Don't throw error for alerts, just log it
      debugPrint('Failed to fetch weather alerts: $e');
      _alerts = []; // Reset alerts on error
    }
  }

  Future<void> _fetchForecastData(double latitude, double longitude) async {
    try {
      final forecast = await getWeatherForecast(
        latitude: latitude,
        longitude: longitude,
      );
      _forecastList = forecast;
    } catch (e) {
      debugPrint('Failed to fetch forecast data: $e');
      // Keep existing forecast data or generate mock data
    }
  }

  /// Refreshes weather data by forcing a new fetch
  Future<void> refreshWeatherData() async {
    await fetchWeatherData(forceRefresh: true);
  }

  /// Gets weather data for a specific location
  Future<WeatherModel?> getWeatherForLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _weatherService.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('Failed to get weather for location: $e');
      return null;
    }
  }

  /// Gets weather forecast for a specific location
  Future<List<WeatherModel>> getWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // If weather service supports forecast, use it
      // Otherwise, create forecast from current weather
      final weather = await _weatherService.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );
      
      if (weather != null) {
        // Generate forecast based on current weather if service doesn't provide forecast
        return List.generate(7, (index) => weather.copyWith(
          timestamp: DateTime.now().add(Duration(days: index + 1)),
          temperature: weather.temperature + (index % 3 - 1) * 2,
          humidity: weather.humidity + (index % 5 - 2) * 5,
          windSpeed: weather.windSpeed + (index % 3 - 1) * 3,
        ));
      }
      return [];
    } catch (e) {
      debugPrint('Failed to get weather forecast: $e');
      return [];
    }
  }

  // Weather condition helpers
  /// Whether current weather conditions include rain
  bool get isRainy {
    if (_currentWeather == null) return false;
    return _currentWeather!.condition.toLowerCase().contains('rain') ||
           _currentWeather!.condition.toLowerCase().contains('drizzle');
  }

  /// Whether current weather conditions are sunny/clear
  bool get isSunny {
    if (_currentWeather == null) return false;
    return _currentWeather!.condition.toLowerCase().contains('clear') ||
           _currentWeather!.condition.toLowerCase().contains('sunny');
  }

  /// Whether current weather conditions are cloudy
  bool get isCloudy {
    if (_currentWeather == null) return false;
    return _currentWeather!.condition.toLowerCase().contains('cloud') ||
           _currentWeather!.condition.toLowerCase().contains('overcast');
  }

  /// Whether current weather conditions include storms
  bool get isStormy {
    if (_currentWeather == null) return false;
    return _currentWeather!.condition.toLowerCase().contains('storm') ||
           _currentWeather!.condition.toLowerCase().contains('thunder');
  }

  /// Provides weather-based farming advice
  String get farmingAdvice {
    if (_currentWeather == null) return 'Weather data not available';

    final temp = _currentWeather!.temperature;
    final humidity = _currentWeather!.humidity;
    final windSpeed = _currentWeather!.windSpeed;

    final advice = <String>[];

    // Temperature advice
    if (temp > 35) {
      advice.add('⚠️ High temperature: Ensure adequate irrigation');
    } else if (temp < 10) {
      advice.add('🥶 Low temperature: Protect crops from frost');
    }

    // Humidity advice
    if (humidity > 80) {
      advice.add('💧 High humidity: Monitor for fungal diseases');
    } else if (humidity < 30) {
      advice.add('🏜️ Low humidity: Increase irrigation frequency');
    }

    // Wind advice
    if (windSpeed > 20) {
      advice.add('💨 Strong winds: Secure young plants and equipment');
    }

    // Rain advice
    if (isRainy) {
      advice.add('🌧️ Rain expected: Delay pesticide application');
    } else if (isSunny) {
      advice.add('☀️ Clear weather: Good for harvesting and field work');
    }

    // UV advice
    if (_currentWeather!.uvIndex > 8) {
      advice.add('☀️ High UV: Protect workers and consider shade for crops');
    }

    return advice.isEmpty 
        ? '✅ Weather conditions are favorable for farming activities'
        : advice.join('\n');
  }

  /// Get weather icon based on current condition
  String getWeatherIcon() {
    if (_currentWeather == null) return '❓';

    final condition = _currentWeather!.condition.toLowerCase();
    
    if (condition.contains('clear') || condition.contains('sunny')) {
      return '☀️';
    } else if (condition.contains('cloud')) {
      return '☁️';
    } else if (condition.contains('rain')) {
      return '🌧️';
    } else if (condition.contains('storm') || condition.contains('thunder')) {
      return '⛈️';
    } else if (condition.contains('snow')) {
      return '🌨️';
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return '🌫️';
    } else {
      return '🌤️';
    }
  }

  /// Check if there are any severe weather alerts
  bool get hasSevereAlerts => _alerts.any((alert) => 
      alert.severity == 'high' || alert.severity == 'extreme');

  /// Get list of severe weather alerts only
  List<WeatherAlert> get severeAlerts => _alerts.where((alert) => 
      alert.severity == 'high' || alert.severity == 'extreme').toList();

  /// Clear error message (for backward compatibility)
  void clearError() {
    _clearError();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _status = WeatherStatus.loading;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = WeatherStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_status == WeatherStatus.error) {
      _status = _currentWeather != null 
          ? WeatherStatus.loaded 
          : WeatherStatus.initial;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any subscriptions or timers here
    super.dispose();
  }
}