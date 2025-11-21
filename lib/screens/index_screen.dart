import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/floating_voice_button.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key, required this.child, required this.currentLocation});

  final Widget child;
  final String currentLocation;

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;

        final content = SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isWide),
              const SizedBox(height: 12),
              widget.child,
              const SizedBox(height: 24),
            ],
          ),
        );

        return Scaffold(
          key: _scaffoldKey,
          appBar: isWide
              ? null
              : AppBar(
                  title: const Text('Krishi Mitra'),
                  leading: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  actions: [Padding(padding: const EdgeInsets.only(right: 8), child: _languageDropdown())],
                ),
          drawer: isWide
              ? null
              : Drawer(
                  child: SafeArea(
                    child: AppSidebar(
                      currentRoute: widget.currentLocation,
                      useRail: false,
                      onNavigate: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (isWide)
                  SizedBox(
                    width: 280,
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: AppSidebar(
                          currentRoute: widget.currentLocation,
                          useRail: true,
                        ),
                      ),
                    ),
                  ),
                Expanded(child: content),
              ],
            ),
          ),
          floatingActionButton: const FloatingVoiceButton(),
        );
      },
    );
  }

  Widget _buildHeader(bool isWide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Dharti Gyan', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Smart farming dashboard for Jharkhand farmers', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        if (isWide) ...[
          Chip(
            avatar: const Icon(Icons.location_on, size: 18),
            label: const Text('Ranchi, Jharkhand'),
          ),
          const SizedBox(width: 12),
          _languageDropdown(),
        ],
      ],
    );
  }

  Widget _languageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _language,
        items: const [
          DropdownMenuItem(value: 'English', child: Text('English')),
          DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
          DropdownMenuItem(value: 'Jharkhandi', child: Text('Jharkhandi')),
        ],
        onChanged: (value) => setState(() => _language = value ?? 'English'),
      ),
    );
  }
}
