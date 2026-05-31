import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/chat/providers/chat_provider.dart';
import 'package:liko_auto/features/chat/widgets/chat_tile.dart';
import 'package:liko_auto/features/notifications_inbox/providers/notifications_inbox_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(chatThreadsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final unreadThreads = threads.where((t) => t.unreadCount > 0).length;

    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.menu, color: AppColors.trust),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Messages',
                style: context.textStyles.headlineMedium?.copyWith(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unreadThreads > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$unreadThreads',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          centerTitle: true,
          actions: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => context.push(AppRoutes.notificationsInbox),
                  icon: const Icon(LucideIcons.bell),
                  color: AppColors.trust,
                  iconSize: 26,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 12,
                    top: 12,
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
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 140),
            itemCount: threads.length,
            itemBuilder: (context, index) => ChatTile(thread: threads[index]),
          ),
        ),
      ],
    );
  }
}
