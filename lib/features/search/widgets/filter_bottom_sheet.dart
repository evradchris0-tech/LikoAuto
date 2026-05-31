import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(1000000, 50000000);
  String _selectedBrand = 'Toutes';
  bool _isVerifiedOnly = false;

  final List<String> _brands = [
    'Toutes',
    'Toyota',
    'Mercedes',
    'Hyundai',
    'Suzuki',
    'Ford',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rBottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.trust,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Réinitialiser',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          const Text(
            'MARQUE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.neutral,
            ),
          ),
          AppSpacing.gapSm,
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _brands.length,
              separatorBuilder: (_, __) => AppSpacing.gapSm,
              itemBuilder: (context, index) {
                final brand = _brands[index];
                final isSelected = _selectedBrand == brand;
                return ChoiceChip(
                  label: Text(brand),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedBrand = brand),
                  selectedColor: AppColors.primarySoft,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.trust,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          AppSpacing.gapLg,
          const Text(
            'ANNÉE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.neutral,
            ),
          ),
          AppSpacing.gapSm,
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  [
                    'Toutes',
                    '2024',
                    '2023',
                    '2022',
                    '2021',
                    '2020',
                    '2019',
                  ].map((year) {
                    final isSelected = year == 'Toutes'; // Default for demo
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(year),
                        selected: isSelected,
                        onSelected: (val) {},
                      ),
                    );
                  }).toList(),
            ),
          ),
          AppSpacing.gapLg,
          const Text(
            'GARAGE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.neutral,
            ),
          ),
          AppSpacing.gapSm,
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: const Text('Choisir un garage'),
            items: ['Elite Garages', 'Star Auto', 'Garage Central'].map((g) {
              return DropdownMenuItem(value: g, child: Text(g));
            }).toList(),
            onChanged: (val) {},
          ),
          AppSpacing.gapLg,
          const Text(
            'FOURCHETTE DE PRIX (FCFA)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.neutral,
            ),
          ),
          RangeSlider(
            values: _priceRange,
            min: 500000,
            max: 100000000,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.outline,
            labels: RangeLabels(
              '${(_priceRange.start / 1000000).toStringAsFixed(1)}M',
              '${(_priceRange.end / 1000000).toStringAsFixed(1)}M',
            ),
            onChanged: (val) => setState(() => _priceRange = val),
          ),
          AppSpacing.gapMd,
          SwitchListTile(
            title: const Text(
              'Annonces vérifiées uniquement',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: const Text(
              'Afficher uniquement les véhicules avec VIN vérifié',
              style: TextStyle(fontSize: 12),
            ),
            value: _isVerifiedOnly,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _isVerifiedOnly = val),
            contentPadding: EdgeInsets.zero,
          ),
          AppSpacing.gapLg,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.trust,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'APPLIQUER LES FILTRES',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
