import 'package:flutter/material.dart';

/// A virtual joystick widget placed at the bottom-left of the screen.
///
/// The user drags within the joystick base; a callback reports the normalised
/// direction vector (dx, dy) ∈ [-1, 1].  Releasing snaps the knob back with
/// a spring animation.
class ZooJoystick extends StatefulWidget {
  final ValueChanged<Offset> onDirectionChanged;
  final double baseSize;
  final double knobSize;

  const ZooJoystick({
    super.key,
    required this.onDirectionChanged,
    this.baseSize = 120,
    this.knobSize = 50,
  });

  @override
  State<ZooJoystick> createState() => _ZooJoystickState();
}

class _ZooJoystickState extends State<ZooJoystick>
    with SingleTickerProviderStateMixin {
  Offset _knobOffset = Offset.zero;
  late AnimationController _springController;
  late Animation<Offset> _springAnimation;

  double get _maxDrag => (widget.baseSize - widget.knobSize) / 2;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _springAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
    _springController.addListener(() {
      setState(() => _knobOffset = _springAnimation.value);
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final newOffset = _knobOffset + d.delta;
    final distance = newOffset.distance;
    final clamped = distance > _maxDrag
        ? Offset.fromDirection(newOffset.direction, _maxDrag)
        : newOffset;

    setState(() => _knobOffset = clamped);

    // Normalise to [-1, 1]
    final norm = Offset(
      clamped.dx / _maxDrag,
      clamped.dy / _maxDrag,
    );
    widget.onDirectionChanged(norm);
  }

  void _onPanEnd(DragEndDetails _) {
    _springAnimation =
        Tween<Offset>(begin: _knobOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
    _springController
      ..reset()
      ..forward();

    widget.onDirectionChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final baseRadius = widget.baseSize / 2;
    final knobRadius = widget.knobSize / 2;

    return SizedBox(
      width: widget.baseSize,
      height: widget.baseSize,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: _JoystickPainter(
            baseRadius: baseRadius,
            knobRadius: knobRadius,
            knobOffset: _knobOffset,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final double baseRadius;
  final double knobRadius;
  final Offset knobOffset;

  _JoystickPainter({
    required this.baseRadius,
    required this.knobRadius,
    required this.knobOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Base circle — glassmorphic
    canvas.drawCircle(
      center,
      baseRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      center,
      baseRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Direction indicators (subtle arrows)
    final arrowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const arrowLen = 10.0;
    const arrowInset = 14.0;
    // Up
    canvas.drawLine(
      Offset(center.dx, center.dy - baseRadius + arrowInset),
      Offset(center.dx, center.dy - baseRadius + arrowInset + arrowLen),
      arrowPaint,
    );
    // Down
    canvas.drawLine(
      Offset(center.dx, center.dy + baseRadius - arrowInset),
      Offset(center.dx, center.dy + baseRadius - arrowInset - arrowLen),
      arrowPaint,
    );
    // Left
    canvas.drawLine(
      Offset(center.dx - baseRadius + arrowInset, center.dy),
      Offset(center.dx - baseRadius + arrowInset + arrowLen, center.dy),
      arrowPaint,
    );
    // Right
    canvas.drawLine(
      Offset(center.dx + baseRadius - arrowInset, center.dy),
      Offset(center.dx + baseRadius - arrowInset - arrowLen, center.dy),
      arrowPaint,
    );

    // Knob
    final knobCenter = center + knobOffset;

    // Knob shadow
    canvas.drawCircle(
      knobCenter + const Offset(0, 2),
      knobRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Knob glow
    final knobGradient = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.6),
        Colors.white.withValues(alpha: 0.25),
        Colors.white.withValues(alpha: 0.1),
      ],
    ).createShader(Rect.fromCircle(center: knobCenter, radius: knobRadius));

    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()..shader = knobGradient,
    );

    // Knob border
    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_JoystickPainter old) =>
      old.knobOffset != knobOffset;
}
