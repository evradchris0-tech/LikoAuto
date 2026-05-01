import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

enum ChatBubbleSide { received, sent }

/// Bulle de message — rose pâle (received, à gauche) ou trust (sent, à droite).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.side,
    this.timeLabel,
    super.key,
  });

  final String message;
  final ChatBubbleSide side;
  final String? timeLabel;

  @override
  Widget build(BuildContext context) {
    final isReceived = side == ChatBubbleSide.received;
    final bg = isReceived ? AppColors.primarySoft : AppColors.trust;
    final fg = isReceived ? AppColors.trust : Colors.white;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isReceived ? 4 : 20),
      bottomRight: Radius.circular(isReceived ? 20 : 4),
    );

    return Row(
      mainAxisAlignment: isReceived
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: isReceived
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(color: bg, borderRadius: radius),
                child: Text(
                  message,
                  style: context.textStyles.bodyLarge?.copyWith(color: fg),
                ),
              ),
              if (timeLabel != null) ...[
                const SizedBox(height: 4),
                Text(timeLabel!, style: context.textStyles.bodySmall),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
