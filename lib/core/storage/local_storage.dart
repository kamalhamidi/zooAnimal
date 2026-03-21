import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static LocalStorage? _instance;
  late SharedPreferences _prefs;

  LocalStorage._();

  static Future<LocalStorage> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorage._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ─── Coins ───
  static const String _coinsKey = 'coins';

  int getCoins() => _prefs.getInt(_coinsKey) ?? 100; // Start with 100 coins

  Future<void> setCoins(int coins) => _prefs.setInt(_coinsKey, coins);

  // ─── Stats ───
  static const String _statsKey = 'player_stats';

  Map<String, dynamic>? getStats() {
    final data = _prefs.getString(_statsKey);
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  Future<void> setStats(Map<String, dynamic> stats) =>
      _prefs.setString(_statsKey, json.encode(stats));

  // ─── Daily Challenge ───
  static const String _dailyAttemptsKey = 'daily_attempts';
  static const String _dailyDateKey = 'daily_date';
  static const String _dailyHighScoreKey = 'daily_high_score';

  int getDailyAttempts() => _prefs.getInt(_dailyAttemptsKey) ?? 0;
  Future<void> setDailyAttempts(int attempts) =>
      _prefs.setInt(_dailyAttemptsKey, attempts);

  String? getDailyDate() => _prefs.getString(_dailyDateKey);
  Future<void> setDailyDate(String date) =>
      _prefs.setString(_dailyDateKey, date);

  int getDailyHighScore() => _prefs.getInt(_dailyHighScoreKey) ?? 0;
  Future<void> setDailyHighScore(int score) =>
      _prefs.setInt(_dailyHighScoreKey, score);

  // ─── Unlocked Animals (Puzzle) ───
  static const String _unlockedAnimalsKey = 'unlocked_animals';

  List<String> getUnlockedAnimals() =>
      _prefs.getStringList(_unlockedAnimalsKey) ?? [];

  Future<void> addUnlockedAnimal(String animalId) async {
    final list = getUnlockedAnimals();
    if (!list.contains(animalId)) {
      list.add(animalId);
      await _prefs.setStringList(_unlockedAnimalsKey, list);
    }
  }

  // ─── Best Streak ───
  static const String _bestStreakKey = 'best_streak';

  int getBestStreak() => _prefs.getInt(_bestStreakKey) ?? 0;
  Future<void> setBestStreak(int streak) =>
      _prefs.setInt(_bestStreakKey, streak);

  // ─── Last Daily Bonus Date ───
  static const String _lastDailyBonusKey = 'last_daily_bonus';

  String? getLastDailyBonusDate() => _prefs.getString(_lastDailyBonusKey);
  Future<void> setLastDailyBonusDate(String date) =>
      _prefs.setString(_lastDailyBonusKey, date);

  // ─── Settings ───
  static const String _volumeKey = 'volume';
  static const String _darkModeKey = 'dark_mode';

  double getVolume() => _prefs.getDouble(_volumeKey) ?? 1.0;
  Future<void> setVolume(double v) => _prefs.setDouble(_volumeKey, v);

  bool getDarkMode() => _prefs.getBool(_darkModeKey) ?? false;
  Future<void> setDarkMode(bool dark) => _prefs.setBool(_darkModeKey, dark);

  // ─── Clear All ───
  Future<void> clearAll() => _prefs.clear();
}
