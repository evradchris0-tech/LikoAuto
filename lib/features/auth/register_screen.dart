import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/api/api_exception.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = '+237${_phoneCtrl.text.trim()}';
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final payload = RegisterPayload(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      phone: phone,
      address: _addressCtrl.text.trim(),
      role: 'buyer', // Default role for standard users
    );

    setState(() => _isLoading = true);
    try {
      // Étape 1 Firebase + Étape 2 NestJS (non bloquant si backend indisponible).
      await ref
          .read(authRepositoryProvider)
          .registerWithBackend(email, password, payload);

      if (!mounted) return;
      context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      // Erreur Firebase réelle (email déjà utilisé, mot de passe faible…).
      if (!mounted) return;
      AppSnack.error(context, _firebaseMessage(e.code));
    } on ConflictException catch (e) {
      if (!mounted) return;
      AppSnack.error(context, e.message);
    } on NetworkException {
      // Pas de réseau → mock fallback pour la démo.
      if (!mounted) return;
      await ref.read(mockSignedInProvider.notifier).signIn();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnack.error(context, e.message);
    } on Object catch (_) {
      // Firebase non configuré en dev → mock fallback pour la démo.
      if (!mounted) return;
      await ref.read(mockSignedInProvider.notifier).signIn();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseMessage(String code) => switch (code) {
    'email-already-in-use' => 'Cet email est déjà utilisé.',
    'weak-password' => 'Mot de passe trop faible (6 caractères min).',
    'invalid-email' => "Format d'email invalide.",
    'network-request-failed' => 'Pas de connexion internet.',
    'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
    'operation-not-allowed' => 'Inscription par email désactivée.',
    _ => "Erreur d'inscription. Réessayez.",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          'Rejoignez Liko Auto',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.gapSm,
              Text(
                'Créez votre compte',
                style: context.textStyles.displaySmall?.copyWith(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w800,
                ),
              ),
              AppSpacing.gapXs,
              Text(
                'Bienvenue sur Liko Auto !',
                style: context.textStyles.bodyLarge?.copyWith(
                  color: AppColors.neutral,
                ),
              ),
              AppSpacing.gapXl,

              // ── Prénom ─────────────────────────────────────────────────────
              LikoTextField(
                controller: _firstNameCtrl,
                hintText: 'Prénom',
                prefixIcon: const Icon(
                  LucideIcons.user,
                  color: AppColors.neutral,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              AppSpacing.gapLg,

              // ── Nom de famille ─────────────────────────────────────────────
              LikoTextField(
                controller: _lastNameCtrl,
                hintText: 'Nom de famille',
                prefixIcon: const Icon(
                  LucideIcons.tag,
                  color: AppColors.neutral,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              AppSpacing.gapLg,

              // ── Téléphone ──────────────────────────────────────────────────
              LikoTextField(
                controller: _phoneCtrl,
                hintText: '6XXXXXXXX',
                keyboardType: TextInputType.phone,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    const Text(
                      '🇨🇲 +237',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.trust,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(width: 1, height: 20, color: AppColors.outline),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 8) return 'Numéro invalide';
                  return null;
                },
              ),
              AppSpacing.gapLg,

              // ── Email ──────────────────────────────────────────────────────
              LikoTextField(
                controller: _emailCtrl,
                hintText: 'Adresse email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  LucideIcons.mail,
                  color: AppColors.neutral,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final emailRe = RegExp(
                    r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$',
                    caseSensitive: false,
                  );
                  if (!emailRe.hasMatch(v.trim())) return 'Email invalide';
                  return null;
                },
              ),
              AppSpacing.gapLg,

              // ── Adresse ────────────────────────────────────────────────────
              LikoTextField(
                controller: _addressCtrl,
                hintText: 'Adresse',
                prefixIcon: const Icon(
                  LucideIcons.mapPin,
                  color: AppColors.neutral,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              AppSpacing.gapLg,

              // ── Mot de passe ───────────────────────────────────────────────
              LikoTextField(
                controller: _passwordCtrl,
                hintText: 'Créer un mot de passe',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(
                  LucideIcons.lock,
                  color: AppColors.neutral,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: AppColors.neutral,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (v.length < 6) return 'Minimum 6 caractères';
                  return null;
                },
              ),
              AppSpacing.gapXl,
            ],
          ),
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
                label: 'Créer mon compte',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              AppSpacing.gapMd,
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: context.textStyles.bodySmall?.copyWith(
                    color: AppColors.neutral,
                  ),
                  children: const [
                    TextSpan(text: 'En créant un compte, vous acceptez nos '),
                    TextSpan(
                      text: 'Conditions Générales',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.trust,
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              AppSpacing.gapMd,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pushReplacement(AppRoutes.login),
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
            ],
          ),
        ),
      ),
    );
  }
}
