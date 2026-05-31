import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/package_info_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  static const _supportPhone = '+237 6 99 12 34 56';
  static const _supportEmail = 'support@likoauto.cm';
  static const _supportWhatsApp = '+237699123456';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkg = ref.watch(packageInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.trust),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Aide & Support',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          const SizedBox(height: AppSpacing.lg),
          const _ContactCard(
            phone: _supportPhone,
            email: _supportEmail,
            whatsApp: _supportWhatsApp,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(label: 'QUESTIONS FRÉQUENTES'),
          for (final cat in _faqCategories) _FaqCategoryCard(category: cat),
          const SizedBox(height: AppSpacing.xl),

          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  'Liko Auto v${pkg.version} (Build ${pkg.buildNumber})',
                  style: context.textStyles.labelSmall?.copyWith(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Made in Cameroun · 2026',
                  style: context.textStyles.labelSmall?.copyWith(
                    color: AppColors.neutral,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.phone,
    required this.email,
    required this.whatsApp,
  });

  final String phone;
  final String email;
  final String whatsApp;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.trust, AppColors.trust.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.headphones, color: Colors.white),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notre équipe à votre écoute',
                      style: context.textStyles.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Lundi → Samedi · 8h–19h',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: LucideIcons.phone,
                  label: 'Appel',
                  onTap: () async {
                    final uri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        AppSnack.error(context, "Impossible de lancer l'appel");
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ContactButton(
                  icon: LucideIcons.messageCircle,
                  label: 'WhatsApp',
                  onTap: () async {
                    // Nettoyage du numéro WhatsApp (+237699123456 -> 237699123456)
                    final cleanPhone = whatsApp.replaceAll('+', '').replaceAll(' ', '');
                    final uri = Uri.parse('whatsapp://send?phone=$cleanPhone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        AppSnack.error(context, "WhatsApp n'est pas installé");
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ContactButton(
                  icon: LucideIcons.mail,
                  label: 'Email',
                  onTap: () async {
                    final uri = Uri.parse('mailto:$email');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        AppSnack.error(context, "Aucune application d'email trouvée");
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            color: AppColors.neutral,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

// ── FAQ ────────────────────────────────────────────────────────────────────

class _FaqEntry {
  const _FaqEntry(this.question, this.answer);
  final String question;
  final String answer;
}

class _FaqCategory {
  const _FaqCategory({
    required this.title,
    required this.icon,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final List<_FaqEntry> entries;
}

const _faqCategories = <_FaqCategory>[
  _FaqCategory(
    title: 'Compte & connexion',
    icon: LucideIcons.user,
    entries: [
      _FaqEntry(
        'Comment créer un compte ?',
        "Touchez « Créer un compte » sur l'écran de connexion. Vous pouvez vous "
            'inscrire via votre numéro de téléphone (recommandé au Cameroun) ou '
            'votre adresse email. La vérification se fait par SMS pour le téléphone, '
            'par email pour les comptes email.',
      ),
      _FaqEntry(
        "Je n'ai pas reçu mon SMS de vérification, que faire ?",
        'Vérifiez votre signal réseau, attendez 1 à 2 minutes, puis touchez '
            "« Renvoyer le code ». Si le problème persiste, contactez l'opérateur "
            'de votre carte SIM ou utilisez la connexion par email.',
      ),
      _FaqEntry(
        'Puis-je changer mon numéro de téléphone ?',
        "Cette fonctionnalité arrive bientôt. En attendant, contactez l'équipe "
            'support pour demander une migration manuelle de votre compte.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Acheter une voiture',
    icon: LucideIcons.shoppingCart,
    entries: [
      _FaqEntry(
        'Que signifie le badge VIN vérifié ?',
        "Le badge vert « VIN vérifié » garantit que le numéro d'identification "
            'du véhicule (17 caractères) est authentique et correspond bien au '
            "véhicule présenté. C'est notre engagement principal contre la fraude.",
      ),
      _FaqEntry(
        'Comment contacter un vendeur ?',
        "Sur la fiche d'une annonce, touchez « Contacter » pour démarrer une "
            "conversation chat. Votre numéro personnel reste privé jusqu'à ce "
            'que vous décidiez de le partager.',
      ),
      _FaqEntry(
        'Puis-je négocier le prix ?',
        "Oui. Si l'annonce affiche le badge orange « Négociable », le vendeur "
            'est ouvert à la discussion. Faites votre offre dans le chat. Sinon, '
            'le prix est ferme.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Vendre une voiture',
    icon: LucideIcons.tag,
    entries: [
      _FaqEntry(
        'Combien de photos dois-je ajouter ?',
        'Minimum 5 photos claires (extérieur, intérieur, moteur, tableau de bord, '
            'compteur kilométrique). Les annonces avec 8 photos ou plus se vendent '
            '3× plus vite. Maximum 21 photos.',
      ),
      _FaqEntry(
        'Pourquoi un VIN est-il demandé ?',
        'Le VIN active le badge « VIN vérifié » et augmente la confiance des '
            'acheteurs. Sans VIN, votre annonce reste publiable mais ne bénéficiera '
            'pas de ce gage de qualité. Le VIN se trouve sur la carte grise et '
            'sur le pare-brise côté conducteur.',
      ),
      _FaqEntry(
        'Mon annonce a été refusée, que faire ?',
        'Une raison précise vous est communiquée dans « Mes annonces ». Les '
            'causes les plus fréquentes : VIN illisible sur les photos, photos '
            'floues, prix incohérent. Modifiez puis re-soumettez.',
      ),
      _FaqEntry(
        'Comment booster mon annonce ?',
        'Le boost (à venir) place votre annonce en haut des résultats pendant '
            '7 jours et triple sa visibilité. Tarif : à partir de 5 000 FCFA.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Sécurité & paiements',
    icon: LucideIcons.shield,
    entries: [
      _FaqEntry(
        'Liko Auto gère-t-il les paiements ?',
        'Non. Les transactions se font en direct entre acheteur et vendeur, '
            "généralement en présence d'un garage partenaire pour la vérification. "
            'Nous ne stockons aucune information bancaire.',
      ),
      _FaqEntry(
        'Comment éviter les arnaques ?',
        'Vérifiez toujours le badge VIN, demandez la carte grise originale, '
            'inspectez le véhicule dans un garage certifié Liko Auto avant de '
            "payer, et ne versez jamais d'avance avant d'avoir vu la voiture.",
      ),
      _FaqEntry(
        'Que faire si je suspecte une fraude ?',
        'Contactez immédiatement notre support via WhatsApp ou téléphone. '
            'Nous bloquons le compte concerné sous 24h après vérification.',
      ),
    ],
  ),
];

class _FaqCategoryCard extends StatelessWidget {
  const _FaqCategoryCard({required this.category});

  final _FaqCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionPanelList.radio(
        elevation: 0,
        materialGapSize: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        dividerColor: AppColors.outline,
        children: [
          ...category.entries.asMap().entries.map((e) {
            final i = e.key;
            final faq = e.value;
            return ExpansionPanelRadio(
              value: '${category.title}_$i',
              backgroundColor: Colors.white,
              canTapOnHeader: true,
              headerBuilder: (_, isOpen) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    if (i == 0) ...[
                      Icon(category.icon, size: 18, color: AppColors.primary),
                      AppSpacing.gapSm,
                    ] else
                      const SizedBox(width: 26),
                    Expanded(
                      child: Text(
                        faq.question,
                        style: TextStyle(
                          color: AppColors.trust,
                          fontWeight: isOpen
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg + 26,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    faq.answer,
                    style: const TextStyle(
                      color: AppColors.neutral,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
