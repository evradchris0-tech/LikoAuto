import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/geo/domain/api_city.dart';
import 'package:liko_auto/features/geo/providers/geo_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Bottom sheet de sélection de ville (données réelles depuis GET /cities).
///
/// Retourne l'[ApiCity] choisie, ou null si l'utilisateur ferme sans choisir.
class CityPickerSheet extends ConsumerStatefulWidget {
  const CityPickerSheet({super.key});

  static Future<ApiCity?> show(BuildContext context) {
    return showModalBottomSheet<ApiCity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CityPickerSheet(),
    );
  }

  @override
  ConsumerState<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<CityPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      if (_query != _searchCtrl.text) {
        setState(() => _query = _searchCtrl.text.toLowerCase().trim());
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cameroun = countryId 1
    final citiesAsync = ref.watch(citiesProvider(1));
    final selected = ref.watch(selectedCityProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollCtrl) {
        return Column(
          children: [
            // Handle
            Padding(
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
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Text(
                    'Choisir une ville',
                    style: TextStyle(
                      color: AppColors.trust,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            // Champ de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Rechercher une ville...',
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: AppColors.neutral,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
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
            ),
            const SizedBox(height: AppSpacing.md),
            // Liste des villes
            Expanded(
              child: citiesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Impossible de charger les villes.\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.neutral),
                  ),
                ),
                data: (cities) {
                  final filtered = _query.isEmpty
                      ? cities
                      : cities
                            .where((c) => c.name.toLowerCase().contains(_query))
                            .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune ville trouvée pour "$_query"',
                        style: const TextStyle(color: AppColors.neutral),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final city = filtered[i];
                      final isSelected = selected?.id == city.id;
                      return ListTile(
                        onTap: () {
                          ref.read(selectedCityProvider.notifier).state = city;
                          Navigator.of(context).pop(city);
                        },
                        leading: Icon(
                          LucideIcons.building,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.neutral,
                          size: 20,
                        ),
                        title: Text(
                          city.name,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.trust,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                LucideIcons.checkCircle,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : null,
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
