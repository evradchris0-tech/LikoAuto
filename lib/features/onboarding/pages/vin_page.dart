import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/feature_pill.dart';
import 'package:liko_auto/features/onboarding/widgets/onboarding_page_layout.dart';
import 'package:liko_auto/shared/widgets/images/hero_image_placeholder.dart';

/// Onboarding 2/4 — La carte d'identité de votre véhicule (VIN).
class VinPage extends StatelessWidget {
  const VinPage({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      step: 2,
      totalSteps: 4,
      title: "La carte d'identité de votre véhicule.",
      body:
          "Le numéro d'identification du véhicule (VIN) garantit l'authenticité et l'historique complet de chaque annonce.",
      primaryLabel: 'Continuer',
      onPrimary: onContinue,
      visual: const _VinVisual(),
      extra: const Column(
        children: [
          FeaturePill(
            icon: Icons.shield_outlined,
            label: 'Protège acheteurs et vendeurs',
          ),
          AppSpacing.gapMd,
          FeaturePill(
            icon: Icons.fingerprint_rounded,
            label: 'Révèle les duplicatas et fraudes',
          ),
          AppSpacing.gapMd,
          FeaturePill(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Un simple scan suffit',
          ),
        ],
      ),
    );
  }
}

class _VinVisual extends StatelessWidget {
  const _VinVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          const Positioned.fill(
            child: HeroImagePlaceholder(
              icon: Icons.local_shipping_rounded,
              label: 'Toyota Hilux',
              gradientColors: [Color(0xFF12253D), Color(0xFF1A3553)],
            ),
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.xl,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.rButton,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Text(
                      'JT1DE12E806123489',
                      style: context.textStyles.labelLarge?.copyWith(
                        color: AppColors.trust,
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
