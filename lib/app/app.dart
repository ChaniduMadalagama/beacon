import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/auth_gate.dart';
import '../features/beacons/presentation/pages/dashboard_page.dart';
import '../features/alerts/presentation/pages/alerts_page.dart';
import '../core/theme/app_colors.dart';

class BeaconApp extends StatelessWidget {
  const BeaconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beacon Tracker',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          onPrimary: AppColors.white,
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/alerts': (context) => const AlertsPage(),
      },
    );
  }
}
