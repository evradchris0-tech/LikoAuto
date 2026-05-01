abstract final class AppConstants {
  static const String appName = 'Liko Auto';
  static const String countryCode = 'CM';
  static const String currency = 'FCFA';
  static const String defaultLocale = 'fr_FR';

  static const List<String> supportedCities = [
    'Douala',
    'Yaoundé',
    'Bafoussam',
  ];

  // VIN
  static const int vinLength = 17;

  // Listing publication
  static const int minPhotos = 5;
  static const int maxPhotos = 21;
  static const int videoMinSeconds = 30;
  static const int videoMaxSeconds = 60;
  static const int descriptionMaxLength = 500;
}
