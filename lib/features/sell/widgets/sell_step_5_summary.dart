import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';

// Provider local pour l'option boost (wireframe 3.5)
final _boostSelectedProvider = StateProvider.autoDispose<bool>((ref) => false);

class SellStep5Summary extends ConsumerWidget {
  const SellStep5Summary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(sellFormProvider);

    final identifier = form.isVinValid
        ? 'VIN ${form.vin}'
        : '${form.brand ?? "?"} ${form.model ?? ""}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Récapitulatif',
          style: context.textStyles.displaySmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        AppSpacing.gapMd,
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              _SummaryItem(
                icon: Icons.image_outlined,
                label: '${form.photos.length} photos ajoutées',
                ok: form.hasPhotosMinimum,
              ),
              const Divider(height: 32),
              _SummaryItem(
                icon: form.isVinValid
                    ? Icons.verified_rounded
                    : Icons.directions_car_outlined,
                label: identifier.isEmpty ? 'Identifiant manquant' : identifier,
                ok: form.isStep1Valid,
              ),
              const Divider(height: 32),
              _SummaryItem(
                icon: Icons.tune_rounded,
                label: form.isStep3Valid
                    ? '${form.mileageKm!.toGroupedString()} km · ${form.year} · '
                          '${form.fuel?.name ?? ""} · ${form.gearbox?.name ?? ""}'
                    : 'Détails techniques manquants',
                ok: form.isStep3Valid,
              ),
              const Divider(height: 32),
              _SummaryItem(
                icon: Icons.payments_outlined,
                label: form.priceFcfa != null && form.priceFcfa! > 0
                    ? '${form.priceFcfa!.toFcfa()}'
                          '${form.isNegotiable ? "  ·  Négociable" : ""}'
                    : 'Prix non défini',
                ok: form.isStep4Valid,
              ),
            ],
          ),
        ),
        AppSpacing.gapXl,
        // Boost (wireframe 3.5)
        _BoostCard(),
        AppSpacing.gapLg,
        Text(
          'En publiant cette annonce, vous acceptez nos conditions générales.',
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall?.copyWith(color: AppColors.neutral),
        ),
      ],
    );
  }
}

// ── Boost card (wireframe 3.5) ──────────────────────────────────────────────────
class _BoostCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boosted = ref.watch(_boostSelectedProvider);
    return GestureDetector(
      onTap: () =>
          ref.read(_boostSelectedProvider.notifier).state = !boosted,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: boosted
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: boosted ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: boosted ? AppColors.primary : AppColors.outline,
            width: boosted ? 2 : 1,
          ),
          boxShadow: boosted
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: boosted
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 22,
                color: boosted ? Colors.white : AppColors.primary,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booster cette annonce',
                    style: TextStyle(
                      color: boosted ? Colors.white : AppColors.trust,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '3× plus de visibilité • 5 000 FCFA / semaine',
                    style: TextStyle(
                      color: boosted
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.neutral,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: boosted,
              onChanged: (v) =>
                  ref.read(_boostSelectedProvider.notifier).state = v,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.ok,
  });

  final IconData icon;
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: ok ? AppColors.primary : AppColors.neutral,
          size: 20,
        ),
        AppSpacing.gapMd,
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          ok ? Icons.check_circle : Icons.error_outline,
          color: ok ? AppColors.success : AppColors.error,
          size: 20,
        ),
      ],
    );
  }
}
