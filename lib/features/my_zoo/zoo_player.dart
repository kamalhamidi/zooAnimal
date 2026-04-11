import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The player avatar rendered in world coordinates.
///
/// Supports either:
/// - An emoji character (default 🧑‍🌾)
/// - A custom image loaded from the file system
///
/// Adds a ground shadow, bouncing walk animation, and horizontal flip
/// based on movement direction.
class ZooPlayer extends StatelessWidget {
  final bool isMoving;
  final bool facingRight;
  final String? customImagePath;
  final String? defaultAssetImagePath;
  final double size;
  final double bouncePhase; // 0–1 normalised phase for walk cycle

  const ZooPlayer({
    super.key,
    required this.isMoving,
    required this.facingRight,
    this.customImagePath,
    this.defaultAssetImagePath,
    this.size = 54,
    this.bouncePhase = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bounceY = isMoving ? math.sin(bouncePhase * math.pi * 2) * 4 : 0.0;
    final scaleX = facingRight ? 1.0 : -1.0;

    return SizedBox(
      width: size + 20,
      height: size + 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ground shadow
          Positioned(
            bottom: 4,
            child: Container(
              width: size * 0.7,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          // Player body
          Positioned(
            bottom: 10 + bounceY,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(scaleX, 1.0, 1.0),
              child: _buildAvatar(),
            ),
          ),
          // Name badge
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'You',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (customImagePath != null && customImagePath!.isNotEmpty) {
      final file = File(customImagePath!);
      if (file.existsSync()) {
        return _avatarFrame(
          child: ClipOval(
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    if (defaultAssetImagePath != null && defaultAssetImagePath!.isNotEmpty) {
      return _avatarFrame(
        child: ClipOval(
          child: Image.asset(
            defaultAssetImagePath!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _emojiAvatar(),
          ),
        ),
      );
    }

    return _avatarFrame(child: _emojiAvatar());
  }

  Widget _avatarFrame({required Widget child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emojiAvatar() {
    // Default emoji avatar
    return Center(
      child: Text(
        '🧑‍🌾',
        style: TextStyle(fontSize: size * 0.52),
      ),
    );
  }
}
