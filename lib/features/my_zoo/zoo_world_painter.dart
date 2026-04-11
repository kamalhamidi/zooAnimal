import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'zoo_world_data.dart';

/// Custom painter that renders the zoo terrain: grass, biome tints,
/// dirt paths, ponds, and a perimeter fence.
///
/// This painter is intentionally static (`shouldRepaint` → false) so Flutter
/// rasterises the terrain once and reuses the cache while the camera pans.
class ZooWorldPainter extends CustomPainter {
  ZooWorldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawGrass(canvas, size);
    _drawBiomeTints(canvas, size);
    _drawPaths(canvas, size);
    _drawPonds(canvas, size);
    _drawFence(canvas, size);
    _drawGrassDetails(canvas, size);
  }

  // ─── Sky gradient at very top ───
  void _drawSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.08);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFB3E5FC).withValues(alpha: 0.5),
        const Color(0xFF81D4FA).withValues(alpha: 0.1),
        Colors.transparent,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  // ─── Base grass fill ───
  void _drawGrass(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF5DA85D),
    );

    // Subtle gradient overlay for depth
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF6EC06E),
        const Color(0xFF4A964A),
        const Color(0xFF3D8A3D),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  // ─── Biome tinting ───
  void _drawBiomeTints(Canvas canvas, Size size) {
    // Farm biome — lighter, warmer green
    _drawBiomeRegion(
      canvas,
      ZooWorldData.farmBiome,
      const Color(0xFF7DC87D),
      0.25,
    );

    // Wild biome — deeper, darker green
    _drawBiomeRegion(
      canvas,
      ZooWorldData.wildBiome,
      const Color(0xFF3A7D3A),
      0.20,
    );

    // Exotic biome — warm sandy tint
    _drawBiomeRegion(
      canvas,
      ZooWorldData.exoticBiome,
      const Color(0xFFB8A060),
      0.18,
    );
  }

  void _drawBiomeRegion(Canvas canvas, Rect rect, Color color, double opacity) {
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(80));
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawRRect(rRect, paint);
  }

  // ─── Dirt paths ───
  void _drawPaths(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = const Color(0xFFBFA76A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pathEdgePaint = Paint()
      ..color = const Color(0xFF9E8850)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 46
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final segment in ZooWorldData.pathSegments) {
      if (segment.length < 2) continue;

      final path = Path()..moveTo(segment[0].dx, segment[0].dy);

      for (int i = 1; i < segment.length; i++) {
        if (i + 1 < segment.length) {
          final cp = segment[i];
          final end = Offset(
            (segment[i].dx + segment[i + 1].dx) / 2,
            (segment[i].dy + segment[i + 1].dy) / 2,
          );
          path.quadraticBezierTo(cp.dx, cp.dy, end.dx, end.dy);
        } else {
          path.lineTo(segment[i].dx, segment[i].dy);
        }
      }

      // Edge shadow first, then path fill
      canvas.drawPath(path, pathEdgePaint);
      canvas.drawPath(path, pathPaint);
    }
  }

  // ─── Ponds with gradient & shoreline ───
  void _drawPonds(Canvas canvas, Size size) {
    for (final pond in ZooWorldData.ponds) {
      final center = pond.center;

      // Sandy shore ring
      final shoreRect = Rect.fromCenter(
        center: center,
        width: pond.width + 30,
        height: pond.height + 30,
      );
      canvas.drawOval(
        shoreRect,
        Paint()
          ..color = const Color(0xFFD4B87A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Water gradient
      final waterGradient = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1.0,
        colors: [
          const Color(0xFF81D4FA),
          const Color(0xFF4FC3F7),
          const Color(0xFF0288D1),
        ],
      ).createShader(pond);

      canvas.drawOval(pond, Paint()..shader = waterGradient);

      // Wave shimmer lines
      final wavePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (int i = 0; i < 5; i++) {
        final yOff = pond.top + pond.height * 0.2 + (i * pond.height * 0.15);
        final xStart = pond.left + 20 + (i * 8.0);
        final xEnd = pond.right - 20 - (i * 8.0);
        final wavePath = Path()
          ..moveTo(xStart, yOff)
          ..quadraticBezierTo(
            (xStart + xEnd) / 2,
            yOff - 6 + (i * 2.0),
            xEnd,
            yOff,
          );
        canvas.drawPath(wavePath, wavePaint);
      }
    }
  }

  // ─── Perimeter fence ───
  void _drawFence(Canvas canvas, Size size) {
    const margin = 20.0;
    const postSpacing = 60.0;
    final fenceRect = Rect.fromLTWH(margin, margin, size.width - margin * 2, size.height - margin * 2);

    // Horizontal rails
    final railPaint = Paint()
      ..color = const Color(0xFF8B6914)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rRect = RRect.fromRectAndRadius(fenceRect, const Radius.circular(6));
    canvas.drawRRect(rRect, railPaint);

    // Inner rail
    final innerRect = Rect.fromLTWH(margin + 4, margin + 8, size.width - (margin + 4) * 2, size.height - (margin + 8) * 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFFA07D28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Fence posts along top and bottom
    final postPaint = Paint()
      ..color = const Color(0xFF6B4D12)
      ..style = PaintingStyle.fill;

    for (double x = margin; x < size.width - margin; x += postSpacing) {
      // Top posts
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, margin - 6, 6, 20),
          const Radius.circular(2),
        ),
        postPaint,
      );
      // Bottom posts
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, size.height - margin - 14, 6, 20),
          const Radius.circular(2),
        ),
        postPaint,
      );
    }

    // Left and right posts
    for (double y = margin; y < size.height - margin; y += postSpacing) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(margin - 6, y - 3, 20, 6),
          const Radius.circular(2),
        ),
        postPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - margin - 14, y - 3, 20, 6),
          const Radius.circular(2),
        ),
        postPaint,
      );
    }
  }

  // ─── Small grass tufts and detail dots ───
  void _drawGrassDetails(Canvas canvas, Size size) {
    final rng = math.Random(42);

    // Grass tufts
    for (int i = 0; i < 600; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final shade = Color.lerp(
        const Color(0xFF4CAF50),
        const Color(0xFF81C784),
        rng.nextDouble(),
      )!;
      canvas.drawCircle(
        Offset(x, y),
        rng.nextDouble() * 3 + 0.8,
        Paint()..color = shade.withValues(alpha: 0.5),
      );
    }

    // Small darker patches for terrain variation
    for (int i = 0; i < 150; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: rng.nextDouble() * 40 + 15,
          height: rng.nextDouble() * 30 + 10,
        ),
        Paint()
          ..color = const Color(0xFF3D7A3D).withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
