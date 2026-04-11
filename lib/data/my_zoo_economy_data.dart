import '../core/models/animal.dart';

class ZooEconomyRule {
  final int price;
  final int coinsPerTick;
  final int intervalSeconds;

  const ZooEconomyRule({
    required this.price,
    required this.coinsPerTick,
    required this.intervalSeconds,
  });
}

/// Central place to tune My Zoo economy values from code.
///
/// You can change:
/// - `price` (buy cost)
/// - `coinsPerTick` (generated money each cycle)
/// - `intervalSeconds` (seconds between payouts)
class MyZooEconomyData {
  MyZooEconomyData._();

  static const ZooEconomyRule _easyDefault = ZooEconomyRule(
    price: 75,
    coinsPerTick: 1,
    intervalSeconds: 45,
  );

  static const ZooEconomyRule _mediumDefault = ZooEconomyRule(
    price: 140,
    coinsPerTick: 2,
    intervalSeconds: 65,
  );

  static const ZooEconomyRule _hardDefault = ZooEconomyRule(
    price: 240,
    coinsPerTick: 3,
    intervalSeconds: 95,
  );

  /// Optional per-animal overrides.
  ///
  /// Example:
  /// `lion: ZooEconomyRule(price: 70, coinsPerTick: 10, intervalSeconds: 40)`
  static const Map<String, ZooEconomyRule> _byAnimalId = {
    'lion': ZooEconomyRule(price: 320, coinsPerTick: 3, intervalSeconds: 110),
    'elephant': ZooEconomyRule(price: 360, coinsPerTick: 4, intervalSeconds: 120),
  };

  static ZooEconomyRule ruleFor(Animal animal) {
    final override = _byAnimalId[animal.id];
    if (override != null) return override;

    switch (animal.difficulty) {
      case AnimalDifficulty.easy:
        return _easyDefault;
      case AnimalDifficulty.medium:
        return _mediumDefault;
      case AnimalDifficulty.hard:
        return _hardDefault;
    }
  }
}
