import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/package_info_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.trust),
          onPressed: () => context.pop(),
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
          const _SectionLabel(label: 'AUTRES'),
          _Card(
            children: [
              _MenuTile(
                icon: Icons.bug_report_outlined,
                label: 'Signaler un bug',
                description: 'Décrivez ce qui ne fonctionne pas.',
                onTap: () => _reportBug(context, pkg.version),
              ),
              _MenuTile(
                icon: Icons.gavel_outlined,
                label: "Conditions d'utilisation",
                description: 'Règles de la marketplace.',
                onTap: () => _showLegalSheet(
                  context,
                  title: "Conditions d'utilisation",
                  body: _termsText,
                ),
              ),
              _MenuTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Politique de confidentialité',
                description: 'Comment nous traitons vos données.',
                onTap: () => _showLegalSheet(
                  context,
                  title: 'Politique de confidentialité',
                  body: _privacyText,
                ),
              ),
            ],
          ),
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
                const SizedBox(height: 4),
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

  void _reportBug(BuildContext context, String version) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signaler un bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Décrivez le problème rencontré (étapes, écran, message d\'erreur).',
              style: context.textStyles.bodySmall?.copyWith(
                color: AppColors.neutral,
              ),
            ),
            AppSpacing.gapMd,
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Quand je clique sur...',
                border: OutlineInputBorder(),
              ),
            ),
            AppSpacing.gapSm,
            Text(
              'Version : $version',
              style: context.textStyles.labelSmall?.copyWith(
                color: AppColors.neutral,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.neutral),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppSnack.success(context, 'Merci, votre rapport est bien noté.');
            },
            child: const Text(
              'Envoyer',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalSheet(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppSpacing.gapMd,
                Text(
                  title,
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    child: Text(
                      body,
                      style: context.textStyles.bodyMedium?.copyWith(
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
          colors: [
            AppColors.trust,
            AppColors.trust.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                ),
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
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  copyValue: whatsApp,
                  copyMessage: 'Numéro WhatsApp copié',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContactButton(
                  icon: Icons.phone_rounded,
                  label: 'Appeler',
                  copyValue: phone,
                  copyMessage: 'Numéro copié',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContactButton(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  copyValue: email,
                  copyMessage: 'Email copié',
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
    required this.copyValue,
    required this.copyMessage,
  });

  final IconData icon;
  final String label;
  final String copyValue;
  final String copyMessage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: copyValue));
          if (context.mounted) {
            AppSnack.info(context, '$copyMessage : $copyValue');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 6),
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
      child: Text(
        label,
        style: context.textStyles.labelSmall?.copyWith(
          color: AppColors.neutral,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, indent: 56, color: AppColors.outline),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: Icon(icon, color: AppColors.neutral),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.trust,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          description,
          style: const TextStyle(
            color: AppColors.neutral,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.outline,
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
    icon: Icons.person_outline_rounded,
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
    icon: Icons.shopping_cart_outlined,
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
            "est ouvert à la discussion. Faites votre offre dans le chat. Sinon, "
            'le prix est ferme.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Vendre une voiture',
    icon: Icons.sell_outlined,
    entries: [
      _FaqEntry(
        'Combien de photos dois-je ajouter ?',
        "Minimum 5 photos claires (extérieur, intérieur, moteur, tableau de bord, "
            'compteur kilométrique). Les annonces avec 8 photos ou plus se vendent '
            "3× plus vite. Maximum 21 photos.",
      ),
      _FaqEntry(
        'Pourquoi un VIN est-il demandé ?',
        "Le VIN active le badge « VIN vérifié » et augmente la confiance des "
            'acheteurs. Sans VIN, votre annonce reste publiable mais ne bénéficiera '
            "pas de ce gage de qualité. Le VIN se trouve sur la carte grise et "
            'sur le pare-brise côté conducteur.',
      ),
      _FaqEntry(
        'Mon annonce a été refusée, que faire ?',
        "Une raison précise vous est communiquée dans « Mes annonces ». Les "
            'causes les plus fréquentes : VIN illisible sur les photos, photos '
            "floues, prix incohérent. Modifiez puis re-soumettez.",
      ),
      _FaqEntry(
        'Comment booster mon annonce ?',
        'Le boost (à venir) place votre annonce en haut des résultats pendant '
            "7 jours et triple sa visibilité. Tarif : à partir de 5 000 FCFA.",
      ),
    ],
  ),
  _FaqCategory(
    title: 'Sécurité & paiements',
    icon: Icons.shield_outlined,
    entries: [
      _FaqEntry(
        'Liko Auto gère-t-il les paiements ?',
        'Non. Les transactions se font en direct entre acheteur et vendeur, '
            "généralement en présence d'un garage partenaire pour la vérification. "
            "Nous ne stockons aucune information bancaire.",
      ),
      _FaqEntry(
        'Comment éviter les arnaques ?',
        "Vérifiez toujours le badge VIN, demandez la carte grise originale, "
            'inspectez le véhicule dans un garage certifié Liko Auto avant de '
            "payer, et ne versez jamais d'avance avant d'avoir vu la voiture.",
      ),
      _FaqEntry(
        'Que faire si je suspecte une fraude ?',
        'Contactez immédiatement notre support via WhatsApp ou téléphone. '
            "Nous bloquons le compte concerné sous 24h après vérification.",
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
                      Icon(
                        category.icon,
                        size: 18,
                        color: AppColors.primary,
                      ),
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

// ── Légal ──────────────────────────────────────────────────────────────────

const _termsText =
    'Conditions d\'utilisation — Liko Auto\n\n'
    '1. Acceptation\n'
    "En utilisant l'application Liko Auto, vous acceptez les présentes "
    "conditions d'utilisation.\n\n"
    '2. Usage de la plateforme\n'
    'Liko Auto est une marketplace mettant en relation acheteurs et vendeurs '
    'de véhicules. Liko Auto n\'est pas partie aux transactions.\n\n'
    '3. Compte utilisateur\n'
    'Vous êtes responsable de la confidentialité de vos identifiants et de '
    'toute activité réalisée sous votre compte.\n\n'
    '4. Annonces\n'
    'Les annonces doivent être conformes à la loi camerounaise. Toute annonce '
    'frauduleuse, incomplète ou trompeuse sera retirée.\n\n'
    '5. Responsabilités\n'
    'Liko Auto ne garantit pas l\'exactitude des informations publiées par '
    'les utilisateurs. Les transactions sont effectuées sous la seule '
    'responsabilité des parties concernées.\n\n'
    '6. Modification\n'
    'Liko Auto se réserve le droit de modifier ces conditions à tout moment. '
    'Les modifications entrent en vigueur dès leur publication.\n\n'
    '7. Contact\n'
    'support@likoauto.cm';

const _privacyText =
    'Politique de confidentialité — Liko Auto\n\n'
    '1. Données collectées\n'
    'Nous collectons : votre numéro de téléphone, votre email (si fourni), '
    "votre nom affiché, votre photo de profil et l'historique de vos annonces "
    'et favoris.\n\n'
    '2. Finalité\n'
    'Ces données servent uniquement à fournir le service Liko Auto : '
    "authentification, mise en relation entre utilisateurs, statistiques d'usage "
    'agrégées et anonymisées.\n\n'
    '3. Stockage\n'
    'Vos données sont stockées sur des serveurs sécurisés en Europe '
    "(Firebase, Google Cloud) avec chiffrement au repos et en transit.\n\n"
    '4. Partage\n'
    'Nous ne vendons jamais vos données à des tiers. Le partage avec un '
    'autre utilisateur (via le chat) reste sous votre contrôle.\n\n'
    '5. Vos droits\n'
    'Vous pouvez à tout moment : consulter vos données, les modifier, '
    'demander leur suppression complète. Utilisez « Supprimer mon compte » '
    'dans les paramètres ou contactez support@likoauto.cm.\n\n'
    '6. Cookies & tracking\n'
    "L'application utilise Firebase Analytics et Crashlytics pour comprendre "
    "l'usage et corriger les bugs. Aucun tracker publicitaire tiers n'est utilisé.\n\n"
    '7. Contact DPO\n'
    'privacy@likoauto.cm';
