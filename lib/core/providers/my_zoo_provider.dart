import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/animal.dart';
import '../../data/animals_data.dart';
import '../../data/my_zoo_economy_data.dart';
import '../storage/local_storage.dart';
import 'coin_provider.dart';

enum MyZooSoundMode { original, recorded }

class MyZooState {
  final Set<String> ownedAnimalIds;
  final Map<String, String> soundModeByAnimal;
  final Map<String, String> recordingPathByAnimal;
  final Map<String, Offset> layoutByAnimal;
  final Map<String, int> incomeLastPayoutMsByAnimal;
  final bool isRecording;
  final String? recordingAnimalId;
  final String? customPlayerImagePath;
  final String? customBackgroundPath;

  const MyZooState({
    this.ownedAnimalIds = const {},
    this.soundModeByAnimal = const {},
    this.recordingPathByAnimal = const {},
    this.layoutByAnimal = const {},
    this.incomeLastPayoutMsByAnimal = const {},
    this.isRecording = false,
    this.recordingAnimalId,
    this.customPlayerImagePath,
    this.customBackgroundPath,
  });

  MyZooState copyWith({
    Set<String>? ownedAnimalIds,
    Map<String, String>? soundModeByAnimal,
    Map<String, String>? recordingPathByAnimal,
    Map<String, Offset>? layoutByAnimal,
    Map<String, int>? incomeLastPayoutMsByAnimal,
    bool? isRecording,
    String? recordingAnimalId,
    bool clearRecordingAnimalId = false,
    String? customPlayerImagePath,
    bool clearCustomPlayerImage = false,
    String? customBackgroundPath,
    bool clearCustomBackground = false,
  }) {
    return MyZooState(
      ownedAnimalIds: ownedAnimalIds ?? this.ownedAnimalIds,
      soundModeByAnimal: soundModeByAnimal ?? this.soundModeByAnimal,
      recordingPathByAnimal: recordingPathByAnimal ?? this.recordingPathByAnimal,
      layoutByAnimal: layoutByAnimal ?? this.layoutByAnimal,
      incomeLastPayoutMsByAnimal:
          incomeLastPayoutMsByAnimal ?? this.incomeLastPayoutMsByAnimal,
      isRecording: isRecording ?? this.isRecording,
      recordingAnimalId:
          clearRecordingAnimalId ? null : (recordingAnimalId ?? this.recordingAnimalId),
      customPlayerImagePath:
          clearCustomPlayerImage ? null : (customPlayerImagePath ?? this.customPlayerImagePath),
      customBackgroundPath:
          clearCustomBackground ? null : (customBackgroundPath ?? this.customBackgroundPath),
    );
  }
}

final myZooProvider = StateNotifierProvider<MyZooNotifier, MyZooState>((ref) {
  final storage = ref.watch(localStorageProvider);
  return MyZooNotifier(storage, ref);
});

class MyZooNotifier extends StateNotifier<MyZooState> {
  final LocalStorage _storage;
  final Ref _ref;
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _incomeTimer;
  bool _isProcessingIncome = false;

  final Map<String, Animal> _animalById = {
    for (final animal in AnimalsData.allAnimals) animal.id: animal,
  };

  MyZooNotifier(this._storage, this._ref) : super(const MyZooState()) {
    _load();
    _startIncomeTicker();
  }

