import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'conductor_screen.dart';

class TripSetupScreen extends StatefulWidget {
  const TripSetupScreen({super.key});

  @override
  State<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends State<TripSetupScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _routes = [];
  Map<String, dynamic>? _selectedRoute;
  final TextEditingController _busNumberController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    try {
      final snapshot = await _firestore.collection('routes').get();
      _routes = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('Routes fetch failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _startTrip() {
    if (_selectedRoute == null || _busNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select route and enter bus number')));
      return;
    }

    // Use existing ConductorScreen logic by navigating there and passing initial params
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConductorScreen(initialRouteId: _selectedRoute!['id'], initialBusNumber: _busNumberController.text.trim())));
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Setup'), backgroundColor: const Color(0xFF1B3A34)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<dynamic>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Select route'),
              items: _routes.map((r) => DropdownMenuItem(value: r, child: Text(r['routeName'] ?? r['name'] ?? r['id']))).toList(),
              onChanged: (v) => setState(() => _selectedRoute = v as Map<String, dynamic>?),
            ),
            const SizedBox(height: 12),
            TextField(controller: _busNumberController, decoration: const InputDecoration(labelText: 'Bus number')),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8A33D),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _startTrip,
              child: const Text('Confirm & Start'),
            ),
          ],
        ),
      ),
    );
  }
}
