import 'package:drift/drift.dart';
import 'package:liko_auto/core/db/converters.dart';

/// Annonces gardées en favori. Clé = `listing_key` (title+price) en attendant
/// l'ID API. Données dénormalisées car pas (encore) de table `Vehicles`.
@DataClassName('FavoriteRow')
class Favorites extends Table {
  TextColumn get listingKey => text()();
  TextColumn get title => text()();
  IntColumn get priceFcfa => integer()();
  TextColumn get location => text()();
  IntColumn get mileageKm => integer()();
  TextColumn get imageAsset => text()();
  IntColumn get photoCount => integer()();
  TextColumn get year => text().withDefault(const Constant('2021'))();
  BoolColumn get isVinVerified =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {listingKey};
}

/// Annonces vues récemment. Cap = 50 entries (géré côté DAO).
@DataClassName('ViewHistoryRow')
class ViewHistory extends Table {
  TextColumn get listingKey => text()();
  TextColumn get title => text()();
  IntColumn get priceFcfa => integer()();
  TextColumn get location => text()();
  IntColumn get mileageKm => integer()();
  TextColumn get imageAsset => text()();
  IntColumn get photoCount => integer()();
  TextColumn get year => text().withDefault(const Constant('2021'))();
  BoolColumn get isVinVerified =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
  DateTimeColumn get viewedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {listingKey};
}

/// Annonces déposées par l'utilisateur courant.
@DataClassName('MyListingRow')
class MyListings extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get priceFcfa => integer()();
  TextColumn get location => text()();
  IntColumn get mileageKm => integer()();
  TextColumn get imageAsset => text()();
  IntColumn get photoCount => integer()();
  TextColumn get year => text().withDefault(const Constant('2021'))();
  BoolColumn get isVinVerified =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
  IntColumn get status => integer()(); // ListingStatus index
  IntColumn get views => integer().withDefault(const Constant(0))();
  IntColumn get contacts => integer().withDefault(const Constant(0))();
  DateTimeColumn get publishedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get rejectionReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Boîte de réception des notifications.
@DataClassName('NotificationRow')
class Notifications extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()(); // NotifType index
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  /// Payload arbitraire (route cible, IDs, etc.) sérialisé en JSON.
  TextColumn get payload => text()
      .map(const JsonMapConverter())
      .withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Rendez-vous garage.
@DataClassName('BookingRow')
class Bookings extends Table {
  TextColumn get id => text()();
  TextColumn get garageName => text()();
  TextColumn get garageLocation => text()();
  TextColumn get garageImageAsset => text()();
  TextColumn get serviceLabel => text()();
  IntColumn get servicePriceFromFcfa => integer()();
  IntColumn get serviceDurationMin => integer()();
  DateTimeColumn get scheduledAt => dateTime()();
  IntColumn get status => integer()(); // BookingStatus index
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Avis publiés (garage / vehicle / seller / buyer).
@DataClassName('ReviewRow')
class Reviews extends Table {
  TextColumn get id => text()();
  IntColumn get targetType => integer()(); // ReviewTargetType index
  TextColumn get targetId => text()();
  TextColumn get authorName => text()();
  RealColumn get rating => real()();
  TextColumn get body => text().nullable()();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  BoolColumn get verified => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Utilisateurs bloqués (par identifiant de thread chat pour V1).
@DataClassName('BlockedUserRow')
class BlockedUsers extends Table {
  TextColumn get userId => text()();
  DateTimeColumn get blockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Threads chat avec notifications désactivées.
@DataClassName('MutedThreadRow')
class MutedThreads extends Table {
  TextColumn get threadId => text()();
  DateTimeColumn get mutedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {threadId};
}