  void _load() {
    final owned = _storage.getMyZooOwnedAnimals().toSet();
    final layout = _parseLayout(_storage.getMyZooLayout());
    final payoutMs = _storage.getMyZooIncomeTimestamps();

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    bool needsLayoutSave = false;
    bool needsIncomeSave = false;

    final normalizedLayout = Map<String, Offset>.from(layout);
    final normalizedIncome = Map<String, int>.from(payoutMs);

    var i = 0;
    for (final animalId in owned) {
      if (!normalizedLayout.containsKey(animalId)) {
        normalizedLayout[animalId] = _defaultPositionForIndex(i);
        needsLayoutSave = true;
      }
      normalizedIncome[animalId] ??= nowMs;
      if (!payoutMs.containsKey(animalId)) {
        needsIncomeSave = true;
      }
      i++;
    }

    state = state.copyWith(
      ownedAnimalIds: owned,
      soundModeByAnimal: _storage.getMyZooSoundModes(),
      recordingPathByAnimal: _storage.getMyZooRecordings(),
      layoutByAnimal: normalizedLayout,
      incomeLastPayoutMsByAnimal: normalizedIncome,
      customPlayerImagePath: _storage.getZooCustomPlayerImage(),
      customBackgroundPath: _storage.getZooCustomBackground(),
    );

    if (needsLayoutSave) {
      unawaited(_storage.setMyZooLayout(_serializeLayout(normalizedLayout)));
    }
    if (needsIncomeSave) {
      unawaited(_storage.setMyZooIncomeTimestamps(normalizedIncome));
    }
  }

  bool isOwned(String animalId) => state.ownedAnimalIds.contains(animalId);

  Future<void> addOwnedAnimal(String animalId) async {
    if (isOwned(animalId)) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final updated = {...state.ownedAnimalIds, animalId};
    final updatedLayout = Map<String, Offset>.from(state.layoutByAnimal)
      ..[animalId] = _defaultPositionForIndex(updated.length - 1);
    final updatedIncome = Map<String, int>.from(state.incomeLastPayoutMsByAnimal)
      ..[animalId] = nowMs;

    state = state.copyWith(
      ownedAnimalIds: updated,
      layoutByAnimal: updatedLayout,
      incomeLastPayoutMsByAnimal: updatedIncome,
    );

    await _storage.addMyZooOwnedAnimal(animalId);
    await _storage.setMyZooLayoutPosition(
      animalId,
      updatedLayout[animalId]!.dx,
      updatedLayout[animalId]!.dy,
    );
    await _storage.setMyZooIncomeTimestamp(animalId, nowMs);
  }

  MyZooSoundMode getSoundMode(String animalId) {
    final modeRaw = state.soundModeByAnimal[animalId] ?? MyZooSoundMode.original.name;
    return modeRaw == MyZooSoundMode.recorded.name
        ? MyZooSoundMode.recorded
        : MyZooSoundMode.original;
  }

  String? getRecordingPath(String animalId) => state.recordingPathByAnimal[animalId];

  Offset getAnimalPosition(String animalId) {
    return state.layoutByAnimal[animalId] ?? const Offset(0.5, 0.5);
  }

  Future<void> setAnimalPosition(
    String animalId,
    Offset position, {
    bool persist = true,
  }) async {
    final clamped = Offset(
      position.dx.clamp(0.0, 1.0),
      position.dy.clamp(0.0, 1.0),
    );

    final updated = Map<String, Offset>.from(state.layoutByAnimal)
      ..[animalId] = clamped;
    state = state.copyWith(layoutByAnimal: updated);

    if (persist) {
      await _storage.setMyZooLayoutPosition(animalId, clamped.dx, clamped.dy);
    }
  }

  Future<void> persistAnimalPosition(String animalId) async {
    final pos = state.layoutByAnimal[animalId];
    if (pos == null) return;
    await _storage.setMyZooLayoutPosition(animalId, pos.dx, pos.dy);
  }

  int secondsUntilNextIncome(
    String animalId,
    int intervalSeconds,
  ) {
    final lastMs =
        state.incomeLastPayoutMsByAnimal[animalId] ?? DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = DateTime.now().millisecondsSinceEpoch - lastMs;
    final intervalMs = intervalSeconds * 1000;
    final remainingMs = intervalMs - (elapsedMs % intervalMs);
    return (remainingMs / 1000).ceil();
  }

  Future<void> setSoundMode(String animalId, MyZooSoundMode mode) async {
    final updated = Map<String, String>.from(state.soundModeByAnimal)
      ..[animalId] = mode.name;

    state = state.copyWith(soundModeByAnimal: updated);
    await _storage.setMyZooSoundMode(animalId, mode.name);
  }

  // ─── Customisation ───

