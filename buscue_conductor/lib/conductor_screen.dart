import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------
/// BusCue — Conductor App
/// -----------------------------------------------------------------------
/// This screen lets the conductor:
///   1. Select their assigned route
///   2. Toggle trip status (Start / Stop broadcasting)
///   3. See a simple status indicator confirming broadcast is active
///
/// GPS streaming and BLE/backend integration are left as TODOs — this
/// file only covers the UI + local state.
/// -----------------------------------------------------------------------

void main() {
  runApp(const BusCueConductorApp());
}

class BusCueConductorApp extends StatelessWidget {
  const BusCueConductorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusCue — Conductor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3A34), // deep green, matches deck
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5F0),
      ),
      home: const ConductorHomeScreen(),
    );
  }
}

class ConductorHomeScreen extends StatefulWidget {
  const ConductorHomeScreen({super.key});

  @override
  State<ConductorHomeScreen> createState() => _ConductorHomeScreenState();
}

class _ConductorHomeScreenState extends State<ConductorHomeScreen> {
  
  final List<String> _routes = const [
    'Route 47 — Thrissur to Guruvayur',
    'Route 12 — Kochi to Aluva',
    'Route 89 — Kollam to Kottarakkara',
  ];

  String? _selectedRoute;
  bool _isTripActive = false;

  void _toggleTrip() {
    if (_selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a route first.')),
      );
      return;
    }

    setState(() {
      _isTripActive = !_isTripActive;
    });

    if (_isTripActive) {
      // TODO: Start GPS location streaming + BLE broadcast here.
      // e.g. LocationService.startBroadcast(routeId: selectedRouteId);
      debugPrint('Trip started for: $_selectedRoute');
    } else {
      // TODO: Stop GPS location streaming + BLE broadcast here.
      // e.g. LocationService.stopBroadcast();
      debugPrint('Trip stopped for: $_selectedRoute');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BusCue — Conductor'),
        backgroundColor: const Color(0xFF1B3A34),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildStatusCard(),
              const SizedBox(height: 28),
              const Text(
                'Select your route',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B3A34),
                ),
              ),
              const SizedBox(height: 10),
              _buildRouteDropdown(),
              const Spacer(),
              _buildTripToggleButton(),
              const SizedBox(height: 12),
              Text(
                _isTripActive
                    ? 'Broadcasting live location and route to commuters.'
                    : 'Not broadcasting. Start your trip when ready.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final Color statusColor =
        _isTripActive ? const Color(0xFFE8A33D) : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: _isTripActive
                  ? [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
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
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedRoute ?? 'No route selected',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildRouteDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRoute,
          isExpanded: true,
          hint: const Text('Choose a route'),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _routes.map((route) {
            return DropdownMenuItem<String>(
              value: route,
              child: Text(route, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          // Disable changing route mid-trip to avoid inconsistent broadcasts.
          onChanged: _isTripActive
              ? null
              : (value) {
                  setState(() {
                    _selectedRoute = value;
                  });
                },
        ),
      ),
    );
  }

  Widget _buildTripToggleButton() {
    return ElevatedButton(
      onPressed: _toggleTrip,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isTripActive ? Colors.redAccent.shade200 : const Color(0xFFE8A33D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: Text(
        _isTripActive ? 'STOP TRIP' : 'START TRIP',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
