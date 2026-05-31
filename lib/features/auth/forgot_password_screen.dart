import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailCtrl.text.trim();
    final confirmed = await _showBackendPreviewDialog(email);
    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(firebaseAuthProvider).sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'user-not-found' => 'Aucun compte associé à cet email.',
        'invalid-email' => "Format d'email invalide.",
        'network-request-failed' => 'Pas de connexion internet.',
        'too-many-requests' => 'Trop de demandes. Réessayez plus tard.',
        _ => "Erreur lors de l'envoi. Réessayez.",
      };
      _showErrorOrMockSent(msg, email);
    } on Object catch (_) {
      // Firebase non configuré → simulation
      if (!mounted) return;
      setState(() => _sent = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorOrMockSent(String msg, String email) {
    // Pour les erreurs réseau on simule quand même l'envoi
    if (msg.contains('connexion')) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              msg,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  Future<bool> _showBackendPreviewDialog(String email) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => _ForgotPasswordPreviewDialog(email: email),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.trust),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Liko Auto',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: _sent
          ? _SuccessBody(email: _emailCtrl.text.trim())
          : _FormBody(formKey: _formKey, emailCtrl: _emailCtrl),
      bottomNavigationBar: _sent
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: PrimaryButton(
                  label: 'Retour à la connexion',
                  icon: LucideIcons.arrowLeft,
                  onPressed: () => context.safePop(),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: PrimaryButton(
                  label: 'Envoyer le lien',
                  icon: LucideIcons.send,
                  isLoading: _isLoading,
                  onPressed: _handleSend,
                ),
              ),
            ),
    );
  }
}

// ── Corps formulaire ───────────────────────────────────────────────────────────

class _FormBody extends StatelessWidget {
  const _FormBody({required this.formKey, required this.emailCtrl});

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.gapLg,
            Text(
              'Mot de passe oublié',
              style: context.textStyles.displaySmall?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
            ),
            AppSpacing.gapMd,
            Text(
              "Entrez l'adresse email associée à votre compte. Nous vous enverrons un lien pour réinitialiser votre mot de passe.",
              style: context.textStyles.bodyLarge?.copyWith(
                color: AppColors.neutral,
                height: 1.5,
              ),
            ),
            AppSpacing.gapXl,
            Text(
              'ADRESSE EMAIL',
              style: context.textStyles.labelSmall?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            AppSpacing.gapSm,
            LikoTextField(
              controller: emailCtrl,
              hintText: 'votre@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                LucideIcons.mail,
                color: AppColors.neutral,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Champ requis';
                final re = RegExp(
                  r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$',
                  caseSensitive: false,
                );
                if (!re.hasMatch(v.trim())) return 'Email invalide';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── État de succès ─────────────────────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.mailCheck,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Email envoyé !',
            style: context.textStyles.headlineLarge?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: context.textStyles.bodyLarge?.copyWith(
                color: AppColors.neutral,
                height: 1.6,
              ),
              children: [
                const TextSpan(
                  text: 'Un lien de réinitialisation a été envoyé à\n',
                ),
                TextSpan(
                  text: email,
                  style: const TextStyle(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text: '\n\nVérifiez vos spams si vous ne le trouvez pas.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dialog preview backend ─────────────────────────────────────────────────────

class _ForgotPasswordPreviewDialog extends StatelessWidget {
  const _ForgotPasswordPreviewDialog({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.cloud,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Text(
              'Simulation Backend',
              style: TextStyle(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xs),
          const _Label('FIREBASE AUTH'),
          const _Row(method: 'POST', endpoint: 'sendPasswordResetEmail'),
          _Data(label: 'email', value: email),
          const SizedBox(height: AppSpacing.md),
          _Label('NESTJS ${AppConfig.baseUrl}'),
          const _Row(method: 'POST', endpoint: '/auth/password-reset'),
          _Data(label: 'email', value: email),
          const SizedBox(height: AppSpacing.md),
          const _Label('RÉPONSE ATTENDUE'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            child: const Text(
              '{ "message": "Reset email sent" }',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.trust,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.trustSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.info, size: 14, color: AppColors.trust),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Backend non disponible — envoi simulé localement.',
                    style: TextStyle(
                      color: AppColors.trust,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.neutral),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(LucideIcons.send, size: 16),
          label: const Text(
            'Envoyer le lien',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.neutral,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.method, required this.endpoint});
  final String method;
  final String endpoint;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            method,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            endpoint,
            style: const TextStyle(
              color: AppColors.trust,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class _Data extends StatelessWidget {
  const _Data({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 3),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.neutral,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.trust,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
