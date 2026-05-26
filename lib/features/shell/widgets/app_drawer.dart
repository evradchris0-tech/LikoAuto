import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/providers/user_role_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  void _navTo(BuildContext context, String route) {
    context
      ..pop() // ferme le drawer
      ..push<void>(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          _buildHeader(context, role),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Accueil',
                  onTap: () => _navTo(context, AppRoutes.home),
                ),
                _DrawerItem(
                  icon: Icons.search_rounded,
                  label: 'Parcourir les annonces',
                  onTap: () => _navTo(context, AppRoutes.search),
                ),
                if (role == UserRole.seller || role == UserRole.garage)
                  _DrawerItem(
                    icon: Icons.directions_car_rounded,
                    label: 'Mes Annonces',
                    onTap: () => _navTo(context, AppRoutes.myListings),
                  ),
                if (role == UserRole.garage)
                  _DrawerItem(
                    icon: Icons.analytics_rounded,
                    label: 'Statistiques Garage',
                    onTap: () {
                      context.pop();
                      AppSnack.info(
                        context,
                        'Statistiques pro : Sprint 7 (à venir).',
                      );
                    },
                  ),
                _DrawerItem(
                  icon: Icons.favorite_rounded,
                  label: 'Mes Favoris',
                  onTap: () => _navTo(context, AppRoutes.favorites),
                ),
                _DrawerItem(
                  icon: Icons.event_available_rounded,
                  label: 'Mes rendez-vous',
                  onTap: () => _navTo(context, AppRoutes.myBookings),
                ),
                _DrawerItem(
                  icon: Icons.storefront_rounded,
                  label: 'Garages Partenaires',
                  onTap: () => _navTo(context, AppRoutes.search),
                ),
                const Divider(indent: 20, endIndent: 20, height: 40),
                _DrawerItem(
                  icon: Icons.notifications_active_rounded,
                  label: 'Notifications',
                  onTap: () =>
                      _navTo(context, AppRoutes.notificationsInbox),
                ),
                _DrawerItem(
                  icon: Icons.shield_rounded,
                  label: 'Vérification VIN',
                  onTap: () {
                    context.pop();
                    AppSnack.info(
                      context,
                      'Scanner VIN : Sprint 7 (à venir).',
                    );
                  },
                ),
                const Divider(indent: 20, endIndent: 20, height: 40),
                _DrawerItem(
                  icon: Icons.settings_suggest_rounded,
                  label: 'Paramètres',
                  onTap: () => _navTo(context, AppRoutes.accountSettings),
                ),
                _DrawerItem(
                  icon: Icons.help_center_rounded,
                  label: "Centre d'aide",
                  onTap: () => _navTo(context, AppRoutes.support),
                ),
                // Demo Role Switcher
                const Divider(indent: 20, endIndent: 20, height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'MODE DÉMO (CHANGER DE PROFIL)',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                _RoleSwitcher(ref: ref),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserRole role) {
    String roleLabel;
    switch (role) {
      case UserRole.buyer:
        roleLabel = 'Acheteur Particulier';
      case UserRole.seller:
        roleLabel = 'Vendeur Particulier';
      case UserRole.garage:
        roleLabel = 'Professionnel (Garage)';
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.trust,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cédric N.',
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  roleLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Consumer(
        builder: (context, ref, _) => Column(
          children: [
            OutlinedButton.icon(
              onPressed: () => _logout(context, ref),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Déconnexion'),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    context.pop(); // ferme le drawer
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(mockSignedInProvider.notifier).signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }
}

class _RoleSwitcher extends StatelessWidget {
  const _RoleSwitcher({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.person_search_rounded, size: 20),
            tooltip: 'Acheteur',
            onPressed: () =>
                ref.read(userRoleProvider.notifier).role = UserRole.buyer,
          ),
          IconButton(
            icon: const Icon(Icons.sell_rounded, size: 20),
            tooltip: 'Vendeur',
            onPressed: () =>
                ref.read(userRoleProvider.notifier).role = UserRole.seller,
          ),
          IconButton(
            icon: const Icon(Icons.business_rounded, size: 20),
            tooltip: 'Garage',
            onPressed: () =>
                ref.read(userRoleProvider.notifier).role = UserRole.garage,
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.trust, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.trust,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );
  }
}
