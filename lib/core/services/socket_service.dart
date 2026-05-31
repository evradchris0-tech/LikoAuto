// ignore_for_file: cascade_invocations // Need to chain calls for UI logic
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/core/providers/push_notification_provider.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();

  // Écouter les changements d'état d'authentification pour se connecter/déconnecter
  ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
    final user = next.valueOrNull;
    final previousUser = previous?.valueOrNull;

    if (user != null) {
      service.connect(user);

      if (previous != null && previousUser == null) {
        ref
            .read(pushNotificationProvider)
            .showLocalNotification(
              title: 'Connexion réussie',
              body: 'Connecté avec succès',
            );
      }
    } else {
      service.disconnect();
    }
  }, fireImmediately: true);

  ref.onDispose(service.dispose);

  return service;
});

class SocketService {
  io.Socket? _socket;
  User? _currentUser;
  bool _isBackground = false;

  io.Socket? get socket => _socket;

  Future<void> connect(User user) async {
    _currentUser = user;
    if (_isBackground) return; // Ne pas connecter si en arrière-plan

    if (_socket != null && _socket!.connected) return;

    try {
      final token = await user.getIdToken();
      if (token == null) return;

      _socket =
          io.io(
              AppConfig.baseUrl,
              io.OptionBuilder()
                  .setTransports(['websocket'])
                  .disableAutoConnect()
                  .setAuth({'token': token})
                  .build(),
            )
            ..onConnect((_) {
              if (kDebugMode) {
                print('Socket.IO connecte avec succes : ${_socket!.id}');
              }
            })
            ..onDisconnect((_) {
              if (kDebugMode) {
                print('Socket.IO deconnecte');
              }
            })
            ..onConnectError((error) {
              if (kDebugMode) {
                print('Erreur de connexion Socket.IO : $error');
              }
            })
            ..connect();
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Erreur lors de l'initialisation Socket.IO : $e");
      }
    }
  }

  void disconnect() {
    _currentUser = null;
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  // ── Gestion du cycle de vie de l'application (Foreground / Background) ────

  void onAppResumed() {
    _isBackground = false;
    if (_currentUser != null) {
      connect(_currentUser!);
    }
  }

  void onAppPaused() {
    _isBackground = true;
    if (_socket != null) {
      _socket!.disconnect();
      if (kDebugMode) {
        print('Socket.IO mis en pause (app in background)');
      }
    }
  }

  void dispose() {
    disconnect();
  }
}
