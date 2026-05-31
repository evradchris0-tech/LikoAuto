import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/api/api_exception.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/features/biometric/data/biometric_repository.dart';
import 'package:liko_auto/features/biometric/providers/biometric_provider.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';
import 'package:liko_auto/shared/widgets/modals/biometric_setup_sheet.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Biométrie ──────────────────────────────────────────────────────────────
  Future<void> _maybePromptBiometric() async {
    final bioRepo = ref.read(biometricRepositoryProvider);
    if (bioRepo.isEnabled) return;
    final available = await bioRepo.isAvailable();
    if (!mounted || !available) return;
    await showBiometricSetupSheet(context, ref);
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);
    try {
      final ok = await ref.read(biometricRepositoryProvider).authenticate();
      if (!mounted) return;
      if (ok) {
        final repo = ref.read(authRepositoryProvider);
        if (repo.currentUser != null) {
          // Session Firebase toujours active — l'empreinte déverrouille l'accès.
          await repo.fetchUserProfile();
        } else {
          // Pas de session Firebase (utilisateur déconnecté) — fallback mock dev.
          await ref.read(mockSignedInProvider.notifier).signIn();
        }
        if (!mounted) return;
        final from = GoRouterState.of(context).uri.queryParameters['from'];
        context.go(from ?? AppRoutes.home);
      } else {
        AppSnack.error(context, 'Empreinte non reconnue. Réessayez.');
      }
    } on Exception catch (_) {
      if (!mounted) return;
      AppSnack.error(context, 'Biométrie indisponible.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Connexion par email / mot de passe ─────────────────────────────────────
  Future<void> _handleEmailLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Montre le payload qui sera envoyé au backend avant toute action réseau.
    final confirmed = await _showBackendPreviewDialog();
    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      // Étape 1 — Firebase Auth (réel).
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Étape 2 — Profil NestJS (non bloquant si backend indisponible).
      await repo.fetchUserProfile();

      if (!mounted) return;
      await _maybePromptBiometric();
      if (!mounted) return;
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      context.go(from ?? AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      // Erreur Firebase réelle (mauvais identifiants, compte inexistant…).
      if (!mounted) return;
      AppSnack.error(context, _firebaseMessage(e.code));
    } on NetworkException {
      // Pas de réseau — on bascule sur le mock pour permettre la démo.
      if (!mounted) return;
      await ref.read(mockSignedInProvider.notifier).signIn();
      if (!mounted) return;
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      context.go(from ?? AppRoutes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnack.error(context, e.message);
    } on Object catch (_) {
      // Firebase non configuré en dev → mock fallback pour la démo.
      if (!mounted) return;
      await ref.read(mockSignedInProvider.notifier).signIn();
      if (!mounted) return;
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      context.go(from ?? AppRoutes.home);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseMessage(String code) => switch (code) {
    'user-not-found' => 'Aucun compte associé à cet email.',
    'wrong-password' ||
    'invalid-credential' => 'Email ou mot de passe incorrect.',
    'user-disabled' => 'Ce compte a été désactivé.',
    'invalid-email' => "Format d'email invalide.",
    'network-request-failed' => 'Pas de connexion internet.',
    'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
    _ => 'Erreur de connexion. Réessayez.',
  };

  /// Affiche un dialog récapitulant les données qui seraient envoyées au backend.
  /// Retourne `true` si l'utilisateur confirme la simulation.
  Future<bool> _showBackendPreviewDialog() async {
    final email = _emailController.text.trim();
    final maskedPwd = '•' * _passwordController.text.length.clamp(6, 12);

    return await showDialog<bool>(
          context: context,
          builder: (ctx) =>
              _BackendPreviewDialog(email: email, maskedPassword: maskedPwd),
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
          onPressed: () {
            if (context.canPop()) {
              context.safePop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Connexion',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.gapXl,
            Text(
              'Ravi de vous revoir !',
              style: context.textStyles.displaySmall?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              'Connectez-vous pour accéder à vos annonces, messages et favoris.',
              style: context.textStyles.bodyLarge?.copyWith(
                color: AppColors.neutral,
                height: 1.5,
              ),
            ),
            AppSpacing.gapXl,
            _EmailForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onForgotPassword: () => context.push(AppRoutes.forgotPassword),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: 'Se connecter',
                isLoading: _isLoading,
                onPressed: _handleEmailLogin,
              ),
              if (ref.watch(biometricEnabledProvider)) ...[
                AppSpacing.gapMd,
                _BiometricButton(onTap: _handleBiometricLogin),
              ],
              AppSpacing.gapLg,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nouveau sur Liko Auto ? ',
                    style: context.textStyles.bodyLarge?.copyWith(
                      color: AppColors.trust,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.pushReplacement(AppRoutes.register),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Créer un compte',
                          style: context.textStyles.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sous-widgets ───────────────────────────────────────────────────────────────

class _EmailForm extends StatelessWidget {
  const _EmailForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LikoTextField(
            controller: emailController,
            hintText: 'Adresse email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(LucideIcons.mail, color: AppColors.neutral),
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
          AppSpacing.gapLg,
          LikoTextField(
            controller: passwordController,
            hintText: 'Mot de passe',
            obscureText: obscurePassword,
            prefixIcon: const Icon(LucideIcons.lock, color: AppColors.neutral),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                color: AppColors.neutral,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BiometricButton extends StatelessWidget {
  const _BiometricButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fingerprint, color: AppColors.primary, size: 24),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Se connecter par empreinte',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dialog simulation backend ──────────────────────────────────────────────────

class _BackendPreviewDialog extends StatelessWidget {
  const _BackendPreviewDialog({
    required this.email,
    required this.maskedPassword,
  });

  final String email;
  final String maskedPassword;

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
          const _SectionLabel('ÉTAPE 1 — Firebase Auth'),
          const _PayloadRow(
            method: 'POST',
            endpoint: 'signInWithEmailAndPassword',
            color: AppColors.trust,
          ),
          _DataRow(label: 'email', value: email),
          _DataRow(label: 'password', value: maskedPassword),
          const SizedBox(height: AppSpacing.md),
          _SectionLabel('ÉTAPE 2 — NestJS ${AppConfig.baseUrl}'),
          const _PayloadRow(
            method: 'GET',
            endpoint: AppConfig.authMe,
            color: AppColors.primary,
          ),
          const _DataRow(
            label: 'Authorization',
            value: 'Bearer <firebase_id_token>',
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('RÉPONSE ATTENDUE'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            child: const Text(
              '{\n'
              '  "userId": "usr_001",\n'
              '  "email": "...",\n'
              '  "role": "buyer",\n'
              '  "firstName": "Demo",\n'
              '  "homeCountryCode": "CM"\n'
              '}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.trust,
                height: 1.6,
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
                    'Backend non disponible — connexion simulée localement.',
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
          icon: const Icon(LucideIcons.logIn, size: 16),
          label: const Text(
            'Simuler la connexion',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.neutral,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _PayloadRow extends StatelessWidget {
  const _PayloadRow({
    required this.method,
    required this.endpoint,
    required this.color,
  });

  final String method;
  final String endpoint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: TextStyle(
                color: color,
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
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}
