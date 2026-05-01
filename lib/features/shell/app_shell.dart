import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/core/theme/app_colors.dart';

/// Shell de navigation principal — persiste le BottomNav entre les 5 onglets
/// (Accueil, Recherche, Vendre, Chat, Profil) via StatefulShellRoute.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: shell,
      bottomNavigationBar: _BottomNav(
        selectedIndex: shell.currentIndex,
        onTap: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.primarySoft,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              label: 'Recherche',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(
                Icons.add_circle_rounded,
                color: AppColors.primary,
              ),
              label: 'Vendre',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primary,
              ),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
              label: 'Moi',
            ),
          ],
        ),
      ),
    );
  }
}
