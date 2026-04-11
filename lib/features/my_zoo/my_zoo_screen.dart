import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/ads/ad_service.dart';
import '../../core/audio/audio_service.dart';
import '../../core/ads/banner_ad_widget.dart';
import '../../core/models/animal.dart';
import '../../core/providers/coin_provider.dart';
import '../../core/providers/my_zoo_provider.dart';
import '../../data/animals_data.dart';
import '../../data/my_zoo_economy_data.dart';
import 'zoo_animal_sprite.dart';
import 'zoo_hud.dart';
import 'zoo_joystick.dart';
import 'zoo_player.dart';
import 'zoo_shop_sheet.dart';
import 'zoo_world_data.dart';
import 'zoo_world_painter.dart';

class MyZooScreen extends ConsumerStatefulWidget {
  const MyZooScreen({super.key});

  @override
  ConsumerState<MyZooScreen> createState() => _MyZooScreenState();
}

class _MyZooScreenState extends ConsumerState<MyZooScreen>
    with SingleTickerProviderStateMixin {
  // Change this path to your own image in assets/images/
  static const String _codeAvatarAssetPath = 'assets/images/avatar.png';

  static const double _animalHalfWidth = 45;
  static const double _animalHalfHeight = 55;
  static const double _minZoom = 0.75;
  static const double _maxZoom = 2.2;
  static const double _bannerReservedHeight = 70;

  // ─── Game loop ───
  late Ticker _ticker;
  Duration _lastTick = Duration.zero;

  // ─── Player state ───
  Offset _playerPos = ZooWorldData.playerStart;
  Offset _joystickDir = Offset.zero;
  bool _facingRight = true;
  double _walkPhase = 0;

  // ─── Camera ───
  Offset _cameraOffset = Offset.zero;
  double _zoom = 1.0;
  double _zoomStart = 1.0;

  // ─── Screen size ───
  Size _screenSize = Size.zero;

  // ─── Sound cooldowns ───
  final Map<String, int> _lastSoundPlayMs = {};

  // ─── Overlay state ───
  bool _showShop = false;

  // ─── UI ticker for income countdowns ───
  Timer? _uiTicker;
  Timer? _interstitialTicker;
  bool _isShowingInterstitial = false;
  bool _pendingInterstitial = false;

  // ─── Image picker ───
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Game loop
    _ticker = createTicker(_onTick);
    _ticker.start();

    // 1-second UI refresh for income countdowns
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    // Show interstitial ad every 2 minutes while in My Zoo.
    _interstitialTicker = Timer.periodic(const Duration(minutes: 2), (_) {
      _tryShowPeriodicInterstitial();
    });

    // Immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _uiTicker?.cancel();
    _interstitialTicker?.cancel();
    AudioService.instance.stopAll();
    // Restore UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> _tryShowPeriodicInterstitial() async {
    if (!mounted || _isShowingInterstitial) return;

    // Avoid interrupting user while shop is open; defer until closed.
    if (_showShop) {
      _pendingInterstitial = true;
      return;
    }

    _isShowingInterstitial = true;
    try {
      await AdService.instance.showInterstitial();
    } finally {
      _isShowingInterstitial = false;
    }
  }

  // ─── Game tick ───
  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 1.0 / 60.0
        : (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    final isMoving = _joystickDir.distance > 0.15;

    if (isMoving) {
      final speed = ZooWorldData.playerSpeed * (dt * 60);
      final dx = _joystickDir.dx * speed;
      final dy = _joystickDir.dy * speed;

      _playerPos = Offset(
        (_playerPos.dx + dx).clamp(60, ZooWorldData.worldWidth - 60),
        (_playerPos.dy + dy).clamp(60, ZooWorldData.worldHeight - 60),
      );

      if (_joystickDir.dx.abs() > 0.1) {
        _facingRight = _joystickDir.dx > 0;
      }

      _walkPhase = (_walkPhase + dt * 4) % 1.0;
    }

    // Camera follows player (centered)
    if (_screenSize != Size.zero) {
      final visibleWorldWidth = _screenSize.width / _zoom;
      final visibleWorldHeight = _screenSize.height / _zoom;

      final targetCam = Offset(
        (_playerPos.dx - visibleWorldWidth / 2).clamp(
          0.0,
          (ZooWorldData.worldWidth - visibleWorldWidth).clamp(0.0, double.infinity),
        ),
        (_playerPos.dy - visibleWorldHeight / 2).clamp(
          0.0,
          (ZooWorldData.worldHeight - visibleWorldHeight).clamp(0.0, double.infinity),
        ),
      );

      // Smooth camera follow
      _cameraOffset = Offset(
        _cameraOffset.dx + (targetCam.dx - _cameraOffset.dx) * 0.12,
        _cameraOffset.dy + (targetCam.dy - _cameraOffset.dy) * 0.12,
      );
    }

    // Proximity sound checks
    _checkProximity();

    // Rebuild
    if (mounted) setState(() {});
  }

  void _onScaleStart(ScaleStartDetails details) {
    _zoomStart = _zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;

    final nextZoom = (_zoomStart * details.scale).clamp(_minZoom, _maxZoom);
    if ((nextZoom - _zoom).abs() < 0.001) return;

    setState(() {
      _zoom = nextZoom;
    });
  }

  void _checkProximity() {
    final zooState = ref.read(myZooProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final animalId in zooState.ownedAnimalIds) {
      final worldPos = _worldAnimalPosition(animalId, zooState);

      final dist = (_playerPos - worldPos).distance;
      if (dist < ZooWorldData.soundProximityRadius) {
        final lastPlay = _lastSoundPlayMs[animalId] ?? 0;
        if (now - lastPlay > ZooWorldData.soundCooldownMs) {
          _lastSoundPlayMs[animalId] = now;
          _playAnimalSound(animalId, zooState);
        }
      }
    }
  }

  Future<void> _playAnimalSound(String animalId, MyZooState zooState) async {
    final animal = AnimalsData.allAnimals.firstWhere(
      (a) => a.id == animalId,
      orElse: () => AnimalsData.allAnimals.first,
    );

    final mode = ref.read(myZooProvider.notifier).getSoundMode(animalId);
    final recording = zooState.recordingPathByAnimal[animalId];

    await AudioService.instance.playPreferredSound(
      originalAssetPath: animal.soundAssetPath,
      recordedFilePath: recording,
      preferRecorded: mode == MyZooSoundMode.recorded,
    );
  }

  // ─── Customisation ───
  Future<void> _pickPlayerImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
      imageQuality: 85,
    );
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/zoo_player_avatar.png';
    await File(picked.path).copy(dest);

    await ref.read(myZooProvider.notifier).setCustomPlayerImage(dest);
  }

  Future<void> _pickBackgroundImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2400,
      maxHeight: 3200,
      imageQuality: 90,
    );
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/zoo_custom_bg.png';
    await File(picked.path).copy(dest);

    await ref.read(myZooProvider.notifier).setCustomBackground(dest);
  }

  void _showSettingsSheet() {
    final zooState = ref.read(myZooProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '🎨 Customise Zoo',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.person, color: AppColors.primaryGreen),
                  ),
                  title: Text('Change Player Character',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    zooState.customPlayerImagePath != null
                        ? 'Custom image set ✓'
                        : 'Upload your own character photo',
                    style: GoogleFonts.nunito(fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPlayerImage();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryOrange.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.landscape, color: AppColors.secondaryOrange),
                  ),
                  title: Text('Change Background',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    zooState.customBackgroundPath != null
                        ? 'Custom background set ✓'
                        : 'Upload a custom zoo background',
                    style: GoogleFonts.nunito(fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickBackgroundImage();
                  },
                ),
                if (zooState.customPlayerImagePath != null ||
                    zooState.customBackgroundPath != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withValues(alpha: 0.1),
                      ),
                      child: const Icon(Icons.restore, color: Colors.red),
                    ),
                    title: Text('Reset to Default',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await ref.read(myZooProvider.notifier).setCustomPlayerImage(null);
                      await ref.read(myZooProvider.notifier).setCustomBackground(null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Build ───
  @override
  Widget build(BuildContext context) {
    final zooState = ref.watch(myZooProvider);
    final coins = ref.watch(coinProvider);
    final allAnimals = AnimalsData.allAnimals;
    final ownedAnimals =
        allAnimals.where((a) => zooState.ownedAnimalIds.contains(a.id)).toList();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _screenSize = Size(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ─── World viewport ───
              _buildWorld(ownedAnimals, zooState),

              // ─── HUD overlay ───
              ZooHud(
                coins: coins,
                onBack: () => Navigator.of(context).pop(),
                onShop: () => setState(() => _showShop = true),
                onSettings: _showSettingsSheet,
                bottomInset: _showShop ? 0 : _bannerReservedHeight,
              ),

              // ─── In-game banner ad (bottom) ───
              if (!_showShop)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: const BannerAdWidget(),
                    ),
                  ),
                ),

              // ─── Joystick ───
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom +
                    (_showShop ? 24 : 24 + _bannerReservedHeight),
                left: 20,
                child: ZooJoystick(
                  onDirectionChanged: (dir) => _joystickDir = dir,
                ),
              ),

              // ─── Shop overlay ───
              if (_showShop) ...[
                // Backdrop
                GestureDetector(
                  onTap: () async {
                    setState(() => _showShop = false);
                    if (_pendingInterstitial) {
                      _pendingInterstitial = false;
                      await _tryShowPeriodicInterstitial();
                    }
                  },
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
                // Sheet
                const ZooShopSheet(),
              ],
            ],
          );
        },
      ),
    );
  }

  // ─── World layer ───
  Widget _buildWorld(List<Animal> ownedAnimals, MyZooState zooState) {
    return ClipRect(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: Stack(
          children: [
            Positioned(
              left: -_cameraOffset.dx * _zoom,
              top: -_cameraOffset.dy * _zoom,
              child: Transform.scale(
                scale: _zoom,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: ZooWorldData.worldWidth,
                  height: ZooWorldData.worldHeight,
                  child: Stack(
                    children: [
                      // Background
                      _buildBackground(zooState),

                      // Decorations
                      ..._buildDecorations(),

                      // Animals
                      ..._buildAnimals(ownedAnimals, zooState),

                      // Player
                      Positioned(
                        left: _playerPos.dx - (ZooWorldData.playerSize + 20) / 2,
                        top: _playerPos.dy - (ZooWorldData.playerSize + 36),
                        child: ZooPlayer(
                          isMoving: _joystickDir.distance > 0.15,
                          facingRight: _facingRight,
                          customImagePath: zooState.customPlayerImagePath,
                          defaultAssetImagePath: _codeAvatarAssetPath,
                          size: ZooWorldData.playerSize,
                          bouncePhase: _walkPhase,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 88,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Text(
                  '${_zoom.toStringAsFixed(2)}x',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(MyZooState zooState) {
    if (zooState.customBackgroundPath != null) {
      final file = File(zooState.customBackgroundPath!);
      if (file.existsSync()) {
        return Positioned.fill(
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _defaultBackground(),
          ),
        );
      }
    }
    return _defaultBackground();
  }

  Widget _defaultBackground() {
    return Positioned.fill(
      child: RepaintBoundary(
        child: CustomPaint(
          size: const Size(ZooWorldData.worldWidth, ZooWorldData.worldHeight),
          painter: ZooWorldPainter(),
        ),
      ),
    );
  }

  List<Widget> _buildDecorations() {
    return ZooWorldData.decorations.map((d) {
      return Positioned(
        left: d.position.dx - d.size / 2,
        top: d.position.dy - d.size / 2,
        child: Text(
          d.emoji,
          style: TextStyle(fontSize: d.size),
        ),
      );
    }).toList();
  }

  List<Widget> _buildAnimals(List<Animal> owned, MyZooState zooState) {
    return owned.map((animal) {
      final worldPos = _worldAnimalPosition(animal.id, zooState);

      final rule = MyZooEconomyData.ruleFor(animal);
      final remaining = ref
          .read(myZooProvider.notifier)
          .secondsUntilNextIncome(animal.id, rule.intervalSeconds);
      final dist = (_playerPos - worldPos).distance;
      final isNearby = dist < ZooWorldData.soundProximityRadius;

      return Positioned(
        left: worldPos.dx - _animalHalfWidth,
        top: worldPos.dy - _animalHalfHeight,
        child: GestureDetector(
          onPanUpdate: (details) {
            final nextWorld = Offset(
              worldPos.dx + details.delta.dx,
              worldPos.dy + details.delta.dy,
            );
            final nextNorm = _worldToLayout(nextWorld);
            ref.read(myZooProvider.notifier).setAnimalPosition(
                  animal.id,
                  nextNorm,
                  persist: false,
                );
          },
          onPanEnd: (_) {
            ref.read(myZooProvider.notifier).persistAnimalPosition(animal.id);
          },
          child: ZooAnimalSprite(
            animal: animal,
            coinsPerTick: rule.coinsPerTick,
            intervalSeconds: rule.intervalSeconds,
            secondsLeft: remaining,
            isNearby: isNearby,
            onTap: () {
              HapticFeedback.lightImpact();
              _playAnimalSound(animal.id, zooState);
              _showAnimalInfo(animal, rule, zooState);
            },
          ),
        ),
      );
    }).toList();
  }

  Offset _worldAnimalPosition(String animalId, MyZooState zooState) {
    final layoutPos = zooState.layoutByAnimal[animalId];
    if (layoutPos != null) return _layoutToWorld(layoutPos);

    final seed = ZooWorldData.animalPositions[animalId];
    if (seed != null) {
      return Offset(
        seed.dx.clamp(_animalHalfWidth, ZooWorldData.worldWidth - _animalHalfWidth),
        seed.dy.clamp(_animalHalfHeight, ZooWorldData.worldHeight - _animalHalfHeight),
      );
    }

    return _layoutToWorld(const Offset(0.5, 0.5));
  }

  Offset _layoutToWorld(Offset normalized) {
    final minX = _animalHalfWidth;
    final maxX = ZooWorldData.worldWidth - _animalHalfWidth;
    final minY = _animalHalfHeight;
    final maxY = ZooWorldData.worldHeight - _animalHalfHeight;

    return Offset(
      minX + (maxX - minX) * normalized.dx.clamp(0.0, 1.0),
      minY + (maxY - minY) * normalized.dy.clamp(0.0, 1.0),
    );
  }

  Offset _worldToLayout(Offset world) {
    final minX = _animalHalfWidth;
    final maxX = ZooWorldData.worldWidth - _animalHalfWidth;
    final minY = _animalHalfHeight;
    final maxY = ZooWorldData.worldHeight - _animalHalfHeight;

    return Offset(
      ((world.dx - minX) / (maxX - minX)).clamp(0.0, 1.0),
      ((world.dy - minY) / (maxY - minY)).clamp(0.0, 1.0),
    );
  }

  void _showAnimalInfo(Animal animal, ZooEconomyRule rule, MyZooState zooState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(animal.emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 10),
                Text(
                  animal.name,
                  style: GoogleFonts.fredoka(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  animal.funFact,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Earns +${rule.coinsPerTick} coins every ${rule.intervalSeconds}s',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentGolden,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _playAnimalSound(animal.id, zooState);
                    },
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Play Sound'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
