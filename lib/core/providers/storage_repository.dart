import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(firebaseStorageProvider));
});

class StorageRepository {
  // Upload simulé en attendant l'activation de Firebase Storage (OPTION A).
  // ignore: avoid_unused_constructor_parameters
  StorageRepository(FirebaseStorage storage);

  /// Upload une image vers Firebase Storage et retourne l'URL de téléchargement.
  /// [path] est le chemin de destination (ex: 'vehicles/uid123/photo1.jpg')
  Future<String> uploadImage({required File imageFile, required String path}) async {
    // OPTION B : Mode Simulation
    // Pour éviter de bloquer le développement sans carte bancaire sur Firebase.
    // Simule un temps d'upload réseau.
    await Future<void>.delayed(const Duration(seconds: 2));

    return 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=800';
  }

  Future<void> deleteFile(String path) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
