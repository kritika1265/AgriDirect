// lib/models/weather_model.dart
class WeatherModel {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final double pressure;
  final double visibility;
  final int uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;
  final DateTime lastUpdated;
  final DateTime timestamp; // For compatibility with existing screen
  final double rainfall; // For agricultural insights

  const WeatherModel({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.lastUpdated,
    DateTime? timestamp,
    this.rainfall = 0.0,
  }) : timestamp = timestamp ?? lastUpdated;

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      location: map['location']?.toString() ?? '',
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (map['feelsLike'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      icon: map['icon']?.toString() ?? '',
      humidity: (map['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (map['windSpeed'] as num?)?.toDouble() ?? 0.0,
      windDirection: map['windDirection']?.toString() ?? '',
      pressure: (map['pressure'] as num?)?.toDouble() ?? 0.0,
      visibility: (map['visibility'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (map['uvIndex'] as num?)?.toInt() ?? 0,
      sunrise: DateTime.tryParse(map['sunrise']?.toString() ?? '') ?? DateTime.now(),
      sunset: DateTime.tryParse(map['sunset']?.toString() ?? '') ?? DateTime.now(),
      hourlyForecast: (map['hourlyForecast'] as List<dynamic>?)
          ?.map((e) => HourlyWeather.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      dailyForecast: (map['dailyForecast'] as List<dynamic>?)
          ?.map((e) => DailyWeather.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      lastUpdated: DateTime.tryParse(map['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? ''),
      rainfall: (map['rainfall'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Legacy fromJson method for backward compatibility
  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'condition': condition,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'pressure': pressure,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'hourlyForecast': hourlyForecast.map((e) => e.toMap()).toList(),
      'dailyForecast': dailyForecast.map((e) => e.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'rainfall': rainfall,
    };
  }

  // Legacy toJson method for backward compatibility
  Map<String, dynamic> toJson() => toMap();

  WeatherModel copyWith({
    String? location,
    double? temperature,
    double? feelsLike,
    String? condition,
    String? description,
    String? icon,
    int? humidity,
    double? windSpeed,
    String? windDirection,
    double? pressure,
    double? visibility,
    int? uvIndex,
    DateTime? sunrise,
    DateTime? sunset,
    List<HourlyWeather>? hourlyForecast,
    List<DailyWeather>? dailyForecast,
    DateTime? lastUpdated,
    DateTime? timestamp,
    double? rainfall,
  }) {
    return WeatherModel(
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      timestamp: timestamp ?? this.timestamp,
      rainfall: rainfall ?? this.rainfall,
    );
  }

  @override
  String toString() {
    return 'WeatherModel(location: $location, temperature: $temperature°C, condition: $condition)';
  }
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double rainChance;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
  });

  factory HourlyWeather.fromMap(Map<String, dynamic> map) {
    return HourlyWeather(
      time: DateTime.tryParse(map['time']?.toString() ?? '') ?? DateTime.now(),
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition']?.toString() ?? '',
      icon: map['icon']?.toString() ?? '',
      humidity: (map['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (map['windSpeed'] as num?)?.toDouble() ?? 0.0,
      rainChance: (map['rainChance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rainChance': rainChance,
    };
  }
}

class DailyWeather {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String condition;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double rainChance;
  final DateTime sunrise;
  final DateTime sunset;

  const DailyWeather({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.condition,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.sunrise,
    required this.sunset,
  });

  factory DailyWeather.fromMap(Map<String, dynamic> map) {
    return DailyWeather(
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      maxTemperature: (map['maxTemperature'] as num?)?.toDouble() ?? 0.0,
      minTemperature: (map['minTemperature'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      icon: map['icon']?.toString() ?? '',
      humidity: (map['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (map['windSpeed'] as num?)?.toDouble() ?? 0.0,
      rainChance: (map['rainChance'] as num?)?.toDouble() ?? 0.0,
      sunrise: DateTime.tryParse(map['sunrise']?.toString() ?? '') ?? DateTime.now(),
      sunset: DateTime.tryParse(map['sunset']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'condition': condition,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rainChance': rainChance,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
    };
  }
}

class WeatherAlert {
  final String id;
  final String title;
  final String description;
  final String severity; // 'low', 'medium', 'high', 'extreme'
  final DateTime startTime;
  final DateTime endTime;
  final List<String> areas;
  final String type; // 'rain', 'storm', 'heat', 'cold', 'wind', etc.

  const WeatherAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.startTime,
    required this.endTime,
    required this.areas,
    required this.type,
  });

  factory WeatherAlert.fromMap(Map<String, dynamic> map) {
    return WeatherAlert(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      severity: map['severity']?.toString() ?? 'low',
      startTime: DateTime.tryParse(map['startTime']?.toString() ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime']?.toString() ?? '') ?? DateTime.now(),
      areas: List<String>.from((map['areas'] as List<dynamic>?) ?? []),
      type: map['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'areas': areas,
      'type': type,
    };
  }
}