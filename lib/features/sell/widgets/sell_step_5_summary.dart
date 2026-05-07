import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';

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
        Text(
          'En publiant cette annonce, vous acceptez nos conditions générales.',
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall?.copyWith(color: AppColors.neutral),
        ),
      ],
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
