import 'package:flutter/foundation.dart';

/// Tranches de prix utilisées dans le filtre Voitures (en FCFA).
enum PriceRange {
  under5M('< 5 M', 0, 5000000),
  range5to10M('5 – 10 M', 5000000, 10000000),
  range10to20M('10 – 20 M', 10000000, 20000000),
  range20to30M('20 – 30 M', 20000000, 30000000),
  over30M('> 30 M', 30000000, 999999999);

  const PriceRange(this.label, this.min, this.max);
  final String label;
  final int min;
  final int max;
}

@immutable
class VehicleFilters {
  const VehicleFilters({
    this.priceRange,
    this.brand,
    this.year,
    this.city,
    this.vinVerifiedOnly = false,
  });

  final PriceRange? priceRange;
  final String? brand;
  final int? year;
  final String? city;
  final bool vinVerifiedOnly;

  int get activeCount {
    var n = 0;
    if (priceRange != null) n++;
    if (brand != null) n++;
    if (year != null) n++;
    if (city != null) n++;
    if (vinVerifiedOnly) n++;
    return n;
  }

  VehicleFilters copyWith({
    PriceRange? priceRange,
    String? brand,
    int? year,
    String? city,
    bool? vinVerifiedOnly,
    bool clearPriceRange = false,
    bool clearBrand = false,
    bool clearYear = false,
    bool clearCity = false,
  }) {
    return VehicleFilters(
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      brand: clearBrand ? null : (brand ?? this.brand),
      year: clearYear ? null : (year ?? this.year),
      city: clearCity ? null : (city ?? this.city),
      vinVerifiedOnly: vinVerifiedOnly ?? this.vinVerifiedOnly,
    );
  }

  static const empty = VehicleFilters();
}

@immutable
class GarageFilters {
  const GarageFilters({
    this.specialty,
    this.city,
    this.minRating,
    this.openNowOnly = false,
  });

  final String? specialty;
  final String? city;
  final double? minRating;
  final bool openNowOnly;

  int get activeCount {
    var n = 0;
    if (specialty != null) n++;
    if (city != null) n++;
    if (minRating != null) n++;
    if (openNowOnly) n++;
    return n;
  }

  GarageFilters copyWith({
    String? specialty,
    String? city,
    double? minRating,
    bool? openNowOnly,
    bool clearSpecialty = false,
    bool clearCity = false,
    bool clearMinRating = false,
  }) {
    return GarageFilters(
      specialty: clearSpecialty ? null : (specialty ?? this.specialty),
      city: clearCity ? null : (city ?? this.city),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      openNowOnly: openNowOnly ?? this.openNowOnly,
    );
  }

  static const empty = GarageFilters();
}
