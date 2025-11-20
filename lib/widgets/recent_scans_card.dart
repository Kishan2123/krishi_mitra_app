import 'package:flutter/material.dart';

class RecentScansCard extends StatelessWidget {
  const RecentScansCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> scans = [
      {'image': 'assets/images/scan1.jpg', 'timestamp': '2025-11-19 10:00 AM'},
      {'image': 'assets/images/scan2.jpg', 'timestamp': '2025-11-18 02:30 PM'},
      {'image': 'assets/images/scan3.jpg', 'timestamp': '2025-11-17 08:45 AM'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Scans',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: scans.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final scan = scans[index];
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          scan['image']!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scan['timestamp']!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
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