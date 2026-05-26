import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/favorites/providers/favorites_provider.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider).valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.trust),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(
              'Mes favoris',
              style: context.textStyles.headlineMedium?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (favorites.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${favorites.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (favorites.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text(
                'Tout vider',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? const _EmptyState()
          : AnimationLimiter(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => AppSpacing.gapSm,
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 320),
                    child: SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(
                        child: Dismissible(
                          key: ValueKey(favoriteKey(item)),
                          direction: DismissDirection.endToStart,
                          background: const _SwipeBackground(),
                          onDismissed: (_) {
                            ref
                                .read(favoritesActionsProvider)
                                .remove(item);
                            AppSnack.info(
                              context,
                              'Annonce retirée des favoris',
                              actionLabel: 'Annuler',
                              onAction: () => ref
                                  .read(favoritesActionsProvider)
                                  .toggle(item),
                            );
                          },
                          child: ListingCard(
                            data: item,
                            onTap: () => context.push(
                              AppRoutes.vehicleDetail,
                              extra: item,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider tous les favoris ?'),
        content: const Text(
          'Toutes les annonces enregistrées seront retirées de cette liste.',
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
              'Tout vider',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(favoritesActionsProvider).clearAll();
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Retirer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.delete_outline_rounded, color: Colors.white),
        ],
      ),
    );
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
                Icons.favorite_border_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.gapLg,
            Text(
              'Aucun favori pour le moment.',
              style: context.textStyles.headlineSmall?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,
            Text(
              'Touchez le ♥ sur une annonce pour la garder sous la main et la retrouver ici.',
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
