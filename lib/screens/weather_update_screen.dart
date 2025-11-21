import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_api_service.dart';
import '../widgets/farm_recommendations_card.dart';
import '../widgets/seven_day_forecast_chart.dart';
import '../widgets/weather_alerts_card.dart';
import '../widgets/weather_card.dart';

class WeatherUpdateScreen extends StatefulWidget {
  const WeatherUpdateScreen({super.key});

  @override
  State<WeatherUpdateScreen> createState() => _WeatherUpdateScreenState();
}

class _WeatherUpdateScreenState extends State<WeatherUpdateScreen> {
  late final WeatherApiService _weatherService;
  late Future<Weather> _weatherFuture;
  bool _locationNoticeShown = false;

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherApiService(onLocationAccessed: _handleLocationAccessed);
    _weatherFuture = _weatherService.fetchWeather();
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Weather>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        final Widget weatherSection;

        if (snapshot.connectionState == ConnectionState.waiting) {
          weatherSection = const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          weatherSection = Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Unable to load weather right now', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          weatherSection = WeatherCard(weather: snapshot.data ?? demoWeather);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weather Update', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              weatherSection,
              const SizedBox(height: 12),
              const WeatherAlertsCard(),
              const SizedBox(height: 12),
              const SevenDayForecastChart(),
              const SizedBox(height: 12),
              const FarmRecommendationsCard(),
            ],
          ),
        );
      },
    );
  }

  void _reload() {
    setState(() {
      _weatherFuture = _weatherService.fetchWeather();
    });
  }

  void _handleLocationAccessed() {
    if (_locationNoticeShown || !mounted) return;
    _locationNoticeShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Location Accessed'),
            content: const Text('Your location has been successfully accessed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}
