import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/alert_service.dart';
import '../widgets/alert_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<Alert>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = AlertService().fetchAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alert>>(
      future: _alertsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final alerts = snapshot.data ?? [];
        if (alerts.isEmpty) {
          return const Center(child: Text('No alerts available.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...alerts.map((a) => AlertCard(alert: a)).toList(),
            ],
          ),
        );
      },
    );
  }
}
