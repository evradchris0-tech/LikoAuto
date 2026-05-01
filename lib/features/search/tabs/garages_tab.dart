import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/search/models/search_filters.dart';
import 'package:liko_auto/features/search/widgets/empty_results.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';
import 'package:liko_auto/features/search/widgets/result_count_header.dart';

class GaragesTab extends StatelessWidget {
  const GaragesTab({
    required this.results,
    required this.onResetFilters,
    required this.filters,
    super.key,
  });

  final List<GarageCardData> results;
  final GarageFilters filters;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return EmptyResults(onReset: onResetFilters);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ResultCountHeader(
            count: results.length,
            sortLabel: filters.minRating != null ? 'Note' : 'Distance',
          ),
        ),
        SliverList.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => GarageResultCard(data: results[i]),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
