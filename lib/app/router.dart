import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/features/auth/forgot_password_screen.dart';
import 'package:liko_auto/features/auth/login_screen.dart';
import 'package:liko_auto/features/auth/otp_verification_screen.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/features/auth/register_screen.dart';
import 'package:liko_auto/features/chat/chat_detail_screen.dart';
import 'package:liko_auto/features/chat/chat_list_screen.dart';
import 'package:liko_auto/features/home/home_screen.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/onboarding/onboarding_screen.dart';
import 'package:liko_auto/features/profile/profile_screen.dart';
import 'package:liko_auto/features/search/search_screen.dart';
import 'package:liko_auto/features/sell/sell_screen.dart';
import 'package:liko_auto/features/shell/app_shell.dart';
import 'package:liko_auto/features/showcase/showcase_screen.dart';
import 'package:liko_auto/features/splash/splash_screen.dart';
import 'package:liko_auto/features/vehicle_details/vehicle_detail_screen.dart';

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
  static const String vehicleDetail = '/vehicle_detail';
  static const String register = '/register';
  static const String login = '/login';
  static const String otpVerification = '/otp_verification';
  static const String forgotPassword = '/forgot_password';
  static const String chatDetail = '/chat_detail';

  /// Routes nécessitant une session utilisateur.
  static const Set<String> guarded = {sell, chat, profile, chatDetail};
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router exposé via Riverpod pour réagir aux changements d'auth.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final loc = state.matchedLocation;

      final needsAuth = AppRoutes.guarded.any(
        (r) => loc == r || loc.startsWith('$r/') || loc.startsWith('$r?'),
      );
      if (needsAuth && !isLoggedIn) {
        return '${AppRoutes.login}?from=${Uri.encodeComponent(loc)}';
      }
      return null;
    },
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
      GoRoute(
        path: AppRoutes.vehicleDetail,
        name: 'vehicleDetail',
        builder: (context, state) {
          final data = state.extra as ListingCardData?;
          if (data == null) {
            return const Scaffold(
              body: Center(child: Text('Erreur : Données manquantes')),
            );
          }
          return VehicleDetailScreen(data: data);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          final verificationId =
              state.uri.queryParameters['verificationId'] ?? '';
          return OtpVerificationScreen(
            phoneNumber: phone,
            verificationId: verificationId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatDetail,
        name: 'chatDetail',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '1';
          return ChatDetailScreen(chatId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.sell,
        name: 'sell',
        builder: (context, state) => const SellScreen(),
      ),

      // Shell stateful — persiste le BottomNav entre les onglets visibles.
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
          // Branche placeholder pour préserver l'index du FAB Vendre dans
          // l'AppShell. Le FAB pousse `context.push(AppRoutes.sell)` au lieu de
          // changer de branche.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/_dummy_sell',
                builder: (context, state) => const Scaffold(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                name: 'chat',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route introuvable : ${state.uri}'))),
  );
});
