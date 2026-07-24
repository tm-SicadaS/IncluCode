import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _conductorId = 'dummy_conductor_1';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _badgeController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await _firestore.collection('conductors').doc(_conductorId).get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] as String? ?? '';
        _phoneController.text = data['phone'] as String? ?? '';
        _badgeController.text = data['badge'] as String? ?? '';
      }
    } catch (e) {
      debugPrint('Profile load failed: $e');
    } finally {
      setState(() => _loading = false);
    }

    // If profile already complete, skip to trip setup
    if (_nameController.text.trim().isNotEmpty && _phoneController.text.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TripSetupScreen()));
      });
    }
  }

  Future<void> _saveAndNext() async {
    try {
      await _firestore.collection('conductors').doc(_conductorId).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'badge': _badgeController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TripSetupScreen()));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Conductor Profile'), backgroundColor: const Color(0xFF1B3A34)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: _badgeController, decoration: const InputDecoration(labelText: 'Badge / employee ID (optional)')),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8A33D),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _saveAndNext,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
