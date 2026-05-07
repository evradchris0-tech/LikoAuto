import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';

class SellStep1Identifier extends ConsumerStatefulWidget {
  const SellStep1Identifier({super.key});

  @override
  ConsumerState<SellStep1Identifier> createState() =>
      _SellStep1IdentifierState();
}

class _SellStep1IdentifierState extends ConsumerState<SellStep1Identifier> {
  late final TextEditingController _vinCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();
    final form = ref.read(sellFormProvider);
    _vinCtrl = TextEditingController(text: form.vin ?? '');
    _brandCtrl = TextEditingController(text: form.brand ?? '');
    _modelCtrl = TextEditingController(text: form.model ?? '');
    _manualMode = form.brand != null;
  }

  @override
  void dispose() {
    _vinCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(sellFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Identifiez votre véhicule',
          style: context.textStyles.displaySmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        AppSpacing.gapMd,
        Text(
          'Entrez le numéro de châssis (VIN — 17 caractères) pour activer le badge VIN vérifié.',
          style: context.textStyles.bodyMedium?.copyWith(
            color: AppColors.neutral,
          ),
        ),
        AppSpacing.gapXl,
        LikoTextField(
          controller: _vinCtrl,
          hintText: 'Numéro de châssis (VIN)',
          prefixIcon: const Icon(
            Icons.qr_code_2_rounded,
            color: AppColors.neutral,
          ),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(17),
            UpperCaseTextFormatter(),
          ],
          onChanged: (value) {
            ref.read(sellFormProvider.notifier).setVin(value);
            setState(() {});
          },
        ),
        AppSpacing.gapSm,
        _VinFeedback(form: form),
        AppSpacing.gapLg,
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OU',
                style: context.textStyles.labelSmall?.copyWith(
                  color: AppColors.neutral,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        AppSpacing.gapLg,
        if (!_manualMode)
          OutlinedButton.icon(
            onPressed: () => setState(() => _manualMode = true),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Saisir manuellement la marque et le modèle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.trust,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          Column(
            children: [
              LikoTextField(
                controller: _brandCtrl,
                hintText: 'Marque (ex : Toyota)',
                prefixIcon: const Icon(
                  Icons.directions_car_filled_outlined,
                  color: AppColors.neutral,
                ),
                onChanged: (v) {
                  ref.read(sellFormProvider.notifier).setBrandModel(
                        brand: v.trim(),
                        model: _modelCtrl.text.trim(),
                      );
                  setState(() {});
                },
              ),
              AppSpacing.gapMd,
              LikoTextField(
                controller: _modelCtrl,
                hintText: 'Modèle (ex : RAV4)',
                prefixIcon: const Icon(
                  Icons.label_outline_rounded,
                  color: AppColors.neutral,
                ),
                onChanged: (v) {
                  ref.read(sellFormProvider.notifier).setBrandModel(
                        brand: _brandCtrl.text.trim(),
                        model: v.trim(),
                      );
                  setState(() {});
                },
              ),
            ],
          ),
      ],
    );
  }
}

class _VinFeedback extends StatelessWidget {
  const _VinFeedback({required this.form});

  final SellFormData form;

  @override
  Widget build(BuildContext context) {
    final vin = form.vin?.trim() ?? '';
    if (vin.isEmpty) {
      return Text(
        '17 caractères, lettres majuscules et chiffres (sauf I, O, Q).',
        style: context.textStyles.labelSmall?.copyWith(color: AppColors.neutral),
      );
    }
    if (form.isVinValid) {
      return Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: AppColors.success,
            size: 16,
          ),
          AppSpacing.gapXs,
          Text(
            'VIN au format valide.',
            style: context.textStyles.labelSmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
        AppSpacing.gapXs,
        Expanded(
          child: Text(
            vin.length < 17
                ? '${vin.length}/17 caractères.'
                : 'Caractères non autorisés (I, O ou Q détectés).',
            style: context.textStyles.labelSmall?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
