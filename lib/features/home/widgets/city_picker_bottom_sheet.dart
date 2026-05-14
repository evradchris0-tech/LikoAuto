import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/city_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

class CityPickerBottomSheet extends ConsumerWidget {
  const CityPickerBottomSheet({super.key});

  static const _cities = ['Douala', 'Yaoundé', 'Bafoussam'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCity = ref.watch(selectedCityProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Choisir votre ville',
            style: context.textStyles.headlineSmall?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ..._cities.map(
            (city) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.location_city_rounded,
                color: city == currentCity
                    ? AppColors.primary
                    : AppColors.neutral,
              ),
              title: Text(
                city,
                style: TextStyle(
                  color: city == currentCity
                      ? AppColors.primary
                      : AppColors.trust,
                  fontWeight: city == currentCity
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              trailing: city == currentCity
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(selectedCityProvider.notifier).state = city;
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.my_location_rounded, color: AppColors.trust),
            title: const Text(
              'Détecter ma position',
              style: TextStyle(
                color: AppColors.trust,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              try {
                await ref.read(detectCityProvider.future);
              } on Exception catch (_) {
                if (context.mounted) {
                  AppSnack.error(
                    context,
                    'Erreur géolocalisation. Veuillez réessayer.',
                    action: SnackBarAction(
                      label: 'Réessayer',
                      textColor: Colors.white,
                      onPressed: () =>
                          ref.invalidate(detectCityProvider),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
