import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

class HomeFilterOption {
  const HomeFilterOption(this.label);
  final String label;
}

/// Barre horizontale de filtres rapides — un sélectionné, les autres outline.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<HomeFilterOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: options.length,
        separatorBuilder: (_, __) => AppSpacing.gapSm,
        itemBuilder: (context, i) => _Chip(
          label: options[i].label,
          selected: i == selectedIndex,
          onTap: () => onSelected(i),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.trust : Colors.white;
    final fg = selected ? Colors.white : AppColors.trust;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.trust : AppColors.primarySoft,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: context.textStyles.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
