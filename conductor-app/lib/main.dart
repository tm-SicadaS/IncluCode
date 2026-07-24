import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'launch_screen.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3A34),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F5F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B3A34),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, fontFamily: 'Roboto'),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Roboto'),
          labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
          bodySmall: TextStyle(fontSize: 12, color: Color(0xFF7C8A85), fontFamily: 'Roboto'),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
          helperStyle: TextStyle(fontSize: 12, color: Color(0xFF7C8A85), fontFamily: 'Roboto'),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE0DED8))),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8A33D),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ),
      home: const LaunchScreen(),
    );
  }
}
