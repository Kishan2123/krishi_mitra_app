import 'package:flutter/material.dart';
import '../widgets/crop_info_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/cost_benefit_analysis_card.dart';

class CropAdvisoryScreen extends StatelessWidget {
  const CropAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Advisory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI-powered recommendations for your crops',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Current Crop Info
            const CropInfoCard(),

            const SizedBox(height: 16),

            // Recommendations
            const Text(
              'Personalized Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RecommendationCard(),

            const SizedBox(height: 16),

            // Cost-Benefit Analysis
            const CostBenefitAnalysisCard(),
          ],
        ),
      ),
    );
  }
}