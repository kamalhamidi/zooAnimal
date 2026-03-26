import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class RewardedAdManager {
  RewardedAdManager._();
  static final RewardedAdManager instance = RewardedAdManager._();

  RewardedAd? _ad;
  bool _isLoading = false;
  int _retryCount = 0;

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
          _retryCount = 0;
          _attachFullScreenDelegate(ad);
          debugPrint('RewardedAdManager: ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('RewardedAdManager: failed to load - $error');
          _scheduleRetry();
        },
      ),
    );
  }

  Future<bool> ensureLoaded({Duration timeout = const Duration(seconds: 10)}) async {
    if (_ad != null) return true;

    loadAd();
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      if (_ad != null) return true;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    return _ad != null;
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
