import 'dart:ui';

/// Static data defining the open-world zoo layout.
///
/// The world uses a 2400 × 3200 logical-pixel canvas.
/// All positions are in world coordinates.
class ZooWorldData {
  ZooWorldData._();

  // ─── World Dimensions ───
  static const double worldWidth = 2400;
  static const double worldHeight = 3200;

  // ─── Player ───
  static const double playerSize = 54;
  static const double playerSpeed = 5.5; // logical px per tick
  static const Offset playerStart = Offset(1200, 1600);

  // ─── Proximity ───
  static const double soundProximityRadius = 140;
  static const int soundCooldownMs = 5000;

  // ─── Animal Positions ───
  static const Map<String, Offset> animalPositions = {
    // ── Farm biome (top-left) ──
    'cow': Offset(280, 340),
    'dog': Offset(530, 300),
    'cat': Offset(180, 600),
    'pig': Offset(460, 560),
    'horse': Offset(320, 820),
    'duck': Offset(130, 1020),
    'sheep': Offset(400, 980),
    'rooster': Offset(580, 780),
    'chicken': Offset(230, 1220),
    'goat': Offset(480, 1180),
    'donkey': Offset(660, 1060),

    // ── Wild biome (top-right & center-right) ──
    'lion': Offset(1580, 560),
    'elephant': Offset(1880, 420),
    'wolf': Offset(1680, 870),
    'owl': Offset(1380, 320),
    'crow': Offset(1780, 1160),
    'monkey': Offset(1480, 1480),
    'alligator': Offset(1020, 1580),
    'gorilla': Offset(1630, 1680),
    'chimp': Offset(1330, 1780),
    'fox': Offset(1880, 1480),
    'eagle': Offset(2080, 660),
    'parrot': Offset(2030, 1060),
    'frog': Offset(1080, 1380),

    // ── Exotic biome (bottom half) ──
    'king_cobra': Offset(380, 2160),
    'leopard': Offset(680, 2360),
    'tiger': Offset(280, 2560),
    'rhino': Offset(580, 2760),
    'snow_leopard': Offset(880, 2460),
    'hyena': Offset(1080, 2660),
    'kookaburra': Offset(1380, 2260),
    'whale': Offset(1180, 1960),
    'bat': Offset(1580, 2560),
    'peacock': Offset(1880, 2360),
  };

  // ─── Ponds ───
  static const List<Rect> ponds = [
    Rect.fromLTWH(920, 1260, 320, 380),
    Rect.fromLTWH(1080, 1860, 260, 300),
  ];

  // ─── Paths (list of waypoint-pairs for bezier drawing) ───
  static const List<List<Offset>> pathSegments = [
    // Main horizontal
    [Offset(50, 1600), Offset(600, 1500), Offset(1200, 1600), Offset(1800, 1700), Offset(2350, 1600)],
    // Main vertical
    [Offset(1200, 50), Offset(1250, 800), Offset(1200, 1600), Offset(1150, 2400), Offset(1200, 3150)],
    // Farm ring
    [Offset(100, 500), Offset(400, 300), Offset(700, 500), Offset(700, 900), Offset(400, 1100), Offset(100, 900), Offset(100, 500)],
    // Wild ring
    [Offset(1300, 400), Offset(1600, 300), Offset(2100, 500), Offset(2100, 1200), Offset(1600, 1400), Offset(1300, 1200), Offset(1300, 400)],
    // Exotic connector
    [Offset(400, 1600), Offset(400, 2200), Offset(600, 2600), Offset(1000, 2800), Offset(1400, 2600), Offset(1800, 2400), Offset(2000, 2000)],
  ];

  // ─── Decorations ───
  static const List<ZooDecor> decorations = [
    // Trees (scattered across world)
    ZooDecor('🌳', Offset(80, 180), 42),
    ZooDecor('🌲', Offset(720, 140), 40),
    ZooDecor('🌴', Offset(850, 400), 44),
    ZooDecor('🌳', Offset(50, 1400), 38),
    ZooDecor('🌲', Offset(760, 1350), 42),
    ZooDecor('🌴', Offset(1900, 300), 40),
    ZooDecor('🌳', Offset(2200, 500), 44),
    ZooDecor('🌲', Offset(2280, 900), 38),
    ZooDecor('🌳', Offset(2100, 1400), 40),
    ZooDecor('🌴', Offset(200, 1800), 42),
    ZooDecor('🌳', Offset(800, 2000), 44),
    ZooDecor('🌲', Offset(1600, 2100), 40),
    ZooDecor('🌴', Offset(2200, 1900), 38),
    ZooDecor('🌳', Offset(300, 2900), 42),
    ZooDecor('🌲', Offset(900, 3000), 40),
    ZooDecor('🌴', Offset(1500, 2900), 44),
    ZooDecor('🌳', Offset(2100, 2800), 38),
    ZooDecor('🌲', Offset(150, 700), 36),
    ZooDecor('🌳', Offset(650, 650), 40),
    ZooDecor('🌴', Offset(1100, 700), 38),

    // Rocks
    ZooDecor('🪨', Offset(300, 1500), 30),
    ZooDecor('🪨', Offset(800, 800), 28),
    ZooDecor('🪨', Offset(1700, 700), 32),
    ZooDecor('🪨', Offset(2000, 1600), 26),
    ZooDecor('🪨', Offset(500, 2500), 30),
    ZooDecor('🪨', Offset(1200, 2500), 28),
    ZooDecor('🪨', Offset(1900, 2700), 26),

    // Flowers
    ZooDecor('🌸', Offset(350, 450), 22),
    ZooDecor('🌺', Offset(550, 700), 24),
    ZooDecor('🌻', Offset(200, 900), 22),
    ZooDecor('🌸', Offset(1500, 500), 24),
    ZooDecor('🌺', Offset(1800, 800), 22),
    ZooDecor('🌻', Offset(2100, 400), 20),
    ZooDecor('🌸', Offset(400, 2300), 22),
    ZooDecor('🌺', Offset(700, 2600), 24),
    ZooDecor('🌻', Offset(1000, 2900), 22),
    ZooDecor('🌸', Offset(1600, 2700), 20),
    ZooDecor('🌺', Offset(1400, 1700), 22),

    // Bushes / Plants
    ZooDecor('🌿', Offset(600, 200), 26),
    ZooDecor('🌿', Offset(1100, 200), 24),
    ZooDecor('🌿', Offset(1600, 1800), 26),
    ZooDecor('🌿', Offset(2200, 2200), 24),
    ZooDecor('🌿', Offset(100, 2600), 26),
    ZooDecor('☘️', Offset(500, 1600), 22),
    ZooDecor('☘️', Offset(1800, 2000), 24),
    ZooDecor('🍄', Offset(790, 300), 20),
    ZooDecor('🍄', Offset(2050, 800), 18),

    // Fence posts (perimeter accents)
    ZooDecor('🏠', Offset(400, 200), 30),
    ZooDecor('⛲', Offset(1200, 1400), 34),
    ZooDecor('🏕️', Offset(1800, 2200), 30),
  ];

  // ─── Biome Regions (for painter tinting) ───
  static const Rect farmBiome = Rect.fromLTWH(0, 0, 900, 1400);
  static const Rect wildBiome = Rect.fromLTWH(1200, 0, 1200, 1600);
  static const Rect exoticBiome = Rect.fromLTWH(0, 1900, 2400, 1300);
}

class ZooDecor {
  final String emoji;
  final Offset position;
  final double size;
  const ZooDecor(this.emoji, this.position, this.size);
}
