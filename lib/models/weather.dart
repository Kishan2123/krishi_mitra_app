import 'package:flutter/material.dart';

class Weather {
  final String location;
  final double temperatureC;
  final int humidity;
  final String condition;
  final double windSpeedKph;
  final int rainChance;
  final String iconName;

  const Weather({
    required this.location,
    required this.temperatureC,
    required this.humidity,
    required this.condition,
    required this.windSpeedKph,
    required this.rainChance,
    required this.iconName,
  });

  Weather copyWith({
    String? location,
    double? temperatureC,
    int? humidity,
    String? condition,
    double? windSpeedKph,
    int? rainChance,
    String? iconName,
  }) {
    return Weather(
      location: location ?? this.location,
      temperatureC: temperatureC ?? this.temperatureC,
      humidity: humidity ?? this.humidity,
      condition: condition ?? this.condition,
      windSpeedKph: windSpeedKph ?? this.windSpeedKph,
      rainChance: rainChance ?? this.rainChance,
      iconName: iconName ?? this.iconName,
    );
  }

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: json['location'] as String? ?? 'Unknown',
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 0,
      humidity: json['humidity'] as int? ?? 0,
      condition: json['condition'] as String? ?? 'Clear',
      windSpeedKph: (json['windSpeedKph'] as num?)?.toDouble() ?? 0,
      rainChance: json['rainChance'] as int? ?? 0,
      iconName: json['iconName'] as String? ?? 'sunny',
    );
  }

  factory Weather.fromWeatherApi(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final forecastDays = (json['forecast']?['forecastday'] as List?) ?? [];
    final firstDay = forecastDays.isNotEmpty ? forecastDays.first as Map<String, dynamic> : {};
    final day = firstDay['day'] as Map<String, dynamic>? ?? {};
    final conditionJson = current['condition'] as Map<String, dynamic>? ?? {};

    final locationName = location['name'] as String? ?? 'Unknown';
    final region = location['region'] as String? ?? '';
    final country = location['country'] as String? ?? '';
    final conditionText = (conditionJson['text'] as String? ?? 'Clear').trim();
    final rainChance = _parseInt(day['daily_chance_of_rain']) ??
        _parseInt(firstDay['hour'] is List && (firstDay['hour'] as List).isNotEmpty
            ? (firstDay['hour'] as List).first['chance_of_rain']
            : null) ??
        0;

    return Weather(
      location: [locationName, region.isNotEmpty ? region : country].where((p) => p.isNotEmpty).join(', '),
      temperatureC: (current['temp_c'] as num?)?.toDouble() ?? 0,
      humidity: current['humidity'] as int? ?? 0,
      condition: conditionText.isEmpty ? 'Clear' : conditionText,
      windSpeedKph: (current['wind_kph'] as num?)?.toDouble() ?? 0,
      rainChance: rainChance,
      iconName: _iconForCondition(conditionText),
    );
  }

  String get iconAsset => 'assets/images/weather/$iconName.svg';

  Color get conditionColor {
    if (rainChance >= 60) return Colors.blueGrey;
    if (humidity > 70) return Colors.teal.shade600;
    return Colors.orange.shade600;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _iconForCondition(String condition) {
    final lc = condition.toLowerCase();
    if (lc.contains('storm') || lc.contains('thunder')) return 'storm';
    if (lc.contains('drizzle') || lc.contains('shower')) return 'drizzle';
    if (lc.contains('rain')) return 'rainy';
    if (lc.contains('snow')) return 'rainy';
    if (lc.contains('fog') || lc.contains('mist') || lc.contains('haze')) return 'fog';
    if (lc.contains('wind')) return 'windy';
    if (lc.contains('overcast')) return 'cloudy';
    if (lc.contains('cloud')) return 'partly_cloudy';
    return 'sunny';
  }
}

const demoWeather = Weather(
  location: 'Ranchi, Jharkhand',
  temperatureC: 28,
  humidity: 68,
  condition: 'Partly Cloudy',
  windSpeedKph: 9.5,
  rainChance: 24,
  iconName: 'partly_cloudy',
);
