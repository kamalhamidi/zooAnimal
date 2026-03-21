import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/animal.dart';

class AnswerButton extends StatelessWidget {
  final Animal animal;
  final bool? isCorrect; // null = not yet answered
  final bool isSelected;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.animal,
    this.isCorrect,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isCorrect == null) {
      // Not answered yet
      bgColor = Theme.of(context).cardTheme.color ?? Colors.white;
      borderColor = Colors.grey.withValues(alpha: 0.2);
      textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    } else if (isCorrect! && isSelected) {
      // Correct answer selected
      bgColor = AppColors.success.withValues(alpha: 0.15);
      borderColor = AppColors.success;
      textColor = AppColors.success;
    } else if (!isCorrect! && isSelected) {
      // Wrong answer selected
      bgColor = AppColors.error.withValues(alpha: 0.15);
      borderColor = AppColors.error;
      textColor = AppColors.error;
    } else if (isCorrect!) {
      // This was the correct answer but user picked another
      bgColor = AppColors.success.withValues(alpha: 0.1);
      borderColor = AppColors.success.withValues(alpha: 0.5);
      textColor = AppColors.success;
    } else {
      // Other wrong options
      bgColor = Colors.grey.withValues(alpha: 0.05);
      borderColor = Colors.grey.withValues(alpha: 0.15);
      textColor = Colors.grey;
    }

    Widget button = GestureDetector(
      onTap: isCorrect == null ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isSelected ? AppColors.softShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              animal.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                animal.name,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCorrect != null && isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                isCorrect! ? Icons.check_circle : Icons.cancel,
                color: isCorrect! ? AppColors.success : AppColors.error,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );

    // Apply animations
    if (isCorrect != null && isSelected) {
      if (isCorrect!) {
        button = button
            .animate()
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 200.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.05, 1.05),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
            );
      } else {
        button = button
            .animate()
            .shakeX(hz: 4, amount: 6, duration: 400.ms);
      }
    }

    return button;
  }
}
