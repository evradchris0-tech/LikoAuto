import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/features/showcase/showcase_screen.dart';

/// Routes de l'application. Pour l'instant : showcase du Design System.
/// Sera enrichi au Sprint 3 avec onboarding, home, search, etc.
abstract final class AppRoutes {
  static const String showcase = '/_showcase';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.showcase,
  routes: [
    GoRoute(
      path: AppRoutes.showcase,
      name: 'showcase',
      builder: (context, state) => const ShowcaseScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Route introuvable : ${state.uri}'))),
);
