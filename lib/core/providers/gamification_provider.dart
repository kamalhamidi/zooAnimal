/// ─── Gamification System ───
/// Manages XP, stars, progress bars, daily streaks, and unlockable stickers.

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/local_storage.dart';
import 'coin_provider.dart';

// ─── MODELS ───

class GameReward {
  final int xp;
  final int stars;
  final String? achievementUnlocked;
  final bool isNewRecord;

  const GameReward({
    required this.xp,
    required this.stars,
    this.achievementUnlocked,
    this.isNewRecord = false,
  });
}

class PlayerProgress {
  final int totalXP;
  final int level;
  final int currentLevelXP;
  final int nextLevelXP;
  final int totalStars;
  final int currentStreak;
  final int bestStreak;
  final DateTime lastPlayDate;
  final Map<String, int> categoryProgress; // e.g. {'farm': 4, 'wild': 7}
  final List<String> unlockedStickers;
  final List<String> achievements;

  const PlayerProgress({
    required this.totalXP,
    required this.level,
    required this.currentLevelXP,
    required this.nextLevelXP,
    required this.totalStars,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastPlayDate,
    required this.categoryProgress,
    required this.unlockedStickers,
    required this.achievements,
  });

  /// Calculate progress to next level as percentage (0-1)
  double get nextLevelProgress => currentLevelXP / nextLevelXP;

  /// Check if eligible for streak bonus
  bool get streakActive {
    final now = DateTime.now();
    final difference = now.difference(lastPlayDate).inDays;
    return difference <= 1; // Played today or yesterday
  }

  PlayerProgress copyWith({
    int? totalXP,
    int? level,
    int? currentLevelXP,
    int? nextLevelXP,
    int? totalStars,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastPlayDate,
    Map<String, int>? categoryProgress,
    List<String>? unlockedStickers,
    List<String>? achievements,
  }) {
    return PlayerProgress(
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      currentLevelXP: currentLevelXP ?? this.currentLevelXP,
      nextLevelXP: nextLevelXP ?? this.nextLevelXP,
      totalStars: totalStars ?? this.totalStars,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      unlockedStickers: unlockedStickers ?? this.unlockedStickers,
      achievements: achievements ?? this.achievements,
    );
  }

  /// Calculate category completion percentage
  double getCategoryProgress(String category, int totalAnimals) {
    final completed = categoryProgress[category] ?? 0;
    return (completed / totalAnimals).clamp(0.0, 1.0);
  }

  /// Get streak bonus multiplier (1.0 base, +0.05 per consecutive day, max 1.5)
  double getStreakMultiplier() {
    if (!streakActive) return 1.0;
    return 1.0 + (currentStreak * 0.05).clamp(0.0, 0.5);
  }
}

// ─── HELPERS ───

/// Calculate XP required for next level (exponential curve)
int _xpForLevel(int level) => (500 * math.pow(1.2, level - 1)).toInt();

int _totalXpForLevel(int level) {
  int total = 0;
  for (int i = 1; i < level; i++) {
    total += _xpForLevel(i);
  }
  return total;
}

// ─── STATE NOTIFIER ───

class GamificationNotifier extends StateNotifier<PlayerProgress> {
  final LocalStorage _storage;

