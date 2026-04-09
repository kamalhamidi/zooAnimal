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

class MyZooScreen extends ConsumerStatefulWidget {
  const MyZooScreen({super.key});

  @override
  ConsumerState<MyZooScreen> createState() => _MyZooScreenState();
}

class _MyZooScreenState extends ConsumerState<MyZooScreen> {
  bool _showOwnedOnly = true;

  @override
  void dispose() {
    AudioService.instance.stopAll();
    super.dispose();
  }

  int _priceFor(Animal animal) {
    switch (animal.difficulty) {
      case AnimalDifficulty.easy:
        return 20;
      case AnimalDifficulty.medium:
        return 35;
      case AnimalDifficulty.hard:
        return 50;
    }
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
    final visible = _showOwnedOnly ? owned : all;

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
                'Build your farm: buy animals, keep original sounds, or record your own!',
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
                  selected: _showOwnedOnly,
                  label: const Text('My Animals'),
                  onSelected: (_) => setState(() => _showOwnedOnly = true),
                ),
                ChoiceChip(
                  selected: !_showOwnedOnly,
                  label: const Text('Shop All'),
                  onSelected: (_) => setState(() => _showOwnedOnly = false),
                ),
              ],
            ),
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
              child: visible.isEmpty
                  ? Center(
                      child: Text(
                        'No animals yet. Switch to Shop All and buy your first friend! 🐾',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (context, i) {
                        final animal = visible[i];
                        final isOwned = zooState.ownedAnimalIds.contains(animal.id);
                        final hasRecording =
                            (zooState.recordingPathByAnimal[animal.id]?.isNotEmpty ?? false);
                        final mode = ref.read(myZooProvider.notifier).getSoundMode(animal.id);
                        final price = _priceFor(animal);

                        return Container(
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
                                isOwned ? 'Owned' : 'Price: $price coins',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700,
                                  color: isOwned ? AppColors.primaryGreen : Colors.black54,
                                ),
                              ),
                              const Spacer(),
                              if (!isOwned)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
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
                                        label: const Text('Original'),
                                        onSelected: (_) {
                                          ref
                                              .read(myZooProvider.notifier)
                                              .setSoundMode(animal.id, MyZooSoundMode.original);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: ChoiceChip(
                                        selected: mode == MyZooSoundMode.recorded,
                                        label: const Text('My Voice'),
                                        onSelected: hasRecording
                                            ? (_) {
                                                ref
                                                    .read(myZooProvider.notifier)
                                                    .setSoundMode(animal.id, MyZooSoundMode.recorded);
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
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          _toggleRecord(animal, zooState);
                                        },
                                        icon: Icon(
                                          zooState.isRecording &&
                                                  zooState.recordingAnimalId == animal.id
                                              ? Icons.stop_circle_rounded
                                              : Icons.mic_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          zooState.isRecording &&
                                                  zooState.recordingAnimalId == animal.id
                                              ? 'Stop'
                                              : 'Record',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          _playAnimal(animal, zooState);
                                        },
                                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                                        label: const Text('Play'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: (i * 50).ms, duration: 250.ms)
                            .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
