import 'package:flutter/material.dart';

class VoiceInterface extends StatelessWidget {
  const VoiceInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Voice Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Tap the button below to start speaking.'),
          ],
        ),
      ),
    );
  }
}