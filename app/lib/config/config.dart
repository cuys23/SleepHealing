class AppConfig {
  AppConfig._();
  static const String baseUrl = 'http://localhost:9080/api';
  static const String uatbaseUrl = 'http://maditam.razinsoft.com/api';

  /// The API host without the `/api` suffix, e.g. `http://localhost:9080`.
  /// Media (image/audio) URLs live under this host's `/storage` path, not
  /// under `/api`, so this is what [normalizeMediaUrl] anchors relative
  /// paths to.
  static String get hostUrl => baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

  //Store links (Invite Friend)
  static const String androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.maditam';
  // TODO: replace with the real App Store URL (https://apps.apple.com/app/idXXXXXXXXXX) once published.
  static const String iosStoreUrl =
      'https://apps.apple.com/app/com.maditam.app';

  //Contact US Config
  static const String ctAboutCompany =
      'RazinSoft, Dhaka, 1216'; //Company name And Address
  static const String ctWhatsApp =
      '+88017xxxxxxxx'; // whats app Number with Country Code
  static const String ctPhone = '+88017xxxxxxxx'; // Contact Phone Number
  static const String ctMail = 'example@gmail.com'; // Contact Mail
}
