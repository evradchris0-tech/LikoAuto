import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/services/mock_data_service.dart';
import 'package:liko_auto/features/garages/domain/garage_entity.dart';

/// Liste complète des garages, chargée depuis mock_data.json.
final garagesProvider = FutureProvider<List<GarageEntity>>((ref) async {
  final service = await ref.watch(mockDataServiceProvider.future);
  return service.garages;
});
