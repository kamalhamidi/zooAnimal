import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/animals_data.dart';
import '../models/animal.dart';
import '../storage/local_storage.dart';
import 'coin_provider.dart';

class DailyChallengeState {
  final List<Animal> questions;
  final int attemptsUsed;
  final int maxAttempts;
  final int highScore;
  final bool isAvailable;
  final Duration timeUntilReset;
  final String dateKey;

  const DailyChallengeState({
    required this.questions,
    required this.attemptsUsed,
    this.maxAttempts = 3,
    required this.highScore,
    required this.isAvailable,
    required this.timeUntilReset,
    required this.dateKey,
  });

  bool get hasAttemptsRemaining => attemptsUsed < maxAttempts;

  DailyChallengeState copyWith({
    List<Animal>? questions,
    int? attemptsUsed,
    int? maxAttempts,
    int? highScore,
    bool? isAvailable,
    Duration? timeUntilReset,
    String? dateKey,
  }) {
    return DailyChallengeState(
      questions: questions ?? this.questions,
      attemptsUsed: attemptsUsed ?? this.attemptsUsed,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      highScore: highScore ?? this.highScore,
      isAvailable: isAvailable ?? this.isAvailable,
      timeUntilReset: timeUntilReset ?? this.timeUntilReset,
      dateKey: dateKey ?? this.dateKey,
    );
  }
}

class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  DailyChallengeNotifier(this._ref) : super(_buildState(_ref.read(localStorageProvider)));

  final Ref _ref;

  static DailyChallengeState _buildState(LocalStorage storage) {
    final now = DateTime.now();
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Reset if new day
    final storedDate = storage.getDailyDate();
    int attempts = 0;
    if (storedDate == dateKey) {
      attempts = storage.getDailyAttempts();
    } else {
      storage.setDailyDate(dateKey);
      storage.setDailyAttempts(0);
    }

    // Generate deterministic questions from date seed
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    final allAnimals = List<Animal>.from(AnimalsData.allAnimals);
    allAnimals.shuffle(random);
    final questions = allAnimals.take(10).toList();

    // Time until next day
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilReset = tomorrow.difference(now);

    return DailyChallengeState(
      questions: questions,
      attemptsUsed: attempts,
      highScore: storage.getDailyHighScore(),
      isAvailable: attempts < 3,
      timeUntilReset: timeUntilReset,
      dateKey: dateKey,
    );
  }

  void refresh() {
    state = _buildState(_ref.read(localStorageProvider));
  }

  Future<bool> consumeAttempt() async {
    refresh();
    if (!state.hasAttemptsRemaining) return false;

    final storage = _ref.read(localStorageProvider);
    final newAttempts = state.attemptsUsed + 1;
    await storage.setDailyAttempts(newAttempts);
    state = state.copyWith(
      attemptsUsed: newAttempts,
      isAvailable: newAttempts < state.maxAttempts,
    );
    return true;
  }

  Future<void> updateHighScore(int score) async {
    if (score <= state.highScore) return;
    final storage = _ref.read(localStorageProvider);
    await storage.setDailyHighScore(score);
    state = state.copyWith(highScore: score);
  }
}

final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>((ref) {
  return DailyChallengeNotifier(ref);
});
