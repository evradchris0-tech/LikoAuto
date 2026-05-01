import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/search/models/search_filters.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/buttons/tertiary_button.dart';

const _specialties = [
  'Toyota',
  'Mercedes',
  'BMW',
  'Diagnostic',
  'Carrosserie',
  'Expertise',
  'Réparation',
];
const _cities = ['Douala', 'Yaoundé', 'Bafoussam'];
const _ratings = [3.0, 3.5, 4.0, 4.5];

/// Bottom sheet de filtres Garages.
class GarageFilterSheet extends StatefulWidget {
  const GarageFilterSheet({required this.initial, super.key});
  final GarageFilters initial;

  static Future<GarageFilters?> show(
    BuildContext context, {
    required GarageFilters initial,
  }) {
    return showModalBottomSheet<GarageFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.rBottomSheet),
      builder: (_) => GarageFilterSheet(initial: initial),
    );
  }

  @override
  State<GarageFilterSheet> createState() => _GarageFilterSheetState();
}

class _GarageFilterSheetState extends State<GarageFilterSheet> {
  late GarageFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
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
                    'Filtres garages',
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
                          setState(() => _filters = GarageFilters.empty),
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
                    title: 'Spécialité',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in _specialties)
                          _SelectChip(
                            label: s,
                            selected: _filters.specialty == s,
                            onTap: () => setState(() {
                              _filters = _filters.specialty == s
                                  ? _filters.copyWith(clearSpecialty: true)
                                  : _filters.copyWith(specialty: s);
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
                    title: 'Note minimum',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final r in _ratings)
                          _SelectChip(
                            label:
                                '${r.toStringAsFixed(1).replaceAll('.', ',')} ★+',
                            selected: _filters.minRating == r,
                            onTap: () => setState(() {
                              _filters = _filters.minRating == r
                                  ? _filters.copyWith(clearMinRating: true)
                                  : _filters.copyWith(minRating: r);
                            }),
                          ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,
                  _Section(
                    title: 'Disponibilité',
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppColors.primary,
                      title: Text(
                        'Ouvert maintenant',
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: AppColors.trust,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: _filters.openNowOnly,
                      onChanged: (v) => setState(
                        () => _filters = _filters.copyWith(openNowOnly: v),
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
