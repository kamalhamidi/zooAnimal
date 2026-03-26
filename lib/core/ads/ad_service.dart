import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

/// Singleton service managing all AdMob ad types:
/// banner, interstitial, rewarded, and app open ads.
class AdService {
  static AdService? _instance;
  AdService._();

  static AdService get instance {
    _instance ??= AdService._();
    return _instance!;
  }

  bool _initialized = false;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;
  bool _isAppOpenReady = false;

  // ─── INIT ───
  Future<void> init() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('AdService: MobileAds SDK initialized');
      // Preload ads
      loadInterstitial();
      loadRewarded();
      // App Open ads disabled.
    } catch (e) {
      debugPrint('AdService: Failed to initialize - $e');
    }
  }

  // ─── BANNER ───
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    BannerAdListener? listener,
  }) {
    return BannerAd(
      adUnitId: AdConfig.bannerId,
      size: size,
      request: const AdRequest(),
      listener: listener ?? BannerAdListener(
        onAdLoaded: (ad) => debugPrint('AdService: Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Banner failed to load - $error');
          ad.dispose();
        },
      ),
    );
  }

  // ─── INTERSTITIAL ───
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          debugPrint('AdService: Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
          debugPrint('AdService: Interstitial failed to load - $error');
        },
      ),
    );
  }

  Future<void> showInterstitial({VoidCallback? onDismissed}) async {
    if (!_isInterstitialReady || _interstitialAd == null) {
      onDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialReady = false;
        _interstitialAd = null;
        loadInterstitial(); // Preload next
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialReady = false;
        _interstitialAd = null;
        loadInterstitial();
        onDismissed?.call();
      },
    );

    await _interstitialAd!.show();
  }

  bool get isInterstitialReady => _isInterstitialReady;

  // ─── REWARDED ───
  void loadRewarded() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          debugPrint('AdService: Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
          debugPrint('AdService: Rewarded ad failed to load - $error');
        },
      ),
    );
  }

  Future<bool> showRewarded({
    required void Function(int amount) onRewarded,
    VoidCallback? onDismissed,
  }) async {
    if (!_isRewardedReady || _rewardedAd == null) {
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedReady = false;
        _rewardedAd = null;
        loadRewarded(); // Preload next
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedReady = false;
        _rewardedAd = null;
        loadRewarded();
        onDismissed?.call();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward.amount.toInt());
      },
    );
    return true;
  }

  bool get isRewardedReady => _isRewardedReady;

  // ─── APP OPEN ───
  void loadAppOpenAd() {
    if (!AdConfig.enableAppOpenAds || AdConfig.appOpenId.isEmpty) {
      _isAppOpenReady = false;
      return;
    }

    AppOpenAd.load(
      adUnitId: AdConfig.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenReady = true;
          debugPrint('AdService: App Open ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isAppOpenReady = false;
          debugPrint('AdService: App Open ad failed to load - $error');
        },
      ),
    );
  }

  Future<void> showAppOpenAd() async {
    if (!AdConfig.enableAppOpenAds) {
      return;
    }

    // Intentionally no-op for now.
    return;
  }

  bool get isAppOpenReady => _isAppOpenReady;

  // ─── DISPOSE ───
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    _instance = null;
  }
}
