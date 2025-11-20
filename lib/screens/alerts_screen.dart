import 'package:flutter/material.dart';
import '../widgets/alert_card.dart';
import '../services/alert_service.dart';
import '../models/alert.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: FutureBuilder<List<Alert>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No alerts available.'));
          }

          final alerts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return AlertCard(alert: alerts[index]);
            },
          );
        },
      ),
    );
  }
}