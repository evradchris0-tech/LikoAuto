import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/listings/providers/listings_provider.dart';

/// Annonces publiées converties en [ListingCardData] pour HomeScreen.
final homeListingsProvider = FutureProvider<List<ListingCardData>>((ref) async {
  final listings = await ref.watch(publishedListingsProvider.future);
  return listings.map((l) => l.toCardData()).toList();
});
