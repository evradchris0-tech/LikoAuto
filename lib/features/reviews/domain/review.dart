import 'package:flutter/foundation.dart';

enum ReviewTargetType { garage, vehicle, seller, buyer }

@immutable
class Review {
  const Review({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.authorName,
    required this.rating,
    required this.createdAt,
    this.body,
    this.tags = const [],
    this.verified = false,
  });

  final String id;
  final ReviewTargetType targetType;
  final String targetId;
  final String authorName;
  final double rating;
  final String? body;
  final List<String> tags;
  final bool verified;
  final DateTime createdAt;
}

/// Tags suggérés affichés en chips lors de la rédaction.
const reviewSuggestedTags = <String>[
  'Professionnel',
  'Rapide',
  'Honnête',
  'Tarif juste',
  'Communication claire',
  'Recommandé',
  'À éviter',
  'Délai non respecté',
];
