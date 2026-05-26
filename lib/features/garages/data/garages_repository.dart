import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/features/garages/domain/garage_entity.dart';

/// Repository garages — données mock en attendant l'API NestJS.
class GaragesRepository {
  const GaragesRepository();

  List<GarageEntity> getAll() => _kGarages;
}

const _kGarages = <GarageEntity>[
  GarageEntity(
    id: '1',
    name: 'Garage Auto Plus',
    location: 'Akwa, Douala',
    rating: 4.8,
    reviewCount: 124,
    listingsCount: 15,
    isVerified: true,
    imageColor: Colors.blue,
  ),
  GarageEntity(
    id: '2',
    name: 'Motors Cameroun',
    location: 'Bonanjo, Douala',
    rating: 4.5,
    reviewCount: 89,
    listingsCount: 42,
    isVerified: true,
    imageColor: Colors.black87,
  ),
  GarageEntity(
    id: '3',
    name: 'Elite Auto Services',
    location: 'Bastos, Yaoundé',
    rating: 4.9,
    reviewCount: 210,
    listingsCount: 8,
    isVerified: true,
    imageColor: AppColors.trust,
  ),
  GarageEntity(
    id: '4',
    name: 'Meca Express',
    location: 'Ndokoti, Douala',
    rating: 4.2,
    reviewCount: 45,
    listingsCount: 3,
    isVerified: false,
    imageColor: AppColors.outline,
  ),
];

final garagesRepositoryProvider = Provider<GaragesRepository>((ref) {
  return const GaragesRepository();
});
