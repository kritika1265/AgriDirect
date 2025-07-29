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
  });

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      location: map['location'] ?? '',
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      feelsLike: (map['feelsLike'] ?? 0.0).toDouble(),
      condition: map['condition'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      humidity: map['humidity'] ?? 0,
      windSpeed: (map['windSpeed'] ?? 0.0).toDouble(),
      windDirection: map['windDirection'] ?? '',
      pressure: (map['pressure'] ?? 0.0).toDouble(),
      visibility: (map['visibility'] ?? 0.0).toDouble(),
      uvIndex: map['uvIndex'] ?? 0,
      sunrise: DateTime.parse(map['sunrise']),
      sunset: DateTime.parse(map['sunset']),
      hourlyForecast: (map['hourlyForecast'] as List<dynamic>?)
          ?.map((e) => HourlyWeather.fromMap(e))
          .toList() ?? [],
      dailyForecast: (map['dailyForecast'] as List<dynamic>?)
          ?.map((e) => DailyWeather.fromMap(e))
          .toList() ?? [],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

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
    };
  }

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
      time: DateTime.parse(map['time']),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      condition: map['condition'] ?? '',
      icon: map['icon'] ?? '',
      humidity: map['humidity'] ?? 0,
      windSpeed: (map['windSpeed'] ?? 0.0).toDouble(),
      rainChance: (map['rainChance'] ?? 0.0).toDouble(),
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
      date: DateTime.parse(map['date']),
      maxTemperature: (map['maxTemperature'] ?? 0.0).toDouble(),
      minTemperature: (map['minTemperature'] ?? 0.0).toDouble(),
      condition: map['condition'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      humidity: map['humidity'] ?? 0,
      windSpeed: (map['windSpeed'] ?? 0.0).toDouble(),
      rainChance: (map['rainChance'] ?? 0.0).toDouble(),
      sunrise: DateTime.parse(map['sunrise']),
      sunset: DateTime.parse(map['sunset']),
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
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'low',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      areas: List<String>.from(map['areas'] ?? []),
      type: map['type'] ?? '',
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