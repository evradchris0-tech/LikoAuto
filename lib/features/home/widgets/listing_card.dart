import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/favorites/providers/favorites_provider.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

/// Modèle de données d'une annonce pour l'affichage en liste.
class ListingCardData {
  const ListingCardData({
    required this.title,
    required this.priceFcfa,
    required this.location,
    required this.mileageKm,
    required this.imageAsset,
    required this.photoCount,
    this.year = '2021',
    this.isVinVerified = false,
    this.isPro = false,
    this.priceDrop, // Badge baisse de prix (wireframe 5.2), ex: -500000
  });

  final String title;
  final int priceFcfa;
  final String location;
  final int mileageKm;
  final String imageAsset;
  final int photoCount;
  final String year;
  final bool isVinVerified;
  final bool isPro;
  final int? priceDrop; // Valeur négative (baisse) ou nulle (pas de baisse)
}

/// Carte d'annonce — image gauche + info droite + badges VIN/Pro.
class ListingCard extends ConsumerWidget {
  const ListingCard({
    required this.data,
    this.onTap,
    this.onFavorite,
    super.key,
  });

  final ListingCardData data;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    final added =
        await ref.read(favoritesActionsProvider).toggle(data);
    if (!context.mounted) return;
    if (added) {
      AppSnack.success(context, 'Ajouté aux favoris');
    } else {
      AppSnack.info(context, 'Retiré des favoris');
    }
    onFavorite?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = data;
    final isFavorited = ref.watch(isFavoriteProvider(d)).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.rCard,
          boxShadow: [
            BoxShadow(
              color: AppColors.trust.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Image gauche ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.card),
                bottomLeft: Radius.circular(AppRadius.card),
              ),
              child: SizedBox(
                width: 125,
                height: 125,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fond coloré derrière l'image (évite le blanc)
                    const ColoredBox(color: Color(0xFFEEEEEE)),
                    // Image
                    Hero(
                      tag: 'car_image_${d.title}_${d.priceFcfa}',
                      child: _CarImage(url: d.imageAsset),
                    ),
                    // Dégradé bas pour le badge photo
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 36,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Compteur photos
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${d.photoCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Infos droite ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre + favori
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            d.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.trust,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _toggleFavorite(context, ref),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isFavorited
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key: ValueKey(isFavorited),
                              size: 20,
                              color: isFavorited
                                  ? AppColors.primary
                                  : AppColors.neutral,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapXs,
                    // Prix + badge baisse de prix (wireframe 5.2)
                    Row(
                      children: [
                        Text(
                          d.priceFcfa.toFcfa(),
                          style: context.textStyles.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            height: 1.1,
                          ),
                        ),
                        if (d.priceDrop != null && d.priceDrop! < 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.trending_down_rounded,
                                  size: 12,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '-${d.priceDrop!.abs() ~/ 1000}k',
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.gapSm,
                    // Badges VIN + Pro
                    Row(
                      children: [
                        if (d.isVinVerified)
                          const _Badge(
                            label: 'VIN',
                            icon: Icons.verified_rounded,
                            color: AppColors.success,
                            bg: AppColors.successSoft,
                          ),
                        if (d.isVinVerified && d.isPro)
                          const SizedBox(width: 6),
                        if (d.isPro)
                          const _Badge(
                            label: 'Pro',
                            color: AppColors.trust,
                            bg: AppColors.primarySoft,
                          ),
                      ],
                    ),
                    AppSpacing.gapSm,
                    // Localisation + km
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.neutral,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${d.location} · ${d.mileageKm.toGroupedString()} km',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: AppColors.neutral,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
  });

  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Affiche une image locale (assets/) ou réseau (http/https).
class _CarImage extends StatelessWidget {
  const _CarImage({required this.url});
  final String url;

  static const _placeholder = ColoredBox(
    color: AppColors.primarySoft,
    child: Center(
      child: Icon(
        Icons.directions_car_rounded,
        color: AppColors.primary,
        size: 36,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder,
      );
    }
    if (url.isEmpty) return _placeholder;
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder,
    );
  }
}
