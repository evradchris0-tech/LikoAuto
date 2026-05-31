import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Données fictives d'un garage pour la liste de l'annuaire / recherche.
class GarageCardData {
  const GarageCardData({
    required this.name,
    required this.specialties,
    required this.rating,
    required this.location,
    required this.imageAsset,
    this.isCertified = false,
  });

  final String name;
  final List<String> specialties;
  final double rating;
  final String location;
  final String imageAsset;
  final bool isCertified;
}

/// Carte garage — photo gauche + infos droite + bouton "Contacter via chat".
class GarageResultCard extends StatelessWidget {
  const GarageResultCard({
    required this.data,
    this.onTap,
    this.onContact,
    super.key,
  });

  final GarageCardData data;
  final VoidCallback? onTap;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Garage ${data.name}, ${data.specialties.join(", ")}, note ${data.rating}',
      button: true,
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
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.rCard,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.rCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.card),
                    ),
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const ColoredBox(color: AppColors.primarySoft),
                          Image.asset(
                            data.imageAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                LucideIcons.wrench,
                                color: AppColors.primary,
                                size: 36,
                              ),
                            ),
                          ),
                          if (data.isCertified)
                            const Positioned(
                              top: 6,
                              left: 6,
                              child: _MiniBadge(
                                icon: LucideIcons.shieldCheck,
                                label: 'Certifié',
                                color: Colors.white,
                                bg: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Infos
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textStyles.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.trust,
                                  ),
                                ),
                              ),
                              _RatingChip(rating: data.rating),
                            ],
                          ),
                          AppSpacing.gapXs,
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (final s in data.specialties.take(3))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    s,
                                    style: context.textStyles.labelSmall
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                          AppSpacing.gapSm,
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
                                  data.location,
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
              // CTA Contact via chat
              const Divider(height: 1, color: AppColors.outline),
              InkWell(
                onTap: onContact,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.card),
                  bottomRight: Radius.circular(AppRadius.card),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.lg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.messageCircle,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Contacter via chat',
                        style: context.textStyles.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: AppSpacing.xxs),
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

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.star, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            rating.toStringAsFixed(1).replaceAll('.', ','),
            style: const TextStyle(
              color: AppColors.trust,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
