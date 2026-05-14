import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _selectedTab = 0; // 0: Acheteur, 1: Vendeur / Garage
  bool _obscurePassword = true;
  bool _isLoading = false;

  // TODO(api): Restaurer l'inscription Firebase quand le backend NestJS est
  // prêt. En attendant on accepte n'importe quelle saisie.
  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await ref.read(mockSignedInProvider.notifier).signIn();
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(AppRoutes.home);
  }

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
          'Rejoignez Liko Auto',
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
            // Segmented Control
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? AppColors.trust
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Acheteur',
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? Colors.white
                                : AppColors.trust,
                            fontWeight: _selectedTab == 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? AppColors.trust
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Vendeur / Garage',
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? Colors.white
                                : AppColors.trust,
                            fontWeight: _selectedTab == 1
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,

            // Fields
            if (_selectedTab == 1) ...[
              const LikoTextField(
                hintText: "Nom de l'entreprise ou du Garage",
              ),
              AppSpacing.gapLg,
            ],
            LikoTextField(
              hintText:
                  'Nom complet${_selectedTab == 1 ? " du contact" : ""}',
            ),
            AppSpacing.gapLg,
            LikoTextField(
              hintText:
                  'Adresse email${_selectedTab == 1 ? " professionnelle" : ""}',
              keyboardType: TextInputType.emailAddress,
            ),
            AppSpacing.gapLg,
            LikoTextField(
              hintText: 'Créer un mot de passe',
              obscureText: _obscurePassword,
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
                label: 'Créer mon compte',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              AppSpacing.gapLg,
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: context.textStyles.bodyMedium
                      ?.copyWith(color: AppColors.neutral),
                  children: const [
                    TextSpan(text: 'En créant un compte, vous acceptez nos '),
                    TextSpan(
                      text: 'CGU',
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
