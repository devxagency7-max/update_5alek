import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motareb/core/services/remote_config_helper.dart';

/// AdsController manages Google Mobile Ads and Firebase Remote Config.
/// It provides a central place to control ad visibility and load ads.
class AdsController {
  // Singleton pattern for easy access across the app
  static final AdsController _instance = AdsController._internal();
  factory AdsController() => _instance;
  AdsController._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Remote Config keys
  static const String _adsEnabledKey = 'ads_enabled';

  // State to track if ads are enabled via Remote Config
  bool _adsEnabled = false;
  bool get adsEnabled => _adsEnabled;

  // Interstitial Ad Reference
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  /// Initialize Remote Config and AdMob
  Future<void> initialize() async {
    try {
      // 1. Initialize Mobile Ads SDK
      await MobileAds.instance.initialize();

      // 2. Set Remote Config settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          // Force immediate update in Debug mode, otherwise every hour
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );

      // 3. Set default values
      await _remoteConfig.setDefaults({
        _adsEnabledKey: false,
        'dev_x_one_url': 'https://dev-x-one.vercel.app/',
        'lek_oraeb_url': 'https://5lek-oraeb.vercel.app/',
        'support_email': 'khalekqoraeb@gmail.com',
        'support_phone': '01129455770',
        'show_phone_field': true,
        'show_ramadan_theme': false,
        'dev_x_logo_url':
            'https://pub-5fe3afd0e7d64de7af15bed6205d045e.r2.dev/devx.png',
        'show_wallet_payment': true,
        'show_card_payment': true,
        'android_banner_ad_unit_id': 'ca-app-pub-2375099279419840/5691604828',
        'ios_banner_ad_unit_id': 'ca-app-pub-2375099279419840/5733680850',
        'android_interstitial_ad_unit_id':
            'ca-app-pub-2375099279419840/5514854314',
        'ios_interstitial_ad_unit_id': 'ca-app-pub-2375099279419840/7909144406',
        'android_native_ad_unit_id': 'ca-app-pub-2375099279419840/1300277132',
        'ios_native_ad_unit_id': 'ca-app-pub-2375099279419840/4688192491',
      });

      // 4. Fetch and activate Remote Config
      // We use fetchAndActivate to get the latest values from the server
      bool activated = await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config activated: $activated');

      // 5. Update local state
      _adsEnabled = _remoteConfig.getBool(_adsEnabledKey);
      debugPrint('🔥 [RemoteConfig] ads_enabled value is: $_adsEnabled');

      // Update RemoteConfigHelper Two-Layer cache
      await RemoteConfigHelper.updateCacheFromFirebase();

      // 6. Preload Interstitial if enabled
      if (_adsEnabled) {
        _loadInterstitialAd();
      }
    } catch (e) {
      debugPrint('Error initializing AdsController: $e');
      // If Remote Config fails, we stick to the default (false)
      _adsEnabled = false;
    }
  }

  /// Re-fetch Remote Config value (e.g., when the app resumes or at specific intervals)
  Future<void> syncRemoteConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _adsEnabled = _remoteConfig.getBool(_adsEnabledKey);

      // Update RemoteConfigHelper Two-Layer cache
      await RemoteConfigHelper.updateCacheFromFirebase();

      // If ads were turned ON, and we don't have an interstitial, load one
      if (_adsEnabled && _interstitialAd == null) {
        _loadInterstitialAd();
      }
    } catch (e) {
      debugPrint('Error syncing Remote Config: $e');
    }
  }

  // --- Ad Unit IDs (Production Safe) ---

  // Replace these with your real Ad Unit IDs from AdMob Console
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Test Banner Android
          : 'ca-app-pub-3940256099942544/2934735716'; // Test Banner iOS
    }
    return Platform.isAndroid
        ? RemoteConfigHelper.androidBannerAdUnitId
        : RemoteConfigHelper.iosBannerAdUnitId;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Test Interstitial Android
          : 'ca-app-pub-3940256099942544/4411468910'; // Test Interstitial iOS
    }
    return Platform.isAndroid
        ? RemoteConfigHelper.androidInterstitialAdUnitId
        : RemoteConfigHelper.iosInterstitialAdUnitId;
  }

  static String get nativeAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110' // Test Native Android
          : 'ca-app-pub-3940256099942544/3986624511'; // Test Native iOS
    }
    return Platform.isAndroid
        ? RemoteConfigHelper.androidNativeAdUnitId
        : RemoteConfigHelper.iosNativeAdUnitId;
  }

  // --- Interstitial Logic ---

  void _loadInterstitialAd() {
    if (!_adsEnabled || _isInterstitialLoading || _interstitialAd != null)
      return;

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('InterstitialAd loaded.');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitialAd(); // Load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Shows an interstitial ad if it's loaded and ads are enabled
  void showInterstitialAd() {
    if (_adsEnabled && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not ready or ads disabled.');
      _loadInterstitialAd(); // Try to load for next time
    }
  }

  /// Call this when the app is being disposed
  void dispose() {
    _interstitialAd?.dispose();
  }
}
