import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/auth/domain/user_session.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';

/// Provider de la session utilisateur complète.
///
/// Écoute [authStateChangesProvider] (Firebase) et, dès qu'un utilisateur
/// est connecté, appelle [AuthRepository.fetchUserProfile] pour obtenir le
/// profil NestJS (permissions, pays, rôles).
///
/// États possibles :
/// - [LoadingSession]       — synchronisation en cours
/// - [GuestSession]         — non connecté
/// - [PendingSyncSession]   — Firebase OK, backend non joignable (mode dégradé)
/// - [AuthenticatedSession] — session complète
///
/// Usage dans n'importe quel widget :
/// ```dart
/// final session = ref.watch(userSessionProvider);
/// if (session.isAuthenticated) { ... }
/// if (session.hasPermission(AppPermissions.vehicles.create)) { ... }
/// ```
final userSessionProvider = StreamProvider<UserSession>((ref) async* {
  yield const LoadingSession();

  // Accès direct au stream Firebase — pas de ref.watch pour éviter la
  // resubscription en boucle dans un StreamProvider.
  final repo = ref.read(authRepositoryProvider);
  final authStream = repo.authStateChanges();

  await for (final firebaseUser in authStream) {
    if (firebaseUser == null) {
      yield const GuestSession();
      continue;
    }

    // Firebase connecté — on tente de récupérer le profil NestJS.
    yield PendingSyncSession(firebaseUser: firebaseUser);

    final profile = await repo.fetchUserProfile();

    if (profile != null) {
      yield AuthenticatedSession(firebaseUser: firebaseUser, profile: profile);
    }
    // Si le backend ne répond pas, on reste en PendingSyncSession (mode dégradé).
  }
});

/// Raccourci — vrai si l'utilisateur a au moins une session Firebase active.
final isSignedInProvider = Provider<bool>((ref) {
  return ref
      .watch(userSessionProvider)
      .maybeWhen(data: (session) => session.isSignedIn, orElse: () => false);
});

/// Raccourci — profil NestJS si disponible, sinon null.
final userProfileProvider = Provider((ref) {
  return ref
      .watch(userSessionProvider)
      .maybeWhen(data: (session) => session.profile, orElse: () => null);
});

/// Vérifie une permission PBAC. Retourne false si la session est incomplète.
///
/// ```dart
/// final canCreate = ref.watch(hasPermissionProvider(AppPermissions.vehicles.create));
/// ```
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  return ref
      .watch(userSessionProvider)
      .maybeWhen(
        data: (session) => session.hasPermission(permission),
        orElse: () => false,
      );
});

extension on UserSession {
  bool hasPermission(String permission) {
    if (this is AuthenticatedSession) {
      return (this as AuthenticatedSession).hasPermission(permission);
    }
    return false;
  }
}
