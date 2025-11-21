import 'package:flutter/material.dart';

class CostBenefitAnalysisCard extends StatelessWidget {
  const CostBenefitAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Cost-Benefit Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _Line(label: 'Cost of Production:', value: '?115,000'),
            SizedBox(height: 4),
            _Line(label: 'Estimated Yield:', value: '20 Quintals'),
            SizedBox(height: 4),
            _Line(label: 'Market Price:', value: '?12,000/Quintal'),
            Divider(height: 16, thickness: 1),
            _Line(
              label: 'Estimated Profit:',
              value: '?125,000',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.isBold = false});

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.bold)
        : const TextStyle();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
