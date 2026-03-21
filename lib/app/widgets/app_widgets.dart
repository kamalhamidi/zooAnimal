/// ─── Reusable App Widgets ───
/// Glassmorphism cards, animal tiles, category pills, custom buttons,
/// and other UI components following Material Design 3 and jungle theme.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// ─── GLASSMORPHISM CARD ───
/// A frosted glass effect card with backdrop blur. Perfect for floating UI elements.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isClickable;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.space16),
    this.borderRadius = AppTheme.radiusMedium,
    this.backgroundColor,
    this.boxShadow,
    this.onTap,
    this.isClickable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.8)
        : AppColors.surfaceLight.withValues(alpha: 0.9);

    final widget = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? glassColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: boxShadow ?? AppTheme.shadowMedium,
      ),
      padding: padding,
      child: child,
    );

    if (isClickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }
    return widget;
  }
}

// ─── ANIMAL TILE CARD ───
/// Grid tile displaying animal with image/emoji, name, and sound indicator.
class AnimalTile extends StatelessWidget {
  final String id;
  final String name;
  final String emoji;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? indicator;
  final bool isSelected;

  const AnimalTile({
    Key? key,
    required this.id,
    required this.name,
    required this.emoji,
    required this.accentColor,
    required this.onTap,
    this.indicator,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        enabled: true,
        label: '$name animal tile',
        child: AnimatedScale(
          scale: isSelected ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: GlassCard(
            borderRadius: AppTheme.radiusLarge,
            backgroundColor: accentColor.withValues(alpha: 0.15),
            padding: const EdgeInsets.all(AppTheme.space12),
            boxShadow: isSelected ? AppTheme.shadowLarge : AppTheme.shadowSmall,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animal emoji/icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                      semanticsLabel: 'Emoji for $name',
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                // Animal name
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (indicator != null) ...[
                  const SizedBox(height: AppTheme.space4),
                  indicator!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SOUND WAVE INDICATOR ───
/// Animated sound wave bars for indicating audio playback status.
class SoundWaveIndicator extends StatelessWidget {
  final bool isPlaying;
  final Color color;
  final double size;

  const SoundWaveIndicator({
    Key? key,
    this.isPlaying = false,
    required this.color,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) {
      return Icon(
        Icons.graphic_eq,
        color: color.withValues(alpha: 0.5),
        size: size,
        semanticLabel: 'Sound indicator',
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              return Container(
                width: 3,
                height: size * (0.4 + 0.3 * ((index + 1) % 3) / 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ─── CATEGORY PILL ───
/// Rounded pill button for filtering by category with active state.
class CategoryPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  const CategoryPill({
    Key? key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        enabled: true,
        label: '$label category ${isActive ? 'active' : 'inactive'}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space16,
            vertical: AppTheme.space8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryGreen
                : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
            border: Border.all(
              color: isActive
                  ? AppColors.primaryGreen
                  : AppColors.dividerLight,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            boxShadow: isActive ? AppTheme.shadowSmall : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isActive ? Colors.white : AppColors.onBackgroundLight,
                  size: 18,
                ),
                const SizedBox(width: AppTheme.space8),
              ],
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.onBackgroundLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── BOUNCY BUTTON ───
/// Custom button with spring/bounce animation on tap, 60x60pt minimum.
class BouncyButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double size;
  final bool enabled;
  final String semanticLabel;

  const BouncyButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.size = AppTheme.minTapTarget,
    this.enabled = true,
    this.semanticLabel = 'Button',
  }) : super(key: key);

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTap: widget.enabled ? _handleTap : null,
        child: Semantics(
          button: true,
          enabled: widget.enabled,
          label: widget.semanticLabel,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor ?? AppColors.primaryGreen,
              boxShadow: widget.enabled ? AppTheme.shadowLarge : [],
              opacity: widget.enabled ? 1.0 : 0.5,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─── PROGRESS RING ───
/// Circular progress indicator with label in center.
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final double size;
  final Color backgroundColor;
  final Color progressColor;

  const ProgressRing({
    Key? key,
    required this.progress,
    this.label,
    this.size = 80,
    this.backgroundColor = const Color(0xFFE8E8E8),
    this.progressColor = AppColors.primaryGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Progress: ${(progress * 100).toStringAsFixed(0)}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor.withValues(alpha: 0.2),
              ),
            ),
            // Progress arc
            CustomPaint(
              size: Size(size, size),
              painter: _ProgressRingPainter(
                progress: progress,
                color: progressColor,
                strokeWidth: 6,
              ),
            ),
            // Center label
            if (label != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    label ?? '',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const startAngle = -3.14159 / 2; // Top of circle
    final sweepAngle = (2 * 3.14159) * progress;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ─── REWARD BADGE ───
/// Display XP, stars, or achievement badges.
class RewardBadge extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const RewardBadge({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.accentYellow,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$value $label',
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space12,
            vertical: AppTheme.space8,
          ),
          borderRadius: AppTheme.radiusPill,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: AppTheme.space8),
              Text(
                value.toString(),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── STAT DISPLAY CARD ───
/// Shows a stat with icon, label, and value in a compact card.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    
    return Semantics(
      label: '$label: $value',
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(AppTheme.space16),
          borderRadius: AppTheme.radiusMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: color ?? AppColors.primaryGreen,
                    size: 22,
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                value,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color ?? AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SKELETON LOADER SHIMMER ───
/// Shimmer effect for loading states (async assets).
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = AppTheme.radiusMedium,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final highlightColor = baseColor.withValues(alpha: 0.7);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: const Alignment(-1, -1),
              end: const Alignment(1, 1),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}
