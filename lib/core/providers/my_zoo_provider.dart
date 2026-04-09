import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../storage/local_storage.dart';
import 'coin_provider.dart';

enum MyZooSoundMode { original, recorded }

class MyZooState {
  final Set<String> ownedAnimalIds;
  final Map<String, String> soundModeByAnimal;
  final Map<String, String> recordingPathByAnimal;
  final bool isRecording;
  final String? recordingAnimalId;

  const MyZooState({
    this.ownedAnimalIds = const {},
    this.soundModeByAnimal = const {},
    this.recordingPathByAnimal = const {},
    this.isRecording = false,
    this.recordingAnimalId,
  });

  MyZooState copyWith({
    Set<String>? ownedAnimalIds,
    Map<String, String>? soundModeByAnimal,
    Map<String, String>? recordingPathByAnimal,
    bool? isRecording,
    String? recordingAnimalId,
    bool clearRecordingAnimalId = false,
  }) {
    return MyZooState(
      ownedAnimalIds: ownedAnimalIds ?? this.ownedAnimalIds,
      soundModeByAnimal: soundModeByAnimal ?? this.soundModeByAnimal,
      recordingPathByAnimal: recordingPathByAnimal ?? this.recordingPathByAnimal,
      isRecording: isRecording ?? this.isRecording,
      recordingAnimalId:
          clearRecordingAnimalId ? null : (recordingAnimalId ?? this.recordingAnimalId),
    );
  }
}

final myZooProvider = StateNotifierProvider<MyZooNotifier, MyZooState>((ref) {
  final storage = ref.watch(localStorageProvider);
  return MyZooNotifier(storage);
});

class MyZooNotifier extends StateNotifier<MyZooState> {
  final LocalStorage _storage;
  final AudioRecorder _recorder = AudioRecorder();

  MyZooNotifier(this._storage) : super(const MyZooState()) {
    _load();
  }

  void _load() {
    state = state.copyWith(
      ownedAnimalIds: _storage.getMyZooOwnedAnimals().toSet(),
      soundModeByAnimal: _storage.getMyZooSoundModes(),
      recordingPathByAnimal: _storage.getMyZooRecordings(),
    );
  }

  bool isOwned(String animalId) => state.ownedAnimalIds.contains(animalId);

  Future<void> addOwnedAnimal(String animalId) async {
    if (isOwned(animalId)) return;

    final updated = {...state.ownedAnimalIds, animalId};
    state = state.copyWith(ownedAnimalIds: updated);
    await _storage.addMyZooOwnedAnimal(animalId);
  }

  MyZooSoundMode getSoundMode(String animalId) {
    final modeRaw = state.soundModeByAnimal[animalId] ?? MyZooSoundMode.original.name;
    return modeRaw == MyZooSoundMode.recorded.name
        ? MyZooSoundMode.recorded
        : MyZooSoundMode.original;
  }

  String? getRecordingPath(String animalId) => state.recordingPathByAnimal[animalId];

  Future<void> setSoundMode(String animalId, MyZooSoundMode mode) async {
    final updated = Map<String, String>.from(state.soundModeByAnimal)
      ..[animalId] = mode.name;

    state = state.copyWith(soundModeByAnimal: updated);
    await _storage.setMyZooSoundMode(animalId, mode.name);
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
    _recorder.dispose();
    super.dispose();
  }
}
