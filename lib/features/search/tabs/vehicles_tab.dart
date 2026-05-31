import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/search/models/search_filters.dart';
import 'package:liko_auto/features/search/widgets/empty_results.dart';

class VehiclesTab extends StatelessWidget {
  const VehiclesTab({
    required this.results,
    required this.onResetFilters,
    required this.filters,
    this.onTap,
    super.key,
  });

  final List<ListingCardData> results;
  final VehicleFilters filters;
  final VoidCallback onResetFilters;
  final ValueChanged<ListingCardData>? onTap;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return EmptyResults(onReset: onResetFilters);
    }

    return CustomScrollView(
      slivers: [
        SliverList.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => ListingCard(
            data: results[i],
            onTap: onTap != null ? () => onTap!(results[i]) : null,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }
}
