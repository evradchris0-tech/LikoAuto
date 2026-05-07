import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/app/app.dart';
import 'package:liko_auto/core/providers/package_info_provider.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Callback essentiel pour recevoir des notifications quand l'application est totalement fermée (Background)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enregistrer le gestionnaire de notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Récupération des infos de version (pubspec.yaml)
  final packageInfo = await PackageInfo.fromPlatform();

  // Préférences locales (flag onboarding, futurs flags)
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        packageInfoProvider.overrideWithValue(packageInfo),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LikoAutoApp(),
    ),
  );
}
