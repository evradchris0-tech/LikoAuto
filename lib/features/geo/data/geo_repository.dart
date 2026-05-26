import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/api_client.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/features/geo/domain/api_city.dart';

class GeoRepository {
  const GeoRepository(this._api);
  final ApiClient _api;

  Future<List<ApiCountry>> getCountries() async {
    final res = await _api.get<List<dynamic>>(AppConfig.countries);
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(ApiCountry.fromJson)
        .toList();
  }

  Future<List<ApiCity>> getCities({int? countryId, int? regionId}) async {
    final params = <String, dynamic>{};
    if (countryId != null) params['countryId'] = countryId;
    if (regionId != null) params['regionId'] = regionId;
    final res = await _api.get<List<dynamic>>(
      AppConfig.cities,
      queryParameters: params.isEmpty ? null : params,
    );
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(ApiCity.fromJson)
        .toList();
  }
}

final geoRepositoryProvider = Provider<GeoRepository>(
  (ref) => GeoRepository(ref.watch(apiClientProvider)),
);
