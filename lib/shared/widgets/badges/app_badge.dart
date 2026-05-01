import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';

/// Badge générique stylé selon le type. Wrap automatique en Semantics.
enum AppBadgeStyle { vinVerified, pro, negotiable, neutral, warning }

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.icon,
    this.style = AppBadgeStyle.neutral,
    super.key,
  });

  /// Badge "VIN vérifié" — vert, avec icône check.
  const AppBadge.vinVerified({super.key})
    : label = 'VIN vérifié',
      icon = Icons.verified_rounded,
      style = AppBadgeStyle.vinVerified;

  /// Badge "Pro" — fond primary, texte blanc.
  const AppBadge.pro({super.key})
    : label = 'Pro',
      icon = Icons.workspace_premium_rounded,
      style = AppBadgeStyle.pro;

  /// Badge "Certifié" — fond primary, texte blanc.
  const AppBadge.certified({super.key})
    : label = 'Garage certifié',
      icon = Icons.verified_user_rounded,
      style = AppBadgeStyle.pro;

  /// Badge "Négociable" — fond orange clair, texte primary.
  const AppBadge.negotiable({super.key})
    : label = 'Négociable',
      icon = null,
      style = AppBadgeStyle.negotiable;

  final String label;
  final IconData? icon;
  final AppBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(context);

    return Semantics(
      label: label,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: colors.foreground),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: context.textStyles.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Color background, Color foreground}) _resolveColors(BuildContext context) {
    switch (style) {
      case AppBadgeStyle.vinVerified:
        return (
          background: AppColors.successSoft,
          foreground: AppColors.success,
        );
      case AppBadgeStyle.pro:
        return (background: AppColors.primary, foreground: Colors.white);
      case AppBadgeStyle.negotiable:
        return (
          background: AppColors.primarySoft,
          foreground: AppColors.primary,
        );
      case AppBadgeStyle.warning:
        return (
          background: const Color(0xFFFFF3DC),
          foreground: const Color(0xFFB97810),
        );
      case AppBadgeStyle.neutral:
        return (
          background: context.colors.surfaceContainerHighest,
          foreground: context.colors.onSurfaceVariant,
        );
    }
  }
}
