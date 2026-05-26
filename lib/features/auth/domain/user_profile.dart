import 'package:liko_auto/features/auth/domain/country.dart';

/// Scope d'un rôle : client marketplace ou staff backoffice.
enum RoleScope { marketplace, backoffice }

/// Un rôle assigné à l'utilisateur (table `roles` NestJS).
class UserRole {
  const UserRole({
    required this.name,
    required this.displayName,
    required this.scope,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
        name: json['name'] as String,
        displayName: json['displayName'] as String,
        scope: json['scope'] == 'backoffice'
            ? RoleScope.backoffice
            : RoleScope.marketplace,
      );

  final String name;        // ex: 'moderator_junior', 'seller'
  final String displayName; // ex: 'Modérateur Junior', 'Vendeur Particulier'
  final RoleScope scope;
}

/// Profil métier de l'utilisateur (table `user_profiles` NestJS).
///
/// Distinct du User Firebase qui ne contient que l'identité d'authentification.
/// Ce profil contient les données humaines et les droits d'accès (PBAC).
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.homeCountry,
    required this.roles,
    required this.permissions,
    this.backendId,
    this.phone,
    this.profilePictureUrl,
    this.allowedCountries = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'] as Map<String, dynamic>? ?? {};
    final rolesJson = (json['roles'] as List<dynamic>?) ?? [];
    final permissionsJson = (json['permissions'] as List<dynamic>?) ?? [];
    final allowedCountriesJson =
        (json['allowedCountries'] as List<dynamic>?) ?? [];

    // Backend returns integer `id` (DB PK) + string `uid`/`firebase_uid`.
    final rawId = json['id'];
    return UserProfile(
      backendId: rawId is int ? rawId : null,
      uid: json['uid'] as String? ??
          json['firebase_uid'] as String? ??
          (rawId is String ? rawId : ''),
      email: json['email'] as String,
      firstName: profileJson['firstName'] as String? ?? '',
      lastName: profileJson['lastName'] as String? ?? '',
      phone: profileJson['phone'] as String?,
      profilePictureUrl: profileJson['profilePictureUrl'] as String?,
      homeCountry: profileJson['homeCountry'] != null
          ? Country.fromJson(
              profileJson['homeCountry'] as Map<String, dynamic>,
            )
          : const Country(code: 'CM', name: 'Cameroun'),
      roles: rolesJson
          .cast<Map<String, dynamic>>()
          .map(UserRole.fromJson)
          .toList(),
      permissions: permissionsJson.cast<String>(),
      allowedCountries: allowedCountriesJson
          .cast<Map<String, dynamic>>()
          .map(Country.fromJson)
          .toList(),
    );
  }

  /// UID Firebase.
  final String uid;

  /// ID entier attribué par le backend (table `users`). Nécessaire pour seller_id.
  final int? backendId;

  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profilePictureUrl;

  /// Pays de résidence par défaut (filtre initial des annonces).
  final Country homeCountry;

  /// Rôles attribués (ex: ['seller', 'buyer']).
  final List<UserRole> roles;

  /// Liste aplatie des permissions PBAC (ex: ['vehicle:create', 'vehicle:delete']).
  final List<String> permissions;

  /// Pays sur lesquels le staff est autorisé à agir (vide pour les clients).
  final List<Country> allowedCountries;

  String get fullName => '$firstName $lastName'.trim();

  bool hasPermission(String permission) => permissions.contains(permission);

  bool get isBackofficeStaff =>
      roles.any((r) => r.scope == RoleScope.backoffice);

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? profilePictureUrl,
    Country? homeCountry,
  }) {
    return UserProfile(
      uid: uid,
      backendId: backendId,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      homeCountry: homeCountry ?? this.homeCountry,
      roles: roles,
      permissions: permissions,
      allowedCountries: allowedCountries,
    );
  }
}
