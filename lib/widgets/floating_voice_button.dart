import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FloatingVoiceButton extends StatelessWidget {
  const FloatingVoiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/voice-assistant'),
      icon: const Icon(Icons.mic_none),
      label: const Text('Ask Dharti Gyan'),
    );
  }
}
