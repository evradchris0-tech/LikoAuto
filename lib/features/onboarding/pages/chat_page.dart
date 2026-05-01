import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/onboarding_page_layout.dart';
import 'package:liko_auto/shared/widgets/chat/chat_bubble.dart';

/// Onboarding 4/4 — Le chat qui remplace le téléphone.
class ChatOnboardingPage extends StatelessWidget {
  const ChatOnboardingPage({
    required this.onStart,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      step: 4,
      totalSteps: 4,
      title: 'Le chat qui remplace le téléphone.',
      body:
          'Négociez le prix et planifiez vos rendez-vous physiques en toute sécurité via notre messagerie intégrée. Votre numéro personnel reste privé.',
      primaryLabel: 'Commencer',
      onPrimary: onStart,
      tertiaryLabel: 'Déjà un compte ? Se connecter',
      onTertiary: onLogin,
      visual: const _ChatVisual(),
    );
  }
}

class _ChatVisual extends StatelessWidget {
  const _ChatVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySoft,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          _ConversationCard(),
          AppSpacing.gapLg,
          const ChatBubble(
            side: ChatBubbleSide.received,
            message: 'Bonjour, le véhicule vous intéresse-t-il toujours ?',
          ),
          AppSpacing.gapSm,
          const ChatBubble(
            side: ChatBubbleSide.sent,
            message: "Oui, j'aimerais le voir. On peut fixer un rendez-vous ?",
          ),
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.rCard,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.trust,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendeur Certifié',
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'En ligne',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
