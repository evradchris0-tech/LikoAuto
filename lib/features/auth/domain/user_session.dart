import 'package:firebase_auth/firebase_auth.dart';
import 'package:liko_auto/features/auth/domain/user_profile.dart';

/// État global de la session utilisateur.
///
/// - LoadingSession     : synchronisation en cours (token Firebase en attente).
/// - GuestSession       : non connecté (invité).
/// - AuthenticatedSession : connecté, profil NestJS chargé.
/// - PendingSyncSession : Firebase OK mais NestJS pas encore consulté
///   (ex : réseau coupé, backend non déployé). L'app fonctionne en mode dégradé.
sealed class UserSession {
  const UserSession();
}

final class LoadingSession extends UserSession {
  const LoadingSession();
}

final class GuestSession extends UserSession {
  const GuestSession();
}

/// Firebase authentifié mais le backend NestJS n'a pas encore confirmé.
/// L'app peut afficher les écrans non-protégés mais pas les actions PBAC.
final class PendingSyncSession extends UserSession {
  const PendingSyncSession({required this.firebaseUser});
  final User firebaseUser;
}

/// Session complète : Firebase + profil NestJS + permissions PBAC.
final class AuthenticatedSession extends UserSession {
  const AuthenticatedSession({
    required this.firebaseUser,
    required this.profile,
  });

  final User firebaseUser;
  final UserProfile profile;

  bool hasPermission(String permission) => profile.hasPermission(permission);
}

extension UserSessionX on UserSession {
  bool get isLoading => this is LoadingSession;
  bool get isGuest => this is GuestSession;
  bool get isAuthenticated => this is AuthenticatedSession;
  bool get isPendingSync => this is PendingSyncSession;

  /// Vrai si l'utilisateur est au moins authentifié Firebase (même sans profil NestJS).
  bool get isSignedIn =>
      this is AuthenticatedSession || this is PendingSyncSession;

  UserProfile? get profile => this is AuthenticatedSession
      ? (this as AuthenticatedSession).profile
      : null;
}
