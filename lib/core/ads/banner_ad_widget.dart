import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

/// Reusable banner ad widget that loads and displays an AdMob banner.
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAd();
    });
  }

  void _loadAd() {
    _bannerAd = AdService.instance.createBannerAd(
      size: widget.adSize,
      listener: BannerAdListener(
      onAdLoaded: (ad) {
        if (!mounted) return;
        setState(() {
          _isLoaded = true;
          _isFailed = false;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        if (!mounted) return;
        setState(() {
          _isLoaded = false;
          _isFailed = true;
        });
        debugPrint('BannerAdWidget: Failed to load - $error');
      },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.adSize.width.toDouble();
    final height = widget.adSize.height.toDouble();

    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: width,
        height: height,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _isFailed ? 'Ad unavailable' : 'Loading ad…',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// UIKit-style naming alias for a reusable banner ad view.
class BannerAdView extends BannerAdWidget {
  const BannerAdView({super.key, super.adSize});
}
