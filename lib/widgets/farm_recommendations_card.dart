import 'package:flutter/material.dart';

class FarmRecommendationsCard extends StatelessWidget {
  const FarmRecommendationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Farm Weather Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Today: Ideal for harvesting wheat'),
            Text('• Tomorrow: Good for field preparation'),
            Text('• Wednesday: Avoid field work due to rain'),
          ],
        ),
      ),
    );
  }
}