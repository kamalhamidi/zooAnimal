import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

// ─── Coin Provider ───
final coinProvider = StateNotifierProvider<CoinNotifier, int>((ref) {
  final storage = ref.watch(localStorageProvider);
  return CoinNotifier(storage);
});

class CoinNotifier extends StateNotifier<int> {
  final LocalStorage _storage;

  CoinNotifier(this._storage) : super(0) {
    _loadCoins();
  }

  void _loadCoins() {
    state = _storage.getCoins();
  }

  Future<void> addCoins(int amount) async {
    state = state + amount;
    await _storage.setCoins(state);
  }

  Future<bool> spendCoins(int amount) async {
    if (state < amount) return false;
    state = state - amount;
    await _storage.setCoins(state);
    return true;
  }

  // Future hook: "Watch ad for +10 coins"
  Future<void> watchAdForCoins() async {
    // Stub method — integrate ad SDK here
    await addCoins(10);
  }

  int get balance => state;
}
