import 'package:flutter/material.dart';
import 'app_theme.dart';

/// A labeled text field matching the wireframe's form fields:
/// small bold label above a rounded, icon-prefixed input.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: AppTheme.inputDecoration(
            hint: hint,
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 18, color: AppColors.textMuted),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
