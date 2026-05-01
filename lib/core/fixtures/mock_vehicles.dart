import 'package:liko_auto/core/constants/app_assets.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

/// Données fictives véhicules — utilisées par Home et Recherche en attendant
/// la livraison de l'API NestJS.
abstract final class MockVehicles {
  static const List<ListingCardData> all = [
    ListingCardData(
      title: 'Toyota RAV4 2020',
      priceFcfa: 14500000,
      location: 'Akwa, Douala',
      mileageKm: 42000,
      imageAsset: AppAssets.carRav4,
      photoCount: 8,
      isVinVerified: true,
      isPro: true,
    ),
    ListingCardData(
      title: 'Hyundai Tucson 2019',
      priceFcfa: 11200000,
      location: 'Bonanjo, Douala',
      mileageKm: 65000,
      imageAsset: AppAssets.carTucson,
      photoCount: 5,
      isVinVerified: true,
    ),
    ListingCardData(
      title: 'Mercedes GLC 300 2021',
      priceFcfa: 28000000,
      location: 'Bastos, Yaoundé',
      mileageKm: 31000,
      imageAsset: AppAssets.logo,
      photoCount: 12,
      isVinVerified: true,
      isPro: true,
    ),
    ListingCardData(
      title: 'Honda CR-V 2019',
      priceFcfa: 9800000,
      location: 'Ngousso, Yaoundé',
      mileageKm: 78000,
      imageAsset: AppAssets.logo,
      photoCount: 6,
    ),
    ListingCardData(
      title: 'Toyota Corolla 2018',
      priceFcfa: 8500000,
      location: 'Bonapriso, Douala',
      mileageKm: 92000,
      imageAsset: AppAssets.carRav4,
      photoCount: 14,
      isVinVerified: true,
    ),
    ListingCardData(
      title: 'Toyota Hilux 2017',
      priceFcfa: 16500000,
      location: 'Bonabéri, Douala',
      mileageKm: 110000,
      imageAsset: AppAssets.carTucson,
      photoCount: 9,
      isVinVerified: true,
      isPro: true,
    ),
    ListingCardData(
      title: 'BMW X3 2020',
      priceFcfa: 24000000,
      location: 'Bonamoussadi, Douala',
      mileageKm: 38000,
      imageAsset: AppAssets.logo,
      photoCount: 11,
      isVinVerified: true,
      isPro: true,
    ),
    ListingCardData(
      title: 'Nissan Qashqai 2018',
      priceFcfa: 9500000,
      location: 'Mvog-Ada, Yaoundé',
      mileageKm: 88000,
      imageAsset: AppAssets.logo,
      photoCount: 7,
    ),
  ];
}
