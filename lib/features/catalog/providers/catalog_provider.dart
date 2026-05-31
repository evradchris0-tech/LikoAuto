import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/catalog/data/catalog_repository.dart';
import 'package:liko_auto/features/catalog/domain/brand.dart';
import 'package:liko_auto/features/catalog/domain/car_model.dart';

/// Liste de toutes les marques actives.
final brandsProvider = FutureProvider<List<Brand>>((ref) {
  return ref.watch(catalogRepositoryProvider).getBrands();
});

/// Liste des modèles, filtrables par marque.
final modelsProvider = FutureProvider.family<List<CarModel>, int?>((
  ref,
  brandId,
) {
  return ref.watch(catalogRepositoryProvider).getModels(brandId: brandId);
});

/// Marque actuellement sélectionnée dans le formulaire Sell.
final selectedBrandProvider = StateProvider<Brand?>((ref) => null);

/// Modèle actuellement sélectionné dans le formulaire Sell.
final selectedModelProvider = StateProvider<CarModel?>((ref) => null);
