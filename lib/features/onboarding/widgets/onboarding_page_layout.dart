import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/step_indicator.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/buttons/tertiary_button.dart';

/// Squelette commun aux 4 pages onboarding :
/// - Bloc visuel haut (image/illustration)
/// - StepIndicator
/// - Titre H1
/// - Body
/// - Slot extra (features/stats/carte chat)
/// - Bouton primary + tertiaire
class OnboardingPageLayout extends StatelessWidget {
  const OnboardingPageLayout({
    required this.visual,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.tertiaryLabel,
    this.onTertiary,
    this.extra,
    super.key,
  });

  final Widget visual;
  final int step;
  final int totalSteps;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? tertiaryLabel;
  final VoidCallback? onTertiary;

  /// Bloc optionnel inséré entre le body et le bouton (features pills, stats…).
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                visual,
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StepIndicator(current: step, total: totalSteps),
                      AppSpacing.gapLg,
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: context.textStyles.headlineLarge?.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      AppSpacing.gapLg,
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      if (extra != null) ...[
                        AppSpacing.gapXl,
                        extra!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              PrimaryButton(
                label: primaryLabel,
                icon: Icons.arrow_forward_rounded,
                onPressed: onPrimary,
              ),
              if (tertiaryLabel != null) ...[
                AppSpacing.gapXs,
                TertiaryButton(
                  label: tertiaryLabel!,
                  onPressed: onTertiary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
