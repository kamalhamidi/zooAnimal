import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/app.dart';
import 'core/audio/audio_service.dart';
import 'core/ads/ad_service.dart';
import 'core/ads/interstitial_ad_manager.dart';
import 'core/ads/rewarded_ad_manager.dart';
import 'core/storage/local_storage.dart';
import 'core/providers/coin_provider.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Catch Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    // Allow Google Fonts runtime fetching when bundled font assets are absent.
    GoogleFonts.config.allowRuntimeFetching = true;

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
    LocalStorage? storage;
    try {
      storage = await LocalStorage.getInstance();
    } catch (e) {
      debugPrint('Failed to init LocalStorage: $e');
    }

    try {
      await AudioService.instance.init();
    } catch (e) {
      debugPrint('Failed to init AudioService: $e');
    }

    try {
      await AdService.instance.init();
      InterstitialAdManager.instance.loadAd();
      RewardedAdManager.instance.loadAd();
    } catch (e) {
      debugPrint('Failed to init AdService: $e');
    }

    runApp(
      ProviderScope(
        overrides: [
          if (storage != null)
            localStorageProvider.overrideWithValue(storage),
        ],
        child: const SoundZooApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack: $stack');
  });
}
