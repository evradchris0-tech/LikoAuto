import 'package:flutter/foundation.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

/// État éditorial d'une annonce déposée par l'utilisateur.
enum ListingStatus {
  /// Visible publiquement.
  active,

  /// En cours de modération (vérification VIN, photos).
  pending,

  /// Vendue par l'utilisateur.
  sold,

  /// Refusée par la modération (VIN invalide, photos non conformes).
  rejected,

  /// Désactivée par l'utilisateur (pause).
  paused,
}

extension ListingStatusX on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.pending:
        return 'En attente';
      case ListingStatus.sold:
        return 'Vendue';
      case ListingStatus.rejected:
        return 'Refusée';
      case ListingStatus.paused:
        return 'En pause';
    }
  }
}

@immutable
class MyListing {
  const MyListing({
    required this.id,
    required this.card,
    required this.status,
    required this.views,
    required this.contacts,
    required this.publishedAt,
    this.expiresAt,
    this.rejectionReason,
  });

  final String id;
  final ListingCardData card;
  final ListingStatus status;
  final int views;
  final int contacts;
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final String? rejectionReason;
}
