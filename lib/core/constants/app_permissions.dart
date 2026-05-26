/// Miroir Flutter des permissions PBAC définies dans `permissions.config.ts` NestJS.
///
/// Ces constantes sont utilisées dans l'UI pour masquer / afficher des actions
/// selon les droits de l'utilisateur connecté :
/// ```dart
/// if (session.hasPermission(AppPermissions.vehicles.validate)) {
///   // Afficher le bouton "Valider"
/// }
/// ```
///
/// RÈGLE DE SYNCHRONISATION :
/// Toute modification dans `permissions.config.ts` NestJS doit être reflétée ici.
abstract final class AppPermissions {
  static const VehiclePermissions vehicles = VehiclePermissions._();
  static const UserPermissions users = UserPermissions._();
  static const FinancePermissions finance = FinancePermissions._();
  static const BookingPermissions bookings = BookingPermissions._();
  static const GaragePermissions garages = GaragePermissions._();
  static const StaffPermissions staff = StaffPermissions._();
}

final class VehiclePermissions {
  const VehiclePermissions._();

  /// Créer une annonce (scope marketplace — Vendeur Particulier & Concessionnaire).
  String get create => 'vehicle:create';

  /// Modifier sa propre annonce.
  String get update => 'vehicle:update';

  /// Supprimer sa propre annonce.
  String get deleteSelf => 'vehicle:delete-self';

  /// Validation simple d'une annonce (Modérateur Junior).
  String get validate => 'vehicle:validate';

  /// Lever une alerte sur annonce (Modérateur Intermédiaire).
  String get resolveAlert => 'vehicle:resolve-alert';

  /// Suppression définitive d'une annonce (Modérateur Sénior).
  String get delete => 'vehicle:delete';

  /// Blocage temporaire d'une annonce (Modérateur Sénior).
  String get suspend => 'vehicle:suspend';
}

final class UserPermissions {
  const UserPermissions._();

  /// Consulter son propre profil.
  String get viewSelf => 'user:view-self';

  /// Modifier son propre profil.
  String get updateSelf => 'user:update-self';

  /// Lever une alerte de bannissement (Modérateur Sénior).
  String get banResolve => 'user:ban-resolve';

  /// Bannissement temporaire d'un utilisateur (Modérateur Sénior).
  String get banTemporary => 'user:ban-temporary';
}

final class FinancePermissions {
  const FinancePermissions._();

  /// Voir les rapports financiers (Finance Manager).
  String get viewReports => 'finance:view';

  /// Gérer les abonnements concessionnaires (Finance Manager).
  String get manageSubscriptions => 'finance:subscriptions';
}

final class BookingPermissions {
  const BookingPermissions._();

  /// Créer une réservation (Acheteur).
  String get create => 'booking:create';

  /// Voir ses propres réservations.
  String get viewSelf => 'booking:view-self';
}

final class GaragePermissions {
  const GaragePermissions._();

  /// Créer un garage / concessionnaire.
  String get create => 'garage:create';

  /// Gérer les annonces d'un garage (Concessionnaire).
  String get manage => 'garage:manage';
}

final class StaffPermissions {
  const StaffPermissions._();

  /// Gérer les membres du staff (Directeur Pays / Supra Admin).
  String get manage => 'staff:manage';

  /// Accéder au tableau de bord backoffice.
  String get viewDashboard => 'staff:view-dashboard';
}
