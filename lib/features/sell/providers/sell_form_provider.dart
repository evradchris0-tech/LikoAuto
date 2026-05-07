import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FuelType { essence, diesel, hybride, electrique }

enum GearboxType { manuelle, automatique }

@immutable
class SellFormData {
  const SellFormData({
    this.vin,
    this.brand,
    this.model,
    this.photos = const [],
    this.mileageKm,
    this.year,
    this.fuel,
    this.gearbox,
    this.priceFcfa,
    this.description,
    this.isNegotiable = false,
  });

  final String? vin;
  final String? brand;
  final String? model;
  final List<File> photos;
  final int? mileageKm;
  final int? year;
  final FuelType? fuel;
  final GearboxType? gearbox;
  final int? priceFcfa;
  final String? description;
  final bool isNegotiable;

  /// VIN valide = exactement 17 caractères alphanumériques (sans I, O, Q).
  bool get isVinValid {
    final v = vin?.trim().toUpperCase();
    if (v == null || v.length != 17) return false;
    return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(v);
  }

  bool get hasPhotosMinimum => photos.length >= 5;

  /// Le step 1 (identifier) accepte le VIN OU une saisie manuelle marque+modèle.
  bool get isStep1Valid => isVinValid || (brand != null && model != null);

  bool get isStep2Valid => hasPhotosMinimum;

  bool get isStep3Valid =>
      mileageKm != null && year != null && fuel != null && gearbox != null;

  bool get isStep4Valid =>
      priceFcfa != null && priceFcfa! > 0 && description != null && description!.trim().length >= 10;

  SellFormData copyWith({
    String? vin,
    String? brand,
    String? model,
    List<File>? photos,
    int? mileageKm,
    int? year,
    FuelType? fuel,
    GearboxType? gearbox,
    int? priceFcfa,
    String? description,
    bool? isNegotiable,
  }) {
    return SellFormData(
      vin: vin ?? this.vin,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      photos: photos ?? this.photos,
      mileageKm: mileageKm ?? this.mileageKm,
      year: year ?? this.year,
      fuel: fuel ?? this.fuel,
      gearbox: gearbox ?? this.gearbox,
      priceFcfa: priceFcfa ?? this.priceFcfa,
      description: description ?? this.description,
      isNegotiable: isNegotiable ?? this.isNegotiable,
    );
  }
}

class SellFormNotifier extends StateNotifier<SellFormData> {
  SellFormNotifier() : super(const SellFormData());

  void setVin(String value) => state = state.copyWith(vin: value);
  void setBrandModel({required String brand, required String model}) =>
      state = state.copyWith(brand: brand, model: model);

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

  void reset() => state = const SellFormData();
}

final sellFormProvider =
    StateNotifierProvider<SellFormNotifier, SellFormData>((ref) {
  return SellFormNotifier();
});
