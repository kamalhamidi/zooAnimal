/// ─── REFERENCE: Enhanced Home Screen Example ───
/// This file demonstrates how to refactor the existing home screen
/// with App Store-quality UI/UX enhancements.
/// 
/// Copy patterns here into your actual lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Imports (add to your home_screen.dart)
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/app_widgets.dart';
import '../../app/animations/app_animations.dart';
import '../../app/widgets/audio_visualization.dart';
import '../../core/audio/audio_service.dart';
import '../../core/models/animal.dart';
import '../../core/models/player_stats.dart';
import '../../core/providers/coin_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../../core/providers/daily_challenge_provider.dart';
import '../../core/providers/gamification_provider.dart';
import '../../data/animals_data.dart';

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 1: Gamification Header
// ─────────────────────────────────────────────────────────────────

class GamificationHeader extends ConsumerWidget {
  const GamificationHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(playerLevelProvider);
    final xp = ref.watch(totalXPProvider);
    final streak = ref.watch(streakProvider);
    final nextLevelProgress = ref.watch(nextLevelProgressProvider);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        children: [
          // Main stats row: Level | XP | Streak
          Row(
            children: [
              // Level card
              Expanded(
                child: StatCard(
                  label: 'Level',
                  value: level.toString(),
                  icon: Icons.star,
                  color: AppColors.accentYellow,
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              // XP card
              Expanded(
                child: StatCard(
                  label: 'XP',
                  value: xp.toString(),
                  icon: Icons.bolt,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              // Streak card (with flame if active)
              Expanded(
                child: StatCard(
                  label: 'Streak',
                  value: '$streak 🔥',
                  icon: Icons.local_fire_department,
                  color: AppColors.streakFire,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          // Level progress bar
          GlassCard(
            padding: const EdgeInsets.all(AppTheme.space12),
            borderRadius: AppTheme.radiusMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Level',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      '${(nextLevelProgress * 100).toInt()}%',
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space8),
                // Progress bar with animation
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: LinearProgressIndicator(
                    value: nextLevelProgress,
                    minHeight: 8,
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 2: Category Tab Bar
// ─────────────────────────────────────────────────────────────────

class CategoryTabBar extends StatefulWidget {
  final Function(String) onCategoryChanged;
  final String selectedCategory;
  final List<String> categories;

  const CategoryTabBar({
    Key? key,
    required this.onCategoryChanged,
    this.selectedCategory = 'all',
    this.categories = const ['All', 'Farm', 'Wild', 'Ocean', 'Exotic'],
  }) : super(key: key);

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      child: Row(
        children: List.generate(
          widget.categories.length,
          (index) {
            final category = widget.categories[index].toLowerCase();
            final isActive = widget.selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: AppTheme.space8),
              child: CategoryPill(
                label: widget.categories[index],
                isActive: isActive,
                icon: _getCategoryIcon(category),
                onTap: () {
                  widget.onCategoryChanged(category);
                  HapticManager.lightTap();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'farm':
        return Icons.agriculture;
      case 'wild':
        return Icons.forest;
      case 'ocean':
        return Icons.waves;
      case 'exotic':
        return Icons.diamond;
      default:
        return Icons.category;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 3: Animal Grid with Glassmorphism Cards
// ─────────────────────────────────────────────────────────────────

class AnimalGridView extends ConsumerWidget {
  final String selectedCategory;
  final Function(Animal) onAnimalTap;

  const AnimalGridView({
    Key? key,
    required this.selectedCategory,
    required this.onAnimalTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get all animals or filtered by category
    final allAnimals = animalsData;
    final filteredAnimals = selectedCategory == 'all'
        ? allAnimals
        : allAnimals
            .where((a) => a.category.toLowerCase() == selectedCategory)
            .toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: AppTheme.space12,
        mainAxisSpacing: AppTheme.space12,
      ),
      padding: const EdgeInsets.all(AppTheme.space16),
      itemCount: filteredAnimals.length,
      itemBuilder: (context, index) {
        final animal = filteredAnimals[index];
        final accentColor = _getAnimalColor(animal.id);

        return FadeIn(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: AnimalTile(
            id: animal.id,
            name: animal.name,
            emoji: animal.emoji,
            accentColor: accentColor,
            indicator: SoundWaveIndicator(
              color: accentColor,
              size: 16,
            ),
            onTap: () {
              HapticManager.lightTap();
              onAnimalTap(animal);
            },
          ),
        );
      },
    );
  }

  Color _getAnimalColor(String animalId) {
    // Map animal IDs to jungle color palette
    final colors = [
      AppColors.primaryGreen,
      AppColors.secondaryOrange,
      AppColors.accentYellow,
      AppColors.primaryLightGreen,
      AppColors.secondaryBrown,
      AppColors.secondaryTan,
    ];
    return colors[animalId.hashCode % colors.length];
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 4: Animal Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────

class AnimalDetailSheet extends StatefulWidget {
  final Animal animal;
  final Color accentColor;

  const AnimalDetailSheet({
    Key? key,
    required this.animal,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<AnimalDetailSheet> createState() => _AnimalDetailSheetState();
}

class _AnimalDetailSheetState extends State<AnimalDetailSheet> {
  bool _isPlaying = false;

  void _toggleAudio() {
    HapticManager.lightTap();
    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      AudioService.instance.playSound(widget.animal.soundAssetPath);
    } else {
      AudioService.instance.stopAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.space24),

              // Large emoji
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor,
                      widget.accentColor.withValues(alpha: 0.6),
                    ],
                  ),
                  boxShadow: AppTheme.shadowLarge,
                ),
                child: Center(
                  child: Text(
                    widget.animal.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space16),

              // Animal name
              Text(
                widget.animal.name,
                style: GoogleFonts.fredoka(
                  fontSize: AppTheme.textHeading1,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space8),

              // Category badge
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space12,
                  vertical: AppTheme.space4,
                ),
                borderRadius: AppTheme.radiusPill,
                child: Text(
                  widget.animal.category.toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space24),

              // Play audio button with waveform
              PlayButtonWithWave(
                isPlaying: _isPlaying,
                onTap: _toggleAudio,
                color: widget.accentColor,
                size: 100,
              ),
              const SizedBox(height: AppTheme.space24),

              // Fun fact
              GlassCard(
                padding: const EdgeInsets.all(AppTheme.space16),
                borderRadius: AppTheme.radiusMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fun Fact',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space8),
                    Text(
                      widget.animal.funFact,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.space24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    AudioService.instance.stopAll();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 5: Daily Challenge Banner with Progress
// ─────────────────────────────────────────────────────────────────

class DailyChallengeBanner extends ConsumerWidget {
  const DailyChallengeBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyChallengeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      child: GlassCard(
        padding: const EdgeInsets.all(AppTheme.space16),
        backgroundColor: isDark
            ? AppColors.accentYellow.withValues(alpha: 0.15)
            : AppColors.accentYellow.withValues(alpha: 0.1),
        borderRadius: AppTheme.radiusLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 24)),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Challenge',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${daily.attemptsRemaining} attempts left',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                ProgressRing(
                  progress: daily.attemptsRemaining / 3,
                  label: null,
                  size: 50,
                  progressColor: AppColors.accentYellow,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            // Countdown timer
            if (daily.isAvailable)
              SizedBox(
                width: double.infinity,
                child: BouncyButton(
                  onPressed: () {
                    HapticManager.mediumTap();
                    context.push('/guess?daily=true');
                  },
                  size: 50,
                  backgroundColor: AppColors.accentYellow,
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              )
            else
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space12,
                  vertical: AppTheme.space8,
                ),
                borderRadius: AppTheme.radiusMedium,
                child: Center(
                  child: Text(
                    'Complete tomorrow',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 6: Putting It All Together - Main Home Screen
// ─────────────────────────────────────────────────────────────────

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen> {
  String _selectedCategory = 'all';
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAnimalDetail(Animal animal) {
    final accentColor = _getAnimalColor(animal.id);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AnimalDetailSheet(
        animal: animal,
        accentColor: accentColor,
      ),
    );
  }

  Color _getAnimalColor(String animalId) {
    final colors = [
      AppColors.primaryGreen,
      AppColors.secondaryOrange,
      AppColors.accentYellow,
      AppColors.primaryLightGreen,
      AppColors.secondaryBrown,
    ];
    return colors[animalId.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text(
                '🎵 SoundZoo',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Gamification header
            SliverToBoxAdapter(
              child: const GamificationHeader(),
            ),

            // Daily challenge banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.space16),
                child: const DailyChallengeBanner(),
              ),
            ),

            // Category tab bar (sticky)
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: CategoryTabBar(
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() => _selectedCategory = category);
                    HapticManager.lightTap();
                  },
                ),
              ),
              toolbarHeight: 60,
            ),

            // Animal grid
            SliverFillRemaining(
              child: AnimalGridView(
                selectedCategory: _selectedCategory,
                onAnimalTap: _showAnimalDetail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HOW TO INTEGRATE INTO YOUR EXISTING HOME SCREEN:
//
// 1. Copy the patterns above into lib/features/home/home_screen.dart
// 2. Replace old floating emoji background with new widgets
// 3. Keep existing game mode buttons but enhance with BouncyButton
// 4. Add haptic feedback imports and calls
// 5. Test on device to ensure animations are smooth
// 6. Adjust colors to match your preference
// 7. Run flutter analyze to check for issues
// ─────────────────────────────────────────────────────────────────
