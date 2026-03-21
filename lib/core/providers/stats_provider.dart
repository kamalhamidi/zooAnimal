import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart';
import '../storage/local_storage.dart';
import 'coin_provider.dart';

final statsProvider =
    StateNotifierProvider<StatsNotifier, PlayerStats>((ref) {
  final storage = ref.watch(localStorageProvider);
  return StatsNotifier(storage);
});

class StatsNotifier extends StateNotifier<PlayerStats> {
  final LocalStorage _storage;

  StatsNotifier(this._storage) : super(const PlayerStats()) {
    _loadStats();
  }

  void _loadStats() {
    final data = _storage.getStats();
    if (data != null) {
      state = PlayerStats.fromMap(data);
    }
  }

  Future<void> _save() async {
    await _storage.setStats(state.toMap());
  }

  Future<void> addScore(int score) async {
    state = state.copyWith(totalScore: state.totalScore + score);
    await _save();
  }

  Future<void> updateBestStreak(int streak) async {
    if (streak > state.bestStreak) {
      state = state.copyWith(bestStreak: streak);
      await _storage.setBestStreak(streak);
      await _save();
    }
  }

  Future<void> incrementGamesPlayed() async {
    state = state.copyWith(gamesPlayed: state.gamesPlayed + 1);
    await _save();
  }

  Future<void> addAnimalFound() async {
    state = state.copyWith(animalsFound: state.animalsFound + 1);
    await _save();
  }

  Future<void> addCoinsEarned(int coins) async {
    state = state.copyWith(
        totalCoinsEarned: state.totalCoinsEarned + coins);
    await _save();
  }

  Future<void> completeDailyChallenge(int score) async {
    state = state.copyWith(
      dailyChallengesCompleted: state.dailyChallengesCompleted + 1,
      dailyChallengeHighScore:
          score > state.dailyChallengeHighScore ? score : state.dailyChallengeHighScore,
    );
    await _save();
  }

  Future<void> updateDifficultyHighScore(String difficulty, int score) async {
    final scores = Map<String, int>.from(state.difficultyHighScores);
    final current = scores[difficulty] ?? 0;
    if (score > current) {
      scores[difficulty] = score;
      state = state.copyWith(difficultyHighScores: scores);
      await _save();
    }
  }

  Future<void> updateLastPlayed() async {
    final now = DateTime.now();
    final lastDate = state.lastPlayedDate;
    int consecutive = state.consecutiveDays;

    if (lastDate != null) {
      final diff = now.difference(lastDate).inDays;
      if (diff == 1) {
        consecutive++;
      } else if (diff > 1) {
        consecutive = 1;
      }
    } else {
      consecutive = 1;
    }

    state = state.copyWith(
      lastPlayedDate: now,
      consecutiveDays: consecutive,
    );
    await _save();
  }
}