  GamificationNotifier(this._storage)
      : super(
          PlayerProgress(
            totalXP: 0,
            level: 1,
            currentLevelXP: 0,
            nextLevelXP: 500,
            totalStars: 0,
            currentStreak: 0,
            bestStreak: 0,
            lastPlayDate: DateTime.now(),
            categoryProgress: {},
            unlockedStickers: [],
            achievements: [],
          ),
        ) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      // Load from storage (implementation depends on LocalStorage)
      // For now, initialize with defaults
      await _saveProgress();
    } catch (e) {
      print('Error loading gamification data: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      // Save to storage (implementation depends on LocalStorage)
      // Serialized as JSON
    } catch (e) {
      print('Error saving gamification data: $e');
    }
  }

  /// Award XP and stars from a game round
  Future<GameReward> awardReward({
    required int xpGained,
    required int starsGained,
    String? category,
  }) async {
    int newTotalXP = state.totalXP + xpGained;
    int newLevel = state.level;
    int newCurrentLevelXP = state.currentLevelXP + xpGained;
    int nextLevelRequirement = _xpForLevel(newLevel + 1);
    String? achievementUnlocked;
    bool isNewRecord = false;

    // Check level up
    if (newCurrentLevelXP >= nextLevelRequirement) {
      newLevel += 1;
      newCurrentLevelXP -= nextLevelRequirement;
      achievementUnlocked = 'level_${newLevel}_reached';
    }

    // Update streak
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastPlay = state.lastPlayDate;
    final lastPlayDate = DateTime(
      lastPlay.year,
      lastPlay.month,
      lastPlay.day,
    );

    int newStreak = state.currentStreak;
    int newBestStreak = state.bestStreak;

    if (lastPlayDate == yesterday || lastPlayDate == DateTime(now.year, now.month, now.day)) {
      newStreak = state.currentStreak + 1;
      if (newStreak > newBestStreak) {
        newBestStreak = newStreak;
        isNewRecord = true;
      }
    } else {
      newStreak = 1; // Reset streak
    }

    // Update category progress
    final newCategoryProgress = Map<String, int>.from(state.categoryProgress);
    if (category != null) {
      newCategoryProgress[category] = (newCategoryProgress[category] ?? 0) + 1;
    }

    // Update state
    state = state.copyWith(
      totalXP: newTotalXP,
      level: newLevel,
      currentLevelXP: newCurrentLevelXP,
      nextLevelXP: nextLevelRequirement,
      totalStars: state.totalStars + starsGained,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      lastPlayDate: now,
      categoryProgress: newCategoryProgress,
      achievements: achievementUnlocked != null
          ? [...state.achievements, achievementUnlocked]
          : state.achievements,
    );

    await _saveProgress();

    return GameReward(
      xp: xpGained,
      stars: starsGained,
      achievementUnlocked: achievementUnlocked,
      isNewRecord: isNewRecord,
    );
  }

  /// Unlock a sticker
  Future<void> unlockSticker(String stickerId) async {
    if (!state.unlockedStickers.contains(stickerId)) {
      state = state.copyWith(
        unlockedStickers: [...state.unlockedStickers, stickerId],
      );
      await _saveProgress();
    }
  }

  /// Reset progress (for testing)
  Future<void> resetProgress() async {
    state = PlayerProgress(
      totalXP: 0,
      level: 1,
      currentLevelXP: 0,
      nextLevelXP: 500,
      totalStars: 0,
      currentStreak: 0,
      bestStreak: 0,
      lastPlayDate: DateTime.now(),
      categoryProgress: {},
      unlockedStickers: [],
      achievements: [],
    );
    await _saveProgress();
  }

  /// Calculate category completion percentage
  double getCategoryProgress(String category, int totalAnimals) {
    final completed = state.categoryProgress[category] ?? 0;
    return (completed / totalAnimals).clamp(0.0, 1.0);
  }

  /// Check if a specific achievement is unlocked
  bool hasAchievement(String achievementId) {
    return state.achievements.contains(achievementId);
  }

  /// Get streak bonus multiplier (1.0 base, +0.1 per consecutive day)
  double getStreakMultiplier() {
    if (!state.streakActive) return 1.0;
    return 1.0 + (state.currentStreak * 0.05).clamp(0.0, 0.5);
  }
}

// ─── PROVIDERS ───

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, PlayerProgress>((ref) {
  final storage = ref.watch(localStorageProvider);
  return GamificationNotifier(storage);
});

/// Watch player level
final playerLevelProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider).level;
});

/// Watch total XP
final totalXPProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider).totalXP;
});

/// Watch stars balance
final starsBalanceProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider).totalStars;
});

/// Watch current streak
final streakProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider).currentStreak;
});

/// Watch best streak record
final bestStreakProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider).bestStreak;
});

/// Watch next level progress (0-1)
final nextLevelProgressProvider = Provider<double>((ref) {
  final progress = ref.watch(gamificationProvider);
  return progress.nextLevelProgress;
});

/// Get category progress for a specific category
final categoryProgressProvider = FutureProvider.family<double, String>((ref, category) async {
  final progress = ref.watch(gamificationProvider);
  // This is simplified; in real implementation, get total animal count from data
  const totalAnimalsPerCategory = 8;
  return progress.getCategoryProgress(category, totalAnimalsPerCategory);
});

/// Watch unlocked stickers
final unlockedStickersProvider = Provider<List<String>>((ref) {
  return ref.watch(gamificationProvider).unlockedStickers;
});

/// Watch achievements
final achievementsProvider = Provider<List<String>>((ref) {
  return ref.watch(gamificationProvider).achievements;
});

/// Watch streak multiplier
final streakMultiplierProvider = Provider<double>((ref) {
  return ref.watch(gamificationProvider).getStreakMultiplier();
});
