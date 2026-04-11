import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';

/// Floating heads-up display overlaid on the world view.
///
/// Contains:
/// - Back button (top-left)
/// - Title (top-center)
/// - Coin counter (top-right)
/// - Shop FAB (bottom-right)
/// - Settings button (top-right, below coins)
class ZooHud extends ConsumerWidget {
  final int coins;
  final VoidCallback onBack;
  final VoidCallback onShop;
  final VoidCallback onSettings;
  final double bottomInset;

  const ZooHud({
    super.key,
    required this.coins,
    required this.onBack,
    required this.onShop,
    required this.onSettings,
    this.bottomInset = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safePad = MediaQuery.of(context).padding;

    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          // ─── Back button ───
          Positioned(
            top: safePad.top + 8,
            left: 12,
            child: _GlassButton(
              onTap: onBack,
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),

          // ─── Title ───
          Positioned(
            top: safePad.top + 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  '🏡 My Zoo',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Coin counter ───
          Positioned(
            top: safePad.top + 8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentGolden.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGolden.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '$coins',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentGolden,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Settings button ───
          Positioned(
            top: safePad.top + 52,
            right: 12,
            child: _GlassButton(
              onTap: onSettings,
              child: const Icon(Icons.brush_rounded, color: Colors.white, size: 20),
            ),
          ),

          // ─── Shop FAB ───
          Positioned(
            bottom: safePad.bottom + 20 + bottomInset,
            right: 16,
            child: GestureDetector(
              onTap: onShop,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D7A3D), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D7A3D).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Semi-transparent glass button used in the HUD.
class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
