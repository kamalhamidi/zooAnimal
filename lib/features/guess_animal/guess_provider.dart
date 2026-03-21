import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/audio_service.dart';
import '../../core/models/animal.dart';
import '../../data/animals_data.dart';

enum GameStatus { idle, playing, roundEnd, gameOver }

class GuessGameState {
  final List<Animal> queue;
  final int currentIndex;
  final int score;
  final int streak;
  final int bestStreak;
  final GameStatus status;
  final bool timerActive;
  final double timeRemaining;
  final int correctAnswers;
  final List<Animal> currentOptions;
  final Animal? selectedAnswer;
  final bool? wasCorrect;
  final int roundCoins;
  final int totalCoins;
  final String difficulty;
  final bool isDaily;
  final int soundPlays;

  const GuessGameState({
    this.queue = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.status = GameStatus.idle,
    this.timerActive = false,
    this.timeRemaining = 10.0,
    this.correctAnswers = 0,
    this.currentOptions = const [],
    this.selectedAnswer,
    this.wasCorrect,
    this.roundCoins = 0,
    this.totalCoins = 0,
    this.difficulty = 'easy',
    this.isDaily = false,
    this.soundPlays = 0,
  });

  Animal? get currentAnimal =>
      currentIndex < queue.length ? queue[currentIndex] : null;

  int get totalRounds => queue.length;

  int get stars {
    if (totalRounds == 0) return 0;
    final ratio = correctAnswers / totalRounds;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.6) return 2;
    if (ratio >= 0.3) return 1;
    return 0;
  }

  GuessGameState copyWith({
    List<Animal>? queue,
    int? currentIndex,
    int? score,
    int? streak,
    int? bestStreak,
    GameStatus? status,
    bool? timerActive,
    double? timeRemaining,
    int? correctAnswers,
    List<Animal>? currentOptions,
    Animal? selectedAnswer,
    bool? wasCorrect,
    int? roundCoins,
    int? totalCoins,
    String? difficulty,
    bool? isDaily,
    int? soundPlays,
  }) {
    return GuessGameState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      status: status ?? this.status,
      timerActive: timerActive ?? this.timerActive,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentOptions: currentOptions ?? this.currentOptions,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      roundCoins: roundCoins ?? this.roundCoins,
      totalCoins: totalCoins ?? this.totalCoins,
      difficulty: difficulty ?? this.difficulty,
      isDaily: isDaily ?? this.isDaily,
      soundPlays: soundPlays ?? this.soundPlays,
    );
  }
}

class GuessGameNotifier extends StateNotifier<GuessGameState> {
  Timer? _timer;
  final Random _random = Random();

  GuessGameNotifier() : super(const GuessGameState());

  void startGame({
    required String difficulty,
    bool isDaily = false,
    List<Animal>? dailyQuestions,
  }) {
    _timer?.cancel();
    AudioService.instance.stopAll();

    List<Animal> queue;
    if (isDaily && dailyQuestions != null) {
      queue = dailyQuestions;
    } else {
      final diff = AnimalDifficulty.values.firstWhere(
        (d) => d.name == difficulty,
        orElse: () => AnimalDifficulty.easy,
      );
      queue = List<Animal>.from(AnimalsData.getByDifficulty(diff));
      queue.shuffle(_random);
      // Take up to 10 questions
      if (queue.length > 10) queue = queue.sublist(0, 10);
    }

    state = GuessGameState(
      queue: queue,
      currentIndex: 0,
      score: 0,
      streak: 0,
      bestStreak: 0,
      status: GameStatus.playing,
      timerActive: true,
      timeRemaining: 10.0,
      correctAnswers: 0,
      currentOptions: _generateOptions(queue[0], difficulty),
      difficulty: difficulty,
      isDaily: isDaily,
      soundPlays: 0,
    );

    _startTimer();
  }

  List<Animal> _generateOptions(Animal correct, String difficulty) {
    final diff = AnimalDifficulty.values.firstWhere(
      (d) => d.name == difficulty,
      orElse: () => AnimalDifficulty.easy,
    );
    final pool = AnimalsData.getByDifficulty(diff)
        .where((a) => a.id != correct.id)
        .toList();
    pool.shuffle(_random);

    final decoys = pool.take(3).toList();
    final options = [correct, ...decoys];
    options.shuffle(_random);
    return options;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!state.timerActive || state.status != GameStatus.playing) {
        timer.cancel();
        return;
      }

      final newTime = state.timeRemaining - 0.1;
      if (newTime <= 0) {
        timer.cancel();
        // Time's up — treat as wrong answer
        _handleTimeout();
      } else {
        state = state.copyWith(timeRemaining: newTime);
      }
    });
  }

  void _handleTimeout() {
    AudioService.instance.stopAll();
    state = state.copyWith(
      status: GameStatus.roundEnd,
      timerActive: false,
      wasCorrect: false,
      streak: 0,
      roundCoins: 0,
    );
  }

  void selectAnswer(Animal answer) {
    if (state.status != GameStatus.playing) return;
    _timer?.cancel();
    AudioService.instance.stopAll();

    final correct = state.currentAnimal;
    if (correct == null) return;

    final isCorrect = answer.id == correct.id;
    int roundScore = 0;
    int roundCoins = 0;
    int newStreak = state.streak;
    int newBest = state.bestStreak;

    if (isCorrect) {
      roundScore = 10;
      // Time bonus
      if (state.timeRemaining >= 5.0) {
        roundScore += 5;
      }
      newStreak++;
      // Streak bonus
      roundScore += newStreak * 2;
      if (newStreak > newBest) newBest = newStreak;
      roundCoins = roundScore ~/ 10;
    } else {
      newStreak = 0;
    }

    state = state.copyWith(
      status: GameStatus.roundEnd,
      timerActive: false,
      selectedAnswer: answer,
      wasCorrect: isCorrect,
      score: state.score + roundScore,
      streak: newStreak,
      bestStreak: newBest,
      correctAnswers:
          isCorrect ? state.correctAnswers + 1 : state.correctAnswers,
      roundCoins: roundCoins,
      totalCoins: state.totalCoins + roundCoins,
    );
  }

  void nextRound() {
    AudioService.instance.stopAll();
    final nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.queue.length) {
      state = state.copyWith(status: GameStatus.gameOver);
      return;
    }

    state = state.copyWith(
      currentIndex: nextIndex,
      status: GameStatus.playing,
      timerActive: true,
      timeRemaining: 10.0,
      selectedAnswer: null,
      wasCorrect: null,
      roundCoins: 0,
      soundPlays: 0,
      currentOptions:
          _generateOptions(state.queue[nextIndex], state.difficulty),
    );

    _startTimer();
  }

  void recordSoundPlay() {
    state = state.copyWith(soundPlays: state.soundPlays + 1);
  }

  void endGame() {
    _timer?.cancel();
    AudioService.instance.stopAll();
    state = state.copyWith(status: GameStatus.gameOver);
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioService.instance.stopAll();
    super.dispose();
  }
}

final guessGameProvider =
    StateNotifierProvider<GuessGameNotifier, GuessGameState>((ref) {
  return GuessGameNotifier();
});
