import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../config/api_config.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = ApiConfig.weatherApiKey;

  // Get current weather by coordinates
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: ${e.toString()}');
    }
  }

  // Get current weather by city name
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: ${e.toString()}');
    }
  }

  // Get 5-day weather forecast
  Future<List<WeatherForecast>> getWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        return forecastList
            .map((item) => WeatherForecast.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: ${e.toString()}');
    }
  }

  // Get weather alerts
  Future<List<WeatherAlert>> getWeatherAlerts({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/onecall?lat=$latitude&lon=$longitude&appid=$_apiKey&exclude=minutely,hourly'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? alerts = data['alerts'];
        
        if (alerts != null) {
          return alerts.map((alert) => WeatherAlert.fromJson(alert)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load weather alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather alerts: ${e.toString()}');
    }
  }

  // Get agricultural weather insights
  Future<Map<String, dynamic>> getAgriculturalInsights({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final weather = await getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );

      Map<String, dynamic> insights = {
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
    if (weather.humidity < 40 && weather.temperature > 30) {
      return 'High irrigation needed';
    } else if (weather.humidity < 60 && weather.temperature > 25) {
      return 'Moderate irrigation needed';
    } else {
      return 'Low irrigation needed';
    }
  }

  String _getFarmingConditions(WeatherModel weather) {
    if (weather.temperature >= 20 && weather.temperature <= 30 && weather.humidity >= 50) {
      return 'Excellent';
    } else if (weather.temperature >= 15 && weather.temperature <= 35) {
      return 'Good';
    } else {
      return 'Poor';
    }
  }

  String _getCropStressLevel(WeatherModel weather) {
    if (weather.temperature > 35 || weather.temperature < 10) {
      return 'High';
    } else if (weather.temperature > 30 || weather.temperature < 15) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  String _getDiseaseRisk(WeatherModel weather) {
    if (weather.humidity > 80 && weather.temperature > 25) {
      return 'High';
    } else if (weather.humidity > 60) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  List<String> _getOptimalActivities(WeatherModel weather) {
    List<String> activities = [];
    
    if (weather.weatherCondition.toLowerCase().contains('clear')) {
      activities.addAll(['Harvesting', 'Planting', 'Spraying']);
    } else if (weather.weatherCondition.toLowerCase().contains('rain')) {
      activities.addAll(['Indoor planning', 'Equipment maintenance']);
    } else {
      activities.addAll(['Light farming activities', 'Monitoring']);
    }
    
    return activities;
  }

  // Get UV Index recommendations
  Future<Map<String, String>> getUVRecommendations({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final weather = await getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );

      Map<String, String> recommendations = {};
      
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

  // Check if weather is suitable for specific farming activity
  bool isSuitableForActivity(WeatherModel weather, String activity) {
    switch (activity.toLowerCase()) {
      case 'planting':
        return weather.temperature >= 15 && 
               weather.temperature <= 35 && 
               !weather.weatherCondition.toLowerCase().contains('rain') &&
               weather.windSpeed < 10;
      
      case 'harvesting':
        return !weather.weatherCondition.toLowerCase().contains('rain') &&
               weather.windSpeed < 15 &&
               weather.humidity < 80;
      
      case 'spraying':
        return weather.windSpeed < 5 &&
               !weather.weatherCondition.toLowerCase().contains('rain') &&
               weather.temperature < 30;
      
      case 'irrigation':
        return weather.humidity < 60 &&
               weather.temperature > 20 &&
               !weather.weatherCondition.toLowerCase().contains('rain');
      
      default:
        return true;
    }
  }
}

class WeatherAlert {
  final String event;
  final String description;
  final DateTime start;
  final DateTime end;
  final String severity;

  WeatherAlert({
    required this.event,
    required this.description,
    required this.start,
    required this.end,
    required this.severity,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      event: json['event'] ?? '',
      description: json['description'] ?? '',
      start: DateTime.fromMillisecondsSinceEpoch(json['start'] * 1000),
      end: DateTime.fromMillisecondsSinceEpoch(json['end'] * 1000),
      severity: json['tags']?[0] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'description': description,
      'start': start.millisecondsSinceEpoch ~/ 1000,
      'end': end.millisecondsSinceEpoch ~/ 1000,
      'severity': severity,
    };
  }
}