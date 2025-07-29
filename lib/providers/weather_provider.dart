import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

enum WeatherStatus {
  initial,
  loading,
  loaded,
  error,
}

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _currentWeather;
  List<WeatherAlert> _alerts = [];
  String? _errorMessage;
  bool _isLoading = false;
  DateTime? _lastUpdated;

  // Getters
  WeatherStatus get status => _status;
  WeatherModel? get currentWeather => _currentWeather;
  List<WeatherAlert> get alerts => _alerts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasData => _currentWeather != null;

  // Check if data needs refresh (older than 30 minutes)
  bool get needsRefresh {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > 30;
  }

  Future<void> fetchWeatherData({bool forceRefresh = false}) async {
    if (_isLoading) return;
    
    // Don't fetch if we have recent data and not forcing refresh
    if (!forceRefresh && !needsRefresh && _currentWeather != null) {
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      // Get current location
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        throw Exception('Unable to get current location');
      }

      // Fetch weather data
      final weatherData = await _weatherService.getCurrentWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      if (weatherData != null) {
        _currentWeather = weatherData;
        _lastUpdated = DateTime.now();
        _status = WeatherStatus.loaded;
      } else {
        throw Exception('Failed to fetch weather data');
      }

      // Fetch weather alerts
      await _fetchWeatherAlerts(location.latitude, location.longitude);

    } catch (e) {
      _setError('Failed to fetch weather data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
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
    }
  }

  Future<void> refreshWeatherData() async {
    await fetchWeatherData(forceRefresh: true);
  }

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

  Future<List<WeatherModel>> getWeatherForecast({
    required double latitude,
    required double longitude,
    int days = 7,
  }) async {
    try {
      return await _weatherService.getWeatherForecast(
        latitude: latitude,
        longitude: longitude,
        days: days,
      );
    } catch (e) {
      debugPrint('Failed to get weather forecast: $e');
      return [];
    }
  }

  // Weather condition helpers
  bool get isRainy {
    if (_currentWeather == null) return false;
    return _currentWeather!.condition.toLowerCase().contains('rain') ||
           _currentWeather!.condition.toLowerCase().contains('drizzle');
  }

  bool get isSunny {
    if (_currentWeather == null) return false;
    return _currentWeather!.condition.toLowerCase().contains('clear') ||
           _currentWeather!.condition.toLowerCase().contains('sunny');
  }

  bool get isCloudy {
    if (_currentWeather == null) return false;
    return _currentWeather!.condition.toLowerCase().contains('cloud') ||
           _currentWeather!.condition.toLowerCase().contains('overcast');
  }

  bool get isStormy {
    if (_currentWeather == null) return false;
    return _currentWeather!.condition.toLowerCase().contains('storm') ||
           _currentWeather!.condition.toLowerCase().contains('thunder');
  }

  // Weather advisory for farming
  String get farmingAdvice {
    if (_currentWeather == null) return 'Weather data not available';

    final temp = _currentWeather!.temperature;
    final humidity = _currentWeather!.humidity;
    final windSpeed = _currentWeather!.windSpeed;

    List<String> advice = [];

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

  // Get weather icon based on condition
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

  // Check for severe weather alerts
  bool get hasSevereAlerts {
    return _alerts.any((alert) => 
        alert.severity == 'high' || alert.severity == 'extreme');
  }

  List<WeatherAlert> get severeAlerts {
    return _alerts.where((alert) => 
        alert.severity == 'high' || alert.severity == 'extreme').toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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