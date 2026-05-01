import 'package:go_router/go_router.dart';
import 'package:liko_auto/features/home/home_screen.dart';
import 'package:liko_auto/features/onboarding/onboarding_screen.dart';
import 'package:liko_auto/features/showcase/showcase_screen.dart';
import 'package:liko_auto/features/splash/splash_screen.dart';

/// Toutes les routes de l'application Liko Auto.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String showcase = '/_showcase';
}

final GoRouter appRouter = GoRouter(
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
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.showcase,
      name: 'showcase',
      builder: (context, state) => const ShowcaseScreen(),
    ),
  ],
  errorBuilder: (context, state) => const HomeScreen(),
);
