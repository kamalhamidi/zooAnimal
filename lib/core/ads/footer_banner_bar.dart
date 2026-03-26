import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'banner_ad_widget.dart';

/// Fixed footer banner area pinned to the very bottom.
class FooterBannerBar extends StatelessWidget {
  const FooterBannerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox(
          height: 56,
          child: ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: AdSize.banner.width.toDouble(),
                height: AdSize.banner.height.toDouble(),
                child: const BannerAdWidget(adSize: AdSize.banner),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
