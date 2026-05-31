import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/api_client.dart';
import 'package:liko_auto/core/api/app_config.dart';

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final pushNotificationProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(
    ref.watch(firebaseMessagingProvider),
    ref.watch(apiClientProvider),
  );
});

class PushNotificationService {
  PushNotificationService(this._messaging, this._apiClient);
  final FirebaseMessaging _messaging;
  final ApiClient _apiClient;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'Notifications Importantes', // title
    description:
        'Cette chaîne est utilisée pour les notifications importantes.', // description
    importance: Importance.high,
  );

  Future<void> initialize() async {
    try {
      await _messaging.requestPermission();

      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      // CORRECTION FINALE : Le paramètre nommé est 'settings' d'après la source
      await _localNotifications.initialize(settings: initializationSettings);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      final token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      unawaited(_sendTokenToBackend(token));

      _messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('FCM Token Refreshed: $newToken');
        }
        unawaited(_sendTokenToBackend(newToken));
      });

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
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Erreur d'initialisation FCM : $e");
      }
    }
  }

  Future<void> _sendTokenToBackend(String? token) async {
    if (token == null) return;
    try {
      await _apiClient.post<dynamic>(
        AppConfig.fcmToken,
        data: {'token': token},
      );
      if (kDebugMode) {
        print('FCM Token envoyé au backend avec succès');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Erreur lors de l'envoi du token FCM au backend : $e");
      }
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
