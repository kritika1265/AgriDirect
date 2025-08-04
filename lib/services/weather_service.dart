import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/weather_model.dart';

/// Service class for handling weather-related API calls and agricultural insights
class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _oneCallUrl = 'https://api.openweathermap.org/data/3.0/onecall';
  static final String _apiKey = ApiConfig.weatherApiKey;

  /// Get current weather by coordinates
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Validate inputs
      if (latitude < -90 || latitude > 90) {
        throw ArgumentError('Invalid latitude: $latitude. Must be between -90 and 90.');
      }
      if (longitude < -180 || longitude > 180) {
        throw ArgumentError('Invalid longitude: $longitude. Must be between -180 and 180.');
      }

      // Get current weather
      final currentResponse = await http.get(
        Uri.parse('$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric'),
        headers: {'Accept': 'application/json'},
      );

      if (currentResponse.statusCode != 200) {
        throw Exception('Failed to load current weather: ${currentResponse.statusCode} - ${currentResponse.body}');
      }

      Map<String, dynamic> currentData;
      try {
        currentData = json.decode(currentResponse.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid JSON response from weather API: $e');
      }

      // Check if the response contains error
      if (currentData.containsKey('cod') && currentData['cod'] != 200) {
        throw Exception('Weather API error: ${currentData['message'] ?? 'Unknown error'}');
      }

      // Get forecast data (for hourly and daily)
      final forecastResponse = await http.get(
        Uri.parse('$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric'),
        headers: {'Accept': 'application/json'},
      );

      if (forecastResponse.statusCode != 200) {
        // If forecast fails, create weather model with current data only
        debugPrint('Forecast request failed: ${forecastResponse.statusCode}');
        return _parseWeatherDataCurrentOnly(currentData);
      }

      Map<String, dynamic> forecastData;
      try {
        forecastData = json.decode(forecastResponse.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Invalid forecast JSON, using current data only: $e');
        return _parseWeatherDataCurrentOnly(currentData);
      }

      return _parseWeatherData(currentData, forecastData);

    } catch (e) {
      throw Exception('Error fetching weather: ${e.toString()}');
    }
  }

  /// Get current weather by city name
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      // Validate input
      if (cityName.trim().isEmpty) {
        throw ArgumentError('City name cannot be empty');
      }

      // Get current weather
      final currentResponse = await http.get(
        Uri.parse('$_baseUrl/weather?q=${Uri.encodeComponent(cityName.trim())}&appid=$_apiKey&units=metric'),
        headers: {'Accept': 'application/json'},
      );

      if (currentResponse.statusCode != 200) {
        throw Exception('Failed to load weather for city: ${currentResponse.statusCode} - ${currentResponse.body}');
      }

      Map<String, dynamic> currentData;
      try {
        currentData = json.decode(currentResponse.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid JSON response from weather API: $e');
      }

      // Check if the response contains error
      if (currentData.containsKey('cod') && currentData['cod'] != 200) {
        throw Exception('Weather API error: ${currentData['message'] ?? 'City not found'}');
      }
      
      final coord = currentData['coord'] as Map<String, dynamic>?;
      if (coord == null) {
        throw Exception('No coordinates found in weather response');
      }

      final lat = (coord['lat'] as num?)?.toDouble();
      final lon = (coord['lon'] as num?)?.toDouble();
      
      if (lat == null || lon == null) {
        throw Exception('Invalid coordinates in weather response');
      }
      
      // Get forecast data
      final forecastResponse = await http.get(
        Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
        headers: {'Accept': 'application/json'},
      );

      if (forecastResponse.statusCode != 200) {
        return _parseWeatherDataCurrentOnly(currentData);
      }

      Map<String, dynamic> forecastData;
      try {
        forecastData = json.decode(forecastResponse.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Invalid forecast JSON, using current data only: $e');
        return _parseWeatherDataCurrentOnly(currentData);
      }

      return _parseWeatherData(currentData, forecastData);

    } catch (e) {
      throw Exception('Error fetching weather by city: ${e.toString()}');
    }
  }

  /// Parse weather data from current weather only (fallback)
  WeatherModel _parseWeatherDataCurrentOnly(Map<String, dynamic> currentData) {
    try {
      // Safely extract main weather data
      final main = currentData['main'] as Map<String, dynamic>?;
      final weather = currentData['weather'] as List<dynamic>?;
      final wind = currentData['wind'] as Map<String, dynamic>?;
      final sys = currentData['sys'] as Map<String, dynamic>?;

      if (main == null || weather == null || weather.isEmpty) {
        throw Exception('Invalid weather data structure');
      }

      final weatherData = weather.first as Map<String, dynamic>;

      return WeatherModel(
        location: currentData['name']?.toString() ?? 'Unknown',
        temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
        feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
        condition: weatherData['main']?.toString() ?? 'Unknown',
        description: weatherData['description']?.toString() ?? 'No description',
        icon: weatherData['icon']?.toString() ?? '01d',
        humidity: (main['humidity'] as num?)?.toInt() ?? 0,
        windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
        windDirection: _getWindDirection((wind?['deg'] as num?)?.toDouble() ?? 0.0),
        pressure: (main['pressure'] as num?)?.toDouble() ?? 0.0,
        visibility: (currentData['visibility'] as num?)?.toDouble() ?? 0.0,
        uvIndex: 0, // UV Index not available in free tier
        sunrise: _parseDateTime(sys?['sunrise']),
        sunset: _parseDateTime(sys?['sunset']),
        hourlyForecast: [], // Empty if no forecast data
        dailyForecast: [], // Empty if no forecast data
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error parsing current weather data: $e');
    }
  }

  /// Safely parse DateTime from timestamp
  DateTime _parseDateTime(dynamic timestamp) {
    try {
      if (timestamp == null) {
        return DateTime.now();
      }
      final ts = timestamp is int ? timestamp : int.tryParse(timestamp.toString());
      if (ts == null) {
        return DateTime.now();
      }
      return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
      return DateTime.now();
    }
  }

  /// Parse weather data from API responses
  WeatherModel _parseWeatherData(Map<String, dynamic> currentData, Map<String, dynamic> forecastData) {
    try {
      // Parse hourly forecast (next 24 hours from 5-day forecast)
      final forecastList = forecastData['list'] as List<dynamic>? ?? [];
      final hourlyForecast = _parseHourlyForecast(forecastList);

      // Parse daily forecast (group by day)
      final dailyForecast = _parseDailyForecast(forecastList);

      // Safely extract current weather data
      final main = currentData['main'] as Map<String, dynamic>?;
      final weather = currentData['weather'] as List<dynamic>?;
      final wind = currentData['wind'] as Map<String, dynamic>?;
      final sys = currentData['sys'] as Map<String, dynamic>?;

      if (main == null || weather == null || weather.isEmpty) {
        throw Exception('Invalid current weather data structure');
      }

      final weatherData = weather.first as Map<String, dynamic>;

      return WeatherModel(
        location: currentData['name']?.toString() ?? 'Unknown',
        temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
        feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
        condition: weatherData['main']?.toString() ?? 'Unknown',
        description: weatherData['description']?.toString() ?? 'No description',
        icon: weatherData['icon']?.toString() ?? '01d',
        humidity: (main['humidity'] as num?)?.toInt() ?? 0,
        windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
        windDirection: _getWindDirection((wind?['deg'] as num?)?.toDouble() ?? 0.0),
        pressure: (main['pressure'] as num?)?.toDouble() ?? 0.0,
        visibility: (currentData['visibility'] as num?)?.toDouble() ?? 0.0,
        uvIndex: 0, // UV Index not available in free tier
        sunrise: _parseDateTime(sys?['sunrise']),
        sunset: _parseDateTime(sys?['sunset']),
        hourlyForecast: hourlyForecast,
        dailyForecast: dailyForecast,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // Fallback to current data only if parsing fails
      debugPrint('Error parsing forecast data: $e');
      return _parseWeatherDataCurrentOnly(currentData);
    }
  }

  /// Parse hourly forecast from forecast list
  List<HourlyWeather> _parseHourlyForecast(List<dynamic> forecastList) {
    try {
      return forecastList.take(8).map((item) {
        final itemData = item as Map<String, dynamic>?;
        if (itemData == null) {
          return null;
        }

        final main = itemData['main'] as Map<String, dynamic>?;
        final weather = itemData['weather'] as List<dynamic>?;
        final wind = itemData['wind'] as Map<String, dynamic>?;

        if (main == null || weather == null || weather.isEmpty) {
          return null;
        }

        final weatherData = weather.first as Map<String, dynamic>;

        return HourlyWeather(
          time: _parseDateTime(itemData['dt']),
          temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
          condition: weatherData['main']?.toString() ?? 'Unknown',
          icon: weatherData['icon']?.toString() ?? '01d',
          humidity: (main['humidity'] as num?)?.toInt() ?? 0,
          windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
          rainChance: (itemData['pop'] as num?)?.toDouble() ?? 0.0,
        );
      }).where((weather) => weather != null).cast<HourlyWeather>().toList();
    } catch (e) {
      debugPrint('Error parsing hourly forecast: $e');
      return [];
    }
  }

  /// Parse daily forecast from forecast list
  List<DailyWeather> _parseDailyForecast(List<dynamic> forecastList) {
    if (forecastList.isEmpty) {
      return [];
    }

    try {
      final dailyData = <String, List<Map<String, dynamic>>>{};
      
      // Group forecast items by date
      for (final item in forecastList) {
        final itemData = item as Map<String, dynamic>?;
        if (itemData == null) {
          continue;
        }

        final dateTime = _parseDateTime(itemData['dt']);
        final dateKey = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
        
        dailyData.putIfAbsent(dateKey, () => []);
        dailyData[dateKey]!.add(itemData);
      }

      // Convert to DailyWeather objects
      return dailyData.entries.map((entry) {
        final dayData = entry.value;
        if (dayData.isEmpty) {
          return null;
        }
        
        final firstItem = dayData.first;
        final weather = firstItem['weather'] as List<dynamic>?;
        if (weather == null || weather.isEmpty) {
          return null;
        }

        final weatherData = weather.first as Map<String, dynamic>;
        
        // Calculate min/max temperatures for the day
        double minTemp = double.infinity;
        double maxTemp = double.negativeInfinity;
        double totalHumidity = 0;
        double totalWindSpeed = 0;
        double maxRainChance = 0;
        int validItems = 0;
        
        for (final item in dayData) {
        final main = item['main'] as Map<String, dynamic>?;
        final wind = item['wind'] as Map<String, dynamic>?;
        
        if (main != null) {
          final temp = (main['temp'] as num?)?.toDouble();
          if (temp != null) {
            minTemp = minTemp > temp ? temp : minTemp;
            maxTemp = maxTemp < temp ? temp : maxTemp;
            totalHumidity += (main['humidity'] as num?)?.toInt() ?? 0;
            validItems++;
          }
        }
        
        if (wind != null) {
          totalWindSpeed += (wind['speed'] as num?)?.toDouble() ?? 0.0;
        }
        
        final rainChance = (item['pop'] as num?)?.toDouble() ?? 0.0;
        maxRainChance = maxRainChance < rainChance ? rainChance : maxRainChance;
        }

        // Handle case where no valid temperature data was found
        if (minTemp == double.infinity) {
          minTemp = 0.0;
        }
        if (maxTemp == double.negativeInfinity) {
          maxTemp = 0.0;
        }

        return DailyWeather(
          date: _parseDateTime(firstItem['dt']),
          maxTemperature: maxTemp,
          minTemperature: minTemp,
          condition: weatherData['main']?.toString() ?? 'Unknown',
          description: weatherData['description']?.toString() ?? 'No description',
          icon: weatherData['icon']?.toString() ?? '01d',
          humidity: validItems > 0 ? (totalHumidity / validItems).round() : 0,
          windSpeed: dayData.isNotEmpty ? totalWindSpeed / dayData.length : 0.0,
          rainChance: maxRainChance,
          sunrise: _parseDateTime(firstItem['dt']), // Approximate
          sunset: _parseDateTime(firstItem['dt']), // Approximate
        );
      }).where((weather) => weather != null).cast<DailyWeather>().toList();
    } catch (e) {
      debugPrint('Error parsing daily forecast: $e');
      return [];
    }
  }

  /// Convert wind degree to direction
  String _getWindDirection(double degree) {
    try {
      const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 
                         'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
      final index = ((degree + 11.25) / 22.5).floor() % 16;
      return directions[index.clamp(0, 15)];
    } catch (e) {
      debugPrint('Error calculating wind direction: $e');
      return 'N';
    }
  }

  /// Get weather alerts
  Future<List<WeatherAlert>> getWeatherAlerts({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Validate inputs
      if (latitude < -90 || latitude > 90) {
        throw ArgumentError('Invalid latitude: $latitude');
      }
      if (longitude < -180 || longitude > 180) {
        throw ArgumentError('Invalid longitude: $longitude');
      }

      final response = await http.get(
        Uri.parse('$_oneCallUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&exclude=minutely,hourly'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        debugPrint('Weather alerts request failed: ${response.statusCode}');
        return [];
      }

      Map<String, dynamic> data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Invalid JSON in alerts response: $e');
        return [];
      }

      final alerts = data['alerts'] as List<dynamic>?;
      
      if (alerts != null && alerts.isNotEmpty) {
        return alerts.map((alert) {
          final alertData = alert as Map<String, dynamic>?;
          if (alertData == null) {
            return null;
          }

          return WeatherAlert(
            id: alertData['event']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title: alertData['event']?.toString() ?? 'Weather Alert',
            description: alertData['description']?.toString() ?? 'No description available',
            severity: _mapSeverity(alertData['tags'] as List<dynamic>?),
            startTime: _parseDateTime(alertData['start']),
            endTime: _parseDateTime(alertData['end']),
            areas: [alertData['sender_name']?.toString() ?? 'Unknown'],
            type: _getAlertType(alertData['event']?.toString() ?? ''),
          );
        }).where((alert) => alert != null).cast<WeatherAlert>().toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching weather alerts: $e');
      return [];
    }
  }

  /// Map alert tags to severity levels
  String _mapSeverity(List<dynamic>? tags) {
    if (tags == null || tags.isEmpty) {
      return 'low';
    }
    
    try {
      final tagString = tags.first.toString().toLowerCase();
      if (tagString.contains('extreme')) {
        return 'extreme';
      }
      if (tagString.contains('severe') || tagString.contains('major')) {
        return 'high';
      }
      if (tagString.contains('moderate')) {
        return 'medium';
      }
      return 'low';
    } catch (e) {
      debugPrint('Error mapping severity: $e');
      return 'low';
    }
  }

  /// Determine alert type from event name
  String _getAlertType(String event) {
    try {
      final eventLower = event.toLowerCase();
      if (eventLower.contains('rain') || eventLower.contains('flood')) {
        return 'rain';
      }
      if (eventLower.contains('storm') || eventLower.contains('thunder')) {
        return 'storm';
      }
      if (eventLower.contains('heat')) {
        return 'heat';
      }
      if (eventLower.contains('cold') || eventLower.contains('freeze')) {
        return 'cold';
      }
      if (eventLower.contains('wind')) {
        return 'wind';
      }
      return 'general';
    } catch (e) {
      debugPrint('Error determining alert type: $e');
      return 'general';
    }
  }

  /// Get agricultural weather insights
  Future<Map<String, dynamic>> getAgriculturalInsights({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final weather = await getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );

      final insights = <String, dynamic>{
        'irrigation_recommendation': _getIrrigationRecommendation(weather),
        'farming_conditions': _getFarmingConditions(weather),
        'crop_stress_level': _getCropStressLevel(weather),
        'disease_risk': _getDiseaseRisk(weather),
        'optimal_activities': _getOptimalActivities(weather),
      };

      return insights;
    } catch (e) {
      throw Exception('Error generating agricultural insights: ${e.toString()}');
    }
  }

  String _getIrrigationRecommendation(WeatherModel weather) {
    try {
      if (weather.humidity < 40 && weather.temperature > 30) {
        return 'High irrigation needed';
      } else if (weather.humidity < 60 && weather.temperature > 25) {
        return 'Moderate irrigation needed';
      } else {
        return 'Low irrigation needed';
      }
    } catch (e) {
      debugPrint('Error getting irrigation recommendation: $e');
      return 'Unable to determine';
    }
  }

  String _getFarmingConditions(WeatherModel weather) {
    try {
      if (weather.temperature >= 20 && weather.temperature <= 30 && weather.humidity >= 50) {
        return 'Excellent';
      } else if (weather.temperature >= 15 && weather.temperature <= 35) {
        return 'Good';
      } else {
        return 'Poor';
      }
    } catch (e) {
      debugPrint('Error getting farming conditions: $e');
      return 'Unable to determine';
    }
  }

  String _getCropStressLevel(WeatherModel weather) {
    try {
      if (weather.temperature > 35 || weather.temperature < 10) {
        return 'High';
      } else if (weather.temperature > 30 || weather.temperature < 15) {
        return 'Medium';
      } else {
        return 'Low';
      }
    } catch (e) {
      debugPrint('Error getting crop stress level: $e');
      return 'Unable to determine';
    }
  }

  String _getDiseaseRisk(WeatherModel weather) {
    try {
      if (weather.humidity > 80 && weather.temperature > 25) {
        return 'High';
      } else if (weather.humidity > 60) {
        return 'Medium';
      } else {
        return 'Low';
      }
    } catch (e) {
      debugPrint('Error getting disease risk: $e');
      return 'Unable to determine';
    }
  }

  List<String> _getOptimalActivities(WeatherModel weather) {
    try {
      final activities = <String>[];
      
      if (weather.condition.toLowerCase().contains('clear')) {
        activities.addAll(['Harvesting', 'Planting', 'Spraying']);
      } else if (weather.condition.toLowerCase().contains('rain')) {
        activities.addAll(['Indoor planning', 'Equipment maintenance']);
      } else {
        activities.addAll(['Light farming activities', 'Monitoring']);
      }
      
      return activities;
    } catch (e) {
      debugPrint('Error getting optimal activities: $e');
      return ['Unable to determine activities'];
    }
  }

  /// Get UV Index recommendations
  Future<Map<String, String>> getUVRecommendations({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final weather = await getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );

      final recommendations = <String, String>{};
      
      if (weather.uvIndex <= 2) {
        recommendations['level'] = 'Low';
        recommendations['recommendation'] = 'Safe for outdoor farming activities';
        recommendations['protection'] = 'Minimal protection needed';
      } else if (weather.uvIndex <= 5) {
        recommendations['level'] = 'Moderate';
        recommendations['recommendation'] = 'Good conditions for farming';
        recommendations['protection'] = 'Wear hat and light clothing';
      } else if (weather.uvIndex <= 7) {
        recommendations['level'] = 'High';
        recommendations['recommendation'] = 'Take breaks in shade';
        recommendations['protection'] = 'Wear hat, sunglasses, and protective clothing';
      } else if (weather.uvIndex <= 10) {
        recommendations['level'] = 'Very High';
        recommendations['recommendation'] = 'Limit outdoor activities to early morning/evening';
        recommendations['protection'] = 'Full protection required';
      } else {
        recommendations['level'] = 'Extreme';
        recommendations['recommendation'] = 'Avoid outdoor activities during midday';
        recommendations['protection'] = 'Maximum protection required';
      }

      return recommendations;
    } catch (e) {
      throw Exception('Error getting UV recommendations: ${e.toString()}');
    }
  }

  /// Check if weather is suitable for specific farming activity
  bool isSuitableForActivity(WeatherModel weather, String activity) {
    try {
      switch (activity.toLowerCase()) {
        case 'planting':
          return weather.temperature >= 15 && 
                 weather.temperature <= 35 && 
                 !weather.condition.toLowerCase().contains('rain') &&
                 weather.windSpeed < 10;
        
        case 'harvesting':
          return !weather.condition.toLowerCase().contains('rain') &&
                 weather.windSpeed < 15 &&
                 weather.humidity < 80;
        
        case 'spraying':
          return weather.windSpeed < 5 &&
                 !weather.condition.toLowerCase().contains('rain') &&
                 weather.temperature < 30;
        
        case 'irrigation':
          return weather.humidity < 60 &&
                 weather.temperature > 20 &&
                 !weather.condition.toLowerCase().contains('rain');
        
        default:
          return true;
      }
    } catch (e) {
      debugPrint('Error checking activity suitability: $e');
      return false;
    }
  }
}