import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/animal.dart';
import '../../data/animals_data.dart';

enum PuzzleStatus { idle, playing, solved, failed }

class PuzzleState {
  final Animal? currentAnimal;
  final List<bool> revealedTiles;
  final int attempts;
  final int maxAttempts;
  final int coinsSpent;
  final int soundReplays;
  final PuzzleStatus status;
  final String? guessText;
  final bool? lastGuessCorrect;
  final List<String> unlockedAnimalIds;

  const PuzzleState({
    this.currentAnimal,
    this.revealedTiles = const [
      false, false, false,
      false, false, false,
      false, false, false
    ],
    this.attempts = 3,
    this.maxAttempts = 3,
    this.coinsSpent = 0,
    this.soundReplays = 0,
    this.status = PuzzleStatus.idle,
    this.guessText,
    this.lastGuessCorrect,
    this.unlockedAnimalIds = const [],
  });

  int get tilesRevealed => revealedTiles.where((t) => t).length;
  int get score => (100 - (tilesRevealed * 10) - (soundReplays * 5)).clamp(0, 100);
  int get coinsReward => (score / 10).floor();

  PuzzleState copyWith({
    Animal? currentAnimal,
    List<bool>? revealedTiles,
    int? attempts,
    int? maxAttempts,
    int? coinsSpent,
    int? soundReplays,
    PuzzleStatus? status,
    String? guessText,
    bool? lastGuessCorrect,
    List<String>? unlockedAnimalIds,
  }) {
    return PuzzleState(
      currentAnimal: currentAnimal ?? this.currentAnimal,
      revealedTiles: revealedTiles ?? this.revealedTiles,
      attempts: attempts ?? this.attempts,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      coinsSpent: coinsSpent ?? this.coinsSpent,
      soundReplays: soundReplays ?? this.soundReplays,
      status: status ?? this.status,
      guessText: guessText ?? this.guessText,
      lastGuessCorrect: lastGuessCorrect ?? this.lastGuessCorrect,
      unlockedAnimalIds: unlockedAnimalIds ?? this.unlockedAnimalIds,
    );
  }
}

class PuzzleNotifier extends StateNotifier<PuzzleState> {
  final Random _random = Random();

  PuzzleNotifier() : super(const PuzzleState());

  void startNewPuzzle({List<String>? unlockedIds}) {
    final animals = List<Animal>.from(AnimalsData.allAnimals);
    animals.shuffle(_random);
    final animal = animals.first;

    state = PuzzleState(
      currentAnimal: animal,
      revealedTiles: List.filled(9, false),
      attempts: 3,
      coinsSpent: 0,
      soundReplays: 0,
      status: PuzzleStatus.playing,
      unlockedAnimalIds: unlockedIds ?? state.unlockedAnimalIds,
    );
  }

  bool revealTile() {
    // Find unrevealed tiles
    final unrevealed = <int>[];
    for (int i = 0; i < state.revealedTiles.length; i++) {
      if (!state.revealedTiles[i]) unrevealed.add(i);
    }
    if (unrevealed.isEmpty) return false;

    final idx = unrevealed[_random.nextInt(unrevealed.length)];
    final newTiles = List<bool>.from(state.revealedTiles);
    newTiles[idx] = true;

    state = state.copyWith(
      revealedTiles: newTiles,
      coinsSpent: state.coinsSpent + 3,
    );
    return true;
  }

  void replaySound() {
    state = state.copyWith(
      soundReplays: state.soundReplays + 1,
      coinsSpent: state.coinsSpent + 1,
    );
  }

  void submitGuess(String guess) {
    if (state.currentAnimal == null || state.status != PuzzleStatus.playing) return;

    final correct = guess.trim().toLowerCase() ==
        state.currentAnimal!.name.toLowerCase();

    if (correct) {
      // Reveal all tiles
      final allRevealed = List.filled(9, true);
      final newUnlocked = List<String>.from(state.unlockedAnimalIds);
      if (!newUnlocked.contains(state.currentAnimal!.id)) {
        newUnlocked.add(state.currentAnimal!.id);
      }
      state = state.copyWith(
        status: PuzzleStatus.solved,
        revealedTiles: allRevealed,
        lastGuessCorrect: true,
        unlockedAnimalIds: newUnlocked,
      );
    } else {
      final newAttempts = state.attempts - 1;
      if (newAttempts <= 0) {
        // Failed
        final allRevealed = List.filled(9, true);
        state = state.copyWith(
          status: PuzzleStatus.failed,
          attempts: 0,
          revealedTiles: allRevealed,
          lastGuessCorrect: false,
        );
      } else {
        state = state.copyWith(
          attempts: newAttempts,
          lastGuessCorrect: false,
        );
      }
    }
  }

  void updateGuessText(String text) {
    state = state.copyWith(guessText: text);
  }

  void grantExtraLife({int lives = 1}) {
    if (lives <= 0) return;

    state = state.copyWith(
      attempts: state.attempts + lives,
      status: PuzzleStatus.playing,
      lastGuessCorrect: null,
    );
  }
}

final puzzleProvider =
    StateNotifierProvider<PuzzleNotifier, PuzzleState>((ref) {
  return PuzzleNotifier();
});
