import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/listings/domain/api_listing.dart';

enum FuelType { essence, diesel, hybride, electrique }

enum GearboxType { manuelle, automatique }

@immutable
class SellFormData {
  const SellFormData({
    this.vin,
    this.brand,
    this.brandId,
    this.model,
    this.modelId,
    this.photos = const [],
    this.mileageKm,
    this.year,
    this.fuel,
    this.gearbox,
    this.priceFcfa,
    this.description,
    this.isNegotiable = false,
    this.isTradeInAccepted = false,
    this.isFinancingAvailable = false,
    this.cityId,
    this.condition,
    this.color,
  });

  final String? vin;
  final String? brand;
  final int? brandId;
  final String? model;
  final int? modelId;
  final List<File> photos;
  final int? mileageKm;
  final int? year;
  final FuelType? fuel;
  final GearboxType? gearbox;
  final int? priceFcfa;
  final String? description;
  final bool isNegotiable;
  final bool isTradeInAccepted;
  final bool isFinancingAvailable;
  final int? cityId;
  final VehicleCondition? condition;
  final String? color;

  /// VIN valide = exactement 17 caractères alphanumériques (sans I, O, Q).
  bool get isVinValid {
    final v = vin?.trim().toUpperCase();
    if (v == null || v.length != 17) return false;
    return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(v);
  }

  bool get hasPhotosMinimum => photos.length >= 5;

  /// Step 1 accepte le VIN OU une sélection marque+modèle via l'API.
  bool get isStep1Valid => isVinValid || (brandId != null && modelId != null);

  bool get isStep2Valid => hasPhotosMinimum;

  bool get isStep3Valid =>
      mileageKm != null && year != null && fuel != null && gearbox != null;

  bool get isStep4Valid =>
      priceFcfa != null &&
      priceFcfa! > 0 &&
      description != null &&
      description!.trim().length >= 10;

  /// Retourne une copie avec la marque définie et le modèle effacé.
  SellFormData withBrand({required int id, required String name}) =>
      SellFormData(
        vin: vin,
        brand: name,
        brandId: id,
        // model intentionally cleared
        photos: photos,
        mileageKm: mileageKm,
        year: year,
        fuel: fuel,
        gearbox: gearbox,
        priceFcfa: priceFcfa,
        description: description,
        isNegotiable: isNegotiable,
        isTradeInAccepted: isTradeInAccepted,
        isFinancingAvailable: isFinancingAvailable,
        cityId: cityId,
        condition: condition,
        color: color,
      );

  SellFormData copyWith({
    String? vin,
    String? brand,
    int? brandId,
    String? model,
    int? modelId,
    List<File>? photos,
    int? mileageKm,
    int? year,
    FuelType? fuel,
    GearboxType? gearbox,
    int? priceFcfa,
    String? description,
    bool? isNegotiable,
    bool? isTradeInAccepted,
    bool? isFinancingAvailable,
    int? cityId,
    VehicleCondition? condition,
    String? color,
  }) {
    return SellFormData(
      vin: vin ?? this.vin,
      brand: brand ?? this.brand,
      brandId: brandId ?? this.brandId,
      model: model ?? this.model,
      modelId: modelId ?? this.modelId,
      photos: photos ?? this.photos,
      mileageKm: mileageKm ?? this.mileageKm,
      year: year ?? this.year,
      fuel: fuel ?? this.fuel,
      gearbox: gearbox ?? this.gearbox,
      priceFcfa: priceFcfa ?? this.priceFcfa,
      description: description ?? this.description,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      isTradeInAccepted: isTradeInAccepted ?? this.isTradeInAccepted,
      isFinancingAvailable: isFinancingAvailable ?? this.isFinancingAvailable,
      cityId: cityId ?? this.cityId,
      condition: condition ?? this.condition,
      color: color ?? this.color,
    );
  }
}

class SellFormNotifier extends StateNotifier<SellFormData> {
  SellFormNotifier() : super(const SellFormData());

  void setVin(String value) => state = state.copyWith(vin: value);

  void setBrand({required int id, required String name}) =>
      state = state.withBrand(id: id, name: name);

  void setModel({required int id, required String name}) =>
      state = state.copyWith(model: name, modelId: id);

  void setPhotos(List<File> files) => state = state.copyWith(photos: files);
  void addPhotos(List<File> files) =>
      state = state.copyWith(photos: [...state.photos, ...files]);
  void removePhotoAt(int index) {
    final next = [...state.photos]..removeAt(index);
    state = state.copyWith(photos: next);
  }

  void setMileage(int km) => state = state.copyWith(mileageKm: km);
  void setYear(int year) => state = state.copyWith(year: year);
  void setFuel(FuelType fuel) => state = state.copyWith(fuel: fuel);
  void setGearbox(GearboxType g) => state = state.copyWith(gearbox: g);

  void setPrice(int price) => state = state.copyWith(priceFcfa: price);
  void setDescription(String d) => state = state.copyWith(description: d);
  void setNegotiable({required bool value}) =>
      state = state.copyWith(isNegotiable: value);
  void setTradeIn({required bool value}) =>
      state = state.copyWith(isTradeInAccepted: value);
  void setFinancing({required bool value}) =>
      state = state.copyWith(isFinancingAvailable: value);

  void setCityId(int id) => state = state.copyWith(cityId: id);
  void setCondition(VehicleCondition c) => state = state.copyWith(condition: c);
  void setColor(String c) => state = state.copyWith(color: c);

  void reset() => state = const SellFormData();
}

final sellFormProvider = StateNotifierProvider<SellFormNotifier, SellFormData>((
  ref,
) {
  return SellFormNotifier();
});
