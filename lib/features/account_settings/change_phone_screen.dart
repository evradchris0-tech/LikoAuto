import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChangePhoneScreen extends ConsumerStatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  ConsumerState<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends ConsumerState<ChangePhoneScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final phone = _phoneCtrl.text.trim();

    if (phone.isEmpty || phone.length < 9) {
      AppSnack.error(context, 'Veuillez entrer un numéro de téléphone valide.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO(api): PATCH /users/me { phone: '+237$phone' }
      await Future<void>.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      AppSnack.success(context, 'Numéro mis à jour.');
      context.safePop();
    } on Exception catch (_) {
      if (!mounted) return;
      AppSnack.error(context, 'Erreur inattendue. Réessayez.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.trust),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Changer de numéro',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.gapSm,
            Text(
              'Saisissez votre nouveau numéro de téléphone. Il sera mis à jour sur votre profil.',
              style: context.textStyles.bodyLarge?.copyWith(
                color: AppColors.neutral,
                height: 1.5,
              ),
            ),
            AppSpacing.gapXl,
            LikoTextField(
              controller: _phoneCtrl,
              hintText: 'Nouveau numéro',
              keyboardType: TextInputType.phone,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🇨🇲 +237',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.trust,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(width: 1, height: 24, color: AppColors.outline),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ),
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
          child: PrimaryButton(
            label: 'Enregistrer le numéro',
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
        ),
      ),
    );
  }
}
