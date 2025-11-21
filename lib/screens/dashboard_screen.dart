import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../models/weather.dart';
import '../widgets/alert_card.dart';
import '../widgets/crop_status_card.dart';
import '../widgets/market_price_card.dart';
import '../widgets/recent_scans_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/voice_interface.dart';
import '../widgets/weather_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = _mockAlerts;
    final recommendations = _mockRecommendations;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final tileWidth = isWide ? constraints.maxWidth / 2 - 20 : constraints.maxWidth;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Icons.location_on, size: 18),
                  SizedBox(width: 6),
                  Text('Ranchi, Jharkhand'),
                  Spacer(),
                  Text('Today', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: const WeatherCard(weather: demoWeather),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: const CropStatusCard(
                      cropName: 'Paddy - Swarna',
                      stage: 'Tillering',
                      moisture: 62,
                      health: 'Good',
                      expectedYield: 18.4,
                      trend: 2.3,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: MarketPriceCard(
                      cropName: 'Paddy',
                      currentPrice: 2140,
                      previousPrice: 2080,
                      market: 'Ranchi Mandi',
                      date: 'Updated today 8:40 AM',
                      demand: 'High',
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: const RecentScansCard(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Recommendations', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...recommendations
                  .map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RecommendationCard(
                        title: rec['title']!,
                        type: rec['type']!,
                        priority: rec['priority']!,
                        description: rec['description']!,
                        reason: rec['reason']!,
                        benefit: rec['benefit']!,
                        cost: rec['cost']!,
                        timeline: rec['timeline']!,
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 12),
              Text('Alerts', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...alerts.map((a) => AlertCard(alert: a)).toList(),
              const SizedBox(height: 20),
              const VoiceInterface(),
            ],
          ),
        );
      },
    );
  }
}

const _mockRecommendations = [
  {
    'title': 'Top dress urea after irrigation',
    'type': 'Soil',
    'priority': 'High',
    'description': 'Apply 22kg urea/acre tonight after the irrigation cycle completes.',
    'reason': 'Moisture + low nitrogen detected.',
    'benefit': 'Faster tiller growth and greener leaves.',
    'cost': '?620',
    'timeline': 'Tonight',
  },
  {
    'title': 'Pest watch: stem borer trap',
    'type': 'Pest',
    'priority': 'Medium',
    'description': 'Install pheromone traps (4/acre) near bunds; monitor larvae count.',
    'reason': 'High moth activity in nearby fields.',
    'benefit': 'Reduces chemical sprays; early detection.',
    'cost': '?180',
    'timeline': 'Within 48 hrs',
  },
];

final _mockAlerts = [
  Alert(
    category: 'Weather',
    message: 'Rain probable tonight. Delay spraying foliar nutrients.',
    severity: 'High',
    time: 'Today 5:30 PM',
  ),
  Alert(
    category: 'Market',
    message: 'Maize up by 1.8% in Hazaribagh mandi.',
    severity: 'Medium',
    time: 'Today 4:05 PM',
  ),
];
