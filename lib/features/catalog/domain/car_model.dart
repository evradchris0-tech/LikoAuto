import 'package:flutter/foundation.dart';
import 'package:liko_auto/features/catalog/domain/brand.dart';

@immutable
class CarModel {
  const CarModel({
    required this.id,
    required this.brandId,
    required this.name,
    this.brand,
    this.isActive = true,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
        id: json['id'] as int,
        brandId: json['brand_id'] as int? ??
            (json['brand'] as Map<String, dynamic>?)?['id'] as int? ?? 0,
        name: json['name'] as String,
        brand: json['brand'] != null
            ? Brand.fromJson(json['brand'] as Map<String, dynamic>)
            : null,
        isActive: json['is_active'] as bool? ?? true,
      );

  final int id;
  final int brandId;
  final String name;
  final Brand? brand;
  final bool isActive;

  @override
  bool operator ==(Object other) => other is CarModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

@immutable
class ModelVariant {
  const ModelVariant({
    required this.id,
    required this.modelId,
    required this.year,
    required this.bodyType,
    this.variantName,
    this.numDoors,
    this.numSeats,
    this.transmissionType,
    this.fuelType,
    this.horsepower,
    this.engineSize,
    this.isActive = true,
  });

  factory ModelVariant.fromJson(Map<String, dynamic> json) => ModelVariant(
        id: json['id'] as int,
        modelId: json['model_id'] as int? ?? 0,
        year: json['year'] as int,
        bodyType: json['body_type'] as String,
        variantName: json['variant_name'] as String?,
        numDoors: json['num_doors'] as int?,
        numSeats: json['num_seats'] as int?,
        transmissionType: json['transmission_type'] as String?,
        fuelType: json['fuel_type'] as String?,
        horsepower: json['horsepower'] as int?,
        engineSize: json['engine_size'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );

  final int id;
  final int modelId;
  final int year;
  final String bodyType;
  final String? variantName;
  final int? numDoors;
  final int? numSeats;
  final String? transmissionType;
  final String? fuelType;
  final int? horsepower;
  final String? engineSize;
  final bool isActive;

  String get displayName => variantName != null ? '$year $variantName' : '$year';
}
