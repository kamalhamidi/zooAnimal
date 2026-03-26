import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class RewardedAdManager {
  RewardedAdManager._();
  static final RewardedAdManager instance = RewardedAdManager._();

  RewardedAd? _ad;
  bool _isLoading = false;

  bool get isReady => _ad != null;

  void loadAd() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          _attachFullScreenDelegate(ad);
          debugPrint('RewardedAdManager: ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('RewardedAdManager: failed to load - $error');
        },
      ),
    );
  }

  Future<bool> showAd({
    required dynamic from,
    required VoidCallback rewardHandler,
  }) async {
    final ad = _ad;
    if (ad == null) {
      loadAd();
      return false;
    }

    _ad = null;
    await ad.show(
      onUserEarnedReward: (_, __) {
        rewardHandler();
      },
    );
    return true;
  }

  void _attachFullScreenDelegate(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAdManager: failed to show - $error');
        ad.dispose();
        loadAd();
      },
    );
  }
}
