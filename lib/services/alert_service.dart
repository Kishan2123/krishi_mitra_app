import 'dart:async';
import '../models/alert.dart';

class AlertService {
  Future<List<Alert>> fetchAlerts() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Placeholder data
    return [
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
      Alert(
        category: 'Pest',
        message: 'Pest infestation detected in nearby farms.',
        severity: 'Low',
        time: '2025-11-19 05:00 PM',
      ),
    ];
  }
}