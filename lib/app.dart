import 'package:flutter/material.dart';
import 'package:krishi_mitra_app/router/app_router.dart';
import 'package:krishi_mitra_app/theme/app_theme.dart';

class KrishiMitraApp extends StatelessWidget {
  const KrishiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Krishi Mitra',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
