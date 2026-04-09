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
    price: 20,
    coinsPerTick: 2,
    intervalSeconds: 20,
  );

  static const ZooEconomyRule _mediumDefault = ZooEconomyRule(
    price: 35,
    coinsPerTick: 4,
    intervalSeconds: 30,
  );

  static const ZooEconomyRule _hardDefault = ZooEconomyRule(
    price: 50,
    coinsPerTick: 7,
    intervalSeconds: 45,
  );

  /// Optional per-animal overrides.
  ///
  /// Example:
  /// `lion: ZooEconomyRule(price: 70, coinsPerTick: 10, intervalSeconds: 40)`
  static const Map<String, ZooEconomyRule> _byAnimalId = {
    'lion': ZooEconomyRule(price: 60, coinsPerTick: 8, intervalSeconds: 40),
    'elephant': ZooEconomyRule(price: 65, coinsPerTick: 9, intervalSeconds: 45),
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
