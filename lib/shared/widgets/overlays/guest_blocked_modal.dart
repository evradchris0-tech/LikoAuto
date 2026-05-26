import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

/// Affiche la modale "invité bloqué" (wireframe 6.5) quand un utilisateur non
/// connecté tente une action réservée aux membres (contacter, favoris...).
Future<void> showGuestBlockedModal(
  BuildContext context, {
  required String actionLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _GuestBlockedSheet(actionLabel: actionLabel),
  );
}

class _GuestBlockedSheet extends StatelessWidget {
  const _GuestBlockedSheet({required this.actionLabel});

  final String actionLabel;

  static const _benefits = [
    (Icons.favorite_rounded, 'Sauvegarder vos favoris'),
    (Icons.chat_bubble_rounded, 'Contacter les vendeurs'),
    (Icons.notifications_rounded, 'Alertes prix en temps réel'),
    (Icons.sell_rounded, 'Déposer une annonce gratuitement'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Icône principale
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Connexion requise',
            style: TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pour "$actionLabel", vous devez être connecté.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.neutral,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Bénéfices
          ..._benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(b.$1, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    b.$2,
                    style: const TextStyle(
                      color: AppColors.trust,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // CTA primaire — Créer un compte
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.register);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Créer un compte gratuit',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // CTA secondaire — Se connecter
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.login);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.trust,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.outline, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Me connecter',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Continuer sans compte
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continuer sans compte',
              style: TextStyle(
                color: AppColors.neutral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
