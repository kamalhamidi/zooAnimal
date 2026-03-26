import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../core/ads/footer_banner_bar.dart';
import '../../core/audio/audio_service.dart';
import '../../core/models/animal.dart';
import '../../data/animals_data.dart';
import 'widgets/animal_card.dart';
import 'widgets/animated_animal.dart';

class BabyScreen extends ConsumerStatefulWidget {
  const BabyScreen({super.key});

  @override
  ConsumerState<BabyScreen> createState() => _BabyScreenState();
}

class _BabyScreenState extends ConsumerState<BabyScreen> {
  final FlutterTts _tts = FlutterTts();
  Animal? _selectedAnimal;
  int _selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.2);
    await _tts.setVolume(1.0);
  }

  @override
  void dispose() {
    _tts.stop();
    AudioService.instance.stopAll();
    super.dispose();
  }

  void _onAnimalTap(Animal animal, int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedAnimal = animal;
      _selectedColorIndex = index % AppColors.babyPastels.length;
    });

    // Play sound, then TTS
    AudioService.instance.playSound(animal.soundAssetPath);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _selectedAnimal?.id == animal.id) {
        _tts.speak(animal.ttsLabel);
      }
    });
  }

  void _onBack() {
    HapticFeedback.lightImpact();
    _tts.stop();
    AudioService.instance.stopAll();
    setState(() {
      _selectedAnimal = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedAnimal != null) {
      return AnimatedAnimal(
        animal: _selectedAnimal!,
        backgroundColor:
            AppColors.babyPastels[_selectedColorIndex],
        onBack: _onBack,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.babyPastels[0],
      bottomNavigationBar: const FooterBannerBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Top bar with parent lock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Parent lock exit — hold for 3 seconds
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        size: 28,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Text(
                    '👶 Baby Mode',
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown[800],
                    ),
                  ),
                  const SizedBox(width: 52),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap an animal to hear its sound!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Animal grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: AnimalsData.allAnimals.length,
                itemBuilder: (context, index) {
                  final animal = AnimalsData.allAnimals[index];
                  final bgColor = AppColors.babyPastels[
                      index % AppColors.babyPastels.length];

                  return AnimalCard(
                    animal: animal,
                    backgroundColor: bgColor,
                    onTap: () => _onAnimalTap(animal, index),
                  )
                      .animate()
                      .fadeIn(
                        delay: (index * 80).ms,
                        duration: 400.ms,
                      )
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        delay: (index * 80).ms,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
