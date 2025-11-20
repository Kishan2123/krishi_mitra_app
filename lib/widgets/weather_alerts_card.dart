import 'package:flutter/material.dart';

class WeatherAlertsCard extends StatelessWidget {
  const WeatherAlertsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Weather Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Heavy Rain Expected: Moderate to heavy rainfall expected on Wednesday.'),
            Text('• High UV Index: UV index will be high today. Use sun protection.'),
          ],
        ),
      ),
    );
  }
}