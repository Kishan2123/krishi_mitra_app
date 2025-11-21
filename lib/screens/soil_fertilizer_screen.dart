import 'package:flutter/material.dart';
import '../widgets/recommendation_card.dart';

enum SoilInputMode { auto, manual, shc }

class SoilFertilizerScreen extends StatefulWidget {
  const SoilFertilizerScreen({super.key});

  @override
  State<SoilFertilizerScreen> createState() => _SoilFertilizerScreenState();
}

class _SoilFertilizerScreenState extends State<SoilFertilizerScreen> {
  SoilInputMode _mode = SoilInputMode.auto;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Soil & Fertilizer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              Icon(Icons.eco_outlined, color: Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard('Soil type', 'Loamy', Icons.landscape),
              _statCard('Organic Carbon', '0.78%', Icons.auto_graph),
              _statCard('Micro nutrients', 'Balanced', Icons.bubble_chart_outlined),
              _statCard('Moisture', '22%', Icons.water_drop_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Text('Active input mode', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<SoilInputMode>(
            segments: const [
              ButtonSegment(value: SoilInputMode.auto, icon: Icon(Icons.sensors), label: Text('Auto Detect')),
              ButtonSegment(value: SoilInputMode.manual, icon: Icon(Icons.edit_note), label: Text('Manual Entry')),
              ButtonSegment(value: SoilInputMode.shc, icon: Icon(Icons.badge_outlined), label: Text('SHC Entry')),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) => setState(() => _mode = selection.first),
          ),
          const SizedBox(height: 16),
          _buildModeContent(),
          const SizedBox(height: 20),
          Text('Nutrient snapshot', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _NutrientTile(label: 'N', value: '42 kg/ha', status: 'Low', color: Colors.orange)),
              SizedBox(width: 12),
              Expanded(child: _NutrientTile(label: 'P', value: '18 kg/ha', status: 'Optimal', color: Colors.green)),
              SizedBox(width: 12),
              Expanded(child: _NutrientTile(label: 'K', value: '210 kg/ha', status: 'Optimal', color: Colors.green)),
              SizedBox(width: 12),
              Expanded(child: _NutrientTile(label: 'pH', value: '6.5', status: 'Neutral', color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Fertilizer recommendations', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._recommendations()
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
        ],
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_mode) {
      case SoilInputMode.auto:
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.sensors, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Using soil test kit data from last scan. Moisture and pH auto-updated every 30 mins.',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      case SoilInputMode.manual:
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(child: _InputField(label: 'Nitrogen (kg/ha)')),
                    SizedBox(width: 12),
                    Expanded(child: _InputField(label: 'Phosphorus (kg/ha)')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: _InputField(label: 'Potassium (kg/ha)')),
                    SizedBox(width: 12),
                    Expanded(child: _InputField(label: 'pH')),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.insights),
                    label: const Text('Update recommendations'),
                  ),
                ),
              ],
            ),
          ),
        );
      case SoilInputMode.shc:
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Enter Soil Health Card ID'),
                SizedBox(height: 8),
                _InputField(label: 'SHC ID (Jharkhand)'),
                SizedBox(height: 12),
                _InputField(label: 'Sample collection date'),
                SizedBox(height: 12),
                Text(
                  'We will parse your SHC values, highlight gaps, and combine with weather to time inputs.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
    }
  }

  List<Map<String, String>> _recommendations() {
    return [
      {
        'title': 'Basal dose of urea',
        'type': 'Fertilizer',
        'priority': 'High',
        'description': 'Apply 45 kg/acre urea split into two equal doses with irrigation.',
        'reason': 'Low nitrogen detected in top soil layer.',
        'benefit': 'Improves vegetative growth and leaf colour.',
        'cost': '?850 / acre',
        'timeline': 'Within 3 days',
      },
      {
        'title': 'Add gypsum for pH balance',
        'type': 'Soil amendment',
        'priority': 'Medium',
        'description': 'Broadcast 50 kg/acre gypsum to keep pH stable for rice transplant.',
        'reason': 'pH leaning acidic; gypsum buffers soil and improves calcium.',
        'benefit': 'Better nutrient uptake, stronger roots.',
        'cost': '?420 / acre',
        'timeline': 'This week',
      },
    ];
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(labelText: label, hintText: 'Enter value'),
      keyboardType: TextInputType.number,
    );
  }
}

class _NutrientTile extends StatelessWidget {
  const _NutrientTile({
    required this.label,
    required this.value,
    required this.status,
    required this.color,
  });

  final String label;
  final String value;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(color: color.shade700)),
        ],
      ),
    );
  }
}

Widget _statCard(String title, String value, IconData icon) {
  return SizedBox(
    width: 220,
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.green.shade700),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
