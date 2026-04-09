# SoundZoo Project Context

## 1) What this project is
SoundZoo is a Flutter mobile game focused on kids/family learning with animal sounds.
Core gameplay modes:
- Guess the Animal
- Sound Puzzle
- Baby Mode
- My Zoo
- Daily challenge flow integrated in home/game progression

The app is primarily configured for iOS in the current workspace.

## 2) Tech stack
- Flutter + Dart
- State management: Riverpod (`flutter_riverpod`)
- Navigation: `go_router`
- Audio: `just_audio`, `audioplayers`
- TTS: `flutter_tts`
- Storage: `shared_preferences`
- Ads: `google_mobile_ads`
- UI/UX packages: `flutter_animate`, `lottie`, `google_fonts`, `shimmer`, `confetti`

## 3) App bootstrap flow
- Entry point: `lib/main.dart`
- Root app widget: `lib/app/app.dart`

Startup sequence in `main.dart`:
1. Flutter bindings initialized
2. Error handlers registered (`FlutterError.onError`, `runZonedGuarded`)
3. Portrait orientation lock applied
4. `LocalStorage` initialized
5. `AudioService` initialized
6. Ads initialized (`AdService`, interstitial/rewarded preload)
7. `ProviderScope` created with optional local storage override

## 4) Navigation map
Router file: `lib/app/router/app_router.dart`

Routes:
- `/landing` -> `LandingScreen`
- `/` -> `HomeScreen`
- `/guess` -> `GuessScreen` (supports query params: `difficulty`, `daily`)
- `/puzzle` -> `PuzzleScreen`
- `/baby` -> `BabyScreen`
- `/my-zoo` -> `MyZooScreen`

## 5) Important project structure
- `lib/app/` -> app shell (theme, router, shared widgets/animations)
- `lib/core/` -> reusable domain/services (ads, audio, models, providers, storage)
- `lib/data/` -> static/data source files (e.g., animals catalog)
- `lib/features/` -> screen-level modules

Feature modules currently present:
- `landing`
- `home`
- `guess_animal`
- `puzzle`
- `baby_mode`
- `my_zoo`

## 6) Data and assets context
Animals dataset is in `lib/data/animals_data.dart`.
Each animal includes:
- id, name, emoji
- `soundAssetPath`
- `imageAssetPath`
- difficulty/category
- fun fact + TTS label

Assets configured in `pubspec.yaml`:
- `assets/sounds/`
- `assets/images/`
- `assets/lottie/`

If assets are missing/invalid, app can fall back to placeholder audio mode (visible in home screen).

## 7) Existing enhancement package context
The repo includes enhancement references and implementation guides:
- `ENHANCEMENT_README.md`
- `ENHANCEMENT_GUIDE.dart`
- `HOME_SCREEN_REFERENCE.dart`
- `GAME_SCREENS_REFERENCE.dart`
- `DEPLOYMENT_GUIDE.dart`
- `DELIVERABLES_INDEX.md`

This package provides design-system, reusable widgets, animation utilities, audio visualization helpers, and gamification provider patterns.

## 8) Current run/build context (latest terminal state)
Last command run:
- `flutter clean && flutter pub get && flutter run --release`

Result:
- Dependencies resolved successfully
- Run step failed because no supported target device is connected
- Flutter detected unsupported targets for this project (`macOS`, `Chrome`) because macOS/web platform folders are not configured for this app

Action needed to run now:
- Connect an iOS device/simulator and run with explicit device ID
- Or add platform support (e.g., macOS/web) if needed

## 9) Fast start checklist for future sessions
1. `flutter pub get`
2. Verify assets paths exist for sounds/images used by data model
3. Confirm iOS target device with `flutter devices`
4. Run `flutter run -d <device_id>`
5. If integrating enhancements, start with theme + one feature screen (Home) before global rollout
