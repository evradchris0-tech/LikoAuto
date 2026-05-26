import 'package:flutter/foundation.dart';
import 'package:liko_auto/features/garage_detail/domain/garage_detail.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmé';
      case BookingStatus.completed:
        return 'Passé';
      case BookingStatus.cancelled:
        return 'Annulé';
    }
  }
}

@immutable
class Booking {
  const Booking({
    required this.id,
    required this.garageName,
    required this.garageLocation,
    required this.garageImageAsset,
    required this.service,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
    this.note,
  });

  /// Helper pour construire à partir d'une `GarageCardData` + service choisi.
  factory Booking.fromGarage({
    required String id,
    required GarageCardData garage,
    required GarageService service,
    required DateTime scheduledAt,
    String? note,
  }) {
    return Booking(
      id: id,
      garageName: garage.name,
      garageLocation: garage.location,
      garageImageAsset: garage.imageAsset,
      service: service,
      scheduledAt: scheduledAt,
      status: BookingStatus.confirmed,
      note: note,
      createdAt: DateTime.now(),
    );
  }

  final String id;
  final String garageName;
  final String garageLocation;
  final String garageImageAsset;
  final GarageService service;
  final DateTime scheduledAt;
  final BookingStatus status;
  final String? note;
  final DateTime createdAt;

  Booking copyWith({BookingStatus? status}) {
    return Booking(
      id: id,
      garageName: garageName,
      garageLocation: garageLocation,
      garageImageAsset: garageImageAsset,
      service: service,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
      note: note,
      createdAt: createdAt,
    );
  }
}
