import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';

class StreakBar extends StatelessWidget {
  final int streak;

  const StreakBar({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: streak >= 3
              ? [AppColors.streakFire, AppColors.streakGlow]
              : [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: streak >= 3
            ? [
                BoxShadow(
                  color: AppColors.streakFire.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            streak >= 3 ? '🔥' : '⚡',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
