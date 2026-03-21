import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';

class TimerRing extends StatelessWidget {
  final double timeRemaining;
  final double maxTime;

  const TimerRing({
    super.key,
    required this.timeRemaining,
    this.maxTime = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (timeRemaining / maxTime).clamp(0.0, 1.0);
    final isWarning = timeRemaining < 3.0;
    final color = isWarning ? AppColors.error : AppColors.secondaryOrange;

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: const Size(80, 80),
            painter: _TimerRingPainter(
              progress: progress,
              color: color,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          // Time text
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.robotoMono(
              fontSize: isWarning ? 22 : 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            child: Text(timeRemaining.ceil().toString()),
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
