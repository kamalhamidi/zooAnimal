class GameResult {
  final int score;
  final int totalRounds;
  final int correctAnswers;
  final int bestStreak;
  final int coinsEarned;
  final int stars;
  final Duration timePlayed;
  final String mode;
  final DateTime playedAt;

  const GameResult({
    required this.score,
    required this.totalRounds,
    required this.correctAnswers,
    required this.bestStreak,
    required this.coinsEarned,
    required this.stars,
    required this.timePlayed,
    required this.mode,
    required this.playedAt,
  });

  double get accuracy =>
      totalRounds > 0 ? (correctAnswers / totalRounds) * 100 : 0;

  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      score: map['score'] as int? ?? 0,
      totalRounds: map['totalRounds'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      bestStreak: map['bestStreak'] as int? ?? 0,
      coinsEarned: map['coinsEarned'] as int? ?? 0,
      stars: map['stars'] as int? ?? 0,
      timePlayed: Duration(milliseconds: map['timePlayed'] as int? ?? 0),
      mode: map['mode'] as String? ?? '',
      playedAt: DateTime.fromMillisecondsSinceEpoch(
        map['playedAt'] as int? ?? 0,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'totalRounds': totalRounds,
      'correctAnswers': correctAnswers,
      'bestStreak': bestStreak,
      'coinsEarned': coinsEarned,
      'stars': stars,
      'timePlayed': timePlayed.inMilliseconds,
      'mode': mode,
      'playedAt': playedAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() =>
      'GameResult(score: $score, correct: $correctAnswers/$totalRounds, streak: $bestStreak)';
}
