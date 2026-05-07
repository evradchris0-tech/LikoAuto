import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/fixtures/mock_vehicles.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

/// Source unique de véhicules pour Home (top 4) et Search (all).
final homeListingsProvider = FutureProvider<List<ListingCardData>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 1800));
  return MockVehicles.all.take(4).toList();
});
