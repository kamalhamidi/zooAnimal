import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  InterstitialAd? _ad;
  bool _isLoading = false;
  int _retryCount = 0;

  bool get isReady => _ad != null;

  void loadAd() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          _retryCount = 0;
          _attachFullScreenDelegate(ad);
          debugPrint('InterstitialAdManager: ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('InterstitialAdManager: failed to load - $error');
          _scheduleRetry();
        },
      ),
    );
  }

  Future<bool> ensureLoaded({Duration timeout = const Duration(seconds: 8)}) async {
    if (_ad != null) return true;

    loadAd();
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (_ad != null) return true;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    return _ad != null;
  }

  Future<void> showAd({required dynamic viewController}) async {
    final ready = await ensureLoaded();
    if (!ready) return;

    final ad = _ad;
    if (ad == null) {
      loadAd();
      return;
    }

    _ad = null;
    await ad.show();
  }

  void _attachFullScreenDelegate(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAdManager: failed to show - $error');
        ad.dispose();
        loadAd();
      },
    );
  }

  void _scheduleRetry() {
    _retryCount++;
    final seconds = _retryCount > 5 ? 10 : _retryCount * 2;
    Future<void>.delayed(Duration(seconds: seconds), () {
      if (_ad == null) {
        loadAd();
      }
    });
  }
}
