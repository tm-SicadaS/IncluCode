import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

// ─── Dynamic BLE Contract ──
// We no longer hardcode UUIDs. We listen to Firebase RTDB 'active_trips'
// to know EXACTLY which buses are currently on the road!

// Minimum RSSI (signal strength) to trigger announcement.
// -95 dBm = very weak signal, ensuring we pick it up even if phones are far or antennas are weak.
const int _kRssiThreshold = -95;

// How long (seconds) to pause scanning after a detection to avoid repeat speech.
const int _kCooldownSeconds = 15;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<DatabaseEvent>? _rtdbSub;
  Timer? _cooldownTimer;

  // Key: bleUuid, Value: {'routeName': '...', 'busNumber': '...'}
  final Map<String, Map<String, String>> _liveBuses = {};

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initTts();
    
    // Listen to scanning state to restart it when it times out.
    _isScanningSub = FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning && !_isCoolingDown && mounted) {
        Future.delayed(const Duration(seconds: 2), _startScan);
      }
    });

    _listenToLiveBuses();
    _requestPermissionsAndScan();
  }

  void _listenToLiveBuses() {
    _rtdbSub = _rtdb.child('active_trips').onValue.listen((event) {
      if (!mounted) return;
      _liveBuses.clear();
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          final trip = value as Map<dynamic, dynamic>;
          final uuid = trip['bleUuid']?.toString().toLowerCase() ?? '';
          final routeName = trip['routeName']?.toString() ?? '';
          final busNumber = trip['busNumber']?.toString() ?? '';
          if (uuid.isNotEmpty) {
            _liveBuses[uuid] = {
              'routeName': routeName,
              'busNumber': busNumber,
            };
          }
        });
      }
      debugPrint('Live buses updated from RTDB: ${_liveBuses.length} active.');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    _rtdbSub?.cancel();
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

    _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen(_onScanResults);
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

      if (advertisedUuids.isNotEmpty) {
        debugPrint('Found BLE Device: ${result.device.remoteId} | RSSI: ${result.rssi} | UUIDs: $advertisedUuids');
      }

      // Check if any of the advertised UUIDs match a LIVE bus on the road
      String matchedUuid = '';
      String routeName = '';
      String busNumber = '';

      for (final advertised in advertisedUuids) {
        if (_liveBuses.containsKey(advertised)) {
          matchedUuid = advertised;
          routeName = _liveBuses[advertised]!['routeName'] ?? '';
          busNumber = _liveBuses[advertised]!['busNumber'] ?? '';
          break;
        }
      }

      if (matchedUuid.isNotEmpty) {
        // Pass the live routeName from RTDB as the label
        final localName = result.advertisementData.advName;
        final label = localName.isNotEmpty ? localName : routeName;
        _onBusDetected(matchedUuid, routeName: label, busNumber: busNumber);
        return;
      }
    }
  }

  void _onBusDetected(String uuid, {String? routeName, String? busNumber}) {
    if (_isCoolingDown) return;
    _stopScan();

    final shortId = uuid.length > 8 ? uuid.substring(0, 8) : uuid;
    final rName = (routeName != null && routeName.isNotEmpty) ? routeName : shortId;
    final bNum = (busNumber != null && busNumber.isNotEmpty) ? busNumber : '';

    final busInfoText = bNum.isNotEmpty ? '$rName (Bus $bNum)' : rName;

    setState(() {
      _busDetected = true;
      _isCoolingDown = true;
      _statusText = 'Bus Arrived!\n$busInfoText';
    });

    if (_isMalayalam) {
      if (bNum.isNotEmpty) {
        _speak('$rName റൂട്ടിലെ $bNum നമ്പർ ബസ്സ് അടുത്തു എത്തുന്നു.');
      } else {
        _speak('$rName ബസ്സ് അടുത്തു എത്തുന്നു.');
      }
    } else {
      if (bNum.isNotEmpty) {
        _speak('Bus $bNum on route $rName is approaching.');
      } else {
        _speak('$rName is approaching.');
      }
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
            _onBusDetected(
              '12345678-1234-1234-1234-123456789abc',
              routeName: 'Route 104 - Express',
              busNumber: '4676',
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
