import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/garages/data/garages_repository.dart';
import 'package:liko_auto/features/garages/domain/garage_entity.dart';

/// Liste de tous les garages disponibles.
final garagesProvider = Provider<List<GarageEntity>>((ref) {
  return ref.watch(garagesRepositoryProvider).getAll();
});
