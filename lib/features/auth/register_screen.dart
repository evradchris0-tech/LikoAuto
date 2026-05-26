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
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';

enum _UserRole { particulier, concessionnaire }

extension _UserRoleX on _UserRole {
  String get label => switch (this) {
        _UserRole.particulier => 'Particulier',
        _UserRole.concessionnaire => 'Concessionnaire',
      };

  String get subtitle => switch (this) {
        _UserRole.particulier => 'Achat & vente personnelle',
        _UserRole.concessionnaire => "Professionnel de l'auto",
      };

  IconData get icon => switch (this) {
        _UserRole.particulier => Icons.person_rounded,
        _UserRole.concessionnaire => Icons.storefront_rounded,
      };

  String get backendRole => switch (this) {
        _UserRole.particulier => 'seller',
        _UserRole.concessionnaire => 'garage_owner',
      };
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  _UserRole _selectedRole = _UserRole.particulier;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final phone = '+237${_phoneCtrl.text.trim()}';
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;

      final payload = RegisterPayload(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: phone,
        role: _selectedRole.backendRole,
        companyName: _selectedRole == _UserRole.concessionnaire
            ? _companyCtrl.text.trim()
            : null,
      );

      await ref
          .read(authRepositoryProvider)
          .registerWithBackend(email, password, payload);

      if (!mounted) return;
      context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      AppSnack.error(context, _firebaseMessage(e.code));
    } on ConflictException catch (e) {
      if (!mounted) return;
      AppSnack.error(context, e.message);
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
          icon: const Icon(Icons.arrow_back, color: AppColors.trust),
          onPressed: () => context.pop(),
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
                'Choisissez votre profil pour démarrer.',
                style: context.textStyles.bodyLarge
                    ?.copyWith(color: AppColors.neutral),
              ),
              AppSpacing.gapXl,

              // ── Sélecteur de rôle ──────────────────────────────────────────
              Row(
                children: _UserRole.values.map((role) {
                  final isSelected = _selectedRole == role;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: role == _UserRole.particulier ? AppSpacing.sm : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = role),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.trust : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.trust
                                  : AppColors.outline,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.trust
                                          .withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : AppColors.primarySoft,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  role.icon,
                                  size: 26,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                role.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.trust,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                role.subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : AppColors.neutral,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.gapXl,

              // ── Société (concessionnaire uniquement) ───────────────────────
              if (_selectedRole == _UserRole.concessionnaire) ...[
                LikoTextField(
                  controller: _companyCtrl,
                  hintText: 'Nom du garage / concession',
                  prefixIcon: const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.neutral,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                ),
                AppSpacing.gapLg,
              ],

              // ── Prénom ─────────────────────────────────────────────────────
              LikoTextField(
                controller: _firstNameCtrl,
                hintText: _selectedRole == _UserRole.concessionnaire
                    ? 'Prénom du responsable'
                    : 'Prénom',
                prefixIcon: const Icon(
                  Icons.person_outline,
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
                hintText: _selectedRole == _UserRole.concessionnaire
                    ? 'Nom du responsable'
                    : 'Nom de famille',
                prefixIcon: const Icon(
                  Icons.badge_outlined,
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
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🇨🇲 +237',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 24, color: AppColors.outline),
                      const SizedBox(width: 8),
                    ],
                  ),
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
                  Icons.email_outlined,
                  color: AppColors.neutral,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$',
                      caseSensitive: false);
                  if (!emailRe.hasMatch(v.trim())) return 'Email invalide';
                  return null;
                },
              ),
              AppSpacing.gapLg,

              // ── Mot de passe ───────────────────────────────────────────────
              LikoTextField(
                controller: _passwordCtrl,
                hintText: 'Créer un mot de passe',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.neutral,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
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
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: AppColors.neutral),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà un compte ? ',
                    style: context.textStyles.bodyLarge
                        ?.copyWith(color: AppColors.trust),
                  ),
                  GestureDetector(
                    onTap: () => context.pushReplacement(AppRoutes.login),
                    child: Text(
                      'Se connecter',
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
