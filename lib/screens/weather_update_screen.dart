import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../widgets/farm_recommendations_card.dart';
import '../widgets/seven_day_forecast_chart.dart';
import '../widgets/weather_alerts_card.dart';
import '../widgets/weather_card.dart';

class WeatherUpdateScreen extends StatelessWidget {
  const WeatherUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Weather Update', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          WeatherCard(weather: demoWeather),
          SizedBox(height: 12),
          WeatherAlertsCard(),
          SizedBox(height: 12),
          SevenDayForecastChart(),
          SizedBox(height: 12),
          FarmRecommendationsCard(),
        ],
      ),
    );
  }
}
