import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/features/chat/providers/chat_provider.dart';

class FilterPill extends ConsumerWidget {
  const FilterPill({required this.label, super.key});
  
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(chatFilterProvider);
    final isSelected = selectedFilter == label;
    
    return GestureDetector(
      onTap: () => ref.read(chatFilterProvider.notifier).state = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.trust : AppColors.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: context.textStyles.labelMedium?.copyWith(
            color: isSelected ? Colors.white : AppColors.trust,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
