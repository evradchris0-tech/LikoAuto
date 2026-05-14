import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/app/app.dart';
import 'package:liko_auto/core/providers/package_info_provider.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge : l'app dessine derrière les barres système (status + nav).
  // Imposé par défaut sur Android 15 (compileSdk 35) ; on l'active explicitement
  // pour cohérence sur Android 12+.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Transparence des barres système ; les icônes s'adapteront par écran via
  // `AnnotatedRegion<SystemUiOverlayStyle>`.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final packageInfo = await PackageInfo.fromPlatform();
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
