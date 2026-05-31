import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/chat/domain/message_entity.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, super.key});
  final MessageEntity message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMe ? 16 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 16),
          ),
          border: message.isMe ? null : Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: message.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: context.textStyles.bodyMedium?.copyWith(
                color: message.isMe ? AppColors.trust : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    color: message.isMe
                        ? AppColors.trust.withValues(alpha: 0.6)
                        : AppColors.neutral,
                    fontSize: 12,
                  ),
                ),
                if (message.isMe) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    message.isRead ? LucideIcons.checkCheck : LucideIcons.check,
                    size: 12,
                    color: message.isRead
                        ? AppColors.trust
                        : AppColors.trust.withValues(alpha: 0.5),
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
