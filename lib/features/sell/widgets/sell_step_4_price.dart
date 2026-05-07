import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';

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
        LikoTextField(
          controller: _priceCtrl,
          hintText: 'Prix de vente (FCFA)',
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
        AppSpacing.gapLg,
        LikoTextField(
          controller: _descCtrl,
          hintText: 'Décrivez votre véhicule (état, entretien, options...)',
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          onChanged: notifier.setDescription,
        ),
        AppSpacing.gapXs,
        Text(
          '${(form.description ?? '').trim().length} caractères (min 10).',
          style: context.textStyles.labelSmall?.copyWith(
            color: AppColors.neutral,
          ),
        ),
      ],
    );
  }
}
