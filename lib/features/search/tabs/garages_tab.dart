import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/search/models/search_filters.dart';
import 'package:liko_auto/features/search/widgets/empty_results.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';

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
        SliverList.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => GarageResultCard(
            data: results[i],
            onTap: () =>
                context.push(AppRoutes.garageDetail, extra: results[i]),
            onContact: () => context.go(AppRoutes.chat),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }
}
