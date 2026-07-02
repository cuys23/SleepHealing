import 'dart:io';

class AdHelper {
  // Temporary switch to disable all ads (banner + interstitial).
  static const bool adsEnabled = false;

  // Banner ads unitId
  static const String androidbannerUnitId =
      'ca-app-pub-3405382556879664/8436297443';
  static const String iosbannerUnitId =
      'ca-app-pub-3405382556879664/8186113485';

// Interstetial ads UnitId
  static const String androidInterstetialUnitId =
      'ca-app-pub-3405382556879664/5810134101';
  static const String iosInterstetialUnitId =
      'ca-app-pub-3405382556879664/6472796311';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return androidbannerUnitId;
    } else if (Platform.isIOS) {
      return iosbannerUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstetialUnitId {
    if (Platform.isAndroid) {
      return androidInterstetialUnitId;
    } else if (Platform.isIOS) {
      return iosInterstetialUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
