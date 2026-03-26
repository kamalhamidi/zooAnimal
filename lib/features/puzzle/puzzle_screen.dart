import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../core/ads/footer_banner_bar.dart';
import '../../core/ads/interstitial_ad_manager.dart';
import '../../core/ads/rewarded_ad_manager.dart';
import '../../core/audio/audio_service.dart';
import '../../core/providers/coin_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../../data/animals_data.dart';
import 'puzzle_provider.dart';
import 'widgets/blurred_image.dart';
import 'widgets/coin_reveal_button.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key});

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  final TextEditingController _guessController = TextEditingController();
  late ConfettiController _confettiController;
  bool _showCollection = false;
  bool _isRewardFlowInProgress = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = ref.read(localStorageProvider);
      final unlocked = storage.getUnlockedAnimals();
      ref.read(puzzleProvider.notifier).startNewPuzzle(unlockedIds: unlocked);
      // Auto-play sound on load
      Future.delayed(const Duration(milliseconds: 500), () {
        final animal = ref.read(puzzleProvider).currentAnimal;
        if (animal != null) {
          AudioService.instance.playSound(animal.soundAssetPath);
        }
      });
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    _confettiController.dispose();
    AudioService.instance.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzleState = ref.watch(puzzleProvider);
    final coins = ref.watch(coinProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: const FooterBannerBar(),
      body: Stack(
        children: [
          SafeArea(
            child: _showCollection
                ? _buildCollection(puzzleState)
                : _buildPuzzle(puzzleState, coins, size),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primaryGreen,
                AppColors.secondaryOrange,
                AppColors.accentYellow,
                AppColors.success,
              ],
              numberOfParticles: 25,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzle(PuzzleState puzzleState, int coins, Size screenSize) {
    final animal = puzzleState.currentAnimal;
    if (animal == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final imageSize = (screenSize.width - 48).clamp(200.0, 350.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
              Text(
                '🧩 Sound Puzzle',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showCollection = true),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.collections_rounded, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Blurred image
          BlurredImage(
            emoji: animal.emoji,
            revealedTiles: puzzleState.revealedTiles,
            size: imageSize,
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 20),
          // Status bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusChip(
                '❤️',
                '${puzzleState.attempts} left',
                puzzleState.attempts <= 1
                    ? AppColors.error
                    : AppColors.secondaryOrange,
              ),
              _buildStatusChip(
                '🪙',
                '$coins coins',
                AppColors.accentGolden,
              ),
              _buildStatusChip(
                '⭐',
                'Score: ${puzzleState.score}',
                AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (puzzleState.status == PuzzleStatus.playing) ...[
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CoinRevealButton(
                    cost: 3,
                    label: 'Reveal tile',
                    icon: Icons.visibility_rounded,
                    enabled: coins >= 3 &&
                        puzzleState.tilesRevealed < 9,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final success = await ref
                          .read(coinProvider.notifier)
                          .spendCoins(3);
                      if (success) {
                        ref.read(puzzleProvider.notifier).revealTile();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CoinRevealButton(
                    cost: 1,
                    label: 'Play sound',
                    icon: Icons.volume_up_rounded,
                    enabled: coins >= 1,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final success = await ref
                          .read(coinProvider.notifier)
                          .spendCoins(1);
                      if (success) {
                        ref.read(puzzleProvider.notifier).replaySound();
                        AudioService.instance
                            .playSound(animal.soundAssetPath);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Guess input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _guessController,
                    decoration: InputDecoration(
                      hintText: 'Type animal name...',
                      hintStyle: GoogleFonts.nunito(color: Colors.grey),
                      prefixIcon: const Icon(Icons.pets_rounded),
                    ),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitGuess(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _submitGuess,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            // Wrong guess feedback
            if (puzzleState.lastGuessCorrect == false &&
                puzzleState.status == PuzzleStatus.playing)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Wrong guess! ${puzzleState.attempts} attempts left',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ).animate().shakeX(hz: 3, amount: 5, duration: 400.ms),
              ),
          ],

          // Solved state
          if (puzzleState.status == PuzzleStatus.solved) ...[
            const SizedBox(height: 16),
            Text(
              '🎉 Correct!',
              style: GoogleFonts.fredoka(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 8),
            Text(
              'It\'s a ${animal.name}! ${animal.emoji}',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
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
                    '+${puzzleState.coinsReward} coins',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentGolden,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],

          // Failed state
          if (puzzleState.status == PuzzleStatus.failed) ...[
            const SizedBox(height: 16),
            Text(
              '😢 Better luck next time!',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'It was a ${animal.name} ${animal.emoji}',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isRewardFlowInProgress
                    ? null
                    : () async {
                        setState(() => _isRewardFlowInProgress = true);

                        final ready = await RewardedAdManager.instance.ensureLoaded();
                        if (!ready) {
                          if (!mounted) return;
                          setState(() => _isRewardFlowInProgress = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rewarded ad is still loading. Please try again in a few seconds.'),
                            ),
                          );
                          return;
                        }

                        final shown = await RewardedAdManager.instance.showAd(
                          from: context,
                          rewardHandler: () {
                            ref.read(puzzleProvider.notifier).grantExtraLife();
                            final currentAnimal = ref.read(puzzleProvider).currentAnimal;
                            if (currentAnimal != null) {
                              AudioService.instance.playSound(currentAnimal.soundAssetPath);
                            }
                          },
                        );

                        if (!mounted) return;
                        setState(() => _isRewardFlowInProgress = false);

                        if (!shown) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rewarded ad is not ready yet. Please try again shortly.'),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.ondemand_video_rounded),
                label: Text(
                  _isRewardFlowInProgress
                      ? 'Loading ad...'
                      : 'Watch ad for extra life',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              await InterstitialAdManager.instance.showAd(viewController: context);
              _guessController.clear();
              ref.read(puzzleProvider.notifier).startNewPuzzle();
              Future.delayed(const Duration(milliseconds: 500), () {
                final animal = ref.read(puzzleProvider).currentAnimal;
                if (animal != null) {
                  AudioService.instance.playSound(animal.soundAssetPath);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Text(
                  '🔄 New Puzzle',
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
            onTap: () async {
              HapticFeedback.lightImpact();
              await InterstitialAdManager.instance.showAd(viewController: context);
              context.go('/');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
    );
  }

  Widget _buildStatusChip(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollection(PuzzleState puzzleState) {
    final allAnimals = AnimalsData.allAnimals;
    final unlocked = puzzleState.unlockedAnimalIds;

    return Column(
      children: [
        const SizedBox(height: 8),
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _showCollection = false),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
              Text(
                '🏆 Collection',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${unlocked.length}/${allAnimals.length}',
                style: GoogleFonts.robotoMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: allAnimals.isEmpty ? 0 : unlocked.length / allAnimals.length,
              minHeight: 8,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: allAnimals.length,
            itemBuilder: (context, index) {
              final animal = allAnimals[index];
              final isUnlocked = unlocked.contains(animal.id);

              return Container(
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.success.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: isUnlocked
                        ? AppColors.success.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isUnlocked ? animal.emoji : '❓',
                      style: TextStyle(fontSize: isUnlocked ? 28 : 24),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUnlocked ? animal.name : '???',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _submitGuess() {
    final text = _guessController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(puzzleProvider.notifier).submitGuess(text);
    _guessController.clear();

    final state = ref.read(puzzleProvider);
    if (state.status == PuzzleStatus.solved) {
      _confettiController.play();
      HapticFeedback.mediumImpact();
      ref.read(coinProvider.notifier).addCoins(state.coinsReward);
      ref.read(statsProvider.notifier).addAnimalFound();

      // Save unlocked animal
      final storage = ref.read(localStorageProvider);
      if (state.currentAnimal != null) {
        storage.addUnlockedAnimal(state.currentAnimal!.id);
      }
    } else if (state.status == PuzzleStatus.failed) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }
}
