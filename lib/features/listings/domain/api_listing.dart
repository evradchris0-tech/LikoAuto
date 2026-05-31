import 'package:flutter/foundation.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

// ── Enums API ─────────────────────────────────────────────────────────────────

enum ListingStatus {
  draft,
  pending,
  published,
  rejected,
  sold,
  expired,
  suspended;

  static ListingStatus fromString(String s) => ListingStatus.values.firstWhere(
    (e) => e.name == s,
    orElse: () => ListingStatus.draft,
  );
}

enum VehicleCondition {
  newCar('new'),
  foreignUsed('foreign_used'),
  locallyUsed('locally_used');

  const VehicleCondition(this.apiValue);
  final String apiValue;

  static VehicleCondition fromString(String s) =>
      VehicleCondition.values.firstWhere(
        (e) => e.apiValue == s,
        orElse: () => VehicleCondition.foreignUsed,
      );

  String get label => switch (this) {
    VehicleCondition.newCar => 'Neuf',
    VehicleCondition.foreignUsed => 'Occasion importée',
    VehicleCondition.locallyUsed => 'Occasion locale',
  };
}

// ── Photo ─────────────────────────────────────────────────────────────────────

@immutable
class ApiPhoto {
  const ApiPhoto({
    required this.id,
    required this.photoUrl,
    this.thumbnailUrl,
    this.isPrimary = false,
    this.position = 0,
  });

  factory ApiPhoto.fromJson(Map<String, dynamic> json) => ApiPhoto(
    id: json['id'].toString(), // API returns UUID
    photoUrl: json['publicUrl'] as String? ?? '', // API returns publicUrl
    thumbnailUrl: json['thumbnailUrl'] as String?,
    isPrimary: json['isPrimary'] as bool? ?? false,
    position: json['sortOrder'] as int? ?? 0,
  );

  final String id;
  final String photoUrl;
  final String? thumbnailUrl;
  final bool isPrimary;
  final int position;
}

// ── Vehicle ───────────────────────────────────────────────────────────────────

@immutable
class ApiVehicle {
  const ApiVehicle({
    required this.id,
    required this.modelId,
    required this.year,
    required this.condition,
    this.vin,
    this.isVinVerified = false,
    this.mileage,
    this.color,
    this.fuelType,
    this.transmissionType,
    this.bodyType,
    this.engineSize,
    this.horsepower,
    this.modelName,
    this.brandName,
  });

  factory ApiVehicle.fromJson(Map<String, dynamic> json) {
    final modelJson = json['model'] as Map<String, dynamic>?;
    final brandJson = modelJson?['brand'] as Map<String, dynamic>?;
    return ApiVehicle(
      id: json['id'] as int,
      modelId: json['model_id'] as int,
      year: json['year'] as int,
      condition: VehicleCondition.fromString(json['condition'] as String),
      vin: json['vin'] as String?,
      isVinVerified: json['is_vin_verified'] as bool? ?? false,
      mileage: json['mileage'] as int?,
      color: json['color'] as String?,
      fuelType: json['fuel_type'] as String?,
      transmissionType: json['transmission_type'] as String?,
      bodyType: json['body_type'] as String?,
      engineSize: json['engine_size'] as String?,
      horsepower: json['horsepower'] as int?,
      modelName: modelJson?['name'] as String?,
      brandName: brandJson?['name'] as String?,
    );
  }

  final int id;
  final int modelId;
  final int year;
  final VehicleCondition condition;
  final String? vin;
  final bool isVinVerified;
  final int? mileage;
  final String? color;
  final String? fuelType;
  final String? transmissionType;
  final String? bodyType;
  final String? engineSize;
  final int? horsepower;
  final String? modelName;
  final String? brandName;

  String get displayName =>
      [brandName, modelName, '$year'].whereType<String>().join(' ');
}

// ── Listing ───────────────────────────────────────────────────────────────────

@immutable
class ApiListing {
  const ApiListing({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.cityId,
    required this.countryId,
    required this.status,
    required this.vehicle,
    this.sellerId,
    this.description,
    this.isBoosted = false,
    this.fraudFlagged = false,
    this.cityName,
    this.photos = const [],
    this.publishedAt,
  });

