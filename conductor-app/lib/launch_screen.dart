import 'package:flutter/material.dart';
import 'profile_screen.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Buscue', style: TextStyle(fontFamily: 'sans-serif',fontSize: 52,fontWeight: FontWeight.w800,letterSpacing: -1.2,height: 1,color: Color(0xFF1B3A34)),),
              const SizedBox(height: 24),
              const Text('Conductor app', style: TextStyle(fontFamily: 'sans-serif',fontSize: 19,fontWeight: FontWeight.w400,letterSpacing: 0.2,color: Color(0xFF1B3A34)),),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8A33D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: const Text('Get Started', style:TextStyle(fontFamily: 'sans-serif',fontSize: 16,fontWeight: FontWeight.w700,letterSpacing: 0.2,color: Colors.white,
)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
