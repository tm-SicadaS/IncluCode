import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.backgroundColor = AppColors.accentOrange,
    this.iconBackgroundColor = const Color(0xFF09251B),
    this.foregroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          height: 172,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: foregroundColor, size: 43),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: .98,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: foregroundColor.withValues(alpha: 0.75),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
