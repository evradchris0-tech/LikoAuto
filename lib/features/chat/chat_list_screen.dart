import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/chat/providers/chat_provider.dart';
import 'package:liko_auto/features/chat/widgets/chat_tile.dart';
import 'package:liko_auto/features/chat/widgets/filter_pill.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(chatThreadsProvider);
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.trust),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: Text(
            'Liko Auto',
            style: context.textStyles.headlineMedium?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11'),
              ),
            ),
          ],
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Messages',
                        style: context.textStyles.displaySmall?.copyWith(
                          color: AppColors.trust,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.errorSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '3 non lus',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: const Row(
                    children: [
                      FilterPill(label: 'Tous'),
                      AppSpacing.gapSm,
                      FilterPill(label: 'Voitures'),
                      AppSpacing.gapSm,
                      FilterPill(label: 'Garages'),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final thread = threads[index];
                    return ChatTile(thread: thread);
                  },
                  childCount: threads.length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
