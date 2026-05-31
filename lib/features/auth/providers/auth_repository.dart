import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/api_client.dart';
import 'package:liko_auto/core/api/api_exception.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/features/auth/domain/user_profile.dart';

// ─── Providers Firebase ───────────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(apiClientProvider),
  );
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// ─── Payload d'inscription envoyé au backend NestJS ──────────────────────────

/// Données métier complémentaires envoyées à NestJS lors de l'inscription.
class RegisterPayload {
  const RegisterPayload({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.role,
    this.homeCountryCode = 'CM',
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String address;

  /// 'buyer' | 'seller'
  final String role;
  final String homeCountryCode;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'address': address,
    'role': role,
    'homeCountryCode': homeCountryCode,
  };
}

// ─── Repository ───────────────────────────────────────────────────────────────

class AuthRepository {
  AuthRepository(this._auth, this._api);

  final FirebaseAuth _auth;
  final ApiClient _api;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Firebase Auth ───────────────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> registerWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Initie le flux de connexion par téléphone.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onError,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Vérifie le code SMS manuel.
  Future<void> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  // ── NestJS Backend ──────────────────────────────────────────────────────────

  /// Inscrit l'utilisateur en 2 étapes :
  /// 1. Firebase Auth (email + password)
  /// 2. NestJS `/auth/register` (données métier + token Firebase)
  ///
  /// Si le backend n'est pas encore disponible, l'étape 2 est silencieusement
  /// ignorée et [UserProfile] sera chargé à la prochaine connexion.
  Future<UserProfile?> registerWithBackend(
    String email,
    String password,
    RegisterPayload payload,
  ) async {
    // Étape 1 — Firebase
    await registerWithEmail(email, password);

    // Étape 2 — NestJS (tentative, non bloquante en dev)
    return _syncWithBackend(payload.toJson());
  }

  /// Appelé après une connexion Firebase réussie pour récupérer le profil
  /// complet (rôles, permissions, pays) depuis NestJS.
  ///
  /// Retourne `null` si le backend n'est pas joignable.
  Future<UserProfile?> fetchUserProfile() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(AppConfig.authMe);
      final data = response.data;
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } on ApiException {
      // Backend non disponible — mode dégradé
      return null;
    }
  }

  // ── Privé ───────────────────────────────────────────────────────────────────

  Future<UserProfile?> _syncWithBackend(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        AppConfig.authRegister,
        data: payload,
      );
      final data = response.data;
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } on ApiException {
      // Backend non disponible — l'inscription Firebase a quand même réussi.
      return null;
    }
  }
}
