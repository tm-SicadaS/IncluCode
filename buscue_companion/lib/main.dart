import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BusCueApp());
}

class BusCueApp extends StatelessWidget {
  const BusCueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusCue Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentOrange,
          brightness: Brightness.dark,
          surface: AppColors.background,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
