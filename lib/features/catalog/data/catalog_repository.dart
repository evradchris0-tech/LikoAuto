import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/api_client.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/features/catalog/domain/brand.dart';
import 'package:liko_auto/features/catalog/domain/car_model.dart';

class CatalogRepository {
  const CatalogRepository(this._api);
  final ApiClient _api;

  Future<List<Brand>> getBrands() async {
    final res = await _api.get<List<dynamic>>(AppConfig.brands);
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(Brand.fromJson)
        .toList();
  }

  Future<List<CarModel>> getModels({int? brandId}) async {
    final res = await _api.get<List<dynamic>>(
      AppConfig.models,
      queryParameters: brandId != null ? {'brandId': brandId} : null,
    );
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(CarModel.fromJson)
        .toList();
  }

  Future<List<ModelVariant>> getVariants(int modelId) async {
    final res = await _api.get<List<dynamic>>(AppConfig.modelVariants(modelId));
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(ModelVariant.fromJson)
        .toList();
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(apiClientProvider)),
);
