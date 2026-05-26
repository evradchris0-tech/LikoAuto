import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';

// Estimation statique de la fourchette de marchÃ©.
({int min, int max}) _estimateRange(SellFormData form) {
  final brand = (form.brand ?? form.vin ?? '').toLowerCase();
  final km = form.mileageKm ?? 50000;
  final year = form.year ?? 2018;
  final age = 2026 - year;

  // Base price par marque (FCFA)
  final int base;
  if (brand.contains('bmw') || brand.contains('mercedes')) {
    base = 22000000;
  } else if (brand.contains('toyota')) {
    base = 14000000;
  } else if (brand.contains('hyundai') || brand.contains('kia')) {
    base = 11000000;
  } else if (brand.contains('nissan') || brand.contains('honda')) {
    base = 10000000;
  } else {
    base = 12000000;
  }

  // DÃ©prÃ©ciation : -6% / an, -1% / 10 000 km supplÃ©mentaires
  final depreciation = (age * 0.06 + (km / 10000) * 0.01).clamp(0.0, 0.55);
  final mid = (base * (1 - depreciation)).round();
  final spread = (mid * 0.12).round();
  return (min: mid - spread, max: mid + spread);
}

class SellStep4Price extends ConsumerStatefulWidget {
  const SellStep4Price({super.key});

  @override
  ConsumerState<SellStep4Price> createState() => _SellStep4PriceState();
}

class _SellStep4PriceState extends ConsumerState<SellStep4Price> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final form = ref.read(sellFormProvider);
    _priceCtrl = TextEditingController(text: form.priceFcfa?.toString() ?? '');
    _descCtrl = TextEditingController(text: form.description ?? '');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(sellFormProvider);
    final notifier = ref.read(sellFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Prix & Description',
          style: context.textStyles.displaySmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        AppSpacing.gapMd,
        _MarketRangeBanner(form: form),
        AppSpacing.gapLg,
        LikoTextField(
          controller: _priceCtrl,
          hintText: 'Votre prix (FCFA)',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(
            Icons.payments_outlined,
            color: AppColors.neutral,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null) notifier.setPrice(n);
          },
        ),
        AppSpacing.gapXs,
        if (form.priceFcfa != null && form.priceFcfa! > 0)
          Text(
            form.priceFcfa!.toFcfa(),
            style: context.textStyles.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        AppSpacing.gapLg,
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: form.isNegotiable,
          onChanged: (v) => notifier.setNegotiable(value: v),
          activeThumbColor: AppColors.primary,
          title: Text(
            'Prix négociable',
            style: context.textStyles.bodyLarge?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Affiche un badge orange pour signaler la flexibilité.',
            style: context.textStyles.bodySmall?.copyWith(
              color: AppColors.neutral,
            ),
          ),
        ),
        AppSpacing.gapMd,
        // Toggle Reprise possible (wireframe 3.4)
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: form.isTradeInAccepted,
          onChanged: (v) => notifier.setTradeIn(value: v),
          activeThumbColor: AppColors.primary,
          title: Text(
            'Reprise possible',
            style: context.textStyles.bodyLarge?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Vous acceptez une voiture en échange partiel.',
            style: context.textStyles.bodySmall?.copyWith(
              color: AppColors.neutral,
            ),
          ),
        ),
        AppSpacing.gapMd,
        // Toggle Financement accepté (wireframe 3.4)
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: form.isFinancingAvailable,
          onChanged: (v) => notifier.setFinancing(value: v),
          activeThumbColor: AppColors.primary,
          title: Text(
            'Financement accepté',
            style: context.textStyles.bodyLarge?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Acheteurs en crédit auto bienvenus.',
            style: context.textStyles.bodySmall?.copyWith(
              color: AppColors.neutral,
            ),
          ),
        ),
        AppSpacing.gapLg,
        LikoTextField(
          controller: _descCtrl,
          hintText: 'DÃ©crivez votre vÃ©hicule (Ã©tat, entretien, options...)',
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          onChanged: notifier.setDescription,
        ),
        AppSpacing.gapXs,
        Text(
          '${(form.description ?? '').trim().length} caractÃ¨res (min 10).',
          style: context.textStyles.labelSmall?.copyWith(
            color: AppColors.neutral,
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Fourchette de marchÃ© (wireframe 3.4) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _MarketRangeBanner extends StatelessWidget {
  const _MarketRangeBanner({required this.form});

  final SellFormData form;

  @override
  Widget build(BuildContext context) {
    final hasContext = form.brand != null || (form.vin?.isNotEmpty ?? false);
    if (!hasContext) return const SizedBox.shrink();

    final range = _estimateRange(form);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'FOURCHETTE DE MARCHÃ‰',
                style: context.textStyles.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${range.min.toFcfa()} â€“ ${range.max.toFcfa()}',
            style: context.textStyles.titleMedium?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Estimation basÃ©e sur le marchÃ© camerounais.',
            style: context.textStyles.labelSmall?.copyWith(color: AppColors.neutral),
          ),
        ],
      ),
    );
  }
}
