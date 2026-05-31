import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/geo/data/geo_repository.dart';
import 'package:liko_auto/features/geo/domain/api_city.dart';

/// Liste des pays actifs.
final countriesProvider = FutureProvider<List<ApiCountry>>((ref) {
  return ref.watch(geoRepositoryProvider).getCountries();
});

/// Villes filtrées par pays (défaut : Cameroun = 1).
final citiesProvider = FutureProvider.family<List<ApiCity>, int?>((
  ref,
  countryId,
) {
  return ref.watch(geoRepositoryProvider).getCities(countryId: countryId);
});

/// Ville sélectionnée dans le formulaire Sell / filtres.
final selectedCityProvider = StateProvider<ApiCity?>((ref) => null);
