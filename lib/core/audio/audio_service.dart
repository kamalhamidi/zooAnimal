import 'package:just_audio/just_audio.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioService {
  static AudioService? _instance;
  final AudioPlayer _player = AudioPlayer();
  final ap.AudioPlayer _fallbackPlayer = ap.AudioPlayer();
  double _volume = 1.0;
  bool _useFallback = false;
  final Set<String> _invalidAssets = <String>{};
  final Set<String> _checkedAssets = <String>{};

  AudioService._();

  static AudioService get instance {
    _instance ??= AudioService._();
    return _instance!;
  }

  Future<void> init() async {
    try {
      await _player.setVolume(_volume);
    } catch (e) {
      _useFallback = true;
    }
  }

  Future<void> preloadSounds(List<String> paths) async {
    // Pre-warm the audio engine
    for (final path in paths) {
      try {
        final canPlay = await _isPlayableAsset(path);
        if (!canPlay) continue;
        if (!_useFallback) {
          await _player.setAsset(path);
        }
      } catch (_) {
        // Silently skip - will load on play
      }
    }
  }

  Future<void> playSound(String assetPath) async {
    final canPlay = await _isPlayableAsset(assetPath);
    if (!canPlay) {
      await SystemSound.play(SystemSoundType.click);
      return;
    }

    try {
      if (_useFallback) {
        await _fallbackPlayer.setVolume(_volume);
        await _fallbackPlayer.play(ap.AssetSource(assetPath.replaceFirst('assets/', '')));
      } else {
        await _player.stop();
        await _player.setAsset(assetPath);
        await _player.setVolume(_volume);
        await _player.play();
      }
    } catch (e) {
      // If just_audio fails, try fallback
      if (!_useFallback) {
        _useFallback = true;
        await playSound(assetPath);
      }
    }
  }

  Future<bool> _isPlayableAsset(String assetPath) async {
    if (_invalidAssets.contains(assetPath)) return false;
    if (_checkedAssets.contains(assetPath)) return true;

    try {
      final data = await rootBundle.load(assetPath);
      if (data.lengthInBytes == 0) {
        _invalidAssets.add(assetPath);
        debugPrint('AudioService: asset is empty, skipping playback -> $assetPath');
        return false;
      }
      _checkedAssets.add(assetPath);
      return true;
    } catch (_) {
      _invalidAssets.add(assetPath);
      debugPrint('AudioService: asset not found, skipping playback -> $assetPath');
      return false;
    }
  }

  bool get isPlaceholderAudioMode => _invalidAssets.isNotEmpty;

  int get invalidAudioAssetCount => _invalidAssets.length;

  Future<void> stopAll() async {
    try {
      await _player.stop();
      await _fallbackPlayer.stop();
    } catch (_) {}
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume);
      await _fallbackPlayer.setVolume(_volume);
    } catch (_) {}
  }

  double get volume => _volume;

  Future<void> dispose() async {
    await _player.dispose();
    await _fallbackPlayer.dispose();
    _instance = null;
  }
}
