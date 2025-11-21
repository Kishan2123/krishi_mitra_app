import 'package:flutter/material.dart';

class MarketPriceCard extends StatelessWidget {
  const MarketPriceCard({
    super.key,
    required this.cropName,
    required this.currentPrice,
    required this.previousPrice,
    required this.market,
    required this.date,
    required this.demand,
  });

  final String cropName;
  final double currentPrice;
  final double previousPrice;
  final String market;
  final String date;
  final String demand;

  double get percentChange {
    if (previousPrice == 0) return 0;
    return ((currentPrice - previousPrice) / previousPrice) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = percentChange >= 0 ? Colors.green : Colors.red;
    final demandColor = _demandColor();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cropName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(market, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Chip(
                  label: Text(demand),
                  backgroundColor: demandColor.withOpacity(0.12),
                  labelStyle: TextStyle(color: demandColor.shade700, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '?${currentPrice.toStringAsFixed(0)} /quintal',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(percentChange >= 0 ? Icons.north_east : Icons.south_east, color: changeColor),
                    const SizedBox(width: 4),
                    Text('${percentChange.abs().toStringAsFixed(1)}%', style: TextStyle(color: changeColor)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Prev: ?${previousPrice.toStringAsFixed(0)}'),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor _demandColor() {
    switch (demand.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}
