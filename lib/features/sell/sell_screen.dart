import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';
import 'package:liko_auto/features/sell/providers/sell_step_provider.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_1_identifier.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_2_photos.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_3_details.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_4_price.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_5_summary.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

class SellScreen extends ConsumerWidget {
  const SellScreen({super.key});

  bool _isStepValid(int step, SellFormData form) {
    switch (step) {
      case 1:
        return form.isStep1Valid;
      case 2:
        return form.isStep2Valid;
      case 3:
        return form.isStep3Valid;
      case 4:
        return form.isStep4Valid;
      case 5:
        return form.isStep1Valid &&
            form.isStep2Valid &&
            form.isStep3Valid &&
            form.isStep4Valid;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(sellStepProvider);
    final totalSteps = ref.watch(sellTotalStepsProvider);
    final form = ref.watch(sellFormProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(sellStepProvider.notifier).state = 1;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.trust),
            onPressed: () => _confirmExit(context, ref),
          ),
          title: Text(
            'Déposer une annonce',
            style: context.textStyles.headlineSmall?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              backgroundColor: AppColors.outline.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Étape $currentStep sur $totalSteps',
                style: context.textStyles.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.gapSm,
              _buildCurrentStep(currentStep),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(
          context,
          ref,
          currentStep,
          totalSteps,
          isValid: _isStepValid(currentStep, form),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context, WidgetRef ref) async {
    final form = ref.read(sellFormProvider);
    final hasData = form.vin != null ||
        form.brand != null ||
        form.photos.isNotEmpty ||
        form.priceFcfa != null;
    if (!hasData) {
      _exit(context, ref);
      return;
    }
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandonner ?'),
        content: const Text(
          'Vos informations saisies seront perdues. Voulez-vous vraiment quitter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuer la saisie'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    if (shouldExit ?? false) {
      if (context.mounted) _exit(context, ref);
    }
  }

  void _exit(BuildContext context, WidgetRef ref) {
    ref.read(sellStepProvider.notifier).state = 1;
    ref.read(sellFormProvider.notifier).reset();
    context.pop();
  }

  Widget _buildCurrentStep(int step) {
    switch (step) {
      case 1:
        return const SellStep1Identifier();
      case 2:
        return const SellStep2Photos();
      case 3:
        return const SellStep3Details();
      case 4:
        return const SellStep4Price();
      case 5:
        return const SellStep5Summary();
      default:
        return const SellStep1Identifier();
    }
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    int currentStep,
    int totalSteps, {
    required bool isValid,
  }) {
    final isLast = currentStep == totalSteps;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (currentStep > 1) ...[
              OutlinedButton(
                onPressed: () =>
                    ref.read(sellStepProvider.notifier).state--,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: AppColors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.trust),
              ),
              AppSpacing.gapMd,
            ],
            Expanded(
              child: PrimaryButton(
                label: isLast ? "Publier l'annonce" : 'Continuer',
                onPressed: isValid
                    ? () {
                        if (isLast) {
                          _publish(context, ref);
                        } else {
                          ref.read(sellStepProvider.notifier).state++;
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _publish(BuildContext context, WidgetRef ref) {
    // TODO(api): brancher sur l'endpoint NestJS quand livré.
    AppSnack.success(context, 'Annonce publiée avec succès (mock).');
    _exit(context, ref);
  }
}
