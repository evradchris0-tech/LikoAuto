import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/garages/domain/garage_entity.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GarageCard extends StatelessWidget {
  const GarageCard({required this.garage, this.onTap, super.key});
  final GarageEntity garage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Avatar garage — icône sur fond primary doux
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.wrench,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          garage.name,
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (garage.isVerified) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          LucideIcons.badgeCheck,
                          color: AppColors.success,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 13,
                        color: AppColors.neutral,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        garage.location,
                        style: context.textStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.star,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        garage.rating.toStringAsFixed(1),
                        style: context.textStyles.labelSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '  (${garage.reviewCount} avis)',
                        style: context.textStyles.labelSmall,
                      ),
                      const Spacer(),
                      if (garage.listingsCount > 0)
                        Text(
                          '${garage.listingsCount} annonces',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.neutral,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
