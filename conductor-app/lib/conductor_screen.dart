import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'models/route_model.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isDestroyed) async {}
}

class ConductorScreen extends StatefulWidget {
  final String? initialRouteId;
  final String? initialBusNumber;

  const ConductorScreen({super.key, this.initialRouteId, this.initialBusNumber});

  @override
  State<ConductorScreen> createState() => _ConductorScreenState();
}

class _ConductorScreenState extends State<ConductorScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  
  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _conductorNameController = TextEditingController();
  final TextEditingController _conductorPhoneController = TextEditingController();
  final TextEditingController _conductorBadgeController = TextEditingController();
  
  bool _isTripActive = false;
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  final String _conductorId = 'dummy_conductor_1';

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _requestPermissions();
    _fetchRoutes();
    _loadConductorProfile();
    _testRtdbWrite(); // Debug: verify RTDB write permission on startup
  }
  
  Future<void> _loadConductorProfile() async {
    try {
      final snapshot = await _firestore
          .collection('conductors')
          .doc(_conductorId)
          .get();

      final data = snapshot.data();
      if (data == null || !mounted) return;

      setState(() {
        _conductorNameController.text = data['name'] as String? ?? '';
        _conductorPhoneController.text = data['phone'] as String? ?? '';
        _conductorBadgeController.text = data['badge'] as String? ?? '';
      });
    } catch (e) {
      debugPrint('Could not load conductor profile: $e');
    }
  }

  /// Writes a test node to RTDB to confirm rules allow unauthenticated writes.
  /// Check Logcat for "RTDB test write OK" vs "RTDB test write FAILED".
  Future<void> _testRtdbWrite() async {
    try {
      await _rtdb.child('_debug/conductor_ping').set({
        'ts': ServerValue.timestamp,
        'msg': 'conductor-app alive',
      });
      debugPrint('✅ RTDB test write OK');
    } catch (e) {
      debugPrint('❌ RTDB test write FAILED: $e');
    }
  }
  
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'buscue_conductor_service',
        channelName: 'Buscue Conductor Service',
        channelDescription: 'Running GPS and BLE in background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.locationAlways,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();
    
    // Foreground task permission
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }

  Future<void> _fetchRoutes() async {
    try {
      final snapshot = await _firestore.collection('routes').get();
      final routes = snapshot.docs.map((doc) => RouteModel.fromMap(doc.id, doc.data())).toList();
      setState(() {
        _routes = routes;
        if (_routes.isNotEmpty) {
          if (widget.initialRouteId != null) {
            _selectedRoute = _routes.firstWhere((r) => r.id == widget.initialRouteId, orElse: () => _routes.first);
          } else {
            _selectedRoute = _routes.first;
          }
        }
        if (widget.initialBusNumber != null) {
          _busNumberController.text = widget.initialBusNumber!;
        }
      });
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
    }
  }

  Future<void> _startTrip() async {
    if (_conductorNameController.text.trim().isEmpty ||
        _conductorPhoneController.text.trim().isEmpty ||
        _selectedRoute == null ||
        _busNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter conductor details, select a route, and enter a bus number',
          ),
        ),
      );
      return;
    }

    try {
      await _firestore.collection('conductors').doc(_conductorId).set({
        'name': _conductorNameController.text.trim(),
        'phone': _conductorPhoneController.text.trim(),
        'badge': _conductorBadgeController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Could not save conductor profile: $e');
    }

    setState(() => _isTripActive = true);
    
    // 1. Start foreground task so Android doesn't kill the app
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Buscue Trip Active',
        notificationText: 'Sharing location for Route: ${_selectedRoute!.routeName}',
        callback: startCallback,
      );
    }

    // 2a. Immediately write to RTDB with last known position so the dashboard
    //     shows the bus right away — even before the stream fires its first event.
    void writeToRtdb(double lat, double lng) {
      _rtdb.child('active_trips/$_conductorId').set({
        'lat': lat,
        'lng': lng,
        'route': _selectedRoute!.id,
        'routeName': _selectedRoute!.routeName,
        'busNumber': _busNumberController.text,
        'conductorName': _conductorNameController.text.trim(),
        'conductorPhone': _conductorPhoneController.text.trim(),
        'conductorBadge': _conductorBadgeController.text.trim(),
        'bleUuid': _selectedRoute!.bleUuid,
        'timestamp': ServerValue.timestamp,
      }).catchError((e) => debugPrint('RTDB write error: $e'));
    }

    try {
      // Try last known position first (instant, no GPS warm-up needed)
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        setState(() => _currentPosition = lastPos);
        writeToRtdb(lastPos.latitude, lastPos.longitude);
        debugPrint('📍 Immediate RTDB write with last known position');
      } else {
        // No last known — request a fresh one (may take a few seconds)
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.low, // low = faster first fix
            forceLocationManager: true,
          ),
        );
        setState(() => _currentPosition = pos);
        writeToRtdb(pos.latitude, pos.longitude);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('GPS Error: $e')));
    }

    // 2b. Start continuous GPS stream for live updates
    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          // ⚠️ Force native Android Location Manager instead of Fused Location
          // Provider (Google Play Services). Required because we're using a web
          // Firebase config that lacks a proper Android SHA-1 certificate.
          forceLocationManager: true,
        ),
      ).listen(
        (Position position) {
          setState(() => _currentPosition = position);
          writeToRtdb(position.latitude, position.longitude);
        },
        onError: (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stream Error: $e')));
        },
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Init Error: $e')));
    }

    // 3. Start BLE Beacon
    try {
      await _blePeripheral.start(advertiseData: AdvertiseData(serviceUuid: _selectedRoute!.bleUuid));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('BLE Error: $e')));
    }
  }

  Future<void> _endTrip() async {
    setState(() {
      _isTripActive = false;
      _currentPosition = null;
      _selectedRoute = null;
      _busNumberController.clear();
    });

    // 1. Stop GPS Stream
    await _positionStream?.cancel();
    
    // 2. Stop foreground task
    await FlutterForegroundTask.stopService();

    // 3. Stop BLE
    await _blePeripheral.stop();

    // 4. Delete from Realtime DB
    await _rtdb.child('active_trips/$_conductorId').remove();
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _conductorNameController.dispose();
    _conductorPhoneController.dispose();
    _conductorBadgeController.dispose();
    _endTrip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F5F0),
        appBar: AppBar(
          title: const Text('Buscue Conductor'),
          backgroundColor: const Color(0xFF1B3A34),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conductor Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _conductorNameController,
                    decoration: const InputDecoration(
                      labelText: 'Conductor name',
                    ),
                  ),
                  TextField(
                    controller: _conductorPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                  ),
                  TextField(
                    controller: _conductorBadgeController,
                    decoration: const InputDecoration(
                      labelText: 'Badge / employee ID (optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Route', style: TextStyle(color: Color(0xFF1B3A34), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<RouteModel>(
                        isExpanded: true,
                        value: _selectedRoute,
                        items: _routes.map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.routeName),
                        )).toList(),
                        onChanged: _isTripActive ? null : (val) => setState(() => _selectedRoute = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bus Number', style: TextStyle(color: Color(0xFF1B3A34), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _busNumberController,
                        enabled: !_isTripActive,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 104',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isTripActive)
                Card(
                  color: const Color(0xFF3F7A5E),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TRIP ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(
                          'Conductor: ${_conductorNameController.text}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${_conductorPhoneController.text}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text('BLE UUID: ${_selectedRoute?.bleUuid}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(
                          'Location: ${_currentPosition?.latitude.toStringAsFixed(4) ?? '...'}, ${_currentPosition?.longitude.toStringAsFixed(4) ?? '...'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTripActive ? const Color(0xFFE53935) : const Color(0xFFE8A33D),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isTripActive ? _endTrip : _startTrip,
                child: Text(
                  _isTripActive ? 'END TRIP' : 'START TRIP',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
