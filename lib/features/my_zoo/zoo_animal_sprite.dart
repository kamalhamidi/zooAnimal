import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/animal.dart';

/// A single animal placed in the world map.
///
/// Shows the animal emoji with:
/// - Idle bobbing animation
/// - Circular income-progress ring
/// - Glow when player is nearby
/// - Name label
/// - Tap callback
class ZooAnimalSprite extends StatefulWidget {
  final Animal animal;
  final int coinsPerTick;
  final int intervalSeconds;
  final int secondsLeft;
  final bool isNearby;
  final VoidCallback onTap;

  const ZooAnimalSprite({
    super.key,
    required this.animal,
    required this.coinsPerTick,
    required this.intervalSeconds,
    required this.secondsLeft,
    required this.isNearby,
    required this.onTap,
  });

  @override
  State<ZooAnimalSprite> createState() => _ZooAnimalSpriteState();
}

class _ZooAnimalSpriteState extends State<ZooAnimalSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.intervalSeconds > 0
        ? 1.0 - (widget.secondsLeft / widget.intervalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _idleController,
        builder: (context, child) {
          final bobY = math.sin(_idleController.value * math.pi) * 3;
          return Transform.translate(
            offset: Offset(0, -bobY),
            child: child,
          );
        },
        child: SizedBox(
          width: 90,
          height: 110,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Proximity glow
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow ring when nearby
                  if (widget.isNearby)
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFCD34D).withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),

                  // Income progress ring
                  SizedBox(
                    width: 66,
                    height: 66,
                    child: CustomPaint(
                      painter: _ProgressRingPainter(
                        progress: progress,
                        isNearby: widget.isNearby,
                      ),
                      child: Center(
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.92),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.animal.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Coin badge
                  Positioned(
                    top: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '+${widget.coinsPerTick}',
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Name label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.animal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              // Countdown
              Text(
                '${widget.secondsLeft}s',
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a circular progress ring around the animal emoji.
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final bool isNearby;

  _ProgressRingPainter({required this.progress, required this.isNearby});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Progress arc
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = isNearby
              ? const Color(0xFFFCD34D)
              : const Color(0xFF4CAF50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.isNearby != isNearby;
}
