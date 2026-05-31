import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/favorites/providers/favorites_provider.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Modèle de données d'une annonce pour l'affichage en liste.
class ListingCardData {
  const ListingCardData({
    required this.id,
    required this.title,
    required this.priceFcfa,
    required this.location,
    required this.mileageKm,
    required this.imageAsset,
    required this.photoCount,
    this.imageUrls = const [],
    this.year = '2021',
    this.isVinVerified = false,
    this.isPro = false,
    this.priceDrop, // Badge baisse de prix (wireframe 5.2), ex: -500000
  });

  final int id;
  final String title;
  final int priceFcfa;
  final String location;
  final int mileageKm;
  final String imageAsset;
  final int photoCount;
  final List<String> imageUrls;
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
    final added = await ref.read(favoritesActionsProvider).toggle(data);
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
    final isFavorited = ref
        .watch(isFavoriteProvider(d))
        .maybeWhen(data: (v) => v, orElse: () => false);
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.rCard,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rCard,
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
                      child: CarImage(url: d.imageAsset),
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
                            LucideIcons.camera,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            '${d.photoCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
                    // Ligne haute : badges VIN/Pro + logo marque + cœur
                    Row(
                      children: [
                        if (d.isVinVerified)
                          const _Badge(
                            label: 'VIN',
                            icon: LucideIcons.badgeCheck,
                            color: AppColors.success,
                            bg: AppColors.successSoft,
                          ),
                        if (d.isVinVerified && d.isPro)
                          const SizedBox(width: AppSpacing.xs),
                        if (d.isPro)
                          const _Badge(
                            label: 'Pro',
                            color: AppColors.trust,
                            bg: AppColors.primarySoft,
                          ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _toggleFavorite(context, ref),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isFavorited
                                  ? AppColors.primarySoft
                                  : AppColors.background,
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (!isFavorited)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
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
                    // Titre (pleine largeur)
                    Text(
                      d.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.trust,
                      ),
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
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.trendingDown,
                                  size: 12,
                                  color: Color(0xFFB91C1C),
                                ),
                                const SizedBox(width: AppSpacing.xxs),
                                Text(
                                  '-${d.priceDrop!.abs() ~/ 1000}k',
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontSize: 12,
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
                    // Localisation uniquement (sans kilométrage)
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 13,
                          color: AppColors.neutral,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            d.location,
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
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Affiche une image locale (assets/) ou réseau (http/https).
class CarImage extends StatelessWidget {
  const CarImage({required this.url, this.fit = BoxFit.cover, super.key});
  final String url;
  final BoxFit fit;

  static const _placeholder = ColoredBox(
    color: AppColors.primarySoft,
    child: Center(
      child: Icon(
        Icons.directions_car_outlined,
        color: AppColors.primary,
        size: 36,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder;

    var resolvedUrl = url;
    if (url.startsWith('/')) {
      resolvedUrl = '${AppConfig.baseUrl}$url';
    }

    if (resolvedUrl.startsWith('http')) {
      return Image.network(
        resolvedUrl,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder,
      );
    }
    return Image.asset(
      url,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder,
    );
  }
}
