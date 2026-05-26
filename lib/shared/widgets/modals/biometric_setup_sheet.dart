import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/biometric/data/biometric_repository.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';

/// Affiche une bottom sheet proposant d'activer la connexion biométrique.
/// À appeler juste après une connexion réussie si la biométrie est disponible
/// mais pas encore activée.
Future<void> showBiometricSetupSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _BiometricSetupSheet(ref: ref),
  );
}

class _BiometricSetupSheet extends StatelessWidget {
  const _BiometricSetupSheet({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.gapLg,
          const Text(
            'Connexion par empreinte',
            style: TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          AppSpacing.gapSm,
          const Text(
            'Activez la connexion biométrique pour accéder à votre compte plus rapidement sans ressaisir votre mot de passe.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.neutral,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          AppSpacing.gapXl,
          PrimaryButton(
            label: 'Activer l\'empreinte digitale',
            onPressed: () async {
              await ref
                  .read(biometricRepositoryProvider)
                  .setEnabled(value: true);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          AppSpacing.gapMd,
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.neutral),
            child: const Text(
              'Pas maintenant',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
