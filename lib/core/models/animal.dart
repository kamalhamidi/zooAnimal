enum AnimalDifficulty { easy, medium, hard }

enum AnimalCategory { farm, wild, ocean, exotic }

class Animal {
  final String id;
  final String name;
  final String emoji;
  final String soundAssetPath;
  final String imageAssetPath;
  final AnimalDifficulty difficulty;
  final String funFact;
  final String category;
  final String ttsLabel;

  const Animal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.soundAssetPath,
    required this.imageAssetPath,
    required this.difficulty,
    required this.funFact,
    required this.category,
    required this.ttsLabel,
  });

  Animal copyWith({
    String? id,
    String? name,
    String? emoji,
    String? soundAssetPath,
    String? imageAssetPath,
    AnimalDifficulty? difficulty,
    String? funFact,
    String? category,
    String? ttsLabel,
  }) {
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      soundAssetPath: soundAssetPath ?? this.soundAssetPath,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      difficulty: difficulty ?? this.difficulty,
      funFact: funFact ?? this.funFact,
      category: category ?? this.category,
      ttsLabel: ttsLabel ?? this.ttsLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Animal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Animal(id: $id, name: $name)';
}
