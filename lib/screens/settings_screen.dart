import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = PreferencesService.instance;
  final _districts = const ['Ranchi', 'Hazaribagh', 'Dhanbad', 'Bokaro', 'Palamu', 'Gumla', 'Deoghar'];

  String _language = 'English';
  String _region = 'Ranchi';
  String _units = 'Metric';
  bool _notifications = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final lang = await _prefs.getLanguage();
    final region = await _prefs.getRegion();
    final units = await _prefs.getUnits();
    final notify = await _prefs.getNotificationsEnabled();
    setState(() {
      _language = lang;
      _region = region;
      _units = units;
      _notifications = notify;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _prefs.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out locally. Re-login on next launch.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _language,
                    decoration: const InputDecoration(labelText: 'Language'),
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                      DropdownMenuItem(value: 'Jharkhandi', child: Text('Jharkhandi')),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _language = value);
                      await _prefs.setLanguage(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _region,
                    decoration: const InputDecoration(labelText: 'District (Jharkhand)'),
                    items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _region = value);
                      await _prefs.setRegion(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _units,
                    decoration: const InputDecoration(labelText: 'Units'),
                    items: const [
                      DropdownMenuItem(value: 'Metric', child: Text('Metric (°C, km/h)')),
                      DropdownMenuItem(value: 'Imperial', child: Text('Imperial (°F, mph)')),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _units = value);
                      await _prefs.setUnits(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Weather, market alerts, and advisory updates'),
                value: _notifications,
                onChanged: (value) async {
                  setState(() => _notifications = value);
                  await _prefs.setNotificationsEnabled(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
