import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/features/home/home_screen.dart';
import 'package:liko_auto/features/onboarding/onboarding_screen.dart';
import 'package:liko_auto/features/placeholders/placeholder_screen.dart';
import 'package:liko_auto/features/search/search_screen.dart';
import 'package:liko_auto/features/shell/app_shell.dart';
import 'package:liko_auto/features/showcase/showcase_screen.dart';
import 'package:liko_auto/features/splash/splash_screen.dart';

/// Toutes les routes de l'application Liko Auto.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String search = '/search';
  static const String sell = '/sell';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String showcase = '/_showcase';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.showcase,
      name: 'showcase',
      builder: (context, state) => const ShowcaseScreen(),
    ),

    // Shell stateful — persiste le BottomNav entre les 5 onglets.
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.search,
              name: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.sell,
              name: 'sell',
              builder: (context, state) => const PlaceholderScreen(
                title: 'Vendre votre véhicule',
                subtitle:
                    "Le flux de dépôt d'annonce en 5 étapes (VIN, photos, vidéo, récap) sera disponible dans le prochain sprint.",
                icon: Icons.add_circle_outline_rounded,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chat,
              name: 'chat',
              builder: (context, state) => const PlaceholderScreen(
                title: 'Vos conversations',
                subtitle:
                    'La messagerie sécurisée acheteur ⇄ vendeur ⇄ garage arrive bientôt. Vos conversations apparaîtront ici.',
                icon: Icons.chat_bubble_outline_rounded,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, state) => const PlaceholderScreen(
                title: 'Mon compte',
                subtitle:
                    'Profil, mes annonces, mes favoris et paramètres seront accessibles ici.',
                icon: Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Route introuvable : ${state.uri}'))),
);
