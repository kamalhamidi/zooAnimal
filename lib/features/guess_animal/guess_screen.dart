import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../core/audio/audio_service.dart';
import '../../core/providers/coin_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../../core/providers/daily_challenge_provider.dart';
import 'guess_provider.dart';
import 'widgets/timer_ring.dart';
import 'widgets/answer_button.dart';
import 'widgets/streak_bar.dart';

class GuessScreen extends ConsumerStatefulWidget {
  final String difficulty;
  final bool isDaily;

  const GuessScreen({
    super.key,
    required this.difficulty,
    this.isDaily = false,
  });

  @override
  ConsumerState<GuessScreen> createState() => _GuessScreenState();
}

class _GuessScreenState extends ConsumerState<GuessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Start game after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final daily = widget.isDaily
          ? ref.read(dailyChallengeProvider)
          : null;

      ref.read(guessGameProvider.notifier).startGame(
            difficulty: widget.difficulty,
            isDaily: widget.isDaily,
            dailyQuestions: daily?.questions,
          );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    AudioService.instance.stopAll();
    super.dispose();
  }

  void _playCurrentSound(GuessGameState gameState) {
    final animal = gameState.currentAnimal;
    if (animal == null) return;

    if (gameState.soundPlays < 2) {
      AudioService.instance.playSound(animal.soundAssetPath);
      ref.read(guessGameProvider.notifier).recordSoundPlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(guessGameProvider);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: _buildBody(gameState),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
                AppColors.success,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(GuessGameState gameState) {
    switch (gameState.status) {
      case GameStatus.idle:
        return const Center(child: CircularProgressIndicator());
      case GameStatus.playing:
        return _buildPlaying(gameState);
      case GameStatus.roundEnd:
        return _buildRoundEnd(gameState);
      case GameStatus.gameOver:
        return _buildGameOver(gameState);
    }
  }

  Widget _buildPlaying(GuessGameState gameState) {
    final isDaily = gameState.isDaily;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
              // Round indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDaily
                      ? AppColors.coinGold.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: isDaily
                      ? Border.all(color: AppColors.coinGold.withValues(alpha: 0.3))
                      : null,
                ),
                child: Text(
                  isDaily
                      ? '⭐ Round ${gameState.currentIndex + 1}/${gameState.totalRounds}'
                      : 'Round ${gameState.currentIndex + 1}/${gameState.totalRounds}',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              StreakBar(streak: gameState.streak),
            ],
          ),
          const Spacer(flex: 1),
          // Timer
          TimerRing(timeRemaining: gameState.timeRemaining),
          const SizedBox(height: 24),
          // Play sound button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _playCurrentSound(gameState);
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: isDaily
                    ? AppColors.goldenGradient
                    : AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.glowShadow(
                  isDaily ? AppColors.coinGold : AppColors.primary,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.08, 1.08),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            gameState.soundPlays < 2 ? 'Tap to play' : 'No replays left',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const Spacer(flex: 1),
          // Answer grid (2x2)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: gameState.currentOptions.map((animal) {
              return AnswerButton(
                animal: animal,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(guessGameProvider.notifier).selectAnswer(animal);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Score
          Text(
            'Score: ${gameState.score}',
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRoundEnd(GuessGameState gameState) {
    final animal = gameState.currentAnimal;
    if (animal == null) return const SizedBox.shrink();

    final wasCorrect = gameState.wasCorrect ?? false;

    // Haptic feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (wasCorrect) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              Text(
                wasCorrect ? '✅ Correct!' : '❌ Wrong!',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: wasCorrect ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const Spacer(flex: 1),
          // Animal emoji & image
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: wasCorrect
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: wasCorrect
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.error.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(animal.emoji, style: const TextStyle(fontSize: 72)),
            ),
          ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 16),
          Text(
            animal.name,
            style: GoogleFonts.fredoka(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Fun fact
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    animal.funFact,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 16),
          // Coins earned
          if (wasCorrect)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.coinGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+${gameState.roundCoins} coins',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.coinGoldDark,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 300.ms)
                .slideY(begin: 0.3, end: 0),
          const Spacer(flex: 1),
          // Next button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(guessGameProvider.notifier).nextRound();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppColors.glowShadow(AppColors.primary),
              ),
              child: Center(
                child: Text(
                  gameState.currentIndex + 1 >= gameState.totalRounds
                      ? 'See Results'
                      : 'Next →',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGameOver(GuessGameState gameState) {
    // Award coins
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameState.totalCoins > 0) {
        ref.read(coinProvider.notifier).addCoins(gameState.totalCoins);
      }
      ref.read(statsProvider.notifier).addScore(gameState.score);
      ref.read(statsProvider.notifier).updateBestStreak(gameState.bestStreak);
      ref.read(statsProvider.notifier).incrementGamesPlayed();
      ref.read(statsProvider.notifier).addCoinsEarned(gameState.totalCoins);

      if (gameState.stars == 3) {
        _confettiController.play();
      }
      HapticFeedback.heavyImpact();
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Game Over!',
              style: GoogleFonts.fredoka(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 24),
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final filled = i < gameState.stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled ? AppColors.starFilled : AppColors.starEmpty,
                    size: 52,
                  ),
                )
                    .animate()
                    .scale(
                      delay: (i * 200).ms,
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    );
              }),
            ),
            const SizedBox(height: 32),
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppColors.mediumShadow,
              ),
              child: Column(
                children: [
                  _buildScoreRow('Score', '${gameState.score}', AppColors.primary),
                  const SizedBox(height: 16),
                  _buildScoreRow(
                    'Correct',
                    '${gameState.correctAnswers}/${gameState.totalRounds}',
                    AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  _buildScoreRow(
                    'Best Streak',
                    '${gameState.bestStreak} 🔥',
                    AppColors.streakFire,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      Text(
                        '+${gameState.totalCoins} coins',
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.coinGoldDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            const SizedBox(height: 32),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(guessGameProvider.notifier).startGame(
                            difficulty: gameState.difficulty,
                            isDaily: gameState.isDaily,
                          );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.secondaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Center(
                        child: Text(
                          '🔄 Replay',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Center(
                        child: Text(
                          '🏠 Home',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
