import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/constants/app_constants.dart';
import 'package:liko_auto/core/providers/push_notification_provider.dart';
import 'package:liko_auto/core/services/socket_service.dart';
import 'package:liko_auto/core/theme/app_theme.dart';

class _BouncingScrollBehavior extends MaterialScrollBehavior {
  const _BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class LikoAutoApp extends ConsumerStatefulWidget {
  const LikoAutoApp({super.key});

  @override
  ConsumerState<LikoAutoApp> createState() => _LikoAutoAppState();
}

class _LikoAutoAppState extends ConsumerState<LikoAutoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Demander la permission pour les notifications au lancement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushNotificationProvider).initialize();
      // On initialise l'écoute de l'authentification dans le SocketService
      ref.read(socketServiceProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(socketServiceProvider).onAppResumed();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(socketServiceProvider).onAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      scrollBehavior: const _BouncingScrollBehavior(),
    );
  }
}
