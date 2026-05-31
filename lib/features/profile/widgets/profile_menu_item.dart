import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Carte individuelle de menu profil — design "carte séparée" (ref. Jon Alishon).
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount,
    this.isDestructive = false,
    this.isNew = false,
    this.iconBg,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool isDestructive;
  final bool isNew;
  final Color? iconBg;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconColor = isDestructive ? AppColors.error : AppColors.trust;
    final iconBackground = isDestructive
        ? AppColors.errorSoft
        : (iconBg ?? AppColors.trustSoft);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.trust.withValues(alpha: 0.1),
          highlightColor: AppColors.trust.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 13,
            ),
            child: Row(
              children: [
                // Icône dans un conteneur coloré arrondi
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Badge ou NEW ou trailing custom
                if (trailing != null)
                  trailing!
                else if (isNew)
                  Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else if (badgeCount != null && badgeCount! > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Icon(
                  LucideIcons.chevronRight,
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.4)
                      : const Color(0xFFCBD5E1),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Groupe de cartes-menu (sans wrapper groupé — chaque item est sa propre carte).
class ProfileSectionList extends StatelessWidget {
  const ProfileSectionList({required this.items, super.key});
  final List<ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: items);
  }
}
