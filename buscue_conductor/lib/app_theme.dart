import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------
/// BusCue — Shared Theme
/// -----------------------------------------------------------------------
/// Central place for colors, spacing, and reusable decorations so every
/// screen stays visually consistent with the wireframe. Update values
/// here to restyle the whole app at once.
/// -----------------------------------------------------------------------

class AppColors {
  AppColors._();

  static const Color deepGreen = Color(0xFF1B3A34); // brand / dark surfaces
  static const Color cream = Color(0xFFF7F5F0); // light surfaces / bg
  static const Color orange = Color(0xFFE8A33D); // primary accent / CTA
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE0DED8);
  static const Color textDark = Color(0xFF1B3A34);
  static const Color textMuted = Color(0xFF7C8A85);
  static const Color success = Color(0xFF3F7A5E);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle stepLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepGreen,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static InputDecoration inputDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.inputFill,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: border(AppColors.inputBorder),
      enabledBorder: border(AppColors.inputBorder),
      focusedBorder: border(AppColors.deepGreen),
    );
  }
}
