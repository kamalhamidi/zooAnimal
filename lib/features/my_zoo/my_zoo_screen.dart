import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../core/ads/footer_banner_bar.dart';
import '../../core/audio/audio_service.dart';
import '../../core/models/animal.dart';
import '../../core/providers/coin_provider.dart';
import '../../core/providers/my_zoo_provider.dart';
import '../../data/animals_data.dart';
import '../../data/my_zoo_economy_data.dart';

class MyZooScreen extends ConsumerStatefulWidget {
  const MyZooScreen({super.key});

  @override
  ConsumerState<MyZooScreen> createState() => _MyZooScreenState();
}

class _MyZooScreenState extends ConsumerState<MyZooScreen> {
  int _tabIndex = 0;
  bool _showOwnedOnly = false;
  Timer? _uiTicker;

  @override
  void initState() {
    super.initState();
    // Rebuild every second for countdown labels.
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTicker?.cancel();
    AudioService.instance.stopAll();
    super.dispose();
  }

  int _priceFor(Animal animal) {
    return MyZooEconomyData.ruleFor(animal).price;
  }

  Future<void> _buyAnimal(Animal animal) async {
    final price = _priceFor(animal);
    final spent = await ref.read(coinProvider.notifier).spendCoins(price);

    if (!spent) {
      _showSnack('Not enough coins to buy ${animal.name}.');
      return;
    }

    await ref.read(myZooProvider.notifier).addOwnedAnimal(animal.id);
    _showSnack('${animal.name} added to your zoo!');
  }

  Future<void> _playAnimal(Animal animal, MyZooState zooState) async {
    final mode = ref.read(myZooProvider.notifier).getSoundMode(animal.id);
    final recordingPath = zooState.recordingPathByAnimal[animal.id];

    await AudioService.instance.playPreferredSound(
      originalAssetPath: animal.soundAssetPath,
      recordedFilePath: recordingPath,
      preferRecorded: mode == MyZooSoundMode.recorded,
    );
  }

