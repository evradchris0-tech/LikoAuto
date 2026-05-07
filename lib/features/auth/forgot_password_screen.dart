import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
          'Liko Auto',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
            const LikoTextField(
              hintText: 'votre@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.neutral),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: PrimaryButton(
            label: 'Envoyer le lien',
            icon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
