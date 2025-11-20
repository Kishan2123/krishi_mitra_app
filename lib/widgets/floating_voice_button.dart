import 'package:flutter/material.dart';

class FloatingVoiceButton extends StatelessWidget {
  const FloatingVoiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Handle voice button press
      },
      child: const Icon(Icons.mic),
    );
  }
}