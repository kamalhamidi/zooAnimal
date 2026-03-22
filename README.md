# SoundZoo 🐾

SoundZoo is a Flutter mobile game for kids and families.
Players listen to animal sounds and play through multiple game modes:

- Guess the Animal
- Sound Puzzle
- Baby Mode
- Daily Challenge

It includes local progress saving, coins/stats, animations, and offline assets (images + sounds).

---

## Requirements

### Core
- Flutter SDK (stable, 3.27+ recommended)
- Dart SDK (comes with Flutter)
- Git

### iOS (macOS only)
- macOS
- Xcode (latest stable)
- CocoaPods
- Apple Developer account (for real iPhone install)
- iPhone with **Developer Mode enabled** (for direct install)

### Android (optional)
- Android Studio
- Android SDK + emulator/device

---

## Clone the Project

1. Copy repository URL from GitHub.
2. Clone and open:

	- `git clone <YOUR_REPO_URL>`
	- `cd zooAnimal`

---

## Project Setup

1. Install dependencies:

	- `flutter pub get`

2. Verify Flutter environment:

	- `flutter doctor`

3. (iOS) Install CocoaPods dependencies:

	- `cd ios && pod install && cd ..`

---

## Run the Game

### On iPhone (recommended)
- Connect device (USB or trusted wireless).
- Ensure device appears:
  - `flutter devices`
- Run:
  - `flutter run -d <DEVICE_ID>`

### On iOS Simulator
- `flutter run -d ios`

### On macOS desktop
- `flutter run -d macos`

---

## Build Release

### iOS
- `flutter build ios --release`

Output app path:
- `build/ios/iphoneos/Runner.app`

---

## Assets

The game uses local assets declared in [pubspec.yaml](pubspec.yaml):

- `assets/sounds/`
- `assets/images/`
- `assets/lottie/`

If you add new files in these folders:
1. Save files.
2. Run `flutter pub get`.
3. Rebuild/reinstall app.

---

## App Icon

This project uses `flutter_launcher_icons`.

Configured icon source:
- [assets/images/app_icon.png](assets/images/app_icon.png)

Regenerate icons:
- `dart run flutter_launcher_icons`

---

## Common iPhone Install Issue (Trust)

If app installs but does not open, trust the developer profile on device:

1. Settings → General → VPN & Device Management
2. Open Developer App profile
3. Tap **Trust**

Also ensure:
- Settings → Privacy & Security → **Developer Mode** is enabled

---

## Tech Stack

- Flutter
- Riverpod
- GoRouter
- just_audio / audioplayers
- shared_preferences

---

## License

Add your preferred license (MIT/Apache-2.0/etc.) in a `LICENSE` file.
