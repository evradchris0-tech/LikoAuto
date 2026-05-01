import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/onboarding_page_layout.dart';
import 'package:liko_auto/shared/widgets/images/hero_image_placeholder.dart';

/// Onboarding 3/4 — Trouvez le bon garage en un clic.
class GaragesPage extends StatelessWidget {
  const GaragesPage({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      step: 3,
      totalSteps: 4,
      title: 'Trouvez le bon garage en un clic.',
      body:
          'Fini les devinettes. Accédez directement aux meilleurs spécialistes de votre quartier pour l\'entretien et la réparation.',
      primaryLabel: 'Continuer',
      onPrimary: onContinue,
      visual: const _GaragesVisual(),
      extra: const _GaragesStatsCard(),
    );
  }
}

class _GaragesVisual extends StatelessWidget {
  const _GaragesVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          Positioned.fill(
            child: HeroImagePlaceholder(
              icon: Icons.map_rounded,
              label: 'Cameroun · Douala / Yaoundé / Bafoussam',
              gradientColors: const [Color(0xFFCFD7DD), Color(0xFFE8EEF1)],
            ),
          ),
          // Pins simulés
          const Positioned(top: 80, left: 110, child: _Pin()),
          const Positioned(top: 120, left: 210, child: _Pin(filled: false)),
          const Positioned(top: 170, left: 150, child: _Pin()),
          const Positioned(top: 210, left: 250, child: _Pin(filled: false)),
          // Specialty chips en bas du visuel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _SpecialtyChip(
                    icon: Icons.verified_rounded,
                    label: 'SPÉCIALISTES TOYOTA',
                    selected: true,
                  ),
                  _SpecialtyChip(label: 'MERCEDES'),
                  _SpecialtyChip(label: 'BMW'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({this.filled = true});
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on_rounded,
      color: filled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.45),
      size: filled ? 32 : 24,
      shadows: const [
        Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 2)),
      ],
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label, this.icon, this.selected = false});

  final String label;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaragesStatsCard extends StatelessWidget {
  const _GaragesStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.rCard,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.handyman_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '48 garages certifiés.',
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Vérifiés, notés, géolocalisés.',
                  style: context.textStyles.bodyMedium,
                ),
              ],
            ),
          ),
          AppSpacing.gapSm,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '4,7',
                  style: context.textStyles.labelMedium?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
