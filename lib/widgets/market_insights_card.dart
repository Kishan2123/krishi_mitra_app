import 'package:flutter/material.dart';

class MarketInsightsCard extends StatelessWidget {
  const MarketInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Market Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('📈 Wheat prices have increased by 8% this week.'),
            Text('⚠️ Rice prices may fluctuate next week due to monsoon forecasts.'),
          ],
        ),
      ),
    );
  }
}