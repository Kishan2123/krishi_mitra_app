import 'package:flutter/material.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/weather_alerts_card.dart';
import '../widgets/seven_day_forecast_chart.dart';
import '../widgets/farm_recommendations_card.dart';

class WeatherUpdateScreen extends StatelessWidget {
  const WeatherUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Update'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CurrentWeatherCard(),
            const SizedBox(height: 16),
            const WeatherAlertsCard(),
            const SizedBox(height: 16),
            const SevenDayForecastChart(),
            const SizedBox(height: 16),
            const FarmRecommendationsCard(),
          ],
        ),
      ),
    );
  }
}