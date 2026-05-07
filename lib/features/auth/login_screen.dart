import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
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

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      if (_selectedTab == 0) {
        // Phone Auth
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) return;
        
        await ref.read(authRepositoryProvider).verifyPhoneNumber(
          phoneNumber: phone.startsWith('+') ? phone : '+237$phone',
          onCodeSent: (verificationId) {
            if (mounted) {
              context.push('${AppRoutes.otpVerification}?phone=${Uri.encodeComponent(phone)}&verificationId=$verificationId');
            }
          },
          onError: (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.message}'), backgroundColor: AppColors.error));
            }
          },
        );
      } else {
        // Email Auth
        await ref.read(authRepositoryProvider).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) context.go(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.message}'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              'Connectez-vous pour accÃ©der Ã  vos annonces, messages et favoris.',
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
                          'TÃ©lÃ©phone',
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
                hintText: 'NumÃ©ro de tÃ©lÃ©phone',
                keyboardType: TextInputType.phone,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('ðŸ‡¨ðŸ‡² +237', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  'Mot de passe oubliÃ© ?',
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
                      'CrÃ©er un compte',
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
