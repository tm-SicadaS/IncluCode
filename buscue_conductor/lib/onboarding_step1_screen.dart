import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_text_field.dart';
import 'primary_button.dart';
import 'onboarding_step2_screen.dart';
import 'data/app_session.dart';
import 'models/app_models.dart';

/// Screen 2 — Step 1 of 3
/// "Set Up Your Profile": conductor's personal + vehicle identifiers.
class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _conductorIdController = TextEditingController();
  final _vehicleRegController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _conductorIdController.dispose();
    _vehicleRegController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_fullNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your name and phone number.')),
      );
      return;
    }
    AppSession.instance.saveStaff([
      StaffMember(
        id: _conductorIdController.text.trim().isEmpty
            ? _phoneController.text.trim()
            : _conductorIdController.text.trim(),
        name: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: StaffRole.conductor,
        badgeNumber: _conductorIdController.text.trim().isEmpty
            ? null
            : _conductorIdController.text.trim(),
      ),
    ]);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnboardingStep2Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    color: AppColors.textDark,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Up Your Profile',
                        style: AppTextStyles.screenTitle),
                    SizedBox(height: 4),
                    Text('STEP 1 OF 3', style: AppTextStyles.stepLabel),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Ramesh Kumar',
                        icon: Icons.person_outline,
                        controller: _fullNameController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone Number',
                        hint: '98765 43210',
                        icon: Icons.call_outlined,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Email Address (Optional)',
                        hint: 'ramesh@example.com',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Conductor ID / Badge No.',
                        hint: 'KL-CND-2023-884',
                        icon: Icons.badge_outlined,
                        controller: _conductorIdController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Vehicle Registration No.',
                        hint: 'KL 08 AB 1234',
                        icon: Icons.directions_bus_outlined,
                        controller: _vehicleRegController,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Next',
                icon: Icons.arrow_forward,
                onPressed: _goNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
