import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/api/api_exception.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/user_session_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/domain/user_session.dart';
import 'package:liko_auto/features/listings/data/listings_repository.dart';
import 'package:liko_auto/features/listings/domain/api_listing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';
import 'package:liko_auto/features/sell/providers/sell_step_provider.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_1_identifier.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_2_photos.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_3_details.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_4_price.dart';
import 'package:liko_auto/features/sell/widgets/sell_step_5_summary.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  bool _canPop = false;

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
  Widget build(BuildContext context) {
    final currentStep = ref.watch(sellStepProvider);
    final totalSteps = ref.watch(sellTotalStepsProvider);
    final form = ref.watch(sellFormProvider);

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExit(context, ref);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.trust),
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
    final hasData =
        form.vin != null ||
        form.brand != null ||
        form.photos.isNotEmpty ||
        form.priceFcfa != null;
    if (!hasData) {
      _exit(context, ref);
      return;
    }
    // Wireframe 6.9 — 3 options
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Votre progression sera perdue si vous quittez sans sauvegarder.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.neutral, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Option 1 — Enregistrer un brouillon
            _ExitOption(
              icon: LucideIcons.save,
              label: 'Enregistrer un brouillon',
              subtitle: 'Reprendre plus tard',
              color: AppColors.trust,
              onTap: () {
                Navigator.pop(ctx);
                AppSnack.info(
                  context,
                  'Brouillon sauvegardé.',
                  actionLabel: 'Voir',
                  onAction: () {
                    ref.read(goRouterProvider).push(AppRoutes.myListings);
                  },
                );
                _exit(context, ref);
              },
            ),
            const SizedBox(height: 10),
            // Option 2 — Quitter sans sauvegarder
            _ExitOption(
              icon: LucideIcons.trash2,
              label: 'Quitter sans sauvegarder',
              subtitle: 'Les informations saisies seront perdues',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(ctx);
                _exit(context, ref);
              },
            ),
            const SizedBox(height: 10),
            // Option 3 — Annuler
            _ExitOption(
              icon: LucideIcons.edit2,
              label: 'Continuer la saisie',
              subtitle: 'Rester sur le formulaire',
              color: AppColors.neutral,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _exit(BuildContext context, WidgetRef ref) {
    ref.read(sellStepProvider.notifier).state = 1;
    ref.read(sellFormProvider.notifier).reset();
    setState(() => _canPop = true);
    Future.microtask(() {
      if (context.mounted) context.safePop();
    });
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
                onPressed: () => ref.read(sellStepProvider.notifier).state--,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: AppColors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  color: AppColors.trust,
                ),
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

  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    final form = ref.read(sellFormProvider);
    final session = ref.read(userSessionProvider).valueOrNull;

    if (session is! AuthenticatedSession) {
      AppSnack.error(
        context,
        'Vous devez être connecté pour publier.',
        actionLabel: 'Se connecter',
        onAction: () => context.push(AppRoutes.login),
      );
      return;
    }

    // cityId / countryId : à remplacer quand la sélection ville est ajoutée au form.
    final cityId = form.cityId ?? 1; // Douala par défaut
    const countryId = 1; // Cameroun par défaut

    final title = [
      form.brand,
      form.model,
      form.year?.toString(),
    ].whereType<String>().join(' ');

    final vehicle = CreateVehicleRequest(
      modelId: form.modelId ?? 0,
      year: form.year ?? DateTime.now().year,
      condition: form.condition ?? VehicleCondition.locallyUsed,
      mileage: form.mileageKm,
      color: form.color,
      fuelType: form.fuel?.name,
      transmissionType: form.gearbox?.name,
      vin: form.isVinValid ? form.vin?.trim() : null,
      isVinVerified: form.isVinValid,
    );

    final request = CreateListingRequest(
      sellerId: session.profile.backendId ?? 0,
      title: title.isEmpty ? 'Véhicule' : title,
      price: form.priceFcfa!,
      cityId: cityId,
      countryId: countryId,
      vehicle: vehicle,
      description: form.description,
    );

    try {
      await ref
          .read(listingsRepositoryProvider)
          .postListingWithMedia(listing: request, photos: form.photos);
      if (!context.mounted) return;
      AppSnack.success(context, 'Annonce publiée avec succès !');
      _exit(context, ref);
    } on ValidationException catch (e) {
      if (!context.mounted) return;
      AppSnack.error(
        context,
        e.errors.isNotEmpty ? e.errors.first : 'Données invalides.',
      );
    } on NetworkException {
      if (!context.mounted) return;
      AppSnack.error(context, 'Pas de connexion. Réessayez.');
    } on ApiException {
      if (!context.mounted) return;
      AppSnack.error(context, 'Erreur lors de la publication. Réessayez.');
    }
  }
}

// ── Option ligne dans le bottom sheet de sortie (wireframe 6.9) ──────────────

class _ExitOption extends StatelessWidget {
  const _ExitOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
