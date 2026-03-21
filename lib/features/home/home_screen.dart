import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../core/audio/audio_service.dart';
import '../../core/models/player_stats.dart';
import '../../core/providers/coin_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../../core/providers/daily_challenge_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgAnimController;
  Timer? _dailyTimer;
  Duration _timeUntilReset = Duration.zero;

  final List<_FloatingEmoji> _floatingEmojis = [];
  final _random = Random();
  final List<String> _emojiList = [
    '🐄', '🐕', '🐱', '🐷', '🦁', '🐘', '🦆', '🐸',
    '🦉', '🐒', '🐴', '🐑', '🐓', '🐺', '🦇', '🦚',
  ];

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Generate floating emojis
    for (int i = 0; i < 12; i++) {
      _floatingEmojis.add(_FloatingEmoji(
        emoji: _emojiList[_random.nextInt(_emojiList.length)],
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 20 + _random.nextDouble() * 20,
        speed: 0.3 + _random.nextDouble() * 0.7,
        opacity: 0.08 + _random.nextDouble() * 0.12,
      ));
    }

    // Daily countdown timer
    _startDailyTimer();
  }

  void _startDailyTimer() {
    _dailyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          final tomorrow = DateTime(now.year, now.month, now.day + 1);
          _timeUntilReset = tomorrow.difference(now);
        });
      }
    });
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _dailyTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(coinProvider);
    final stats = ref.watch(statsProvider);
    final daily = ref.watch(dailyChallengeProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background floating emojis
          ...List.generate(_floatingEmojis.length, (i) {
            final e = _floatingEmojis[i];
            return AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, child) {
                final progress = (_bgAnimController.value * e.speed) % 1.0;
                final yPos = (e.y + progress) % 1.2 - 0.1;
                return Positioned(
                  left: e.x * size.width,
                  top: yPos * size.height,
                  child: Opacity(
                    opacity: e.opacity,
                    child: Text(
                      e.emoji,
                      style: TextStyle(fontSize: e.size),
                    ),
                  ),
                );
              },
            );
          }),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // ─── Top Bar ───
                  _buildTopBar(coins),
                  const SizedBox(height: 24),
                  // ─── Logo & Title ───
                  _buildLogo(),
                  if (AudioService.instance.isPlaceholderAudioMode) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        'Placeholder audio mode is active (${AudioService.instance.invalidAudioAssetCount} invalid files). Add real files in assets/sounds.',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // ─── Mode Cards ───
                  _buildModeCard(
                    emoji: '🎧',
                    title: 'Guess the Animal',
                    description: 'Can you identify it?',
                    gradient: AppColors.primaryGradient,
                    shadowColor: AppColors.primary,
                    onTap: () => _showDifficultyPicker(context),
                    index: 0,
                  ),
                  const SizedBox(height: 16),
                  _buildModeCard(
                    emoji: '🧩',
                    title: 'Sound Puzzle',
                    description: 'Reveal the mystery animal',
                    gradient: AppColors.secondaryGradient,
                    shadowColor: AppColors.secondary,
                    onTap: () => context.push('/puzzle'),
                    index: 1,
                  ),
                  const SizedBox(height: 16),
                  _buildModeCard(
                    emoji: '👶',
                    title: 'Baby Mode',
                    description: 'Tap & learn!',
                    gradient: AppColors.accentGradient,
                    shadowColor: AppColors.accent,
                    onTap: () => context.push('/baby'),
                    index: 2,
                  ),
                  const SizedBox(height: 24),
                  // ─── Daily Challenge Banner ───
                  _buildDailyChallenge(daily),
                  const SizedBox(height: 24),
                  // ─── Stats Row ───
                  _buildStatsRow(stats),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(int coins) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '🐾',
          style: TextStyle(fontSize: 28),
        ),
        // Animated coin counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '$coins',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.coinGoldDark,
                ),
              ),
            ],
          ),
        )
            .animate(
              key: ValueKey(coins),
            )
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.15, 1.15),
              duration: 150.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(1.0, 1.0),
              duration: 150.ms,
            ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        const Text(
          '🦁🐯🐻',
          style: TextStyle(fontSize: 40),
        )
            .animate(
              onPlay: (c) => c.repeat(reverse: true),
            )
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 8),
        Text(
          'SoundZoo',
          style: GoogleFonts.fredoka(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, end: 0, duration: 600.ms),
        const SizedBox(height: 4),
        Text(
          'Listen, learn, and have fun!',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildModeCard({
    required String emoji,
    required String title,
    required String description,
    required LinearGradient gradient,
    required Color shadowColor,
    required VoidCallback onTap,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppColors.glowShadow(shadowColor),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 22,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (200 + index * 150).ms, duration: 500.ms)
        .slideX(begin: 0.1, end: 0, delay: (200 + index * 150).ms);
  }

  Widget _buildDailyChallenge(DailyChallengeState daily) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.goldenGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppColors.glowShadow(AppColors.coinGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Daily Challenge',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown[800],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.brown[800]?.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                ),
                child: Text(
                  '${daily.attemptsUsed}/${daily.maxAttempts}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resets in',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.brown[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDuration(_timeUntilReset),
                    style: GoogleFonts.robotoMono(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown[800],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: daily.isAvailable
                    ? () {
                        HapticFeedback.lightImpact();
                        context.push('/guess?daily=true');
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: daily.isAvailable
                        ? Colors.brown[800]
                        : Colors.brown[400],
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Text(
                    daily.isAvailable ? 'Play Now' : 'Completed',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildStatsRow(PlayerStats stats) {
    return Row(
      children: [
        _buildStatItem('🔥', 'Best Streak', '${stats.bestStreak}'),
        const SizedBox(width: 12),
        _buildStatItem('🏆', 'Total Score', '${stats.totalScore}'),
        const SizedBox(width: 12),
        _buildStatItem('🐾', 'Found', '${stats.animalsFound}'),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Difficulty',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildDifficultyOption(
                ctx,
                'Easy',
                '8 animals • Farm friends',
                AppColors.easyGreen,
                '🐄',
                'easy',
              ),
              const SizedBox(height: 12),
              _buildDifficultyOption(
                ctx,
                'Medium',
                '6 animals • Wild world',
                AppColors.mediumYellow,
                '🦁',
                'medium',
              ),
              const SizedBox(height: 12),
              _buildDifficultyOption(
                ctx,
                'Hard',
                '6 animals • Exotic sounds',
                AppColors.hardRed,
                '🐆',
                'hard',
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(
    BuildContext ctx,
    String title,
    String subtitle,
    Color color,
    String emoji,
    String difficulty,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(ctx);
        context.push('/guess?difficulty=$difficulty');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, color: color, size: 32),
          ],
        ),
      ),
    );
  }
}

class _FloatingEmoji {
  final String emoji;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _FloatingEmoji({
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
