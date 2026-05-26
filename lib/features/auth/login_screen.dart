import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/api/api_exception.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/features/biometric/data/biometric_repository.dart';
import 'package:liko_auto/features/biometric/providers/biometric_provider.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';
import 'package:liko_auto/shared/widgets/modals/biometric_setup_sheet.dart';

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

  void _showOAuthPlaceholder(String provider) {
    AppSnack.info(context, '$provider disponible après intégration backend.');
  }

  // ── Connexion par email / mot de passe ─────────────────────────────────────
  Future<void> _handleEmailLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await repo.fetchUserProfile();

      if (!mounted) return;
      await _maybePromptBiometric();
      if (!mounted) return;
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      context.go(from ?? AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      AppSnack.error(context, _firebaseMessage(e.code));
    } on NetworkException {
      if (!mounted) return;
      AppSnack.error(context, 'Pas de connexion internet.');
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnack.error(context, e.message);
    } on Object catch (_) {
      if (!mounted) return;
      AppSnack.error(context, 'Erreur inattendue. Réessayez.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseMessage(String code) => switch (code) {
        'user-not-found' => 'Aucun compte associé à cet email.',
        'wrong-password' || 'invalid-credential' =>
          'Email ou mot de passe incorrect.',
        'user-disabled' => 'Ce compte a été désactivé.',
        'invalid-email' => "Format d'email invalide.",
        'network-request-failed' => 'Pas de connexion internet.',
        'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
        _ => 'Erreur de connexion. Réessayez.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.trust),
          onPressed: () => context.pop(),
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
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OU CONTINUER AVEC',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: AppColors.neutral,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              AppSpacing.gapMd,
              Row(
                children: [
                  Expanded(
                    child: _OAuthButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata_rounded,
                      iconColor: const Color(0xFFEA4335),
                      onTap: () => _showOAuthPlaceholder('Google'),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: _OAuthButton(
                      label: 'Facebook',
                      icon: Icons.facebook_rounded,
                      iconColor: const Color(0xFF1877F2),
                      onTap: () => _showOAuthPlaceholder('Facebook'),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapLg,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nouveau sur Liko Auto ? ',
                    style: context.textStyles.bodyLarge
                        ?.copyWith(color: AppColors.trust),
                  ),
                  GestureDetector(
                    onTap: () => context.pushReplacement(AppRoutes.register),
                    child: Text(
                      'Créer un compte',
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
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
            prefixIcon:
                const Icon(Icons.email_outlined, color: AppColors.neutral),
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
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.neutral,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.neutral,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Champ requis' : null,
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

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w700,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 24),
          SizedBox(width: 8),
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
