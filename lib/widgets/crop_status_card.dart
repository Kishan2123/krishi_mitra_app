import 'package:flutter/material.dart';

class CropStatusCard extends StatelessWidget {
  const CropStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Crop Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Crop: Winter Wheat'),
            Text('Stage: Flowering'),
            Text('Expected Yield: 4.2 tons/hectare'),
          ],
        ),
      ),
    );
  }
}