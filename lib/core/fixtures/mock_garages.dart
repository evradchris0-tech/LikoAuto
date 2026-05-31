import 'package:liko_auto/core/constants/app_assets.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';

/// Données fictives garages — utilisées par l'annuaire et la recherche.
abstract final class MockGarages {
  static const List<GarageCardData> all = [
    GarageCardData(
      name: 'Garage Toyota Akwa',
      specialties: ['Toyota', 'Diagnostic', 'Carrosserie'],
      rating: 4.8,

      location: 'Akwa, Douala',
      imageAsset: AppAssets.logo,

      isCertified: true,
    ),
    GarageCardData(
      name: 'Mercedes Center Bonapriso',
      specialties: ['Mercedes', 'Expertise'],
      rating: 4.6,

      location: 'Bonapriso, Douala',
      imageAsset: AppAssets.logo,

      isCertified: true,
    ),
    GarageCardData(
      name: 'Auto Service Bonanjo',
      specialties: ['Diagnostic', 'Réparation', 'Toyota'],
      rating: 4.4,

      location: 'Bonanjo, Douala',
      imageAsset: AppAssets.logo,
    ),
    GarageCardData(
      name: 'BMW Workshop Yaoundé',
      specialties: ['BMW', 'Diagnostic'],
      rating: 4.7,

      location: 'Bastos, Yaoundé',
      imageAsset: AppAssets.logo,
      isCertified: true,
    ),
    GarageCardData(
      name: 'Hilux Garage Bonabéri',
      specialties: ['Toyota', 'Carrosserie'],
      rating: 4.3,

      location: 'Bonabéri, Douala',
      imageAsset: AppAssets.logo,
    ),
    GarageCardData(
      name: 'Quick Diag Bafoussam',
      specialties: ['Diagnostic', 'Expertise'],
      rating: 4.5,

      location: 'Bafoussam',
      imageAsset: AppAssets.logo,
    ),
  ];
}
