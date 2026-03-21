/// ─── Animation Utilities ───
/// Reusable animations: bounce, pulse, confetti, skeleton shimmer,
/// matched geometry, and more.

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart' as confetti_lib;
import 'dart:math' as math;

// ─── PULSE ANIMATION ───
/// Pulsing scale effect for highlighting elements or sound playback.
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool animate;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 1.0,
    this.maxScale = 1.2,
    this.animate = true,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: widget.minScale, end: widget.maxScale)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && oldWidget.animate) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

// ─── SOUND WAVE PULSE ───
/// Animated concentric circles for sound wave visualization.
class SoundWavePulse extends StatefulWidget {
  final double size;
  final Color color;
  final bool isPlaying;

  const SoundWavePulse({
    Key? key,
    this.size = 100,
    this.color = const Color(0xFF2D7A3D),
    this.isPlaying = true,
  }) : super(key: key);

  @override
  State<SoundWavePulse> createState() => _SoundWavePulseState();
}

class _SoundWavePulseState extends State<SoundWavePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SoundWavePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _SoundWavePainter(
          animation: _controller,
          color: widget.color,
        ),
      ),
    );
  }
}

class _SoundWavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _SoundWavePainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final radius = (animation.value * maxRadius) + (i * maxRadius / 3);
      final opacity = 1.0 - ((radius % maxRadius) / maxRadius);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SoundWavePainter oldDelegate) => true;
}

// ─── BOUNCE ANIMATION ───
/// Spring-based bounce effect for interactive elements.
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final Duration duration;
  final bool trigger;

  const BounceAnimation({
    Key? key,
    required this.child,
    this.onComplete,
    this.duration = const Duration(milliseconds: 600),
    this.trigger = false,
  }) : super(key: key);

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(BounceAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: widget.child,
    );
  }
}

// ─── CONFETTI BURST ───
/// Particle burst effect for correct answers and achievements.
class ConfettiBurst extends StatefulWidget {
  final bool trigger;
  final Duration duration;
  final Color? particleColor;

  const ConfettiBurst({
    Key? key,
    this.trigger = false,
    this.duration = const Duration(milliseconds: 3000),
    this.particleColor,
  }) : super(key: key);

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> {
  late confetti_lib.ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = confetti_lib.ConfettiController(
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(ConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return confetti_lib.ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: confetti_lib.BlastDirectionality.explosive,
      emissionFrequency: 0.05,
      numberOfParticles: 50,
      gravity: 0.2,
      shouldLoop: false,
      particleDrag: 0.05,
      maxBlastForce: 100,
      minBlastForce: 75,
      startVelocity: 100,
      colors: [
        widget.particleColor ?? const Color(0xFF2D7A3D),
        const Color(0xFFFCD34D),
        const Color(0xFFD97706),
        const Color(0xFF059669),
      ],
      strokeColor: Colors.transparent,
      strokeWidth: 0,
    );
  }
}

// ─── FLOATING WIDGET ───
/// Floating up and fading out animation (like score popups).
class FloatingUp extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double distance;
  final VoidCallback? onComplete;

  const FloatingUp({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.distance = 100,
    this.onComplete,
  }) : super(key: key);

  @override
  State<FloatingUp> createState() => _FloatingUpState();
}

class _FloatingUpState extends State<FloatingUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -widget.distance),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}

// ─── FADE IN ANIMATION ───
/// Simple fade in from transparent to opaque.
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeIn({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeIn,
  }) : super(key: key);

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: widget.curve),
      child: widget.child,
    );
  }
}

// ─── SHIMMER LOADING ANIMATION ───
/// Horizontal shimmer effect for loading skeletons.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.7,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.05).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─── SLIDE IN FROM SIDE ───
/// Slide in animation from left/right.
class SlideInFromSide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool fromRight;
  final Curve curve;

  const SlideInFromSide({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.fromRight = false,
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<SlideInFromSide> createState() => _SlideInFromSideState();
}

class _SlideInFromSideState extends State<SlideInFromSide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final begin = widget.fromRight ? const Offset(1, 0) : const Offset(-1, 0);
    _slideAnimation = Tween<Offset>(begin: begin, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

// ─── ROTATE ANIMATION ───
/// Continuous rotation for loading spinners.
class RotatingLoader extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const RotatingLoader({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<RotatingLoader> createState() => _RotatingLoaderState();
}

class _RotatingLoaderState extends State<RotatingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: widget.child,
    );
  }
}

// ─── MATCHED GEOMETRY TRANSITION ───
/// Smooth Hero-like transition between pages.
extension MatchedGeometry on BuildContext {
  /// Create matched geometry hero
  Widget matchedGeometryHero({
    required String tag,
    required Widget child,
    bool enabled = true,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
        return Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: animation,
            child: toContext.widget,
          ),
        );
      },
      child: child,
    );
  }
}
