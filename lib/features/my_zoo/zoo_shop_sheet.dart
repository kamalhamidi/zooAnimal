import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../core/audio/audio_service.dart';
import '../../core/models/animal.dart';
import '../../core/providers/coin_provider.dart';
import '../../core/providers/my_zoo_provider.dart';
import '../../data/animals_data.dart';
import '../../data/my_zoo_economy_data.dart';

/// Bottom-sheet overlay containing the animal shop & economy controls.
///
/// Extracted from the original MyZooScreen shop tab so the world view
/// can present it as a draggable sheet.
class ZooShopSheet extends ConsumerStatefulWidget {
  const ZooShopSheet({super.key});

  @override
  ConsumerState<ZooShopSheet> createState() => _ZooShopSheetState();
}

class _ZooShopSheetState extends ConsumerState<ZooShopSheet> {
  bool _showOwnedOnly = false;

  int _priceFor(Animal animal) => MyZooEconomyData.ruleFor(animal).price;

  Future<void> _buyAnimal(Animal animal) async {
    final price = _priceFor(animal);
    final spent = await ref.read(coinProvider.notifier).spendCoins(price);
    if (!spent) {
      _snack('Not enough coins to buy ${animal.name}.');
      return;
    }
    await ref.read(myZooProvider.notifier).addOwnedAnimal(animal.id);
    _snack('${animal.name} added to your zoo! 🎉');
  }

  Future<void> _playAnimal(Animal animal) async {
    final zooState = ref.read(myZooProvider);
    final mode = ref.read(myZooProvider.notifier).getSoundMode(animal.id);
    final recordingPath = zooState.recordingPathByAnimal[animal.id];

    await AudioService.instance.playPreferredSound(
      originalAssetPath: animal.soundAssetPath,
      recordedFilePath: recordingPath,
      preferRecorded: mode == MyZooSoundMode.recorded,
    );
  }

  Future<void> _toggleRecord(Animal animal) async {
    final zooState = ref.read(myZooProvider);
    final notifier = ref.read(myZooProvider.notifier);

    if (zooState.isRecording && zooState.recordingAnimalId == animal.id) {
      final path = await notifier.stopRecording(animal.id);
      _snack(path == null
          ? 'Recording failed for ${animal.name}.'
          : 'Saved your ${animal.name} recording!');
      return;
    }
    if (zooState.isRecording) {
      _snack('Stop current recording first.');
      return;
    }
    final ok = await notifier.startRecording(animal.id);
    _snack(ok
        ? 'Recording ${animal.name}... tap mic again to stop.'
        : 'Microphone permission is required.');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(coinProvider);
    final zooState = ref.watch(myZooProvider);
    final all = AnimalsData.allAnimals;
    final owned =
        all.where((a) => zooState.ownedAnimalIds.contains(a.id)).toList();
    final visible = _showOwnedOnly ? owned : all;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '🛒 Animal Shop',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(100),
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

              const SizedBox(height: 8),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ChoiceChip(
                      selected: !_showOwnedOnly,
                      label: const Text('All'),
                      onSelected: (_) =>
                          setState(() => _showOwnedOnly = false),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      selected: _showOwnedOnly,
                      label: const Text('Owned'),
                      onSelected: (_) =>
                          setState(() => _showOwnedOnly = true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Recording indicator
              if (zooState.isRecording)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic_rounded, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Recording in progress...',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),

              // Grid
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text(
                          'No animals here yet.',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : GridView.builder(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, i) {
                          final animal = visible[i];
                          final isOwned = zooState.ownedAnimalIds
                              .contains(animal.id);
                          final hasRec = (zooState
                                      .recordingPathByAnimal[animal.id]
                                      ?.isNotEmpty ??
                                  false);
                          final mode = ref
                              .read(myZooProvider.notifier)
                              .getSoundMode(animal.id);
                          final rule = MyZooEconomyData.ruleFor(animal);

                          return _ShopCard(
                            animal: animal,
                            isOwned: isOwned,
                            hasRecording: hasRec,
                            mode: mode,
                            rule: rule,
                            zooState: zooState,
                            onBuy: () => _buyAnimal(animal),
                            onPlay: () => _playAnimal(animal),
                            onRecord: () => _toggleRecord(animal),
                            onSetMode: (m) => ref
                                .read(myZooProvider.notifier)
                                .setSoundMode(animal.id, m),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual shop card for one animal.
class _ShopCard extends StatelessWidget {
  final Animal animal;
  final bool isOwned;
  final bool hasRecording;
  final MyZooSoundMode mode;
  final ZooEconomyRule rule;
  final MyZooState zooState;
  final VoidCallback onBuy;
  final VoidCallback onPlay;
  final VoidCallback onRecord;
  final ValueChanged<MyZooSoundMode> onSetMode;

  const _ShopCard({
    required this.animal,
    required this.isOwned,
    required this.hasRecording,
    required this.mode,
    required this.rule,
    required this.zooState,
    required this.onBuy,
    required this.onPlay,
    required this.onRecord,
    required this.onSetMode,
  });

  @override
  Widget build(BuildContext context) {
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
            isOwned
                ? 'Owned ✓'
                : 'Price: ${rule.price} coins',
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
          const Spacer(),
          if (!isOwned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(38),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onBuy();
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
                    label: const Text('Original',
                        overflow: TextOverflow.ellipsis),
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) =>
                        onSetMode(MyZooSoundMode.original),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ChoiceChip(
                    selected: mode == MyZooSoundMode.recorded,
                    label: const Text('My Voice',
                        overflow: TextOverflow.ellipsis),
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    onSelected: hasRecording
                        ? (_) => onSetMode(MyZooSoundMode.recorded)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(36),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onRecord();
                    },
                    child: Text(
                      zooState.isRecording &&
                              zooState.recordingAnimalId == animal.id
                          ? 'Stop'
                          : 'Record',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(36),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onPlay();
                    },
                    child: const Text('Play',
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
