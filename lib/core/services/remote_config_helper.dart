import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteConfigHelper {
  // In-memory cache variables with initial default values
  static String _devXOneUrl = 'https://dev-x-one.vercel.app/';
  static String _lekOraebUrl = 'https://5lek-oraeb.vercel.app/';
  static String _supportEmail = 'khalekqoraeb@gmail.com';
  static String _supportPhone = '01129455770';
  static bool _showPhoneField = true;
  static bool _showRamadanTheme = false;
  static String _devXLogoUrl =
      'https://pub-5fe3afd0e7d64de7af15bed6205d045e.r2.dev/devx.png';
  static String _supportWebsiteUrl = 'https://khaleek-qoraeb.vercel.app/';
  static bool _showWalletPayment = true;
  static bool _showCardPayment = true;

  // Production Ad Unit IDs fallbacks
  static String _androidBannerAdUnitId =
      'ca-app-pub-2375099279419840/5691604828';
  static String _iosBannerAdUnitId = 'ca-app-pub-2375099279419840/5733680850';
  static String _androidInterstitialAdUnitId =
      'ca-app-pub-2375099279419840/5514854314';
  static String _iosInterstitialAdUnitId =
      'ca-app-pub-2375099279419840/7909144406';
  static String _androidNativeAdUnitId =
      'ca-app-pub-2375099279419840/1300277132';
  static String _iosNativeAdUnitId = 'ca-app-pub-2375099279419840/4688192491';

  // Synced high-performance Getters
  static String get devXOneUrl => _devXOneUrl;
  static String get lekOraebUrl => _lekOraebUrl;
  static String get supportEmail => _supportEmail;
  static String get supportPhone => _supportPhone;
  static bool get showPhoneField => _showPhoneField;
  static bool get showRamadanTheme => _showRamadanTheme;
  static String get devXLogoUrl => _devXLogoUrl;
  static String get supportWebsiteUrl => _supportWebsiteUrl;
  static bool get showWalletPayment => _showWalletPayment;
  static bool get showCardPayment => _showCardPayment;

  static String get androidBannerAdUnitId => _androidBannerAdUnitId;
  static String get iosBannerAdUnitId => _iosBannerAdUnitId;
  static String get androidInterstitialAdUnitId => _androidInterstitialAdUnitId;
  static String get iosInterstitialAdUnitId => _iosInterstitialAdUnitId;
  static String get androidNativeAdUnitId => _androidNativeAdUnitId;
  static String get iosNativeAdUnitId => _iosNativeAdUnitId;

  /// Loads stored fallback cache from SharedPreferences on startup
  static Future<void> loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _devXOneUrl = prefs.getString('rc_dev_x_one_url') ?? _devXOneUrl;
      _lekOraebUrl = prefs.getString('rc_lek_oraeb_url') ?? _lekOraebUrl;
      _supportEmail = prefs.getString('rc_support_email') ?? _supportEmail;
      _supportPhone = prefs.getString('rc_support_phone') ?? _supportPhone;
      _showPhoneField = prefs.getBool('rc_show_phone_field') ?? _showPhoneField;
      _showRamadanTheme =
          prefs.getBool('rc_show_ramadan_theme') ?? _showRamadanTheme;
      _devXLogoUrl = prefs.getString('rc_dev_x_logo_url') ?? _devXLogoUrl;
      _supportWebsiteUrl =
          prefs.getString('rc_support_website_url') ?? _supportWebsiteUrl;
      _showWalletPayment =
          prefs.getBool('rc_show_wallet_payment') ?? _showWalletPayment;
      _showCardPayment =
          prefs.getBool('rc_show_card_payment') ?? _showCardPayment;

      _androidBannerAdUnitId =
          prefs.getString('rc_android_banner_ad_unit_id') ??
          _androidBannerAdUnitId;
      _iosBannerAdUnitId =
          prefs.getString('rc_ios_banner_ad_unit_id') ?? _iosBannerAdUnitId;
      _androidInterstitialAdUnitId =
          prefs.getString('rc_android_interstitial_ad_unit_id') ??
          _androidInterstitialAdUnitId;
      _iosInterstitialAdUnitId =
          prefs.getString('rc_ios_interstitial_ad_unit_id') ??
          _iosInterstitialAdUnitId;
      _androidNativeAdUnitId =
          prefs.getString('rc_android_native_ad_unit_id') ??
          _androidNativeAdUnitId;
      _iosNativeAdUnitId =
          prefs.getString('rc_ios_native_ad_unit_id') ?? _iosNativeAdUnitId;
    } catch (_) {
      // Fail silently, fallbacks are already set
    }
  }

  /// Updates both In-Memory variables and SharedPreferences cache from Firebase
  static Future<void> updateCacheFromFirebase() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      final prefs = await SharedPreferences.getInstance();

      // Read from active Remote Config
      _devXOneUrl = rc.getString('dev_x_one_url');
      _lekOraebUrl = rc.getString('lek_oraeb_url');
      _supportEmail = rc.getString('support_email');
      _supportPhone = rc.getString('support_phone');
      _showPhoneField = rc.getBool('show_phone_field');
      _showRamadanTheme = rc.getBool('show_ramadan_theme');
      _supportWebsiteUrl = rc.getString('support_website_url').isEmpty
          ? _supportWebsiteUrl
          : rc.getString('support_website_url');
      _showWalletPayment = rc.getBool('show_wallet_payment');
      _showCardPayment = rc.getBool('show_card_payment');

      _devXLogoUrl = rc.getString('dev_x_logo_url').isEmpty
          ? _devXLogoUrl
          : rc.getString('dev_x_logo_url');

      // Update values from Remote Config if they exist
      _androidBannerAdUnitId = rc.getString('android_banner_ad_unit_id').isEmpty
          ? _androidBannerAdUnitId
          : rc.getString('android_banner_ad_unit_id');
      _iosBannerAdUnitId = rc.getString('ios_banner_ad_unit_id').isEmpty
          ? _iosBannerAdUnitId
          : rc.getString('ios_banner_ad_unit_id');
      _androidInterstitialAdUnitId =
          rc.getString('android_interstitial_ad_unit_id').isEmpty
          ? _androidInterstitialAdUnitId
          : rc.getString('android_interstitial_ad_unit_id');
      _iosInterstitialAdUnitId =
          rc.getString('ios_interstitial_ad_unit_id').isEmpty
          ? _iosInterstitialAdUnitId
          : rc.getString('ios_interstitial_ad_unit_id');
      _androidNativeAdUnitId = rc.getString('android_native_ad_unit_id').isEmpty
          ? _androidNativeAdUnitId
          : rc.getString('android_native_ad_unit_id');
      _iosNativeAdUnitId = rc.getString('ios_native_ad_unit_id').isEmpty
          ? _iosNativeAdUnitId
          : rc.getString('ios_native_ad_unit_id');

      // Write back to SharedPreferences cache
      await prefs.setString('rc_dev_x_one_url', _devXOneUrl);
      await prefs.setString('rc_lek_oraeb_url', _lekOraebUrl);
      await prefs.setString('rc_support_email', _supportEmail);
      await prefs.setString('rc_support_phone', _supportPhone);
      await prefs.setBool('rc_show_phone_field', _showPhoneField);
      await prefs.setBool('rc_show_ramadan_theme', _showRamadanTheme);
      await prefs.setString('rc_dev_x_logo_url', _devXLogoUrl);
      await prefs.setString('rc_support_website_url', _supportWebsiteUrl);
      await prefs.setBool('rc_show_wallet_payment', _showWalletPayment);
      await prefs.setBool('rc_show_card_payment', _showCardPayment);

      await prefs.setString(
        'rc_android_banner_ad_unit_id',
        _androidBannerAdUnitId,
      );
      await prefs.setString('rc_ios_banner_ad_unit_id', _iosBannerAdUnitId);
      await prefs.setString(
        'rc_android_interstitial_ad_unit_id',
        _androidInterstitialAdUnitId,
      );
      await prefs.setString(
        'rc_ios_interstitial_ad_unit_id',
        _iosInterstitialAdUnitId,
      );
      await prefs.setString(
        'rc_android_native_ad_unit_id',
        _androidNativeAdUnitId,
      );
      await prefs.setString('rc_ios_native_ad_unit_id', _iosNativeAdUnitId);
    } catch (_) {
      // Fail silently
    }
  }
}
