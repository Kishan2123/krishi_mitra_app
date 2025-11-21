import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherApiService {
  WeatherApiService({
    http.Client? client,
    String? apiKey,
    void Function()? onLocationAccessed,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('WEATHER_API_KEY'),
        _onLocationAccessed = onLocationAccessed;

  final http.Client _client;
  final String _apiKey;
  final void Function()? _onLocationAccessed;

  static const _host = 'api.weatherapi.com';
  static const _path = '/v1/forecast.json';

  Future<Weather> fetchWeather({String? city}) async {
    _ensureApiKey();
    final query = await _resolveQuery(city);
    final uri = Uri.https(_host, _path, {
      'key': _apiKey,
      'q': query,
      'days': '1',
      'aqi': 'no',
      'alerts': 'no',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather (status ${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Weather.fromWeatherApi(decoded);
  }

  Future<String> _resolveQuery(String? city) async {
    if (city != null && city.trim().isNotEmpty) return city.trim();
    final position = await _getCurrentPosition();
    return '${position.latitude},${position.longitude}';
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    _onLocationAccessed?.call();
    return position;
  }

  void _ensureApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception('WEATHER_API_KEY is not configured.');
    }
  }

  void dispose() {
    _client.close();
  }
}
