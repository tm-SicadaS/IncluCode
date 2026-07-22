import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── Shared BLE contract — must match conductor-app and admin-panel routes ──
const List<String> _kKnownBusUuids = [
  '12345678-1234-1234-1234-123456789abc',
  // Add additional route BLE UUIDs here as they are created in the admin panel
];

// Minimum RSSI (signal strength) to trigger announcement.
// -80 dBm ≈ about 5-10 metres. Lower the number = require closer proximity.
const int _kRssiThreshold = -80;

// How long (seconds) to pause scanning after a detection to avoid repeat speech.
const int _kCooldownSeconds = 15;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Force portrait — better for accessibility / screen reader navigation.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BuscueUserApp());
}

class BuscueUserApp extends StatelessWidget {
  const BuscueUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscue',
      debugShowCheckedModeBanner: false,
      // Pure black theme — maximum contrast for visual impairment.
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Colors.black,
        ),
      ),
      home: const BusScannerPage(),
    );
  }
}

class BusScannerPage extends StatefulWidget {
  const BusScannerPage({super.key});

  @override
  State<BusScannerPage> createState() => _BusScannerPageState();
}

class _BusScannerPageState extends State<BusScannerPage>
    with WidgetsBindingObserver {
  // ── State ─────────────────────────────────────────────────────────────────
  String _statusText = 'Starting up…';
  bool _busDetected = false;
  bool _isScanning = false;
  bool _isCoolingDown = false;

  // ── Services ──────────────────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  StreamSubscription<List<ScanResult>>? _scanSub;
  Timer? _cooldownTimer;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initTts();
    _requestPermissionsAndScan();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanSub?.cancel();
    _cooldownTimer?.cancel();
    FlutterBluePlus.stopScan();
    _tts.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isScanning && !_isCoolingDown) {
      _startScan();
    } else if (state == AppLifecycleState.paused) {
      _stopScan();
    }
  }

  bool _isMalayalam = false;

  // ── TTS setup ─────────────────────────────────────────────────────────────
  Future<void> _initTts() async {
    await _tts.setVolume(1.0); // max volume
    await _tts.setSpeechRate(0.45); // slightly slower for clarity

    // Prefer Malayalam; fall back to English.
    final languages = await _tts.getLanguages as List?;
    if (languages != null && (languages.contains('ml-IN') || languages.contains('ml_IN'))) {
      await _tts.setLanguage('ml-IN');
      _isMalayalam = true;
    } else {
      await _tts.setLanguage('en-IN');
      _isMalayalam = false;
    }
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  // ── Permissions ───────────────────────────────────────────────────────────
  Future<void> _requestPermissionsAndScan() async {
    _setStatus('Requesting permissions…');

    final statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final allGranted = statuses.values.every(
      (s) => s == PermissionStatus.granted,
    );

    if (!allGranted) {
      _setStatus(
        'Permissions denied.\nPlease grant Location & Bluetooth in Settings.',
      );
      await _speak('Permissions are required. Please open Settings.');
      return;
    }

    _startScan();
  }

  // ── BLE Scanning ──────────────────────────────────────────────────────────
  Future<void> _startScan() async {
    if (_isScanning || _isCoolingDown) return;

    // Check that Bluetooth adapter is on.
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _setStatus('Bluetooth is off.\nPlease turn on Bluetooth.');
      await _speak('Bluetooth is off. Please turn it on.');
      return;
    }

    setState(() {
      _busDetected = false;
      _isScanning = true;
      _statusText = 'Scanning for nearby buses…';
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 30),
      continuousUpdates: true,
    );

    _scanSub = FlutterBluePlus.scanResults.listen(_onScanResults);

    // Restart scan automatically when it times out.
    FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning && !_isCoolingDown && mounted) {
        Future.delayed(const Duration(seconds: 2), _startScan);
      }
    });
  }

  void _stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    FlutterBluePlus.stopScan();
    setState(() => _isScanning = false);
  }

  void _onScanResults(List<ScanResult> results) {
    if (_isCoolingDown) return;

    for (final result in results) {
      if (result.rssi < _kRssiThreshold) continue;

      // Check advertised service UUIDs for a known bus beacon.
      final advertisedUuids = result.advertisementData.serviceUuids
          .map((u) => u.toString().toLowerCase())
          .toList();

      final matchedUuid = _kKnownBusUuids.firstWhere(
        (known) => advertisedUuids.contains(known.toLowerCase()),
        orElse: () => '',
      );

      if (matchedUuid.isNotEmpty) {
        // Pass the human-readable local name if advertised, else fall back to UUID
        final localName = result.advertisementData.advName;
        final label = localName.isNotEmpty ? localName : matchedUuid;
        _onBusDetected(matchedUuid, label: label);
        return;
      }
    }
  }

  void _onBusDetected(String uuid, {String? label}) {
    if (_isCoolingDown) return;
    _stopScan();

    final shortId = uuid.length > 8 ? uuid.substring(0, 8) : uuid;
    final displayName = (label != null && label.isNotEmpty) ? label : shortId;

    setState(() {
      _busDetected = true;
      _isCoolingDown = true;
      _statusText = 'Bus Arrived!\n$displayName';
    });

    if (_isMalayalam) {
      _speak('$displayName ബസ്സ് അടുത്തു എത്തുന്നു.');
    } else {
      _speak('$displayName is approaching.');
    }

    // Resume scanning after cooldown.
    _cooldownTimer = Timer(Duration(seconds: _kCooldownSeconds), () {
      if (!mounted) return;
      setState(() {
        _isCoolingDown = false;
        _busDetected = false;
        _statusText = 'Scanning for nearby buses...';
      });
      _startScan();
    });
  }

  void _setStatus(String text) {
    if (!mounted) return;
    setState(() => _statusText = text);
  }

  // ── Re-announce on tap ────────────────────────────────────────────────────
  void _onTap() {
    _speak(_statusText.replaceAll(RegExp(r'[🚌…]'), '').trim());
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        onLongPress: () {
          // Demo trigger: Simulate bus arrival for single-phone testing!
          _onBusDetected(
            '12345678-1234-1234-1234-123456789abc',
            label: 'Route 104 - Express',
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Bus icon ─────────────────────────────────────────────
                Semantics(
                  label: _busDetected ? 'Bus has arrived' : 'Scanning for bus',
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Icon(
                      _busDetected
                          ? Icons.directions_bus_rounded
                          : Icons.bluetooth_searching_rounded,
                      key: ValueKey(_busDetected),
                      size: 96,
                      color: _busDetected ? Colors.greenAccent : Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // ── Main status text ──────────────────────────────────────
                Semantics(
                  liveRegion: true,
                  label: _statusText,
                  child: Text(
                    _statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _busDetected ? Colors.greenAccent : Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Tap-to-repeat hint ────────────────────────────────────
                Semantics(
                  hint: 'Tap anywhere to repeat the announcement',
                  child: const Text(
                    'Tap anywhere to repeat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 64),

                // ── Scanning indicator ────────────────────────────────────
                if (_isScanning && !_busDetected)
                  Semantics(
                    label: 'Actively scanning for Bluetooth beacons',
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white38,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Active scan',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                // ── Cooldown countdown ────────────────────────────────────
                if (_isCoolingDown && _busDetected)
                  Semantics(
                    label: 'Pausing before next scan',
                    child: const Text(
                      'Resuming scan shortly…',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
