import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/package_info_provider.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/features/bookings/providers/bookings_provider.dart';
import 'package:liko_auto/features/favorites/providers/favorites_provider.dart';
import 'package:liko_auto/features/my_listings/providers/my_listings_provider.dart';
import 'package:liko_auto/features/notifications_inbox/providers/notifications_inbox_provider.dart';
import 'package:liko_auto/features/profile/widgets/profile_menu_item.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final authState = ref.watch(authStateChangesProvider);
    final activeListings = ref.watch(activeListingsCountProvider);
    final favoritesCount = ref.watch(favoritesCountProvider);
    final unreadNotifs = ref.watch(unreadNotificationsCountProvider);
    final upcomingBookings = ref.watch(upcomingBookingsCountProvider);

    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.trust),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: Text(
            'Mon Compte',
            style: context.textStyles.headlineMedium?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        Expanded(
          child: authState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Erreur de session : $err')),
            data: (user) => SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileHeader(user: user),
                  AppSpacing.gapMd,
                  ProfileSectionList(
                    items: [
                      ProfileMenuItem(
                        icon: Icons.directions_car_outlined,
                        label: 'Mes annonces',
                        badgeCount: activeListings,
                        onTap: () => context.push(AppRoutes.myListings),
                      ),
                      ProfileMenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Mes favoris',
                        badgeCount: favoritesCount,
                        onTap: () => context.push(AppRoutes.favorites),
                      ),
                      ProfileMenuItem(
                        icon: Icons.event_available_rounded,
                        label: 'Mes rendez-vous',
                        badgeCount: upcomingBookings,
                        onTap: () => context.push(AppRoutes.myBookings),
                      ),
                      ProfileMenuItem(
                        icon: Icons.history_rounded,
                        label: 'Historique des vues',
                        onTap: () => context.push(AppRoutes.history),
                      ),
                      ProfileMenuItem(
                        icon: Icons.inbox_rounded,
                        label: 'Notifications',
                        badgeCount: unreadNotifs,
                        onTap: () =>
                            context.push(AppRoutes.notificationsInbox),
                      ),
                    ],
                  ),
                  AppSpacing.gapMd,
                  ProfileSectionList(
                    items: [
                      ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Paramètres du compte',
                        onTap: () => context.push(AppRoutes.accountSettings),
                      ),
                      ProfileMenuItem(
                        icon: Icons.notifications_none_rounded,
                        label: 'Préférences de notification',
                        onTap: () =>
                            context.push(AppRoutes.notificationSettings),
                      ),
                      ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Aide & Support',
                        onTap: () => context.push(AppRoutes.support),
                      ),
                    ],
                  ),
                  AppSpacing.gapMd,
                  ProfileSectionList(
                    items: [
                      ProfileMenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Se déconnecter',
                        isDestructive: true,
                        onTap: () => _confirmLogout(context, ref),
                      ),
                    ],
                  ),
                  AppSpacing.gapXl,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: Text(
                        'Liko Auto v${packageInfo.version} '
                        '(Build ${packageInfo.buildNumber})',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapXl,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.neutral),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(mockSignedInProvider.notifier).signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.trim().isNotEmpty ?? false
        ? user!.displayName!
        : (user?.email?.split('@').first ?? user?.phoneNumber ?? 'Invité');
    final subtitle = user?.email ?? user?.phoneNumber ?? 'Mode invité';
    final avatarUrl = user?.photoURL;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.outline,
              shape: BoxShape.circle,
              image: avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: avatarUrl == null
                ? Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: context.textStyles.displaySmall?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: AppColors.neutral,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user == null ? 'Invité' : 'Vendeur Particulier',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
