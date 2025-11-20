import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Nitrogen Fertilizer Application',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Apply 40kg/hectare of Urea fertilizer within next 3 days.'),
            Text('Reason: Soil nitrogen levels are low.'),
            Text('Expected Benefit: 15-20% yield increase'),
            Text('Cost: ₹2,400/hectare'),
            Text('Timeframe: Next 3 days'),
          ],
        ),
      ),
    );
  }
}