/// Configuration des URLs de l'API NestJS selon l'environnement.
///
/// En dev : pointer vers localhost ou le tunnel ngrok du backend.
/// En prod : pointer vers l'URL de production.
abstract final class AppConfig {
  static const String _devBaseUrl = 'http://147.135.128.19:20342';
  static const String _prodBaseUrl = 'http://147.135.128.19:20342'; // TODO(Dev): Update when real prod is ready

  static const bool _isDebug = !bool.fromEnvironment('dart.vm.product');
  static String get baseUrl => _isDebug ? _devBaseUrl : _prodBaseUrl;

  // ── Auth (à venir — module non encore documenté dans le spec) ─────────────
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String fcmToken = '/users/fcm-token';

  // ── Catalogue ──────────────────────────────────────────────────────────────
  static const String brands = '/brands';
  static const String models = '/models';
  static const String features = '/features';

  // ── Géographie ────────────────────────────────────────────────────────────
  static const String countries = '/countries';
  static const String regions = '/regions';
  static const String cities = '/cities';

  // ── Annonces ──────────────────────────────────────────────────────────────
  static const String listings = '/listings';
  static const String listingsWithMedia = '/listings/with-media';

  // ── Médias ─────────────────────────────────────────────────────────────────
  static const String mediaUpload = '/media/upload';

  // ── Helpers ────────────────────────────────────────────────────────────────
  static String listing(int id) => '/listings/$id';
  static String listingPhotos(int listingId) => '/listings/$listingId/photos';
  static String vehicleHistories(int vehicleId) =>
      '/vehicles/$vehicleId/histories';
  static String vehicleMedia(int vehicleId) => '/vehicles/$vehicleId/media';
  static String modelVariants(int modelId) => '/models/$modelId/variants';
}
