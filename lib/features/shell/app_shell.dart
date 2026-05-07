import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/features/shell/widgets/app_drawer.dart';

/// Shell de navigation principal â€” persiste le BottomNav entre les 5 onglets
/// (Accueil, Recherche, Vendre, Chat, Profil) via StatefulShellRoute.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: shell.goBranch,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              unselectedIconTheme: const IconThemeData(color: AppColors.neutral),
              selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: const TextStyle(color: AppColors.neutral),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  selectedIcon: Icon(Icons.space_dashboard_rounded),
                  label: Text('Accueil'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search_rounded),
                  selectedIcon: Icon(Icons.search_rounded),
                  label: Text('Annonces'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded),
                  label: Text('Vendre'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum_rounded),
                  label: Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle_rounded),
                  label: Text('Profil'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: shell),
          ],
        ),
        drawer: const AppDrawer(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: shell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.sell),
        backgroundColor: AppColors.primary,
        elevation: 6,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 20,
        height: 80, // Increased height to prevent overflow
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.space_dashboard_outlined,
              selectedIcon: Icons.space_dashboard_rounded,
              label: 'Accueil',
              isSelected: shell.currentIndex == 0,
              onTap: () => shell.goBranch(0, initialLocation: 0 == shell.currentIndex),
            ),
            _NavBarItem(
              icon: Icons.search_rounded,
              selectedIcon: Icons.search_rounded,
              label: 'Annonces',
              isSelected: shell.currentIndex == 1,
              onTap: () => shell.goBranch(1, initialLocation: 1 == shell.currentIndex),
            ),
            const SizedBox(width: 40), // Spacer for FAB
            _NavBarItem(
              icon: Icons.forum_outlined,
              selectedIcon: Icons.forum_rounded,
              label: 'Messages',
              isSelected: shell.currentIndex == 3,
              onTap: () => shell.goBranch(3, initialLocation: 3 == shell.currentIndex),
            ),
            _NavBarItem(
              icon: Icons.account_circle_outlined,
              selectedIcon: Icons.account_circle_rounded,
              label: 'Profil',
              isSelected: shell.currentIndex == 4,
              onTap: () => shell.goBranch(4, initialLocation: 4 == shell.currentIndex),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.neutral;
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Centering helps with overflow
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? selectedIcon : icon,
              color: color,
              size: 24,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

