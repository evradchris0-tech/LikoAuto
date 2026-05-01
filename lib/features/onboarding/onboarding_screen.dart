import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/features/onboarding/pages/chat_page.dart';
import 'package:liko_auto/features/onboarding/pages/garages_page.dart';
import 'package:liko_auto/features/onboarding/pages/vin_page.dart';
import 'package:liko_auto/features/onboarding/pages/welcome_page.dart';

/// Container des 4 pages d'onboarding.
/// - PageView avec transition fluide (500ms, fastEaseInToSlowEaseOut)
/// - Dots de progression animés (le dot actif s'élargit)
/// - Bouton "Passer" unique en haut à droite
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
  }

  void _finish() {
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── PageView ──────────────────────────────────────────────────
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                WelcomePage(onContinue: _next, onSkip: _finish),
                VinPage(onContinue: _next),
                GaragesPage(onContinue: _next),
                ChatOnboardingPage(onStart: _finish, onLogin: _finish),
              ],
            ),

            // ── Bouton "Passer" — haut droit — caché sur dernière page ───
            if (_currentPage < _pageCount - 1)
              Positioned(top: 8, right: 16, child: _SkipButton(onTap: _finish)),

            // ── Dots de progression — bas de page ─────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _PageDots(count: _pageCount, current: _currentPage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton "Passer" discret avec ripple.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            'Passer',
            style: TextStyle(
              color: AppColors.neutral,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dots de progression avec animation.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final isActive = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
