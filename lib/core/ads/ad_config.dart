/// Ad unit ID constants for AdMob
class AdConfig {
  AdConfig._();

  // Global ad switches
  static const bool enableAppOpenAds = false;

  // ─── APP ID ───
  // Using Google sample App ID for test mode.
  static const String appId = 'ca-app-pub-7347264977043529~7238928088';

  // ─── AD UNIT IDS (Google official TEST IDs) ───
  // These show a clear "Test Ad" badge.
  // IMPORTANT: bannerId must always be a BANNER ad unit.
  static const String bannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String interstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const String rewardedId = 'ca-app-pub-3940256099942544/1712485313';
  static const String appOpenId = '';
}
