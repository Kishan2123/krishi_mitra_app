import 'package:flutter/material.dart';
import '../widgets/upload_preview_card.dart';
import '../widgets/recent_scans_card.dart';
import '../widgets/photography_tips_card.dart';

class PestDetectionScreen extends StatelessWidget {
  const PestDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest & Disease Detection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload crop images for AI-powered pest identification',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Upload Section
            const UploadPreviewCard(),

            const SizedBox(height: 16),

            // Recent Scans
            const RecentScansCard(),

            const SizedBox(height: 16),

            // Photography Tips
            const PhotographyTipsCard(),
          ],
        ),
      ),
    );
  }
}