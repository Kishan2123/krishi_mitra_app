import 'package:flutter/material.dart';
import '../widgets/cost_benefit_analysis_card.dart';
import '../widgets/crop_info_card.dart';
import '../widgets/recommendation_card.dart';

class CropAdvisoryScreen extends StatelessWidget {
  const CropAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recs = _recommendations;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crop Advisory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('AI recommendations aligned with Dharti Gyan web experience'),
          const SizedBox(height: 16),
          const CropInfoCard(),
          const SizedBox(height: 12),
          ...recs
              .map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecommendationCard(
                    title: rec['title']!,
                    type: rec['type']!,
                    priority: rec['priority']!,
                    description: rec['description']!,
                    reason: rec['reason']!,
                    benefit: rec['benefit']!,
                    cost: rec['cost']!,
                    timeline: rec['timeline']!,
                  ),
                ),
              )
              .toList(),
          const CostBenefitAnalysisCard(),
        ],
      ),
    );
  }
}

const _recommendations = [
  {
    'title': 'Sona masoori seed selection',
    'type': 'Variety',
    'priority': 'Medium',
    'description': 'Shift 30% to Sona masoori early maturing variety for staggered harvest.',
    'reason': 'Better market price in September window.',
    'benefit': '₹240/q premium expected.',
    'cost': '₹950 / acre',
    'timeline': 'Before next sowing',
  },
  {
    'title': 'Micronutrient spray',
    'type': 'Fertilizer',
    'priority': 'Low',
    'description': 'Foliar spray of Zn + B mix 1.5g/L during evening hours.',
    'reason': 'Leaf sample shows mild Zn deficiency.',
    'benefit': 'Uniform grain filling.',
    'cost': '₹110 / acre',
    'timeline': 'After rain clears',
  },
];
