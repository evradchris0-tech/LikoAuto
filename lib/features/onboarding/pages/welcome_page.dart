import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/onboarding_page_layout.dart';
import 'package:liko_auto/features/onboarding/widgets/stats_card.dart';
import 'package:liko_auto/shared/widgets/images/hero_image_placeholder.dart';

/// Onboarding 1/4 — Bienvenue sur Liko Auto.
class WelcomePage extends StatelessWidget {
  const WelcomePage({
    required this.onContinue,
    required this.onSkip,
    super.key,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      step: 1,
      totalSteps: 4,
      title: 'Bienvenue sur Liko Auto.',
      body:
          'La marketplace de voitures la plus fiable du Cameroun — de Douala à Yaoundé.',
      primaryLabel: 'Continuer',
      onPrimary: onContinue,
      tertiaryLabel: "Passer l'introduction",
      onTertiary: onSkip,
      visual: _WelcomeVisual(onSkip: onSkip),
      extra: const StatsCard(
        items: [
          StatItem(value: '187', label: 'Véhicules en ligne'),
          StatItem(
            value: '92%',
            label: 'VIN vérifiés',
            valueColor: AppColors.success,
          ),
          StatItem(value: '48', label: 'Garages partenaires'),
        ],
      ),
    );
  }
}

class _WelcomeVisual extends StatelessWidget {
  const _WelcomeVisual({required this.onSkip});
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          const Positioned.fill(
            child: HeroImagePlaceholder(
              icon: Icons.directions_car_rounded,
              label: 'Toyota Land Cruiser · Douala',
            ),
          ),
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Chip(
                  icon: Icons.verified_rounded,
                  label: 'VIN VÉRIFIÉ',
                  background: AppColors.success,
                  foreground: Colors.white,
                ),
                AppSpacing.gapSm,
                _Chip(
                  icon: Icons.location_on_rounded,
                  label: 'DOUALA',
                  background: Colors.white,
                  foreground: AppColors.trust,
                ),
              ],
            ),
          ),
          Positioned(
            top: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSkip,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    'Passer',
                    style: context.textStyles.labelMedium?.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: foreground,
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
