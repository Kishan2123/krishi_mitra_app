import 'package:flutter/material.dart';
import '../widgets/alert_card.dart';
import '../widgets/voice_interface.dart';
import '../widgets/floating_voice_button.dart';
import '../models/alert.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Alert> alerts = [
      Alert(
        category: 'Weather',
        message: 'Heavy rainfall expected tomorrow.',
        severity: 'High',
        time: '2025-11-20 10:00 AM',
      ),
      Alert(
        category: 'Market',
        message: 'Price drop in wheat.',
        severity: 'Medium',
        time: '2025-11-20 09:00 AM',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Good morning, Ramesh! 🌾',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Text('Ranchi, Jharkhand'),
                    ],
                  ),
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Stats
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: alerts.map((alert) => AlertCard(alert: alert)).toList(),
              ),

              const SizedBox(height: 16),

              // Voice Assistant
              const VoiceInterface(),

              // Floating Button
              const FloatingVoiceButton(),
            ],
          ),
        ),
      ),
    );
  }
}