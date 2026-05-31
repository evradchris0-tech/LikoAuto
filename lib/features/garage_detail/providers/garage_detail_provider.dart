import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/garage_detail/domain/garage_detail.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';

/// Génère un `GarageDetail` à partir d'une `GarageCardData` minimale en
/// y greffant des données mock cohérentes (services, avis, horaires).
final garageDetailProvider = Provider.family<GarageDetail, GarageCardData>((
  ref,
  card,
) {
  return GarageDetail(
    card: card,
    about: _mockAbout(card),
    services: _mockServices(card),
    reviews: _mockReviews(card),
    hours: _mockHours(card),
    phone: '+237 6 99 ${_seedDigits(card.name, 6)}',
    address: _mockAddress(card),
  );
});

String _mockAbout(GarageCardData c) {
  final specs = c.specialties.join(', ');
  final cert = c.isCertified ? 'certifié Liko Auto ' : '';
  return '${c.name} est un atelier ${cert}spécialisé en $specs, '
      "basé à ${c.location}. Diagnostic électronique, pièces d'origine "
      'et garantie sur les interventions.';
}

List<GarageService> _mockServices(GarageCardData c) {
  final base = <GarageService>[
    const GarageService(
      label: 'Diagnostic électronique',
      priceFromFcfa: 15000,
      durationMin: 45,
    ),
    const GarageService(
      label: 'Vidange + filtres',
      priceFromFcfa: 35000,
      durationMin: 60,
    ),
    const GarageService(
      label: 'Plaquettes de frein',
      priceFromFcfa: 45000,
      durationMin: 90,
    ),
    const GarageService(
      label: 'Pneumatique (par roue)',
      priceFromFcfa: 8000,
      durationMin: 30,
    ),
  ];
  if (c.specialties.contains('Carrosserie')) {
    base.add(
      const GarageService(
        label: 'Réparation carrosserie',
        priceFromFcfa: 75000,
        durationMin: 240,
      ),
    );
  }
  if (c.specialties.contains('Expertise')) {
    base.add(
      const GarageService(
        label: 'Expertise pré-achat',
        priceFromFcfa: 25000,
        durationMin: 60,
      ),
    );
  }
  return base;
}

List<GarageReview> _mockReviews(GarageCardData c) {
  return const [
    GarageReview(
      author: 'Marc T.',
      rating: 5,
      body:
          'Diagnostic rapide et précis. Devis transparent, intervention propre. '
          'Je recommande sans hésiter.',
      daysAgo: 3,
      verified: true,
    ),
    GarageReview(
      author: 'Sophie B.',
      rating: 4,
      body:
          'Bon accueil et délai respecté. Le tarif est un peu au-dessus du marché '
          'mais la qualité est au rendez-vous.',
      daysAgo: 12,
      verified: true,
    ),
    GarageReview(
      author: 'Jean-Paul N.',
      rating: 5,
      body:
          "Expertise pré-achat très complète, ça m'a évité une grosse arnaque.",
      daysAgo: 28,
    ),
    GarageReview(
      author: 'Clara M.',
      rating: 4,
      body: "Personnel pro. Quelques minutes d'attente, rien de grave.",
      daysAgo: 47,
      verified: true,
    ),
  ];
}

List<GarageHours> _mockHours(GarageCardData c) {
  return const [
    GarageHours(day: 'Lundi', range: '08:00 – 18:00'),
    GarageHours(day: 'Mardi', range: '08:00 – 18:00'),
    GarageHours(day: 'Mercredi', range: '08:00 – 18:00'),
    GarageHours(day: 'Jeudi', range: '08:00 – 18:00'),
    GarageHours(day: 'Vendredi', range: '08:00 – 18:00'),
    GarageHours(day: 'Samedi', range: '09:00 – 14:00'),
    GarageHours(day: 'Dimanche', range: 'Fermé'),
  ];
}

String _mockAddress(GarageCardData c) {
  final street = _seedStreets[c.name.hashCode.abs() % _seedStreets.length];
  return '$street, ${c.location}';
}

const _seedStreets = [
  'Rue Joss',
  'Boulevard de la Liberté',
  'Avenue Charles de Gaulle',
  'Rue Bonanjo',
  'Rue Foch',
  'Boulevard du 20 mai',
];

/// Génère N chiffres pseudo-aléatoires stables par seed (nom du garage).
String _seedDigits(String seed, int n) {
  var h = seed.hashCode.abs();
  final b = StringBuffer();
  for (var i = 0; i < n; i++) {
    b.write(h % 10);
    h ~/= 7;
  }
  return b.toString();
}
