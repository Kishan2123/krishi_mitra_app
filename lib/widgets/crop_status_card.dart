import 'package:flutter/material.dart';

class CropStatusCard extends StatelessWidget {
  const CropStatusCard({
    super.key,
    required this.cropName,
    required this.stage,
    required this.moisture,
    required this.health,
    required this.expectedYield,
    required this.trend,
  });

  final String cropName;
  final String stage;
  final double moisture;
  final String health;
  final double expectedYield;
  final double trend;

  Color get _healthColor {
    switch (health.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'watch':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('Stage: $stage', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Chip(
                  label: Text(health),
                  backgroundColor: _healthColor.withOpacity(0.12),
                  labelStyle: TextStyle(color: _healthColor.shade700, fontWeight: FontWeight.w600),
                  avatar: Icon(Icons.eco, color: _healthColor.shade700, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (moisture / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text('Soil moisture: ${moisture.toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.grain, color: Colors.brown),
                const SizedBox(width: 8),
                Text(
                  'Expected yield: ${expectedYield.toStringAsFixed(1)} t/ha',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      trend >= 0 ? Icons.north_east : Icons.south_east,
                      color: trend >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text('${trend.abs().toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
