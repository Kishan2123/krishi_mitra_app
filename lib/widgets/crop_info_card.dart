import 'package:flutter/material.dart';

class CropInfoCard extends StatelessWidget {
  const CropInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Winter Wheat - Flowering Stage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Planted: Nov 15, 2024'),
            Text('Expected Harvest: Apr 15, 2025'),
            Text('Investment: ₹45,000/hectare'),
            Text('Expected Revenue: ₹95,000/hectare'),
          ],
        ),
      ),
    );
  }
}