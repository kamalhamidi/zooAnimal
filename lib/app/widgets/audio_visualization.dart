/// ─── Audio Visualization & Haptics ───
/// Waveform animation synced to audio, haptic feedback, and audio utilities.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// ─── HAPTIC FEEDBACK HELPER ───

/// Unified haptic feedback manager
class HapticManager {
  static Future<void> lightTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptics not supported on platform
    }
  }

  static Future<void> mediumTap() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptics not supported on platform
    }
  }

  static Future<void> heavyTap() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptics not supported on platform
    }
  }

  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptics not supported on platform
    }
  }

  /// Haptic success feedback (double tap pattern)
  static Future<void> success() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptics not supported on platform
    }
  }

  /// Haptic error feedback (triple quick taps)
  static Future<void> error() async {
    try {
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      // Haptics not supported on platform
    }
  }

  /// Haptic warning feedback (two medium taps)
  static Future<void> warning() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptics not supported on platform
    }
  }
}

// ─── ANIMATED WAVEFORM ───

/// Waveform visualization with animated bars synced to playback.
class AnimatedWaveform extends StatefulWidget {
  final bool isPlaying;
  final double duration; // Total duration in seconds
  final double currentPosition; // Current playback position in seconds
  final Color color;
  final int barCount;
  final double height;

  const AnimatedWaveform({
    Key? key,
    required this.isPlaying,
    required this.duration,
    required this.currentPosition,
    this.color = AppColors.primaryGreen,
    this.barCount = 60,
    this.height = 40,
  }) : super(key: key);

  @override
  State<AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<AnimatedWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize random bar heights
    _generateRandomHeights();

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  void _generateRandomHeights() {
    _barHeights.clear();
    final random = DateTime.now().millisecond;
    for (int i = 0; i < widget.barCount; i++) {
      _barHeights.add(
        0.3 + ((random * (i + 1)) % 70) / 100,
      );
    }
  }

  @override
  void didUpdateWidget(AnimatedWaveform oldWidget) {
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
    final progressPercent = widget.duration > 0
        ? (widget.currentPosition / widget.duration).clamp(0.0, 1.0)
        : 0.0;
    final progressIndex = (progressPercent * widget.barCount).toInt();

    return Semantics(
      label:
          'Waveform showing ${(progressPercent * 100).toStringAsFixed(0)}% progress',
      child: SizedBox(
        height: widget.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            final isPlayed = index < progressIndex;
            final barHeight = _barHeights[index % _barHeights.length];

            return Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double animatedHeight = barHeight;
                  if (widget.isPlaying) {
                    animatedHeight += math.sin(_controller.value * math.pi * 2) * 0.2;
                  }
                  animatedHeight = animatedHeight.clamp(0.1, 1.0);

                  return Center(
                    child: Container(
                      width: 3,
                      height: animatedHeight * widget.height,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isPlayed
                            ? widget.color
                            : widget.color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

// ─── SOUND FREQUENCY VISUALIZER ───

/// Animated frequency bars like an equalizer.
class FrequencyVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int bandCount;
  final double height;

  const FrequencyVisualizer({
    Key? key,
    required this.isPlaying,
    this.color = AppColors.primaryGreen,
    this.bandCount = 20,
    this.height = 80,
  }) : super(key: key);

  @override
  State<FrequencyVisualizer> createState() => _FrequencyVisualizerState();
}

class _FrequencyVisualizerState extends State<FrequencyVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _bandHeights = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _generateRandomHeights();

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  void _generateRandomHeights() {
    _bandHeights.clear();
    for (int i = 0; i < widget.bandCount; i++) {
      _bandHeights.add((math.Random().nextDouble() * 0.6) + 0.2);
    }
  }

  @override
  void didUpdateWidget(FrequencyVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
      _generateRandomHeights();
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
    return Semantics(
      label: 'Frequency equalizer ${widget.isPlaying ? 'animating' : 'idle'}',
      child: SizedBox(
        height: widget.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.bandCount, (index) {
            return Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double animatedHeight = _bandHeights[index];

                  if (widget.isPlaying) {
                    // Add sine wave oscillation
                    final offset = (index / widget.bandCount) * math.pi * 2;
                    animatedHeight +=
                        math.sin((_controller.value * math.pi * 4) + offset) *
                            0.15;
                  }

                  animatedHeight = animatedHeight.clamp(0.1, 1.0);

                  return Center(
                    child: Container(
                      width: 4,
                      height: animatedHeight * widget.height,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: widget.isPlaying
                            ? [
                                BoxShadow(
                                  color: widget.color.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                )
                              ]
                            : [],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── PLAY BUTTON WITH WAVEFORM RING ───

/// Animated play button with pulsing waveform circle.
class PlayButtonWithWave extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const PlayButtonWithWave({
    Key? key,
    required this.isPlaying,
    required this.onTap,
    this.color = AppColors.primaryGreen,
    this.size = 80,
  }) : super(key: key);

  @override
  State<PlayButtonWithWave> createState() => _PlayButtonWithWaveState();
}

class _PlayButtonWithWaveState extends State<PlayButtonWithWave>
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
  void didUpdateWidget(PlayButtonWithWave oldWidget) {
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

  void _handleTap() {
    HapticManager.lightTap();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: widget.isPlaying ? 'Pause audio' : 'Play audio',
      onTap: _handleTap,
      child: GestureDetector(
        onTap: _handleTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing wave rings
              if (widget.isPlaying)
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.3).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                  ),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              if (widget.isPlaying)
                ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1.1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Container(
                    width: widget.size * 0.7,
                    height: widget.size * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              // Main button
              Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: widget.size * 0.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── AUDIO DURATION DISPLAY ───

/// Display audio duration with formatted time.
class AudioDurationDisplay extends StatelessWidget {
  final Duration duration;
  final Duration current;
  final bool showSeconds;

  const AudioDurationDisplay({
    Key? key,
    required this.duration,
    required this.current,
    this.showSeconds = true,
  }) : super(key: key);

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (showSeconds) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${_formatDuration(current)} of ${_formatDuration(duration)}',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatDuration(current),
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(width: AppTheme.space8),
          Text(
            '/',
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: AppTheme.space8),
          Text(
            _formatDuration(duration),
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
