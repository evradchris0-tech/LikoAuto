import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/services/mock_data_service.dart';
import 'package:liko_auto/features/garages/domain/garage_entity.dart';

class GaragesRepository {
  const GaragesRepository(this._service);
  final MockDataService _service;

  List<GarageEntity> getAll() => _service.garages;

  GarageEntity? getById(String id) => _service.garages
      .cast<GarageEntity?>()
      .firstWhere((g) => g?.id == id, orElse: () => null);
}

final garagesRepositoryProvider = Provider<GaragesRepository>((ref) {
  // Throws AsyncLoading until mockDataServiceProvider resolves —
  // callers should use garagesProvider (FutureProvider) instead.
  final service = ref.watch(mockDataServiceProvider).requireValue;
  return GaragesRepository(service);
});
