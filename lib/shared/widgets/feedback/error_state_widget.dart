import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.wifiOff, size: 56, color: AppColors.neutral),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Impossible de charger les données',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Réessayer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.trust,
                  side: const BorderSide(color: AppColors.trust),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
