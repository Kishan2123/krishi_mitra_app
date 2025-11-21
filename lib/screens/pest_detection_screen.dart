import 'package:flutter/material.dart';
import '../widgets/photography_tips_card.dart';
import '../widgets/recent_scans_card.dart';
import '../widgets/upload_preview_card.dart';

class PestDetectionScreen extends StatelessWidget {
  const PestDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Pest & Disease Detection', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('Upload crop images for AI-powered pest identification'),
          SizedBox(height: 12),
          UploadPreviewCard(),
          SizedBox(height: 12),
          RecentScansCard(),
          SizedBox(height: 12),
          PhotographyTipsCard(),
        ],
      ),
    );
  }
}
