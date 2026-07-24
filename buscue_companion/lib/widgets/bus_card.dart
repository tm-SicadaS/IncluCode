import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../theme/app_colors.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
  final VoidCallback onSpeak;

  const BusCard({super.key, required this.bus, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(28, 25, 28, 23),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route ${bus.route}',
                style: const TextStyle(
                  color: AppColors.accentOrange,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                ),
              ),
              InkWell(
                onTap: onSpeak,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.accentOrange,
                    size: 29,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${bus.from} \u2192 ${bus.to}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            bus.arrivalLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
