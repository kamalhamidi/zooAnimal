import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

class BlurredImage extends StatelessWidget {
  final String emoji;
  final List<bool> revealedTiles;
  final double size;

  const BlurredImage({
    super.key,
    required this.emoji,
    required this.revealedTiles,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final tileSize = size / 3;
    final allRevealed = revealedTiles.every((t) => t);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Base "image" (emoji big)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: size * 0.55),
                ),
              ),
            ),
            // Blur overlay (if not all revealed)
            if (!allRevealed)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20.0,
                  sigmaY: 20.0,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            // Individual tile overlays
            ...List.generate(9, (index) {
              final row = index ~/ 3;
              final col = index % 3;
              final revealed = revealedTiles[index];

              return Positioned(
                left: col * tileSize,
                top: row * tileSize,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: revealed
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.6),
                    border: Border.all(
                      color: revealed
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: revealed
                      ? const SizedBox.shrink()
                      : Center(
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: tileSize * 0.3,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
