import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceInterface extends StatefulWidget {
  const VoiceInterface({super.key, this.fullscreen = false});

  final bool fullscreen;

  @override
  State<VoiceInterface> createState() => _VoiceInterfaceState();
}

class _VoiceInterfaceState extends State<VoiceInterface> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  bool _listening = false;
  final List<String> _transcripts = [
    'Ask: Market price for paddy in Ranchi',
    'Try: What should I spray for aphids on brinjal?',
  ];
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
    lowerBound: 0.94,
    upperBound: 1.04,
  );

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-IN');
    _tts.setSpeechRate(0.95);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      _pulseController.stop();
      setState(() => _listening = false);
      await _tts.stop();
      return;
    }

    setState(() => _listening = true);
    _pulseController.repeat(reverse: true);
    await _speak('I am listening, ask your farming question.');
    _simulateTranscript();
  }

  Future<void> _simulateTranscript() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || !_listening) return;
    setState(() {
      _transcripts.insert(0, 'User: What should I spray for leaf curl?');
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted || !_listening) return;
    const response = 'Leaf curl detected. Spray neem oil 3ml/litre in the evening; avoid sun. I will remind you in 7 days.';
    setState(() {
      _transcripts.insert(0, response);
      _listening = false;
    });
    _pulseController.stop();
    await _speak(response);
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (_) {
      // Ignore TTS errors in offline/dev mode
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (widget.fullscreen) {
      return Scaffold(
        appBar: AppBar(title: const Text('Voice Assistant')),
        body: SafeArea(child: content),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.mic_none, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Voice Assistant', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Ask in any language. We transcribe, analyse, and speak back with guidance.'),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final entry = _transcripts[index];
                final isUser = entry.toLowerCase().startsWith('user:');
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(isUser ? Icons.account_circle : Icons.smart_toy, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry,
                        style: TextStyle(color: isUser ? Colors.black87 : Colors.green.shade900, fontWeight: isUser ? FontWeight.w500 : FontWeight.w600),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: _transcripts.length,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: _micButton()),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _VoiceChip('Weather today'),
            _VoiceChip('Soil pH for paddy'),
            _VoiceChip('Wheat price in Ranchi'),
            _VoiceChip('Spray schedule'),
          ],
        ),
      ],
    );
  }

  Widget _micButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = _listening ? _pulseController.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                _listening ? Colors.redAccent : Colors.green,
                _listening ? Colors.deepOrange : Colors.green.shade700,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: (_listening ? Colors.redAccent : Colors.green).withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            _listening ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _VoiceChip extends StatelessWidget {
  const _VoiceChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.green.shade50,
      label: Text(label, style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600)),
      avatar: Icon(Icons.mic_none, size: 16, color: Colors.green.shade700),
    );
  }
}
