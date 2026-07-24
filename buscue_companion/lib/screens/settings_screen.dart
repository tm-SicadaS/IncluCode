import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _voiceSpeed = .5;
  double _volume = .8;
  String _language = 'English';

  void _testVoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test voice: Your bus is arriving in two minutes.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
        children: [
          const _AccessibilityBanner(
            message:
                'Screen reader announces: Settings screen. 5 sections: Voice and Audio, Language, My Stop, Notifications, About. Swipe to navigate.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 31,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel(icon: Icons.volume_up_outlined, text: 'VOICE & AUDIO'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF244434)),
            ),
            child: Column(
              children: [
                _SliderSetting(
                  title: 'Voice Speed',
                  valueLabel: _voiceSpeedLabel,
                  value: _voiceSpeed,
                  startLabel: 'Slow',
                  endLabel: 'Fast',
                  semanticLabel: 'Voice speed slider. Currently $_voiceSpeedLabel.',
                  onChanged: (value) => setState(() => _voiceSpeed = value),
                ),
                const Divider(color: AppColors.divider, height: 28),
                _SliderSetting(
                  title: 'Volume',
                  valueLabel: '${(_volume * 100).round()}%',
                  value: _volume,
                  startLabel: 'Low',
                  endLabel: 'High',
                  semanticLabel: 'Volume slider. Currently ${(_volume * 100).round()} percent.',
                  onChanged: (value) => setState(() => _volume = value),
                ),
                const Divider(color: AppColors.divider, height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _testVoice,
                    icon: const Icon(Icons.play_arrow_rounded, size: 23),
                    label: const Text('Test Voice'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.accentOrange, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Plays a sample voice announcement',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionLabel(icon: Icons.translate_rounded, text: 'LANGUAGE'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF244434)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _language,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                iconEnabledColor: AppColors.accentOrange,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                items: const ['English', 'Malayalam', 'Hindi']
                    .map((language) => DropdownMenuItem(value: language, child: Text(language)))
                    .toList(),
                onChanged: (language) {
                  if (language != null) setState(() => _language = language);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _voiceSpeedLabel {
    if (_voiceSpeed < .34) return 'Slow';
    if (_voiceSpeed > .66) return 'Fast';
    return 'Normal';
  }
}

class _AccessibilityBanner extends StatelessWidget {
  final String message;

  const _AccessibilityBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: const BoxDecoration(
        color: Color(0xFF0B2B1B),
        border: Border(left: BorderSide(color: AppColors.accentOrange, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign_outlined, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFD5B958),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 17),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
        ],
      );
}

class _SliderSetting extends StatelessWidget {
  final String title;
  final String valueLabel;
  final String startLabel;
  final String endLabel;
  final String semanticLabel;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.startLabel,
    required this.endLabel,
    required this.semanticLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
              Text(valueLabel,
                  style: const TextStyle(
                      color: AppColors.accentOrange, fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          Semantics(
            label: semanticLabel,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accentOrange,
                inactiveTrackColor: const Color(0xFF0A2118),
                thumbColor: AppColors.textPrimary,
                overlayColor: AppColors.accentOrange.withValues(alpha: 0.15),
                trackHeight: 7,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(startLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text(endLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      );
}
