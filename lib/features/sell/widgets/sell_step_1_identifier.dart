import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/catalog/domain/brand.dart';
import 'package:liko_auto/features/catalog/domain/car_model.dart';
import 'package:liko_auto/features/catalog/providers/catalog_provider.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SellStep1Identifier extends ConsumerStatefulWidget {
  const SellStep1Identifier({super.key});

  @override
  ConsumerState<SellStep1Identifier> createState() =>
      _SellStep1IdentifierState();
}

class _SellStep1IdentifierState extends ConsumerState<SellStep1Identifier> {
  late final TextEditingController _vinCtrl;

  @override
  void initState() {
    super.initState();
    _vinCtrl = TextEditingController(
      text: ref.read(sellFormProvider).vin ?? '',
    );
  }

  @override
  void dispose() {
    _vinCtrl.dispose();
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
        // Section VIN — carte claire
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Numéro de châssis (VIN)',
                    style: context.textStyles.labelMedium?.copyWith(
                      color: AppColors.trust,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'RECOMMANDÉ',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _vinCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(17),
                  UpperCaseTextFormatter(),
                ],
                onChanged: (value) =>
                    ref.read(sellFormProvider.notifier).setVin(value),
                style: const TextStyle(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Ex : JT3HP10V1P0123456',
                  hintStyle: const TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  prefixIcon: const Icon(
                    LucideIcons.qrCode,
                    color: AppColors.trust,
                    size: 22,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _VinFeedback(form: form),
            ],
          ),
        ),
        AppSpacing.gapLg,
        // Séparateur OU
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.trustSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'OU',
                  style: context.textStyles.labelSmall?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        AppSpacing.gapLg,
        // Section Marque
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marque',
                style: context.textStyles.labelMedium?.copyWith(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ApiBrandChips(
                selectedBrandId: form.brandId,
                onSelect: (brand) => ref
                    .read(sellFormProvider.notifier)
                    .setBrand(id: brand.id, name: brand.name),
              ),
              if (form.brandId != null) ...[
                AppSpacing.gapLg,
                _ApiModelChips(
                  brandId: form.brandId!,
                  selectedModelId: form.modelId,
                  onSelect: (model) => ref
                      .read(sellFormProvider.notifier)
                      .setModel(id: model.id, name: model.name),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── VIN feedback ──────────────────────────────────────────────────────────────

class _VinFeedback extends StatelessWidget {
  const _VinFeedback({required this.form});

  final SellFormData form;

  @override
  Widget build(BuildContext context) {
    final vin = form.vin?.trim() ?? '';
    if (vin.isEmpty) {
      return Text(
        '17 caractères, lettres majuscules et chiffres (sauf I, O, Q).',
        style: context.textStyles.labelSmall?.copyWith(
          color: AppColors.neutral,
        ),
      );
    }
    if (form.isVinValid) {
      return Row(
        children: [
          const Icon(
            LucideIcons.badgeCheck,
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
        const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 16),
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

// ── API brand chips ────────────────────────────────────────────────────────────

class _ApiBrandChips extends ConsumerWidget {
  const _ApiBrandChips({required this.selectedBrandId, required this.onSelect});

  final int? selectedBrandId;
  final void Function(Brand) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);
    return brandsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Text(
        'Impossible de charger les marques.',
        style: context.textStyles.labelSmall?.copyWith(color: AppColors.error),
      ),
      data: (brands) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: brands.where((b) => b.isActive).map((brand) {
          final isActive = selectedBrandId == brand.id;
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => onSelect(brand),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.trust : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? AppColors.trust : AppColors.outline,
                  ),
                ),
                child: Text(
                  brand.name,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.trust,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── API model chips ────────────────────────────────────────────────────────────

class _ApiModelChips extends ConsumerWidget {
  const _ApiModelChips({
    required this.brandId,
    required this.selectedModelId,
    required this.onSelect,
  });

  final int brandId;
  final int? selectedModelId;
  final void Function(CarModel) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(modelsProvider(brandId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modèle',
          style: context.textStyles.labelMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        modelsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, __) => Text(
            'Impossible de charger les modèles.',
            style: context.textStyles.labelSmall?.copyWith(
              color: AppColors.error,
            ),
          ),
          data: (models) {
            final active = models.where((m) => m.isActive).toList();
            if (active.isEmpty) {
              return Text(
                'Aucun modèle disponible pour cette marque.',
                style: context.textStyles.labelSmall?.copyWith(
                  color: AppColors.neutral,
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: active.map((model) {
                final isActive = selectedModelId == model.id;
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => onSelect(model),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.trust : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive ? AppColors.trust : AppColors.outline,
                        ),
                      ),
                      child: Text(
                        model.name,
                        style: TextStyle(
                          color: isActive ? Colors.white : AppColors.trust,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ── VIN formatter ──────────────────────────────────────────────────────────────

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
