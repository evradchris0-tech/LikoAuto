import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

/// Données fictives d'un garage pour la liste de l'annuaire / recherche.
class GarageCardData {
  const GarageCardData({
    required this.name,
    required this.specialties,
    required this.rating,
    required this.distanceKm,
    required this.location,
    required this.imageAsset,
    required this.isOpen,
    this.isCertified = false,
  });

  final String name;
  final List<String> specialties;
  final double rating;
  final double distanceKm;
  final String location;
  final String imageAsset;
  final bool isOpen;
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
          'Garage ${data.name}, ${data.specialties.join(", ")}, note ${data.rating}, à ${data.distanceKm} kilomètres',
      button: true,
      child: GestureDetector(
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
                                Icons.handyman_rounded,
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
                                icon: Icons.verified_user_rounded,
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
                                          fontSize: 11,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                          AppSpacing.gapSm,
                          Row(
                            children: [
                              Icon(
                                data.isOpen
                                    ? Icons.circle
                                    : Icons.do_not_disturb_on_outlined,
                                size: 10,
                                color: data.isOpen
                                    ? AppColors.success
                                    : AppColors.neutral,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data.isOpen ? 'Ouvert' : 'Fermé',
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: data.isOpen
                                      ? AppColors.success
                                      : AppColors.neutral,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppColors.neutral,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  '${data.location} · ${data.distanceKm.toStringAsFixed(1)} km',
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
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
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
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
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
          const Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 2),
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
