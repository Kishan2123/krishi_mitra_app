import 'package:flutter/material.dart';

class MarketPriceCard extends StatelessWidget {
  const MarketPriceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Wheat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Current Price: ₹2,240 per quintal'),
            Text('Previous Price: ₹2,070 per quintal'),
            Text('Market: Ludhiana Mandi'),
            SizedBox(height: 8),
            Text('Change: +8.2%', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}