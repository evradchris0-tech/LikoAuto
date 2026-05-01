import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/buttons/secondary_button.dart';

/// État vide affiché quand aucun résultat ne correspond aux filtres.
class EmptyResults extends StatelessWidget {
  const EmptyResults({
    required this.onReset,
    this.title = 'Aucun résultat',
    this.subtitle =
        "Essayez d'élargir votre recherche ou de modifier les filtres.",
    super.key,
  });

  final VoidCallback onReset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.gapLg,
          Text(
            title,
            style: context.textStyles.headlineMedium?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.gapSm,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium,
          ),
          AppSpacing.gapXl,
          SecondaryButton(
            label: 'Réinitialiser les filtres',
            icon: Icons.refresh_rounded,
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}
