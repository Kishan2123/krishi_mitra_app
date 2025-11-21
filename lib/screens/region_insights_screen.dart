import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../widgets/weather_card.dart';

class RegionInsightsScreen extends StatefulWidget {
  const RegionInsightsScreen({super.key});

  @override
  State<RegionInsightsScreen> createState() => _RegionInsightsScreenState();
}

class _RegionInsightsScreenState extends State<RegionInsightsScreen> {
  final _districts = const ['Ranchi', 'Hazaribagh', 'Dhanbad', 'Bokaro', 'Palamu'];
  String _selectedDistrict = 'Ranchi';

  Map<String, dynamic> get _insight => _mockInsights[_selectedDistrict]!;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Region Insights', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Chip(
                avatar: const Icon(Icons.my_location, size: 18),
                label: Text('Auto-detected: $_selectedDistrict'),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedDistrict,
                items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (value) => setState(() => _selectedDistrict = value!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeatherCard(
            weather: demoWeather.copyWith(location: '$_selectedDistrict, Jharkhand'),
          ),
          const SizedBox(height: 16),
          _insightCard('Top crops', _insight['crops'] as String, Icons.agriculture),
          const SizedBox(height: 12),
          _marketCard(),
          const SizedBox(height: 12),
          _insightCard('Soil & rainfall', _insight['soil'] as String, Icons.waterfall_chart),
        ],
      ),
    );
  }

  Widget _insightCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.green.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marketCard() {
    final summary = _insight['market'] as Map<String, dynamic>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.price_change, color: Colors.green.withOpacity(0.8)),
                const SizedBox(width: 8),
                const Text('Market summary', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Hot crop: ${summary['hot']}', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text('Price trend: ${summary['trend']}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (summary['mandis'] as List<String>)
                  .map((m) => Chip(label: Text(m)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

const Map<String, Map<String, dynamic>> _mockInsights = {
  'Ranchi': {
    'crops': 'Paddy transplanting active; maize and vegetables expanding',
    'soil': 'Loamy soil with 42% moisture; 28mm rain expected this week',
    'market': {
      'hot': 'Tomato (\u20b928/kg)',
      'trend': 'Upward due to festival demand',
      'mandis': ['Kanke', 'Itki', 'Nagmangala'],
    },
  },
  'Hazaribagh': {
    'crops': 'Chickpea sowing window open; monitor for wilt',
    'soil': 'Sandy loam, moisture 18%, irrigation advised',
    'market': {
      'hot': 'Lentil (\u20b994/kg)',
      'trend': 'Stable prices week-on-week',
      'mandis': ['Hazaribagh main', 'Katkamdag'],
    },
  },
  'Dhanbad': {
    'crops': 'Vegetable cluster expansion; okra & brinjal dominating',
    'soil': 'Alluvial soil with moderate organic carbon',
    'market': {
      'hot': 'Cauliflower (\u20b932/kg)',
      'trend': 'Slight downtrend due to arrivals',
      'mandis': ['Jharia', 'Govindpur'],
    },
  },
  'Bokaro': {
    'crops': 'Pulses under irrigation; check micronutrients',
    'soil': 'Red laterite soil; rainfall deficit 12% this month',
    'market': {
      'hot': 'Mustard (\u20b96,400/quintal)',
      'trend': 'Upward 1.4%',
      'mandis': ['Chas', 'Kasmar'],
    },
  },
  'Palamu': {
    'crops': 'Millets and oilseeds suggested for dry pockets',
    'soil': 'Sandy soil; conserve moisture with mulching',
    'market': {
      'hot': 'Mahua (local)',
      'trend': 'Volatile; check daily',
      'mandis': ['Daltonganj'],
    },
  },
};
