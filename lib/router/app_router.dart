import 'package:go_router/go_router.dart';
import '../screens/index_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/crop_advisory_screen.dart';
import '../screens/market_prices_screen.dart';
import '../screens/weather_update_screen.dart';
import '../screens/pest_detection_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/upload_crop_photo_screen.dart';
import '../screens/not_found_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const IndexScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/crop-advisory',
        builder: (context, state) => const CropAdvisoryScreen(),
      ),
      GoRoute(
        path: '/market-prices',
        builder: (context, state) => const MarketPricesScreen(),
      ),
      GoRoute(
        path: '/weather-update',
        builder: (context, state) => const WeatherUpdateScreen(),
      ),
      GoRoute(
        path: '/pest-detection',
        builder: (context, state) => const PestDetectionScreen(),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/upload-crop-photo',
        builder: (context, state) => const UploadCropPhotoScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}