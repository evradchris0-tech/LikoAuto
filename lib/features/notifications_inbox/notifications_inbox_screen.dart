import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/notifications_inbox/domain/app_notification.dart';
import 'package:liko_auto/features/notifications_inbox/providers/notifications_inbox_provider.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsInboxProvider).valueOrNull ?? const [];
    final unread = items.where((n) => !n.isRead).length;
    final actions = ref.read(notificationsActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.trust),
          onPressed: () => context.safePop(),
        ),
        title: Row(
          children: [
            Text(
              'Notifications',
              style: context.textStyles.headlineMedium?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (items.isNotEmpty) ...[
            if (unread > 0)
              TextButton(
                onPressed: actions?.markAllRead,
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text(
                  'Tout lire',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            PopupMenuButton<String>(
              color: Colors.white,
              icon: const Icon(
                LucideIcons.moreVertical,
                color: AppColors.primary,
              ),
              onSelected: (v) async {
                if (v == 'clear') {
                  await _confirmClear(context, ref);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, color: AppColors.error),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        'Tout effacer',
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: items.isEmpty
          ? const _EmptyState()
          : AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final n = items[i];
                  return AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 300),
                    child: SlideAnimation(
                      verticalOffset: 20,
                      child: FadeInAnimation(
                        child: _NotificationTile(
                          notification: n,
                          onTap: () => _open(context, ref, n),
                          onDismiss: () => actions?.delete(n.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    await ref.read(notificationsActionsProvider)?.markRead(n.id);
    if (!context.mounted) return;
    final route = n.payload['route'] as String?;
    if (route != null) {
      await context.push<void>(route);
    } else {
      AppSnack.info(context, 'Aucun écran lié à cette notification.');
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer toutes les notifications ?'),
        content: const Text(
          'Toutes les notifications, lues et non lues, seront supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.neutral),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Tout effacer',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(notificationsActionsProvider)?.clearAll();
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final unread = !n.isRead;
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Effacer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(LucideIcons.trash2, color: Colors.white),
          ],
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: unread ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: n.type.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(n.type.icon, color: n.type.accent, size: 20),
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
                                n.title,
                                style: TextStyle(
                                  color: AppColors.trust,
                                  fontWeight: unread
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (unread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          n.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unread ? AppColors.trust : AppColors.neutral,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _relativeTime(n.createdAt),
                          style: const TextStyle(
                            color: AppColors.neutral,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return '${t.day.toString().padLeft(2, '0')}/'
        '${t.month.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bell,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.gapLg,
            Text(
              'Aucune notification.',
              style: context.textStyles.headlineSmall?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              'Vos messages, alertes de prix et rendez-vous '
              'apparaîtront ici.',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppColors.neutral,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
