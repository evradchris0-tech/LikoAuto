import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/pages/chat_page.dart';
import 'package:liko_auto/features/onboarding/pages/garages_page.dart';
import 'package:liko_auto/features/onboarding/pages/role_selection_page.dart';
import 'package:liko_auto/features/onboarding/pages/vin_page.dart';
import 'package:liko_auto/features/onboarding/pages/welcome_page.dart';

/// 4 pages swipeables — Welcome / VIN / Garages / Chat. Une fois terminé,
/// `onboardingSeenProvider` est marqué et l'utilisateur ne reverra plus
/// l'onboarding au prochain lancement.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  static const _totalPages = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markSeen() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
  }

  void _next() {
    if (_index < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await _markSeen();
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _goLogin() async {
    await _markSeen();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _skip() async {
    await _markSeen();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              currentIndex: _index,
              total: _totalPages,
              onSkip: _index < _totalPages - 1 ? _skip : null,
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  WelcomePage(onContinue: _next),
                  VinPage(onContinue: _next),
                  GaragesPage(onContinue: _next),
                  RoleSelectionPage(onContinue: _next),
                  ChatOnboardingPage(onStart: _finish, onLogin: _goLogin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.currentIndex, required this.total, this.onSkip});

  final int currentIndex;
  final int total;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(total, (i) {
                final isActive = i == currentIndex;
                final isPast = i < currentIndex;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive || isPast
                          ? AppColors.primary
                          : AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          AppSpacing.gapMd,
          if (onSkip != null)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.neutral,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Passer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