  Future<void> setCustomPlayerImage(String? path) async {
    if (path == null) {
      state = state.copyWith(clearCustomPlayerImage: true);
    } else {
      state = state.copyWith(customPlayerImagePath: path);
    }
    await _storage.setZooCustomPlayerImage(path);
  }

  Future<void> setCustomBackground(String? path) async {
    if (path == null) {
      state = state.copyWith(clearCustomBackground: true);
    } else {
      state = state.copyWith(customBackgroundPath: path);
    }
    await _storage.setZooCustomBackground(path);
  }

  void _startIncomeTicker() {
    _incomeTimer?.cancel();
    _incomeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_processIncomeTick());
    });
  }

  Future<void> _processIncomeTick() async {
    if (_isProcessingIncome || state.ownedAnimalIds.isEmpty) return;
    _isProcessingIncome = true;

    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final updatedIncome = Map<String, int>.from(state.incomeLastPayoutMsByAnimal);
      var earned = 0;
      var changed = false;

      for (final animalId in state.ownedAnimalIds) {
        final animal = _animalById[animalId];
        if (animal == null) continue;

        final rule = MyZooEconomyData.ruleFor(animal);
        final intervalMs = rule.intervalSeconds * 1000;
        final lastMs = updatedIncome[animalId] ?? nowMs;
        final elapsedMs = nowMs - lastMs;
        final cycles = elapsedMs ~/ intervalMs;

        if (cycles > 0) {
          earned += cycles * rule.coinsPerTick;
          updatedIncome[animalId] = lastMs + (cycles * intervalMs);
          changed = true;
        }
      }

      if (changed) {
        state = state.copyWith(incomeLastPayoutMsByAnimal: updatedIncome);
        await _storage.setMyZooIncomeTimestamps(updatedIncome);
      }

      if (earned > 0) {
        await _ref.read(coinProvider.notifier).addCoins(earned);
      }
    } finally {
      _isProcessingIncome = false;
    }
  }

  Map<String, Offset> _parseLayout(Map<String, String> raw) {
    final map = <String, Offset>{};
    raw.forEach((animalId, value) {
      final parts = value.split(',');
      if (parts.length != 2) return;
      final x = double.tryParse(parts[0]);
      final y = double.tryParse(parts[1]);
      if (x == null || y == null) return;
      map[animalId] = Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
    });
    return map;
  }

  Map<String, String> _serializeLayout(Map<String, Offset> map) {
    return map.map((k, v) => MapEntry(k, '${v.dx},${v.dy}'));
  }

  Offset _defaultPositionForIndex(int index) {
    final column = index % 3;
    final row = index ~/ 3;

    final x = 0.08 + (column * 0.34);
    final y = 0.10 + (row * 0.20);
    return Offset(
      x.clamp(0.02, 0.92),
      y.clamp(0.02, 0.92),
    );
  }

  Future<bool> startRecording(String animalId) async {
    if (!isOwned(animalId)) return false;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/my_zoo_$animalId.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: path,
    );

    state = state.copyWith(
      isRecording: true,
      recordingAnimalId: animalId,
    );

    return true;
  }

  Future<String?> stopRecording(String animalId) async {
    if (!state.isRecording || state.recordingAnimalId != animalId) return null;

    final path = await _recorder.stop();
    state = state.copyWith(
      isRecording: false,
      clearRecordingAnimalId: true,
    );

    if (path == null) return null;

    final file = File(path);
    if (!await file.exists() || await file.length() == 0) return null;

    final recordings = Map<String, String>.from(state.recordingPathByAnimal)
      ..[animalId] = path;
    final modes = Map<String, String>.from(state.soundModeByAnimal)
      ..[animalId] = MyZooSoundMode.recorded.name;

    state = state.copyWith(
      recordingPathByAnimal: recordings,
      soundModeByAnimal: modes,
    );

    await _storage.setMyZooRecordingPath(animalId, path);
    await _storage.setMyZooSoundMode(animalId, MyZooSoundMode.recorded.name);

    return path;
  }

  @override
  void dispose() {
    _incomeTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