  factory ApiListing.fromJson(Map<String, dynamic> json) {
    final vehicleJson = json['vehicle'] as Map<String, dynamic>?;
    final cityJson = json['city'] as Map<String, dynamic>?;
    final photosJson =
        json['media'] as List<dynamic>? ?? []; // API returns 'media'

    return ApiListing(
      id: json['id'] as int,
      title: json['title'] as String,
      price: double.parse(json['price'].toString()).toInt(),
      currency: json['currency'] as String? ?? 'XAF',
      cityId: json['city_id'] as int,
      countryId: json['country_id'] as int,
      status: ListingStatus.fromString(json['status'] as String? ?? 'draft'),
      vehicle: vehicleJson != null
          ? ApiVehicle.fromJson(vehicleJson)
          : const ApiVehicle(
              id: 0,
              modelId: 0,
              year: 0,
              condition: VehicleCondition.foreignUsed,
            ),
      sellerId: json['seller_id'] as int?,
      description: json['description'] as String?,
      isBoosted: json['is_boosted'] as bool? ?? false,
      fraudFlagged: json['fraud_flagged'] as bool? ?? false,
      cityName: cityJson?['name'] as String?,
      photos:
          photosJson
              .cast<Map<String, dynamic>>()
              .map(ApiPhoto.fromJson)
              .toList()
            ..sort((a, b) => a.position.compareTo(b.position)),
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
    );
  }

  final int id;
  final int? sellerId;
  final String title;
  final String? description;
  final int price;
  final String currency;
  final int cityId;
  final String? cityName;
  final int countryId;
  final ListingStatus status;
  final ApiVehicle vehicle;
  final bool isBoosted;
  final bool fraudFlagged;
  final List<ApiPhoto> photos;
  final DateTime? publishedAt;

  String get primaryPhotoUrl => photos
      .firstWhere((p) => p.isPrimary, orElse: () => photos.first)
      .photoUrl;

  bool get hasPhotos => photos.isNotEmpty;

  /// Convertit vers le modèle d'affichage [ListingCardData].
  ListingCardData toCardData() {
    return ListingCardData(
      id: id,
      title: title,
      priceFcfa: price,
      location: cityName ?? 'Cameroun',
      mileageKm: vehicle.mileage ?? 0,
      imageAsset: hasPhotos ? primaryPhotoUrl : '',
      photoCount: photos.length,
      imageUrls: hasPhotos ? photos.map((p) => p.photoUrl).toList() : [],
      year: '${vehicle.year}',
      isVinVerified: vehicle.isVinVerified,
    );
  }
}

// ── Request ────────────────────────────────────────────────────────────────────

class CreateListingRequest {
  const CreateListingRequest({
    required this.sellerId,
    required this.title,
    required this.price,
    required this.cityId,
    required this.countryId,
    required this.vehicle,
    this.description,
    this.currency = 'XAF',
    this.status = ListingStatus.pending,
  });

  final int sellerId;
  final String title;
  final String? description;
  final int price;
  final String currency;
  final int cityId;
  final int countryId;
  final ListingStatus status;
  final CreateVehicleRequest vehicle;

  Map<String, dynamic> toJson() => {
    'seller_id': sellerId,
    'title': title,
    if (description != null) 'description': description,
    'price': price,
    'currency': currency,
    'city_id': cityId,
    'country_id': countryId,
    'status': status.name,
    'vehicle': vehicle.toJson(),
  };
}

class CreateVehicleRequest {
  const CreateVehicleRequest({
    required this.modelId,
    required this.year,
    required this.condition,
    this.mileage,
    this.color,
    this.fuelType,
    this.transmissionType,
    this.bodyType,
    this.vin,
    this.isVinVerified = false,
  });

  final int modelId;
  final int year;
  final VehicleCondition condition;
  final int? mileage;
  final String? color;
  final String? fuelType;
  final String? transmissionType;
  final String? bodyType;
  final String? vin;
  final bool isVinVerified;

  Map<String, dynamic> toJson() => {
    'model_id': modelId,
    'year': year,
    'condition': condition.apiValue,
    if (mileage != null) 'mileage': mileage,
    if (color != null) 'color': color,
    if (fuelType != null) 'fuel_type': fuelType,
    if (transmissionType != null) 'transmission_type': transmissionType,
    if (bodyType != null) 'body_type': bodyType,
    if (vin != null) 'vin': vin,
    'is_vin_verified': isVinVerified,
  };
}
