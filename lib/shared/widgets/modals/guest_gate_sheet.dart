import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Modale invité bloqué (wireframe 6.5).
/// Affichée quand un invité tente d'accéder à une action réservée.
///
/// Usage :
/// ```dart
/// GuestGateSheet.show(context, reason: 'Sauvegarder vos favoris');
/// ```
class GuestGateSheet extends StatelessWidget {
  const GuestGateSheet({required this.reason, super.key});

  final String reason;

  static Future<void> show(BuildContext context, {String? reason}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          GuestGateSheet(reason: reason ?? 'accéder à cette fonctionnalité'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.rBottomSheet,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AppSpacing.gapXl,
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.lock,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.gapLg,
              Text(
                'Connectez-vous pour continuer.',
                style: context.textStyles.headlineSmall?.copyWith(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapSm,
              Text(
                'Un compte gratuit vous permet de\n$reason.',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: AppColors.neutral,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapLg,
              const _BenefitRow(
                icon: LucideIcons.heart,
                label: 'Sauvegarder vos favoris',
              ),
              const _BenefitRow(
                icon: LucideIcons.messageSquare,
                label: 'Discuter avec les vendeurs',
              ),
              const _BenefitRow(
                icon: LucideIcons.bell,
                label: 'Recevoir des alertes prix',
              ),
              AppSpacing.gapXl,
              PrimaryButton(
                label: 'Créer un compte',
                onPressed: () {
                  context
                    ..pop()
                    ..push(AppRoutes.register);
                },
              ),
              AppSpacing.gapMd,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context
                      ..pop()
                      ..push(AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.trust,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: AppColors.outline,
                      width: 1.5,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.rButton,
                    ),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
              AppSpacing.gapSm,
              TextButton(
                onPressed: () => context.safePop(),
                style: TextButton.styleFrom(foregroundColor: AppColors.neutral),
                child: const Text('Continuer en invité'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.success),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
