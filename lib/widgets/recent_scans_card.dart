import 'package:flutter/material.dart';

class RecentScansCard extends StatelessWidget {
  const RecentScansCard({super.key});

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scans = [
      {
        'image': 'assets/images/uploads/3b626cd8-3bc5-4b85-97a6-271f133cacab.png',
        'pest': 'Leaf blight',
        'severity': 'High',
        'treatment': 'Spray copper oxychloride 2.5g/L, repeat in 7 days',
        'time': 'Today, 9:30 AM',
      },
      {
        'image': 'assets/images/uploads/3b626cd8-3bc5-4b85-97a6-271f133cacab.png',
        'pest': 'Aphids',
        'severity': 'Medium',
        'treatment': 'Use neem oil 3ml/L in evening',
        'time': 'Yesterday, 6:10 PM',
      },
      {
        'image': 'assets/images/uploads/3b626cd8-3bc5-4b85-97a6-271f133cacab.png',
        'pest': 'Healthy sample',
        'severity': 'Low',
        'treatment': 'No action needed',
        'time': 'Mon, 4:45 PM',
      },
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Scans', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: scans.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final scan = scans[index];
                  final severity = scan['severity']!;
                  return Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                          child: Image.asset(
                            scan['image']!,
                            height: 90,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pest_control, size: 16, color: Colors.grey[700]),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      scan['pest']!,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(scan['treatment']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _severityColor(severity).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(severity, style: TextStyle(color: _severityColor(severity), fontWeight: FontWeight.w700)),
                                  ),
                                  const Spacer(),
                                  Text(scan['time']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
