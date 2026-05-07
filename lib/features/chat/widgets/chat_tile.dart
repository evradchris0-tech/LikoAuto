import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/chat/domain/chat_thread.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({required this.thread, super.key});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '${AppRoutes.chatDetail}?id=${Uri.encodeComponent(thread.id)}',
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                _AvatarWidget(thread: thread),
                if (thread.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        thread.name,
                        style: context.textStyles.headlineSmall?.copyWith(
                          color: AppColors.trust,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      if (thread.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_outlined, size: 16, color: AppColors.trust),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.lastMessage,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: thread.unreadCount > 0 ? AppColors.trust : AppColors.neutral,
                      fontWeight: thread.unreadCount > 0 ? FontWeight.w700 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppSpacing.gapSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  thread.time,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: thread.unreadCount > 0 ? AppColors.primary : AppColors.neutral,
                    fontWeight: thread.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (thread.unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      thread.unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (thread.avatarAsset) color = Colors.blue;
    if (thread.avatarInitials != null) color = const Color(0xFFB4C4E8);
    if (thread.name == 'Motors Cameroun') color = Colors.black87;
    if (thread.name == 'Liko Auto Info') color = AppColors.trust;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color ?? AppColors.outline,
        shape: BoxShape.circle,
        image: thread.avatarUrl != null
            ? DecorationImage(image: NetworkImage(thread.avatarUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: thread.avatarInitials != null
          ? Text(thread.avatarInitials!, style: const TextStyle(color: AppColors.trust, fontWeight: FontWeight.bold, fontSize: 18))
          : thread.name == 'Liko Auto Info'
              ? const Icon(Icons.notifications_none, color: Colors.white)
              : thread.avatarAsset
                  ? const Icon(Icons.directions_car, color: Colors.white38)
                  : null,
    );
  }
}
