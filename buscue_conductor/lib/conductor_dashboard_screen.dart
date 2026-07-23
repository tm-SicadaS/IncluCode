import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'primary_button.dart';
import 'data/app_session.dart';

/// UI-only trip setup screen. Replace [_routes] with backend data later.
class ConductorDashboardScreen extends StatefulWidget {
  const ConductorDashboardScreen({super.key});

  @override
  State<ConductorDashboardScreen> createState() =>
      _ConductorDashboardScreenState();
}

class _ConductorDashboardScreenState extends State<ConductorDashboardScreen> {
  final _session = AppSession.instance;
  bool _isTripActive = false;

  void _toggleTrip() {
    if (!_isTripActive && _session.currentTrip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select a route and enter the bus number first.')),
      );
      return;
    }
    setState(() => _isTripActive = !_isTripActive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BusCue - Conductor')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _statusCard(),
              const SizedBox(height: 28),
              const Text('Selected route', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
              _routeSummary(),
              const SizedBox(height: 18),
              const Spacer(),
              PrimaryButton(
                label: _isTripActive ? 'Stop Trip' : 'Start Trip',
                icon: _isTripActive
                    ? Icons.stop_circle_outlined
                    : Icons.play_arrow,
                backgroundColor:
                    _isTripActive ? Colors.redAccent : AppColors.orange,
                onPressed: _toggleTrip,
              ),
              const SizedBox(height: 12),
              Text(
                _isTripActive
                    ? 'Trip active - UI demo mode.'
                    : 'Review your route and bus number, then begin.',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeSummary() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Text(_session.currentTrip == null
            ? 'No route selected'
            : '${_session.currentTrip!.route.name}\n${_session.currentTrip!.busNumber}'),
      );

  Widget _statusCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.deepGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _isTripActive ? AppColors.orange : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isTripActive ? 'TRIP ACTIVE' : 'TRIP INACTIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _session.currentTrip?.route.name ?? 'No route selected',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
