import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.title,
    required this.type,
    required this.priority,
    required this.description,
    required this.reason,
    required this.benefit,
    required this.cost,
    required this.timeline,
  });

  final String title;
  final String type;
  final String priority;
  final String description;
  final String reason;
  final String benefit;
  final String cost;
  final String timeline;

  Color get _priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      default:
        return Colors.green;
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(type, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _priorityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$priority priority',
                    style: TextStyle(
                      color: _priorityColor.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            _detailRow(Icons.lightbulb_outline, 'Reason', reason),
            _detailRow(Icons.trending_up, 'Benefit', benefit),
            _detailRow(Icons.payments_outlined, 'Cost', cost),
            _detailRow(Icons.schedule, 'Timeline', timeline),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
