import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Header "X résultats" + bouton de tri.
class ResultCountHeader extends StatelessWidget {
  const ResultCountHeader({
    required this.count,
    this.sortLabel = 'Pertinence',
    this.onSort,
    super.key,
  });

  final int count;
  final String sortLabel;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            '$count résultat${count > 1 ? 's' : ''}',
            style: context.textStyles.labelLarge?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (onSort != null)
            InkWell(
              onTap: onSort,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.arrowUpDown,
                      size: 18,
                      color: AppColors.neutral,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      sortLabel,
                      style: context.textStyles.labelMedium?.copyWith(
                        color: AppColors.neutral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