  Future<void> _toggleRecord(Animal animal, MyZooState state) async {
    final notifier = ref.read(myZooProvider.notifier);

    if (state.isRecording && state.recordingAnimalId == animal.id) {
      final path = await notifier.stopRecording(animal.id);
      if (path == null) {
        _showSnack('Recording failed for ${animal.name}.');
      } else {
        _showSnack('Saved your ${animal.name} recording!');
      }
      return;
    }

    if (state.isRecording) {
      _showSnack('Stop current recording first.');
      return;
    }

    final ok = await notifier.startRecording(animal.id);
    if (!ok) {
      _showSnack('Microphone permission is required.');
      return;
    }

    _showSnack('Recording ${animal.name}... tap mic again to stop.');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(coinProvider);
    final zooState = ref.watch(myZooProvider);

    final all = AnimalsData.allAnimals;
    final owned = all.where((a) => zooState.ownedAnimalIds.contains(a.id)).toList();
    final visibleShopAnimals = _showOwnedOnly ? owned : all;

    return Scaffold(
      bottomNavigationBar: const FooterBannerBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '🏡 My Zoo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Text(
                      '🪙 $coins',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentGolden,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _tabIndex == 0
                    ? 'Drag your owned animals in a real 2D zoo. Tap any animal to hear its sound. They earn coins automatically over time.'
                    : 'Shop and tune each animal economy from code (price, income, and payout interval).',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  selected: _tabIndex == 0,
                  label: const Text('Zoo View'),
                  onSelected: (_) => setState(() => _tabIndex = 0),
                ),
                ChoiceChip(
                  selected: _tabIndex == 1,
                  label: const Text('Shop'),
                  onSelected: (_) => setState(() => _tabIndex = 1),
                ),
              ],
            ),
            if (_tabIndex == 1) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    selected: _showOwnedOnly,
                    label: const Text('Owned only'),
                    onSelected: (_) => setState(() => _showOwnedOnly = true),
                  ),
                  ChoiceChip(
                    selected: !_showOwnedOnly,
                    label: const Text('All animals'),
                    onSelected: (_) => setState(() => _showOwnedOnly = false),
                  ),
                ],
              ),
            ],
            if (zooState.isRecording) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic_rounded, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recording in progress...',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: _tabIndex == 0
                  ? _buildZooView(owned: owned, zooState: zooState)
                  : _buildShopView(
                      zooState: zooState,
                      visibleShopAnimals: visibleShopAnimals,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZooView({
    required List<Animal> owned,
    required MyZooState zooState,
  }) {
    if (owned.isEmpty) {
      return Center(
        child: Text(
          'No animals owned yet. Open Shop and buy your first animal! 🐾',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFBEE9FF),
                Color(0xFFDCFFC8),
                Color(0xFFB9ED97),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemSize = constraints.maxWidth < 380 ? 84.0 : 92.0;
              final maxLeft = (constraints.maxWidth - itemSize).clamp(1.0, double.infinity);
              final maxTop = (constraints.maxHeight - itemSize).clamp(1.0, double.infinity);

              return Stack(
                children: [
                  _buildZooDecor(),
                  for (var i = 0; i < owned.length; i++) ...[
                    () {
                      final animal = owned[i];
                      final pos = zooState.layoutByAnimal[animal.id] ??
                          ref.read(myZooProvider.notifier).getAnimalPosition(animal.id);
                      final left = pos.dx * maxLeft;
                      final top = pos.dy * maxTop;
                      final rule = MyZooEconomyData.ruleFor(animal);
                      final remaining = ref
                          .read(myZooProvider.notifier)
                          .secondsUntilNextIncome(animal.id, rule.intervalSeconds);

                      return Positioned(
                        left: left,
                        top: top,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _playAnimal(animal, zooState);
                          },
                          onPanUpdate: (details) {
                            final current = ref.read(myZooProvider).layoutByAnimal[animal.id] ?? pos;
                            final dx = (current.dx + (details.delta.dx / maxLeft)).clamp(0.0, 1.0);
                            final dy = (current.dy + (details.delta.dy / maxTop)).clamp(0.0, 1.0);
                            ref
                                .read(myZooProvider.notifier)
                                .setAnimalPosition(animal.id, Offset(dx, dy), persist: false);
                          },
                          onPanEnd: (_) {
                            ref.read(myZooProvider.notifier).persistAnimalPosition(animal.id);
                          },
                          child: _ZooAnimalNode(
                            animal: animal,
                            size: itemSize,
                            coinsPerTick: rule.coinsPerTick,
                            intervalSeconds: rule.intervalSeconds,
                            secondsLeft: remaining,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (i * 35).ms, duration: 220.ms)
                          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
                    }(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShopView({
    required MyZooState zooState,
    required List<Animal> visibleShopAnimals,
  }) {
    if (visibleShopAnimals.isEmpty) {
      return Center(
        child: Text(
          'No owned animals yet. Switch filter to All animals.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: visibleShopAnimals.length,
      itemBuilder: (context, i) {
        final animal = visibleShopAnimals[i];
        final isOwned = zooState.ownedAnimalIds.contains(animal.id);
        final hasRecording = (zooState.recordingPathByAnimal[animal.id]?.isNotEmpty ?? false);
        final mode = ref.read(myZooProvider.notifier).getSoundMode(animal.id);
        final rule = MyZooEconomyData.ruleFor(animal);

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isOwned
                  ? AppColors.primaryGreen.withValues(alpha: 0.35)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(animal.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(height: 6),
              Text(
                animal.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isOwned ? 'Owned' : 'Price: ${_priceFor(animal)} coins',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: isOwned ? AppColors.primaryGreen : Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Income: +${rule.coinsPerTick} every ${rule.intervalSeconds}s',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              if (!isOwned)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(38),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _buyAnimal(animal);
                    },
                    icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                    label: const Text('Buy'),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        selected: mode == MyZooSoundMode.original,
                        label: const Text('Original', overflow: TextOverflow.ellipsis),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) {
                          ref.read(myZooProvider.notifier).setSoundMode(
                                animal.id,
                                MyZooSoundMode.original,
                              );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ChoiceChip(
                        selected: mode == MyZooSoundMode.recorded,
                        label: const Text('My Voice', overflow: TextOverflow.ellipsis),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                        visualDensity: VisualDensity.compact,
                        onSelected: hasRecording
                            ? (_) {
                                ref.read(myZooProvider.notifier).setSoundMode(
                                      animal.id,
                                      MyZooSoundMode.recorded,
                                    );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(38),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _toggleRecord(animal, zooState);
                        },
                        child: Text(
                          zooState.isRecording && zooState.recordingAnimalId == animal.id
                              ? 'Stop'
                              : 'Record',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(38),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _playAnimal(animal, zooState);
                        },
                        child: const Text(
                          'Play',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (i * 40).ms, duration: 220.ms)
            .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
      },
    );
  }

  Widget _buildZooDecor() {
    return Stack(
      children: const [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 60,
          child: ColoredBox(color: Color(0xFF6AB86B)),
        ),
        Positioned(
          left: 18,
          top: 22,
          child: Text('🌳', style: TextStyle(fontSize: 34)),
        ),
        Positioned(
          right: 20,
          top: 28,
          child: Text('🌴', style: TextStyle(fontSize: 30)),
        ),
        Positioned(
          left: 30,
          bottom: 18,
          child: Text('🪨', style: TextStyle(fontSize: 28)),
        ),
        Positioned(
          right: 40,
          bottom: 16,
          child: Text('🪨', style: TextStyle(fontSize: 24)),
        ),
        Positioned(
          left: 90,
          bottom: 20,
          child: Text('🌿', style: TextStyle(fontSize: 24)),
        ),
        Positioned(
          right: 95,
          bottom: 24,
          child: Text('🌿', style: TextStyle(fontSize: 22)),
        ),
      ],
    );
  }
}

class _ZooAnimalNode extends StatelessWidget {
  final Animal animal;
  final double size;
  final int coinsPerTick;
  final int intervalSeconds;
  final int secondsLeft;

  const _ZooAnimalNode({
    required this.animal,
    required this.size,
    required this.coinsPerTick,
    required this.intervalSeconds,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        children: [
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              animal.emoji,
              style: TextStyle(fontSize: size * 0.34),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$coinsPerTick/${intervalSeconds}s • ${secondsLeft}s',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
