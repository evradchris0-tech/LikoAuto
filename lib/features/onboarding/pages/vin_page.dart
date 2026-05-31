import 'package:flutter/material.dart';
import 'package:liko_auto/core/constants/app_assets.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/feature_pill.dart';
import 'package:liko_auto/features/onboarding/widgets/onboarding_page_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Onboarding 2/5 — La carte d'identité de votre véhicule (VIN).
class VinPage extends StatelessWidget {
  const VinPage({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      step: 2,
      totalSteps: 5,
      title: "La carte d'identité de votre véhicule.",
      body:
          "Le numéro VIN garantit l'authenticité et l'historique complet de chaque annonce.",
      primaryLabel: 'Continuer',
      onPrimary: onContinue,
      visual: const _VinVisual(),
      extra: const Column(
        children: [
          FeaturePill(
            icon: LucideIcons.shield,
            label: 'Protège acheteurs et vendeurs',
          ),
          AppSpacing.gapMd,
          FeaturePill(
            icon: LucideIcons.fingerprint,
            label: 'Révèle les duplicatas et fraudes',
          ),
          AppSpacing.gapMd,
          FeaturePill(icon: LucideIcons.scan, label: 'Un simple scan suffit'),
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
      height: 260,
      child: Stack(
        children: [
          // Image du véhicule
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Image.asset(AppAssets.carTucson, fit: BoxFit.cover),
            ),
          ),

          // Dégradé bas
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0D1F35).withValues(alpha: 0.85),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),

          // Carte VIN en bas
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.rButton,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.qrCode, color: AppColors.primary, size: 22),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hyundai Tucson · 2021',
                          style: TextStyle(
                            color: AppColors.trust,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'JT1DE12E806123489',
                          style: TextStyle(
                            color: AppColors.neutral,
                            fontFamily: 'monospace',
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.badgeCheck,
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
