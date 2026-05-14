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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  int _selectedTab = 0; // 0 = Phone, 1 = Email
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // TODO(api): Restaurer l'auth Firebase (Phone OTP + Email/Password) une
  // fois que le backend NestJS est livré. Pour l'instant on accepte n'importe
  // quelle saisie et on set le flag `mockSignedIn` pour passer les guards.
  Future<void> _handleLogin() async {
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
            
            // Onglets de bascule
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 0
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : [],
                        ),
                        child: Text(
                          'Téléphone',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 0 ? AppColors.trust : AppColors.neutral,
                            fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 1
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : [],
                        ),
                        child: Text(
                          'Email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 1 ? AppColors.trust : AppColors.neutral,
                            fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,
            
            if (_selectedTab == 0) ...[
              LikoTextField(
                controller: _phoneController,
                hintText: 'Numéro de téléphone',
                keyboardType: TextInputType.phone,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🇨🇲 +237', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 24, color: AppColors.outline),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ] else ...[
              LikoTextField(
                controller: _emailController,
                hintText: 'Adresse email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.neutral),
              ),
              AppSpacing.gapLg,
              LikoTextField(
                controller: _passwordController,
                hintText: 'Mot de passe',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.neutral),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.neutral,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ],
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: 'Se connecter',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              AppSpacing.gapXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nouveau sur Liko Auto ? ', style: context.textStyles.bodyLarge?.copyWith(color: AppColors.trust)),
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
