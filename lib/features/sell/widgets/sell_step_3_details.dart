import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SellStep3Details extends ConsumerStatefulWidget {
  const SellStep3Details({super.key});

  @override
  ConsumerState<SellStep3Details> createState() => _SellStep3DetailsState();
}

class _SellStep3DetailsState extends ConsumerState<SellStep3Details> {
  late final TextEditingController _kmCtrl;
  late final TextEditingController _yearCtrl;

  @override
  void initState() {
    super.initState();
    final form = ref.read(sellFormProvider);
    _kmCtrl = TextEditingController(text: form.mileageKm?.toString() ?? '');
    _yearCtrl = TextEditingController(text: form.year?.toString() ?? '');
  }

  @override
  void dispose() {
    _kmCtrl.dispose();
    _yearCtrl.dispose();
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
          'Détails techniques',
          style: context.textStyles.displaySmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        AppSpacing.gapMd,
        Text(
          'Précisez les caractéristiques pour aider les acheteurs à se décider.',
          style: context.textStyles.bodyMedium?.copyWith(
            color: AppColors.neutral,
          ),
        ),
        AppSpacing.gapXl,
        LikoTextField(
          controller: _kmCtrl,
          hintText: 'Kilométrage (km)',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(LucideIcons.gauge, color: AppColors.neutral),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null) notifier.setMileage(n);
          },
        ),
        AppSpacing.gapLg,
        LikoTextField(
          controller: _yearCtrl,
          hintText: 'Année de fabrication',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(
            LucideIcons.calendar,
            color: AppColors.neutral,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null) notifier.setYear(n);
          },
        ),
        AppSpacing.gapLg,
        DropdownButtonFormField<FuelType>(
          initialValue: form.fuel,
          style: context.textStyles.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: _decoration(
            context,
            hint: 'Type de carburant',
            icon: LucideIcons.fuel,
          ),
          items: FuelType.values
              .map(
                (f) => DropdownMenuItem(value: f, child: Text(_labelFuel(f))),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) notifier.setFuel(v);
          },
        ),
        AppSpacing.gapLg,
        DropdownButtonFormField<GearboxType>(
          initialValue: form.gearbox,
          style: context.textStyles.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: _decoration(
            context,
            hint: 'Boîte de vitesse',
            icon: LucideIcons.settings,
          ),
          items: GearboxType.values
              .map(
                (g) =>
                    DropdownMenuItem(value: g, child: Text(_labelGearbox(g))),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) notifier.setGearbox(v);
          },
        ),
      ],
    );
  }

  InputDecoration _decoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: context.textStyles.bodyLarge?.copyWith(
        color: AppColors.neutral,
      ),
      prefixIcon: Icon(icon, color: AppColors.neutral),
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
    );
  }

  String _labelFuel(FuelType f) {
    switch (f) {
      case FuelType.essence:
        return 'Essence';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.hybride:
        return 'Hybride';
      case FuelType.electrique:
        return 'Électrique';
    }
  }

  String _labelGearbox(GearboxType g) {
    switch (g) {
      case GearboxType.manuelle:
        return 'Manuelle';
      case GearboxType.automatique:
        return 'Automatique';
    }
  }
}
