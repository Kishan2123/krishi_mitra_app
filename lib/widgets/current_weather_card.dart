import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Current Weather',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Temperature: 32°C'),
            Text('Feels Like: 35°C'),
            Text('Humidity: 65%'),
            Text('Wind Speed: 12 km/h'),
            Text('Visibility: 10 km'),
            Text('UV Index: 7'),
          ],
        ),
      ),
    );
  }
}