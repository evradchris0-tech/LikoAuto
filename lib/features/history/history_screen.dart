import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/history/providers/view_history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(viewHistoryProvider).valueOrNull ?? const [];
    final groups = _groupByDay(entries);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.trust),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Historique',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (entries.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text(
                'Tout effacer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: entries.isEmpty
          ? const _EmptyState()
          : AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                itemCount: groups.length,
                itemBuilder: (context, groupIndex) {
                  final g = groups[groupIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          g.label,
                          style: context.textStyles.labelLarge?.copyWith(
                            color: AppColors.neutral,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      ...g.items.asMap().entries.map((entry) {
                        final i = entry.key;
                        final v = entry.value;
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 280),
                          child: SlideAnimation(
                            verticalOffset: 20,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xs,
                                ),
                                child: _HistoryTile(
                                  viewed: v,
                                  onTap: () => context.push(
                                    AppRoutes.vehicleDetail,
                                    extra: v.data,
                                  ),
                                  onRemove: () => ref
                                      .read(viewHistoryActionsProvider)
                                      .remove(v.data),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
    );
  }

  List<_DayGroup> _groupByDay(List<ViewedListing> all) {
    if (all.isEmpty) return const [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(const Duration(days: 7));

    final byBucket = <String, List<ViewedListing>>{
      "Aujourd'hui": [],
      'Hier': [],
      'Cette semaine': [],
      'Plus ancien': [],
    };
    for (final v in all) {
      final d = DateTime(v.viewedAt.year, v.viewedAt.month, v.viewedAt.day);
      if (d == today) {
        byBucket["Aujourd'hui"]!.add(v);
      } else if (d == yesterday) {
        byBucket['Hier']!.add(v);
      } else if (d.isAfter(weekStart)) {
        byBucket['Cette semaine']!.add(v);
      } else {
        byBucket['Plus ancien']!.add(v);
      }
    }
    return byBucket.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => _DayGroup(label: e.key, items: e.value))
        .toList();
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Effacer l'historique ?"),
        content: const Text(
          'Toutes les annonces consultées seront retirées de cette liste.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.neutral),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Tout effacer',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(viewHistoryActionsProvider).clearAll();
  }
}

class _DayGroup {
  const _DayGroup({required this.label, required this.items});
  final String label;
  final List<ViewedListing> items;
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.viewed,
    required this.onTap,
    required this.onRemove,
  });

  final ViewedListing viewed;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final d = viewed.data;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 70,
                  height: 56,
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Image.asset(d.imageAsset, fit: BoxFit.cover),
                  ),
                ),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: AppColors.trust,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d.priceFcfa.toFcfa(),
                      style: context.textStyles.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppColors.neutral,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _relativeTime(viewed.viewedAt),
                          style: context.textStyles.labelSmall?.copyWith(
                            color: AppColors.neutral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.neutral,
                ),
                onPressed: onRemove,
                tooltip: "Retirer de l'historique",
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return '${t.day.toString().padLeft(2, '0')}/'
        '${t.month.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.gapLg,
            Text(
              'Aucune annonce consultée.',
              style: context.textStyles.headlineSmall?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,
            Text(
              'Les véhicules que vous ouvrez apparaîtront ici, '
              'par ordre chronologique.',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppColors.neutral,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
