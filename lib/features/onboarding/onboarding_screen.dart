import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/features/onboarding/pages/chat_page.dart';
import 'package:liko_auto/features/onboarding/pages/garages_page.dart';
import 'package:liko_auto/features/onboarding/pages/vin_page.dart';
import 'package:liko_auto/features/onboarding/pages/welcome_page.dart';

/// Container des 4 pages d'onboarding (PageView swipeable).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: _controller,
          children: [
            WelcomePage(onContinue: _next, onSkip: _finish),
            VinPage(onContinue: _next),
            GaragesPage(onContinue: _next),
            ChatOnboardingPage(onStart: _finish, onLogin: _finish),
          ],
        ),
      ),
    );
  }
}
