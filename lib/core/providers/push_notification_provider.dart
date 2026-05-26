import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final pushNotificationProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.watch(firebaseMessagingProvider));
});

class PushNotificationService {

  PushNotificationService(this._messaging);
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications Importantes',
    description: 'Ce canal est utilisé pour les notifications urgentes.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    final notificationSettings = await _messaging.requestPermission(
      
    );

    if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const initializationSettingsDarwin =
          DarwinInitializationSettings();

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // CORRECTION FINALE : Le paramètre nommé est 'settings' d'après la source
      await _localNotifications.initialize(
        settings: initializationSettings,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      final token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;

        if (notification != null && !kIsWeb) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notification cliquée: ${message.data}');
        }
      });
    }
  }
}
