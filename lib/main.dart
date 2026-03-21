import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/audio/audio_service.dart';
import 'core/storage/local_storage.dart';
import 'core/providers/coin_provider.dart';
import 'data/animals_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set iOS status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize services
  final storage = await LocalStorage.getInstance();
  await AudioService.instance.init();
  await AudioService.instance.preloadSounds(
    AnimalsData.allAnimals.map((a) => a.soundAssetPath).toSet().toList(),
  );

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
      child: const SoundZooApp(),
    ),
  );
}
