import 'package:flutter/material.dart';
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
      title: 'La marketplace auto\nla plus fiable du Cameroun.',
      body: 'Achetez et vendez en toute confiance,\nde Douala à Yaoundé.',
      primaryLabel: 'Commencer',
      onPrimary: onContinue,
      visual: const _WelcomeVisual(),
      extra: const StatsCard(
        items: [
          StatItem(value: '187', label: 'Véhicules'),
          StatItem(
            value: '92%',
            label: 'VIN vérifiés',
            valueColor: AppColors.success,
          ),
          StatItem(value: '48', label: 'Garages'),
        ],
      ),
    );
  }
}

class _WelcomeVisual extends StatelessWidget {
  const _WelcomeVisual();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Stack(
        children: [
          Positioned.fill(
            child: HeroImagePlaceholder(
              icon: Icons.directions_car_rounded,
              label: 'Toyota Land Cruiser · Douala',
            ),
          ),
          // Chips en bas à gauche
          Positioned(
            left: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Chip(
                  icon: Icons.verified_rounded,
                  label: 'VIN VÉRIFIÉ',
                  background: AppColors.success,
                  foreground: Colors.white,
                ),
                SizedBox(height: 6),
                _Chip(
                  icon: Icons.location_on_rounded,
                  label: 'DOUALA',
                  background: Colors.white,
                  foreground: AppColors.trust,
                ),
              ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
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
