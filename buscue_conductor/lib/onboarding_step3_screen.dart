import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'conductor_dashboard_screen.dart';
import 'data/app_session.dart';
import 'models/app_models.dart';
import 'primary_button.dart';
import 'services/location_service.dart';

/// The driver manually selects an approved route, while location is detected
/// directly from the phone. Firestore will replace the temporary route list.
class OnboardingStep3Screen extends StatefulWidget {
  const OnboardingStep3Screen({super.key});

  @override
  State<OnboardingStep3Screen> createState() => _OnboardingStep3ScreenState();
}

class _OnboardingStep3ScreenState extends State<OnboardingStep3Screen> {
  final _session = AppSession.instance;
  final _locationService = const LocationService();
  final _busNumberController = TextEditingController();
  late BusRoute _route = _session.routes.first;
  LocationPosition? _currentPosition;
  bool _isLocating = false;

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await _locationService.requestCurrentPosition();
      if (!mounted) return;
      setState(() => _currentPosition = position);
    } on LocationServiceDisabledException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turn on Location services, then try again.')),
        );
      }
    } on PermissionDeniedException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Location permission was denied.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get your current location.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _confirm() {
    if (_busNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the bus number for this trip.')),
      );
      return;
    }
    _session.currentTrip = TripDraft(
      route: _route,
      busNumber: _busNumberController.text.trim(),
      shift: 'Current trip',
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ConductorDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Set Up This Trip', style: AppTextStyles.screenTitle),
                      SizedBox(height: 4),
                      Text('STEP 2 OF 2', style: AppTextStyles.stepLabel),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Bus number for this trip',
                          style: AppTextStyles.fieldLabel,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _busNumberController,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (_) => setState(() {}),
                          decoration: AppTheme.inputDecoration(
                            hint: 'KL 08 AB 1234',
                            prefixIcon: const Icon(Icons.directions_bus_outlined),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Select the route for this trip',
                          style: AppTextStyles.fieldLabel,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<BusRoute>(
                          initialValue: _route,
                          isExpanded: true,
                          decoration: AppTheme.inputDecoration(
                            hint: 'Choose a route',
                            prefixIcon: const Icon(Icons.route_outlined),
                          ),
                          items: _session.routes
                              .map(
                                (route) => DropdownMenuItem(
                                  value: route,
                                  child: Text(
                                    route.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (route) {
                            if (route != null) setState(() => _route = route);
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'For now, select the route manually. Once connected, '
                          'this list comes from Firestore and can suggest nearby routes.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 24),
                        _locationCard(),
                        const SizedBox(height: 24),
                        _tripCard(),
                        const SizedBox(height: 24),
                        const Text('ROUTE STOPS', style: AppTextStyles.sectionLabel),
                        const SizedBox(height: 8),
                        ..._route.stops.map(
                          (stop) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: AppColors.deepGreen,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(stop.name)),
                                Text(
                                  stop.time,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Confirm Route & Start',
                  icon: Icons.arrow_forward,
                  backgroundColor: AppColors.deepGreen,
                  onPressed: _confirm,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _locationCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.my_location, color: AppColors.deepGreen),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Current location',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _currentPosition == null
                  ? 'Detect your phone location before starting the trip.'
                  : 'Location detected: ${_currentPosition!.latitude.toStringAsFixed(5)}, '
                      '${_currentPosition!.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLocating ? null : _detectLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.gps_fixed),
              label: Text(_isLocating ? 'Detecting location...' : 'Detect my location'),
            ),
          ],
        ),
      );

  Widget _tripCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_bus_outlined, color: AppColors.deepGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trip setup', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    _busNumberController.text.trim().isEmpty
                        ? 'Enter the current bus number above.'
                        : _busNumberController.text.trim(),
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
