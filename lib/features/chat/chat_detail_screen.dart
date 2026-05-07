import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/chat/providers/chat_detail_provider.dart';
import 'package:liko_auto/features/chat/widgets/chat_bubble.dart';

class ChatDetailScreen extends ConsumerWidget {
  const ChatDetailScreen({required this.chatId, super.key});
  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider(chatId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.trust),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.directions_car, color: Colors.white38),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Garage Auto Plus',
                      style: context.textStyles.headlineSmall?.copyWith(
                        color: AppColors.trust,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_outlined, size: 14, color: AppColors.trust),
                  ],
                ),
                Text(
                  'En ligne',
                  style: context.textStyles.labelSmall?.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined, color: AppColors.trust), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: AppColors.trust), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Vehicle reference banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.directions_car, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toyota RAV4 2021',
                        style: context.textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '14 500 000 FCFA',
                        style: context.textStyles.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.neutral),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              reverse: true, // Start from bottom
              itemCount: messages.length + 1, // +1 for the date header
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
                    child: Center(
                      child: Text(
                        "Aujourd'hui",
                        style: TextStyle(color: AppColors.neutral, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                final message = messages[messages.length - 1 - index];
                return ChatBubble(message: message);
              },
            ),
          ),
          
          // Input Area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.neutral),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Écrire un message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          maxLines: null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
