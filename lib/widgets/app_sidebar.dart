import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.currentRoute,
    this.useRail = false,
    this.onNavigate,
  });

  final String currentRoute;
  final bool useRail;
  final VoidCallback? onNavigate;

  List<_NavItem> get _items => const [
        _NavItem('Dashboard', '/dashboard', Icons.dashboard_customize_outlined),
        _NavItem('Crop Advisory', '/crop-advisory', Icons.grass_outlined),
        _NavItem('Soil & Fertilizer', '/soil-fertilizer', Icons.science_outlined),
        _NavItem('Pest Detection', '/pest-detection', Icons.bug_report_outlined),
        _NavItem('Market Prices', '/market-prices', Icons.price_change_outlined),
        _NavItem('Alerts', '/alerts', Icons.campaign_outlined),
        _NavItem('Community', '/community', Icons.groups_2_outlined),
        _NavItem('Settings', '/settings', Icons.settings_outlined),
        _NavItem('Region Insights', '/region-insights', Icons.map_outlined),
        _NavItem('Analytics', '/analytics', Icons.analytics_outlined),
      ];

  int get _selectedIndex {
    final index = _items.indexWhere(
      (item) => currentRoute.startsWith(item.route),
    );
    return index == -1 ? 0 : index;
  }

  void _navigate(BuildContext context, String route) {
    onNavigate?.call();
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    if (useRail) {
      return NavigationRail(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        labelType: NavigationRailLabelType.all,
        minWidth: 88,
        onDestinationSelected: (index) => _navigate(context, _items[index].route),
        destinations: _items
            .map(
              (item) => NavigationRailDestination(
                icon: Icon(item.icon, color: Colors.grey[600]),
                selectedIcon: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                label: Text(item.label),
              ),
            )
            .toList(),
      );
    }

    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => _navigate(context, _items[index].route),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Krishi Mitra',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text('Dharti Gyan farmer tools', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        const Divider(),
        ..._items.map(
          (item) => NavigationDrawerDestination(
            icon: Icon(item.icon),
            label: Text(item.label),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final String label;
  final String route;
  final IconData icon;

  const _NavItem(this.label, this.route, this.icon);
}
