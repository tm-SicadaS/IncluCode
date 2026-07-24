import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'onboarding_step1_screen.dart';
import 'primary_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  void _continueToProfile(BuildContext context, String provider) {
    // TODO(firebase_auth): sign in with the selected provider, then load the
    // profile/staff records for the authenticated user.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in will be connected to Firebase.')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingStep1Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(backgroundColor: AppColors.cream, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text('Welcome back', style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              const Text('Choose the quickest way to continue.',
                  style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 32),
              _providerButton(context, 'Continue with Google', Icons.g_mobiledata),
              const SizedBox(height: 12),
              _providerButton(context, 'Continue with Facebook', Icons.facebook),
              const SizedBox(height: 20),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or')), Expanded(child: Divider())]),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Use phone number',
                icon: Icons.phone_outlined,
                onPressed: () => _continueToProfile(context, 'Phone'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OnboardingStep1Screen()),
                ),
                child: const Text('New here? Create your profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerButton(BuildContext context, String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () => _continueToProfile(context, label.replaceFirst('Continue with ', '')),
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
    );
  }
}
