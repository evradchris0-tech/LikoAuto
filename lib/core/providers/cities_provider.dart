import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/api_client.dart';
import 'package:liko_auto/core/api/app_config.dart';

class ApiCity {
  const ApiCity({required this.id, required this.name});

  factory ApiCity.fromJson(Map<String, dynamic> j) =>
      ApiCity(id: j['id'] as int, name: j['name'] as String);

  final int id;
  final String name;
}

const _kFallbackCities = <ApiCity>[
  ApiCity(id: 1, name: 'Douala'),
  ApiCity(id: 2, name: 'Yaoundé'),
  ApiCity(id: 3, name: 'Bafoussam'),
  ApiCity(id: 4, name: 'Garoua'),
  ApiCity(id: 5, name: 'Maroua'),
  ApiCity(id: 6, name: 'Ngaoundéré'),
  ApiCity(id: 7, name: 'Bertoua'),
  ApiCity(id: 8, name: 'Ebolowa'),
];

/// Villes disponibles — appel `GET /cities`, fallback camerounais si hors-ligne.
final citiesProvider = FutureProvider<List<ApiCity>>((ref) async {
  try {
    final client = ref.watch(apiClientProvider);
    final res = await client.get<List<dynamic>>(AppConfig.cities);
    final data = (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(ApiCity.fromJson)
        .toList();
    if (data.isNotEmpty) return data;
  } on Exception catch (_) {}
  return _kFallbackCities;
});
