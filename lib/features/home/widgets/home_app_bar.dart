import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/branding/liko_logo.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    required this.isScrolled,
    required this.city,
    required this.unreadNotifs,
    required this.onCityTap,
    required this.onNotifTap,
    super.key,
  });

  final bool isScrolled;
  final String city;
  final int unreadNotifs;
  final VoidCallback onCityTap;
  final VoidCallback onNotifTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: isScrolled
              ? [
                  BoxShadow(
                    color: AppColors.trust.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                // Menu button (fixed width)
                SizedBox(
                  width: 48,
                  child: IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(LucideIcons.menu, color: AppColors.trust),
                  ),
                ),
                // Logo (centered in available space)
                const Expanded(child: Center(child: LikoLogo.app())),
                // Actions (City + Notif)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        onTap: onCityTap,
                        borderRadius: BorderRadius.circular(999),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.mapPin,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                              Text(
                                city,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                              const Icon(
                                LucideIcons.chevronDown,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _NotifBell(count: unreadNotifs, onTap: onNotifTap),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifBell extends StatelessWidget {
  const _NotifBell({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.trust,
          iconSize: 24,
          tooltip: 'Notifications',
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 9,
              height: 9,
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
