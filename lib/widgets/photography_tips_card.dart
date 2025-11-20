import 'package:flutter/material.dart';

class PhotographyTipsCard extends StatelessWidget {
  const PhotographyTipsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Photography Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('✅ Best Practices:'),
            Text('• Take photos in good natural light'),
            Text('• Focus on affected areas clearly'),
            Text('• Include some healthy parts for comparison'),
            Text('• Hold camera steady to avoid blur'),
            SizedBox(height: 8),
            Text('❌ Avoid These:'),
            Text('• Blurry or too dark images'),
            Text('• Photos taken from too far away'),
            Text('• Images with heavy shadows'),
            Text('• Multiple different issues in one photo'),
          ],
        ),
      ),
    );
  }
}