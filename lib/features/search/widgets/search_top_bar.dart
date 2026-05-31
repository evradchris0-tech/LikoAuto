import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Barre supérieure de la Recherche : champ de saisie + bouton filtres avec
/// indicateur du nombre de filtres actifs.
class SearchTopBar extends StatelessWidget {
  const SearchTopBar({
    required this.controller,
    required this.onFilterTap,
    required this.activeFilters,
    this.hint = 'Rechercher...',
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final int activeFilters;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.trustSoft,
                borderRadius: AppRadius.rButton,
              ),
              child: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: AppColors.trust,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: context.textStyles.bodyLarge?.copyWith(
                    color: AppColors.neutral,
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: AppColors.neutral,
                    size: 22,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          color: AppColors.neutral,
                          size: 18,
                        ),
                        onPressed: controller.clear,
                      );
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.trustSoft,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadius.rButton,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.rButton,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.rButton,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterButton(activeCount: activeFilters, onPressed: onFilterTap),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onPressed});

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.trust,
          borderRadius: AppRadius.rButton,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.rButton,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(LucideIcons.sliders, color: Colors.white, size: 22),
            ),
          ),
        ),
        if (activeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              constraints: const BoxConstraints(minWidth: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                '$activeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
