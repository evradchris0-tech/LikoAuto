import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/listings/providers/listings_provider.dart';

/// Annonces pour HomeScreen — API réelle en priorité, fallback JSON si hors-ligne.
final homeListingsProvider = FutureProvider<List<ListingCardData>>((ref) async {
  try {
    final listings = await ref.watch(publishedListingsProvider.future);
    if (listings.isNotEmpty) {
      return listings.map((l) => l.toCardData()).toList();
    }
    return []; // Return empty instead of mock data if empty
  } catch (e) {
    // Failed to fetch, let UI handle error
    rethrow; // Rethrow to show error state in UI
  }
});
