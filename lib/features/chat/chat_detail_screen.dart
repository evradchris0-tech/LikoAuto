import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/chat/providers/chat_detail_provider.dart';
import 'package:liko_auto/features/chat/providers/moderation_provider.dart';
import 'package:liko_auto/features/chat/widgets/chat_bubble.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatDetailScreen extends ConsumerWidget {
  const ChatDetailScreen({required this.chatId, super.key});
  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider(chatId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.trust),
          onPressed: () => context.safePop(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car_outlined,
                    color: AppColors.primary,
                  ),
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
            const SizedBox(width: AppSpacing.md),
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
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      LucideIcons.badgeCheck,
                      size: 14,
                      color: AppColors.trust,
                    ),
                  ],
                ),
                Text(
                  'En ligne',
                  style: context.textStyles.labelSmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [_ChatMenu(chatId: chatId, ref: ref)],
      ),
      body: Column(
        children: [
          // Vehicle reference banner
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: AppRadius.rXs,
                  ),
                  child: const Icon(
                    Icons.directions_car_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toyota RAV4 2021',
                        style: context.textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '14 500 000 FCFA',
                        style: context.textStyles.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: AppColors.neutral),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              reverse: true, // Start from bottom
              itemCount: messages.length + 1, // +1 for the date header
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(
                      top: AppSpacing.xl,
                      bottom: AppSpacing.sm,
                    ),
                    child: Center(
                      child: Text(
                        "Aujourd'hui",
                        style: TextStyle(
                          color: AppColors.neutral,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.camera,
                        color: AppColors.neutral,
                      ),
                      onPressed: () =>
                          AppSnack.info(context, 'Ajout de photo (Sprint 5)'),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Écrire un message...',
                          hintStyle: const TextStyle(color: AppColors.neutral),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.bottomSheet,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.outline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.bottomSheet,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.bottomSheet,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          LucideIcons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => AppSnack.info(
                          context,
                          'Envoi de message (Sprint 5)',
                        ),
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

enum _ChatAction { mute, unmute, block, report }

class _ChatMenu extends ConsumerWidget {
  const _ChatMenu({required this.chatId, required this.ref});
  final String chatId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final muted = ref.watch(mutedThreadsProvider).valueOrNull ?? const {};
    final isMuted = muted.contains(chatId);
    return PopupMenuButton<_ChatAction>(
      icon: const Icon(LucideIcons.moreVertical, color: AppColors.primary),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (a) => _handle(context, a),
      itemBuilder: (_) => [
        if (isMuted)
          const PopupMenuItem(
            value: _ChatAction.unmute,
            child: Row(
              children: [
                Icon(LucideIcons.bellRing, color: AppColors.primary),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Réactiver les notifications',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          const PopupMenuItem(
            value: _ChatAction.mute,
            child: Row(
              children: [
                Icon(LucideIcons.bellOff, color: AppColors.primary),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Couper les notifications',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const PopupMenuDivider(color: AppColors.outline),
        const PopupMenuItem(
          value: _ChatAction.block,
          child: Row(
            children: [
              Icon(Icons.block, color: AppColors.error),
              SizedBox(width: AppSpacing.md),
              Text(
                "Bloquer l'utilisateur",
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _ChatAction.report,
          child: Row(
            children: [
              Icon(LucideIcons.flag, color: AppColors.error),
              SizedBox(width: AppSpacing.md),
              Text(
                'Signaler la conversation',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handle(BuildContext context, _ChatAction action) async {
    final mod = ref.read(moderationActionsProvider);
    switch (action) {
      case _ChatAction.mute:
        await mod.muteThread(chatId);
        if (context.mounted) {
          AppSnack.info(context, 'Notifications coupées pour ce chat.');
        }
        return;
      case _ChatAction.unmute:
        await mod.unmuteThread(chatId);
        if (context.mounted) {
          AppSnack.success(context, 'Notifications réactivées.');
        }
        return;
      case _ChatAction.block:
        final ok = await _confirm(
          context,
          title: 'Bloquer cet utilisateur ?',
          body:
              'Vous ne recevrez plus ses messages. Vous pouvez le '
              'débloquer à tout moment depuis les paramètres.',
          confirmLabel: 'Bloquer',
        );
        if (ok && context.mounted) {
          await mod.blockUser(chatId);
          if (context.mounted) {
            AppSnack.error(context, 'Utilisateur bloqué.');
            context.safePop();
          }
        }
        return;
      case _ChatAction.report:
        AppSnack.success(context, 'Conversation signalée. Merci.');
        return;
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
  }) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
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
            child: Text(
              confirmLabel,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return r ?? false;
  }
}
