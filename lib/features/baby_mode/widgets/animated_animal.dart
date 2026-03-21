import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/animal.dart';

class AnimatedAnimal extends StatefulWidget {
  final Animal animal;
  final Color backgroundColor;
  final VoidCallback onBack;

  const AnimatedAnimal({
    super.key,
    required this.animal,
    required this.backgroundColor,
    required this.onBack,
  });

  @override
  State<AnimatedAnimal> createState() => _AnimatedAnimalState();
}

class _AnimatedAnimalState extends State<AnimatedAnimal>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _sparkleController;
  final List<_Sparkle> _sparkles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Generate sparkles
    for (int i = 0; i < 12; i++) {
      _sparkles.add(_Sparkle(
        angle: (i / 12) * 2 * pi,
        distance: 80 + _random.nextDouble() * 60,
        size: 8 + _random.nextDouble() * 12,
        emoji: ['✨', '⭐', '💫', '🌟'][_random.nextInt(4)],
      ));
    }

    _startBounce();
  }

  void _startBounce() async {
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      _bounceController.forward();
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _bounceController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            // Sparkles
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: _sparkles.map((sparkle) {
                        final progress =
                            (_sparkleController.value + sparkle.angle / (2 * pi)) % 1.0;
                        final opacity =
                            (sin(progress * pi * 2) * 0.5 + 0.5).clamp(0.0, 1.0);
                        final distance = sparkle.distance * progress;

                        return Positioned(
                          left: 150 + cos(sparkle.angle) * distance - sparkle.size / 2,
                          top: 150 + sin(sparkle.angle) * distance - sparkle.size / 2,
                          child: Opacity(
                            opacity: opacity,
                            child: Text(
                              sparkle.emoji,
                              style: TextStyle(fontSize: sparkle.size),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated emoji
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      final scale = 1.0 +
                          _bounceController.value * 0.15 *
                              sin(_bounceController.value * pi);
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          widget.animal.emoji,
                          style: const TextStyle(fontSize: 120),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Animal name
                  Text(
                    widget.animal.name,
                    style: GoogleFonts.fredoka(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown[800],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    widget.animal.ttsLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown[600],
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                ],
              ),
            ),

            // Back button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '⬅ Back',
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown[800],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sparkle {
  final double angle;
  final double distance;
  final double size;
  final String emoji;

  _Sparkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.emoji,
  });
}
