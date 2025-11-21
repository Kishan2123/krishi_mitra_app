import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/alerts_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/community_screen.dart';
import '../screens/crop_advisory_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/index_screen.dart';
import '../screens/market_prices_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/pest_detection_screen.dart';
import '../screens/region_insights_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/soil_fertilizer_screen.dart';
import '../screens/upload_crop_photo_screen.dart';
import '../screens/weather_update_screen.dart';
import '../widgets/voice_interface.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => IndexScreen(
          currentLocation: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/crop-advisory',
            builder: (context, state) => const CropAdvisoryScreen(),
          ),
          GoRoute(
            path: '/soil-fertilizer',
            builder: (context, state) => const SoilFertilizerScreen(),
          ),
          GoRoute(
            path: '/pest-detection',
            builder: (context, state) => const PestDetectionScreen(),
          ),
          GoRoute(
            path: '/market-prices',
            builder: (context, state) => const MarketPricesScreen(),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/region-insights',
            builder: (context, state) => const RegionInsightsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/weather',
            builder: (context, state) => const WeatherUpdateScreen(),
          ),
          GoRoute(
            path: '/upload-crop-photo',
            builder: (context, state) => const UploadCropPhotoScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/voice-assistant',
        builder: (context, state) => const VoiceInterface(fullscreen: true),
      ),
    ],
  );
}
