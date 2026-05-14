import 'package:flutter/foundation.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';

/// Avis client sur un garage.
@immutable
class GarageReview {
  const GarageReview({
    required this.author,
    required this.rating,
    required this.body,
    required this.daysAgo,
    this.verified = false,
  });

  final String author;
  final double rating;
  final String body;
  final int daysAgo;
  final bool verified;
}

/// Service proposé par un garage (avec tarif indicatif).
@immutable
class GarageService {
  const GarageService({
    required this.label,
    required this.priceFromFcfa,
    required this.durationMin,
  });

  final String label;
  final int priceFromFcfa;
  final int durationMin;
}

/// Horaires d'ouverture sur une semaine.
@immutable
class GarageHours {
  const GarageHours({required this.day, required this.range});
  final String day;
  final String range; // "08:00 – 18:00" ou "Fermé"
}

/// Donnée complète d'une fiche garage. Construit à partir d'un
/// `GarageCardData` minimal (utilisé dans la recherche) + données mock.
@immutable
class GarageDetail {
  const GarageDetail({
    required this.card,
    required this.about,
    required this.services,
    required this.reviews,
    required this.hours,
    required this.phone,
    required this.address,
  });

  final GarageCardData card;
  final String about;
  final List<GarageService> services;
  final List<GarageReview> reviews;
  final List<GarageHours> hours;
  final String phone;
  final String address;

  int get reviewCount => reviews.length;
}
