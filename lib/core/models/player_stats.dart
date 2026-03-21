class PlayerStats {
  final int totalScore;
  final int bestStreak;
  final int gamesPlayed;
  final int animalsFound;
  final int totalCoinsEarned;
  final int dailyChallengesCompleted;
  final int dailyChallengeHighScore;
  final Map<String, int> difficultyHighScores;
  final DateTime? lastPlayedDate;
  final int consecutiveDays;

  const PlayerStats({
    this.totalScore = 0,
    this.bestStreak = 0,
    this.gamesPlayed = 0,
    this.animalsFound = 0,
    this.totalCoinsEarned = 0,
    this.dailyChallengesCompleted = 0,
    this.dailyChallengeHighScore = 0,
    this.difficultyHighScores = const {},
    this.lastPlayedDate,
    this.consecutiveDays = 0,
  });

  PlayerStats copyWith({
    int? totalScore,
    int? bestStreak,
    int? gamesPlayed,
    int? animalsFound,
    int? totalCoinsEarned,
    int? dailyChallengesCompleted,
    int? dailyChallengeHighScore,
    Map<String, int>? difficultyHighScores,
    DateTime? lastPlayedDate,
    int? consecutiveDays,
  }) {
    return PlayerStats(
      totalScore: totalScore ?? this.totalScore,
      bestStreak: bestStreak ?? this.bestStreak,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      animalsFound: animalsFound ?? this.animalsFound,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
      dailyChallengeHighScore:
          dailyChallengeHighScore ?? this.dailyChallengeHighScore,
      difficultyHighScores: difficultyHighScores ?? this.difficultyHighScores,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
    );
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      totalScore: map['totalScore'] as int? ?? 0,
      bestStreak: map['bestStreak'] as int? ?? 0,
      gamesPlayed: map['gamesPlayed'] as int? ?? 0,
      animalsFound: map['animalsFound'] as int? ?? 0,
      totalCoinsEarned: map['totalCoinsEarned'] as int? ?? 0,
      dailyChallengesCompleted: map['dailyChallengesCompleted'] as int? ?? 0,
      dailyChallengeHighScore: map['dailyChallengeHighScore'] as int? ?? 0,
      difficultyHighScores:
          (map['difficultyHighScores'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, v as int),
              ) ??
              {},
      lastPlayedDate: map['lastPlayedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastPlayedDate'] as int)
          : null,
      consecutiveDays: map['consecutiveDays'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalScore': totalScore,
      'bestStreak': bestStreak,
      'gamesPlayed': gamesPlayed,
      'animalsFound': animalsFound,
      'totalCoinsEarned': totalCoinsEarned,
      'dailyChallengesCompleted': dailyChallengesCompleted,
      'dailyChallengeHighScore': dailyChallengeHighScore,
      'difficultyHighScores': difficultyHighScores,
      'lastPlayedDate': lastPlayedDate?.millisecondsSinceEpoch,
      'consecutiveDays': consecutiveDays,
    };
  }
}
