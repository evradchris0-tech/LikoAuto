import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/my_listings/domain/my_listing.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      color: AppColors.surface,
      borderRadius: AppRadius.rCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rCard,
            // Bordure dorée si boosté (wireframe 5.1)
            border: listing.isBoosted
                ? Border.all(color: AppColors.boost, width: 1.5)
                : null,
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
                    borderRadius: AppRadius.rButton,
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: ColoredBox(
                        color: AppColors.background,
                        child: CarImage(url: card.imageAsset),
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge BOOSTÉ (wireframe 5.1)
                        if (listing.isBoosted)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.boostSoft,
                              borderRadius: AppRadius.rXs,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.rocket,
                                  size: 11,
                                  color: AppColors.boost,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'BOOSTÉ',
                                  style: TextStyle(
                                    color: AppColors.boost,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              LucideIcons.mapPin,
                              size: 13,
                              color: AppColors.neutral,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
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
                        LucideIcons.alertCircle,
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
                    icon: LucideIcons.eye,
                    value: listing.views.toGroupedString(),
                    label: 'vues',
                  ),
                  AppSpacing.gapSm,
                  _StatChip(
                    icon: LucideIcons.messageSquare,
                    value: listing.contacts.toString(),
                    label: 'contacts',
                  ),
                  const Spacer(),
                  _ActionsMenu(status: listing.status, onSelected: onAction),
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
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
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
      case ListingStatus.draft:
        return (AppColors.outline, AppColors.neutral, LucideIcons.fileEdit);
      case ListingStatus.active:
        return (AppColors.successSoft, AppColors.success, LucideIcons.zap);
      case ListingStatus.pending:
        return (AppColors.primarySoft, AppColors.primary, LucideIcons.clock);
      case ListingStatus.sold:
        return (AppColors.trustSoft, AppColors.trust, LucideIcons.badgeCheck);
      case ListingStatus.rejected:
        return (AppColors.errorSoft, AppColors.error, LucideIcons.alertCircle);
      case ListingStatus.paused:
        return (AppColors.outline, AppColors.trust, LucideIcons.pauseCircle);
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
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral,
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
      color: Colors.white,
      icon: const Icon(LucideIcons.moreVertical, color: AppColors.primary),
      onSelected: onSelected,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.rCard),
      itemBuilder: (_) => [
        if (status == ListingStatus.active ||
            status == ListingStatus.paused ||
            status == ListingStatus.rejected)
          const PopupMenuItem(
            value: MyListingAction.edit,
            child: _ActionRow(icon: LucideIcons.edit2, label: 'Modifier'),
          ),
        if (status == ListingStatus.active)
          const PopupMenuItem(
            value: MyListingAction.boost,
            child: _ActionRow(
              icon: LucideIcons.rocket,
              label: 'Booster',
              accent: true,
            ),
          ),
        if (status == ListingStatus.active)
          const PopupMenuItem(
            value: MyListingAction.pause,
            child: _ActionRow(
              icon: LucideIcons.pauseCircle,
              label: 'Mettre en pause',
            ),
          ),
        if (status == ListingStatus.paused)
          const PopupMenuItem(
            value: MyListingAction.resume,
            child: _ActionRow(icon: LucideIcons.playCircle, label: 'Réactiver'),
          ),
        if (status == ListingStatus.active || status == ListingStatus.paused)
          const PopupMenuItem(
            value: MyListingAction.markSold,
            child: _ActionRow(
              icon: LucideIcons.badgeCheck,
              label: 'Marquer vendue',
            ),
          ),
        const PopupMenuDivider(color: AppColors.outline),
        const PopupMenuItem(
          value: MyListingAction.delete,
          child: _ActionRow(
            icon: LucideIcons.trash2,
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
        : AppColors.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
