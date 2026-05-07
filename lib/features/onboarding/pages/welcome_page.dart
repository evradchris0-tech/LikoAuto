import 'package:flutter/material.dart';
import 'package:liko_auto/core/constants/app_assets.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/onboarding_page_layout.dart';

/// Onboarding 1/4 â€” Bienvenue sur Liko Auto.
class WelcomePage extends StatelessWidget {
  const WelcomePage({
    required this.onContinue,
    super.key,
  });

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      step: 1,
      totalSteps: 4,
      title: 'La marketplace auto\nla plus fiable du Cameroun.',
      body: 'Achetez et vendez en toute confiance,\nde Douala Ã  YaoundÃ©.',
      primaryLabel: 'Commencer',
      onPrimary: onContinue,
      visual: const _WelcomeVisual(),
      extra: const Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.center,
        children: [
          _Bubble(icon: Icons.directions_car_rounded, label: '+ de 1000 VÃ©hicules'),
          _Bubble(icon: Icons.verified_user_rounded, label: 'Vendeurs VÃ©rifiÃ©s'),
          _Bubble(icon: Icons.support_agent_rounded, label: 'Support 24/7'),
        ],
      ),
    );
  }
}

class _WelcomeVisual extends StatelessWidget {
  const _WelcomeVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage(AppAssets.heroBanner),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Premium Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.4, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Chips en bas Ã  gauche
          const Positioned(
            left: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Chip(
                  icon: Icons.verified_rounded,
                  label: 'VÃ‰HICULE VÃ‰RIFIÃ‰',
                  background: AppColors.success,
                  foreground: Colors.white,
                ),
                SizedBox(height: 8),
                _Chip(
                  icon: Icons.workspace_premium_rounded,
                  label: 'SÃ‰LECTION PREMIUM',
                  background: Colors.white,
                  foreground: AppColors.primary,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
