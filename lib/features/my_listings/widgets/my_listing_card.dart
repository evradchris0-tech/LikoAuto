import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/my_listings/domain/my_listing.dart';

enum MyListingAction { edit, boost, pause, resume, markSold, delete }

class MyListingCard extends StatelessWidget {
  const MyListingCard({
    required this.listing,
    required this.onTap,
    required this.onAction,
    super.key,
  });

  final MyListing listing;
  final VoidCallback onTap;
  final ValueChanged<MyListingAction> onAction;

  @override
  Widget build(BuildContext context) {
    final card = listing.card;
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.rCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rCard,
            boxShadow: [
              BoxShadow(
                color: AppColors.trust.withValues(alpha: 0.05),
                blurRadius: 10,
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: ColoredBox(
                        color: AppColors.background,
                        child: Image.asset(card.imageAsset, fit: BoxFit.cover),
                      ),
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
                                card.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textStyles.bodyLarge?.copyWith(
                                  color: AppColors.trust,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _StatusPill(status: listing.status),
                          ],
                        ),
                        AppSpacing.gapXs,
                        Text(
                          card.priceFcfa.toFcfa(),
                          style: context.textStyles.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppSpacing.gapXs,
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColors.neutral,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                card.location,
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
                ],
              ),
              if (listing.rejectionReason != null) ...[
                AppSpacing.gapSm,
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      AppSpacing.gapXs,
                      Expanded(
                        child: Text(
                          listing.rejectionReason!,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              AppSpacing.gapMd,
              Row(
                children: [
                  _StatChip(
                    icon: Icons.remove_red_eye_outlined,
                    value: listing.views.toGroupedString(),
                    label: 'vues',
                  ),
                  AppSpacing.gapSm,
                  _StatChip(
                    icon: Icons.forum_outlined,
                    value: listing.contacts.toString(),
                    label: 'contacts',
                  ),
                  const Spacer(),
                  _ActionsMenu(
                    status: listing.status,
                    onSelected: onAction,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _style(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  static (Color, Color, IconData) _style(ListingStatus s) {
    switch (s) {
      case ListingStatus.active:
        return (AppColors.successSoft, AppColors.success, Icons.bolt_rounded);
      case ListingStatus.pending:
        return (
          AppColors.primarySoft,
          AppColors.primary,
          Icons.schedule_rounded,
        );
      case ListingStatus.sold:
        return (
          const Color(0xFFE3EAF3),
          AppColors.trust,
          Icons.verified_rounded,
        );
      case ListingStatus.rejected:
        return (
          AppColors.errorSoft,
          AppColors.error,
          Icons.error_outline_rounded,
        );
      case ListingStatus.paused:
        return (
          AppColors.outline,
          AppColors.trust,
          Icons.pause_circle_outline_rounded,
        );
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neutral),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({required this.status, required this.onSelected});

  final ListingStatus status;
  final ValueChanged<MyListingAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MyListingAction>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.trust),
      onSelected: onSelected,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.rCard),
      itemBuilder: (_) => [
        if (status == ListingStatus.active ||
            status == ListingStatus.paused ||
            status == ListingStatus.rejected)
          const PopupMenuItem(
            value: MyListingAction.edit,
            child: _ActionRow(
              icon: Icons.edit_outlined,
              label: 'Modifier',
            ),
          ),
        if (status == ListingStatus.active)
          const PopupMenuItem(
            value: MyListingAction.boost,
            child: _ActionRow(
              icon: Icons.rocket_launch_outlined,
              label: 'Booster',
              accent: true,
            ),
          ),
        if (status == ListingStatus.active)
          const PopupMenuItem(
            value: MyListingAction.pause,
            child: _ActionRow(
              icon: Icons.pause_circle_outline_rounded,
              label: 'Mettre en pause',
            ),
          ),
        if (status == ListingStatus.paused)
          const PopupMenuItem(
            value: MyListingAction.resume,
            child: _ActionRow(
              icon: Icons.play_circle_outline_rounded,
              label: 'Réactiver',
            ),
          ),
        if (status == ListingStatus.active || status == ListingStatus.paused)
          const PopupMenuItem(
            value: MyListingAction.markSold,
            child: _ActionRow(
              icon: Icons.verified_outlined,
              label: 'Marquer vendue',
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: MyListingAction.delete,
          child: _ActionRow(
            icon: Icons.delete_outline_rounded,
            label: 'Supprimer',
            destructive: true,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    this.destructive = false,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? AppColors.error
        : (accent ? AppColors.primary : AppColors.trust);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
