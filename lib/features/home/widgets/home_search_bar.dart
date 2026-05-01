import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

/// Header Home : icône menu (gauche) + barre de recherche rose pâle + cloche notif.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    this.onMenu,
    this.onSearch,
    this.onNotifications,
    this.unreadNotifications = 0,
    super.key,
  });

  final VoidCallback? onMenu;
  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded),
            color: AppColors.trust,
            tooltip: 'Menu',
          ),
          AppSpacing.gapSm,
          Expanded(
            child: GestureDetector(
              onTap: onSearch,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.rButton,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.neutral,
                      size: 22,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      'Rechercher...',
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.gapSm,
          _NotificationBell(
            unread: unreadNotifications,
            onPressed: onNotifications,
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unread, this.onPressed});
  final int unread;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.notifications_none_rounded),
          color: AppColors.trust,
          tooltip: 'Notifications',
        ),
        if (unread > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
