import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/biometric/data/biometric_repository.dart';

export 'package:liko_auto/features/biometric/data/biometric_repository.dart'
    show BiometricRepository;

/// Vrai si l'appareil supporte la biométrie (hardware + empreinte enregistrée).
final biometricAvailableProvider = FutureProvider<bool>((ref) {
  return ref.watch(biometricRepositoryProvider).isAvailable();
});

/// Vrai si l'utilisateur a activé la biométrie dans les préférences de l'app.
final biometricEnabledProvider = Provider<bool>((ref) {
  return ref.watch(biometricRepositoryProvider).isEnabled;
});
