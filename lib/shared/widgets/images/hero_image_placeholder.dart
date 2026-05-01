import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/branding/liko_logo.dart';

/// Placeholder visuel pour les zones où une vraie image est attendue
/// (photos véhicules, hero onboarding, carte du Cameroun…).
/// Affiche un dégradé Trust/Primary + le logo en filigrane + un libellé.
///
/// À remplacer par les vraies images quand le backend les fournira.
class HeroImagePlaceholder extends StatelessWidget {
  const HeroImagePlaceholder({
    this.label,
    this.icon,
    this.gradientColors,
    this.height,
    this.borderRadius,
    super.key,
  });

  final String? label;
  final IconData? icon;
  final List<Color>? gradientColors;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ??
        [AppColors.trust, AppColors.trust.withValues(alpha: 0.55)];

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.18,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: LikoLogo(size: (height ?? 200) * 0.6, rounded: false),
              ),
            ),
            if (icon != null || label != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  if (label != null) ...[
                    AppSpacing.gapSm,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        label!,
                        textAlign: TextAlign.center,
                        style: context.textStyles.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
