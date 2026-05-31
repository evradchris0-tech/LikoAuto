import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/search/models/search_filters.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/buttons/tertiary_button.dart';

const _brands = ['Toyota', 'Mercedes', 'BMW', 'Hyundai', 'Honda', 'Nissan'];
const _cities = ['Douala', 'Yaoundé', 'Bafoussam'];
const _years = [2024, 2023, 2022, 2021, 2020, 2019, 2018, 2017, 2016, 2015];

/// Bottom sheet de filtres Voitures.
class VehicleFilterSheet extends StatefulWidget {
  const VehicleFilterSheet({required this.initial, super.key});
  final VehicleFilters initial;

  static Future<VehicleFilters?> show(
    BuildContext context, {
    required VehicleFilters initial,
  }) {
    return showModalBottomSheet<VehicleFilters>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.rBottomSheet),
      builder: (_) => VehicleFilterSheet(initial: initial),
    );
  }

  @override
  State<VehicleFilterSheet> createState() => _VehicleFilterSheetState();
}

class _VehicleFilterSheetState extends State<VehicleFilterSheet> {
  late VehicleFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _Handle(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'Filtres',
                    style: context.textStyles.headlineMedium?.copyWith(
                      color: AppColors.trust,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (_filters.activeCount > 0)
                    TertiaryButton(
                      label: 'Réinitialiser',
                      onPressed: () =>
                          setState(() => _filters = VehicleFilters.empty),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.outline),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  _Section(
                    title: 'Prix',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in PriceRange.values)
                          _SelectChip(
                            label: p.label,
                            selected: _filters.priceRange == p,
                            onTap: () => setState(() {
                              _filters = _filters.priceRange == p
                                  ? _filters.copyWith(clearPriceRange: true)
                                  : _filters.copyWith(priceRange: p);
                            }),
                          ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,
                  _Section(
                    title: 'Marque',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final b in _brands)
                          _SelectChip(
                            label: b,
                            selected: _filters.brand == b,
                            onTap: () => setState(() {
                              _filters = _filters.brand == b
                                  ? _filters.copyWith(clearBrand: true)
                                  : _filters.copyWith(brand: b);
                            }),
                          ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,
                  _Section(
                    title: 'Année',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final y in _years)
                          _SelectChip(
                            label: '$y',
                            selected: _filters.year == y,
                            onTap: () => setState(() {
                              _filters = _filters.year == y
                                  ? _filters.copyWith(clearYear: true)
                                  : _filters.copyWith(year: y);
                            }),
                          ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,
                  _Section(
                    title: 'Ville',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in _cities)
                          _SelectChip(
                            label: c,
                            selected: _filters.city == c,
                            onTap: () => setState(() {
                              _filters = _filters.city == c
                                  ? _filters.copyWith(clearCity: true)
                                  : _filters.copyWith(city: c);
                            }),
                          ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,
                  _Section(
                    title: 'Confiance',
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primarySoft,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: AppColors.outline,
                      title: Text(
                        'VIN vérifié uniquement',
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: AppColors.trust,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Annonces avec numéro de série validé',
                        style: context.textStyles.bodySmall,
                      ),
                      value: _filters.vinVerifiedOnly,
                      onChanged: (v) => setState(
                        () => _filters = _filters.copyWith(vinVerifiedOnly: v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: PrimaryButton(
                  label: 'Appliquer les filtres',
                  onPressed: () => Navigator.of(context).pop(_filters),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.outline,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textStyles.headlineSmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        AppSpacing.gapSm,
        child,
      ],
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.trust : Colors.white;
    final fg = selected ? Colors.white : AppColors.trust;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.trust : AppColors.primarySoft,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: context.textStyles.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
