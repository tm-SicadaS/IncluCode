import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'launch_screen.dart';

/// -----------------------------------------------------------------------
/// BusCue — Conductor App
/// -----------------------------------------------------------------------
/// Base build matching the wireframe flow:
///   1. Launch Screen        -> lib/screens/launch_screen.dart
///   2. Step 1 of 2 (Conductor profile) -> onboarding_step1_screen.dart
///   3. Step 2 of 2 (Bus number and route) -> onboarding_step3_screen.dart
///   4. Conductor Dashboard -> conductor_dashboard_screen.dart
///
/// Shared colors/text styles live in lib/theme/app_theme.dart, and
/// reusable form pieces live in lib/widgets/. Navigation is done with
/// plain MaterialPageRoute pushes — swap in go_router/named routes later
/// if the project grows.
///
/// GPS streaming, BLE broadcast, and backend/API calls are left as TODOs
/// throughout — this covers UI + local state only.
/// -----------------------------------------------------------------------

Future<void> main() async {
  runApp(const BusCueConductorApp());
}

class BusCueConductorApp extends StatelessWidget {
  const BusCueConductorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusCue — Conductor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LaunchScreen(),
    );
  }
}
