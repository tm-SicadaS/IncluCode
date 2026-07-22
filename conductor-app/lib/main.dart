import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'conductor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ConductorApp());
}

class ConductorApp extends StatelessWidget {
  const ConductorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscue Conductor',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ConductorScreen(),
    );
  }
}
