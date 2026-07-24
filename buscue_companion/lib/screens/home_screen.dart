import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../theme/app_colors.dart';
import '../widgets/action_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/bus_card.dart';
import '../widgets/status_pill.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final String stopName = 'Thrissur Bus Stand';

  final List<Bus> nearbyBuses = const [
    Bus(route: '47', from: 'Thrissur', to: 'Guruvayur', arrivingInMinutes: 2),
    Bus(route: '12', from: 'Thrissur', to: 'Palakkad', arrivingInMinutes: 8),
    Bus(route: '5C', from: 'Thrissur', to: 'Chalakudy', arrivingInMinutes: 15),
  ];

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _navIndex == 1
          ? const SettingsScreen()
          : SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 27, 16, 28),
          children: [
            // Header
            Row(
              children: const [
                Text(
                  'BusCue',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Companion',
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.accentOrange, size: 43),
                const SizedBox(width: 15),
                Text(
                  stopName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Center(child: StatusPill(label: 'Listening for buses...')),
            const SizedBox(height: 24),

            // Primary actions
            ActionCard(
              icon: Icons.directions_bus_filled_rounded,
              title: 'List Incoming Buses',
              subtitle: 'Hear buses arriving at this stop',
              backgroundColor: AppColors.accentOrange,
              onTap: () => _showSnack('Listing incoming buses...'),
            ),
            const SizedBox(height: 18),
            ActionCard(
              icon: Icons.notifications_rounded,
              title: 'Alert on Arrival',
              subtitle: 'Get audio alert when your bus arrives',
              backgroundColor: AppColors.accentOrange,
              onTap: () => _showSnack('Arrival alert set.'),
            ),
            const SizedBox(height: 18),
            ActionCard(
              icon: Icons.power_settings_new_rounded,
              title: 'Exit App',
              subtitle: 'Stop listening and close',
              backgroundColor: AppColors.exitRed,
              iconBackgroundColor: const Color(0xFF5F1318),
              foregroundColor: AppColors.textPrimary,
              onTap: () => _showSnack('Stopping and closing...'),
            ),
            const SizedBox(height: 34),

            // Nearby buses section
            Row(
              children: [
                Text(
                  'NEARBY BUSES',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider, thickness: 3, height: 3),
            const SizedBox(height: 18),

            ...nearbyBuses.map(
              (bus) => BusCard(
                bus: bus,
                onSpeak: () => _showSnack(
                  'Route ${bus.route} to ${bus.to}, ${bus.arrivalLabel.toLowerCase()}',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BusCueBottomNav(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}
