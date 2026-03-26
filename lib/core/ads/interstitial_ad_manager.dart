import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  InterstitialAd? _ad;
  bool _isLoading = false;

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
          _attachFullScreenDelegate(ad);
          debugPrint('InterstitialAdManager: ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('InterstitialAdManager: failed to load - $error');
        },
      ),
    );
  }

  Future<void> showAd({required dynamic viewController}) async {
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
}
