import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motareb/core/services/ad_service.dart';
import 'package:motareb/core/services/ads_controller.dart';

class NativeAdWidget extends StatefulWidget {
  final double height;
  final String factoryId;
  const NativeAdWidget({
    super.key,
    this.height = 260,
    this.factoryId = 'listTileMedium',
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // ⬇️ New Check: Don't even try to load if ads are disabled remotely
    if (AdsController().adsEnabled) {
      _tryGetPooledAd();
    } else {
      debugPrint('🚫 NativeAdWidget: Ads are disabled via Remote Config.');
    }
  }

  void _tryGetPooledAd() {
    // Attempt to get a pre-loaded ad from the correct pool
    final pooledAd = AdService().getNativeAd(widget.factoryId);
    if (pooledAd != null) {
      debugPrint('⚡ Using pre-loaded Native Ad (${widget.factoryId})');
      setState(() {
        _nativeAd = pooledAd;
        _isAdLoaded = true;
      });
    } else {
      debugPrint('⌛ Pool empty for ${widget.factoryId}, loading normally');
      _loadAdManual();
    }
  }

  void _loadAdManual() {
    final String adUnitId = AdsController.nativeAdUnitId;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: widget.factoryId == 'listTileLarge'
          ? 'listTileMedium'
          : widget.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (_isDisposed) {
            ad.dispose();
            return;
          }
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!_isDisposed) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: const Color(0xFF2A3038))
            : null,
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}
