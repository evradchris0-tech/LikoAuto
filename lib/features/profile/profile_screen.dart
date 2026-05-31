import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/package_info_provider.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/providers/user_role_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/features/bookings/providers/bookings_provider.dart';
import 'package:liko_auto/features/favorites/providers/favorites_provider.dart';
import 'package:liko_auto/features/my_listings/providers/my_listings_provider.dart';
import 'package:liko_auto/features/notifications_inbox/providers/notifications_inbox_provider.dart';
import 'package:liko_auto/features/profile/widgets/profile_menu_item.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final authState = ref.watch(authStateChangesProvider);
    final role = ref.watch(userRoleProvider);
    final activeListings = ref.watch(activeListingsCountProvider);
    final favoritesCount = ref.watch(favoritesCountProvider);
    final unreadNotifs = ref.watch(unreadNotificationsCountProvider);
    final upcomingBookings = ref.watch(upcomingBookingsCountProvider);

    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.menu, color: AppColors.trust),
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
            error: (err, _) => Center(child: Text('Erreur de session : $err')),
            data: (user) => SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileHeader(
                    user: user,
                    role: role,
                    activeListings: activeListings,
                    favoritesCount: favoritesCount,
                    upcomingBookings: upcomingBookings,
                  ),

                  // ── Sections selon le rôle ──────────────────────────────
                  if (role == UserRole.buyer)
                    ..._buyerSections(
                      context,
                      ref,
                      favoritesCount: favoritesCount,
                      upcomingBookings: upcomingBookings,
                      unreadNotifs: unreadNotifs,
                    ),
                  if (role == UserRole.seller)
                    ..._sellerSections(
                      context,
                      ref,
                      activeListings: activeListings,
                      favoritesCount: favoritesCount,
                      upcomingBookings: upcomingBookings,
                      unreadNotifs: unreadNotifs,
                    ),
                  if (role == UserRole.garage)
                    ..._garageSections(
                      context,
                      ref,
                      activeListings: activeListings,
                      upcomingBookings: upcomingBookings,
                      unreadNotifs: unreadNotifs,
                    ),

                  // ── Compte (commun) ─────────────────────────────────────
                  const _SectionLabel(label: 'COMPTE'),
                  ProfileSectionList(
                    items: [
                      ProfileMenuItem(
                        icon: LucideIcons.settings,
                        label: 'Paramètres du compte',
                        onTap: () => context.push(AppRoutes.accountSettings),
                      ),
                      ProfileMenuItem(
                        icon: LucideIcons.bell,
                        label: 'Préférences de notification',
                        onTap: () =>
                            context.push(AppRoutes.notificationSettings),
                      ),
                      ProfileMenuItem(
                        icon: LucideIcons.helpCircle,
                        label: 'Aide & Support',
                        onTap: () => context.push(AppRoutes.support),
                      ),
                    ],
                  ),

                  // ── Déconnexion ─────────────────────────────────────────
                  AppSpacing.gapMd,
                  ProfileSectionList(
                    items: [
                      ProfileMenuItem(
                        icon: LucideIcons.logOut,
                        label: 'Se déconnecter',
                        isDestructive: true,
                        onTap: () => _confirmLogout(context, ref),
                      ),
                    ],
                  ),

                  // ── Version ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
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
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sections Acheteur ───────────────────────────────────────────────────────

  List<Widget> _buyerSections(
    BuildContext context,
    WidgetRef ref, {
    required int favoritesCount,
    required int upcomingBookings,
    required int unreadNotifs,
  }) => [
    const _SectionLabel(label: 'ACTIVITÉ'),
    ProfileSectionList(
      items: [
        ProfileMenuItem(
          icon: LucideIcons.heart,
          label: 'Mes favoris',
          badgeCount: favoritesCount,
          onTap: () => context.push(AppRoutes.favorites),
        ),
        ProfileMenuItem(
          icon: LucideIcons.calendar,
          label: 'Mes rendez-vous garage',
          badgeCount: upcomingBookings,
          onTap: () => context.push(AppRoutes.myBookings),
        ),
        ProfileMenuItem(
          icon: LucideIcons.history,
          label: 'Historique des vues',
          onTap: () => context.push(AppRoutes.history),
        ),
        ProfileMenuItem(
          icon: LucideIcons.inbox,
          label: 'Notifications',
          badgeCount: unreadNotifs,
          onTap: () => context.push(AppRoutes.notificationsInbox),
        ),
      ],
    ),
    const _SectionLabel(label: 'OUTILS'),
    ProfileSectionList(
      items: [
        ProfileMenuItem(
          icon: LucideIcons.calculator,
          label: 'Estimer ma voiture',
          isNew: true,
          onTap: () =>
              AppSnack.info(context, 'Estimateur disponible au Sprint 6.'),
        ),
        ProfileMenuItem(
          icon: LucideIcons.tag,
          label: 'Vendre ma voiture',
          onTap: () => context.push(AppRoutes.sell),
        ),
      ],
    ),
    const _SectionLabel(label: 'PROFESSIONNEL'),
    ProfileSectionList(
      items: [
        ProfileMenuItem(
          icon: LucideIcons.store,
          label: 'Devenir Vendeur Pro / Créer un Garage',
          onTap: () => AppSnack.info(
            context,
            'Création de compte pro : Bientôt disponible.',
          ),
        ),
      ],
    ),
  ];

  // ── Sections Vendeur ────────────────────────────────────────────────────────

  List<Widget> _sellerSections(
    BuildContext context,
    WidgetRef ref, {
    required int activeListings,
    required int favoritesCount,
    required int upcomingBookings,
    required int unreadNotifs,
  }) => [
    const _SectionLabel(label: 'ACTIVITÉ'),
    ProfileSectionList(
      items: [
        ProfileMenuItem(
          icon: LucideIcons.car,
          label: 'Mes annonces',
          badgeCount: activeListings,
          onTap: () => context.push(AppRoutes.myListings),
        ),
        ProfileMenuItem(
          icon: LucideIcons.heart,
          label: 'Mes favoris',
          badgeCount: favoritesCount,
          onTap: () => context.push(AppRoutes.favorites),
        ),
        ProfileMenuItem(
          icon: LucideIcons.calendar,
          label: 'Mes rendez-vous',
          badgeCount: upcomingBookings,
          onTap: () => context.push(AppRoutes.myBookings),
        ),
        ProfileMenuItem(
          icon: LucideIcons.history,
          label: 'Historique des vues',
          onTap: () => context.push(AppRoutes.history),
        ),
        ProfileMenuItem(
          icon: LucideIcons.inbox,
          label: 'Notifications',
          badgeCount: unreadNotifs,
          onTap: () => context.push(AppRoutes.notificationsInbox),
        ),
      ],
    ),
    const _SectionLabel(label: 'VENTE'),
    ProfileSectionList(
      items: [
        ProfileMenuItem(
          icon: LucideIcons.plusCircle,
          label: 'Publier une annonce',
          onTap: () => context.push(AppRoutes.sell),
        ),
        ProfileMenuItem(
          icon: LucideIcons.calculator,
          label: 'Estimer ma voiture',
          isNew: true,
          onTap: () =>
              AppSnack.info(context, 'Estimateur disponible au Sprint 6.'),
        ),
      ],
    ),
    const _SectionLabel(label: 'PROFESSIONNEL'),
    ProfileSectionList(
      items: [
        ProfileMenuItem(
          icon: LucideIcons.store,
          label: 'Devenir Vendeur Pro / Créer un Garage',
          onTap: () => AppSnack.info(
            context,
            'Création de compte pro : Bientôt disponible.',
          ),
        ),
      ],
    ),
  ];

  // ── Sections Garage ─────────────────────────────────────────────────────────

  List<Widget> _garageSections(
    BuildContext context,
    WidgetRef ref, {
    required int activeListings,
    required int upcomingBookings,
    required int unreadNotifs,
  }) => [
    const _SectionLabel(label: 'ACTIVITÉ'),
    ProfileSectionList(
      items: [
        ProfileMenuItem(
          icon: Icons.directions_car_outlined,
          label: 'Mes annonces',
          badgeCount: activeListings,
          onTap: () => context.push(AppRoutes.myListings),
        ),
        ProfileMenuItem(
          icon: LucideIcons.calendar,
          label: 'Rendez-vous clients',
          badgeCount: upcomingBookings,
          onTap: () => context.push(AppRoutes.myBookings),
        ),
        ProfileMenuItem(
          icon: LucideIcons.inbox,
          label: 'Notifications',
          badgeCount: unreadNotifs,
          onTap: () => context.push(AppRoutes.notificationsInbox),
        ),
      ],
    ),
    const _SectionLabel(label: 'MON GARAGE'),
    ProfileSectionList(
      items: [
        ProfileMenuItem(
          icon: LucideIcons.barChart2,
          label: 'Boosts & Visibilité',
          onTap: () => AppSnack.info(context, 'Options de boost au Sprint 6.'),
        ),
        ProfileMenuItem(
          icon: LucideIcons.store,
          label: 'Mon profil garage',
          onTap: () =>
              AppSnack.info(context, 'Profil garage disponible au Sprint 7.'),
        ),
        ProfileMenuItem(
          icon: LucideIcons.wrench,
          label: 'Gérer mes services',
          onTap: () => AppSnack.info(
            context,
            'Gestion services disponible au Sprint 7.',
          ),
        ),
        ProfileMenuItem(
          icon: LucideIcons.pieChart,
          label: 'Statistiques',
          onTap: () =>
              AppSnack.info(context, 'Statistiques disponibles au Sprint 7.'),
        ),
        ProfileMenuItem(
          icon: LucideIcons.briefcase,
          label: 'Publier une annonce',
          onTap: () => context.push(AppRoutes.sell),
        ),
      ],
    ),
  ];

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

// ── Header profil ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.role,
    required this.activeListings,
    required this.favoritesCount,
    required this.upcomingBookings,
  });

  final User? user;
  final UserRole role;
  final int activeListings;
  final int favoritesCount;
  final int upcomingBookings;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.trim().isNotEmpty ?? false
        ? user!.displayName!
        : (user?.email?.split('@').first ?? user?.phoneNumber ?? 'Invité');
    final subtitle = user?.email ?? user?.phoneNumber ?? 'Mode invité';
    final avatarUrl = user?.photoURL;

    final (roleLabel, badgeBg, badgeText) = switch (role) {
      UserRole.buyer => (
        'Acheteur Particulier',
        AppColors.primarySoft,
        AppColors.primary,
      ),
      UserRole.seller => (
        'Vendeur Particulier',
        AppColors.primarySoft,
        AppColors.primary,
      ),
      UserRole.garage => (
        'Professionnel Garage',
        AppColors.trustSoft,
        AppColors.trust,
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        children: [
          // Carte identité (style référence : bords ronds, fond trust)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                if (user != null) {
                  context.push(AppRoutes.accountSettings);
                } else {
                  context.push(AppRoutes.login);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.trust,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Badge rôle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        user == null ? 'Invité' : roleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.gapSm,
          // Statistiques sur fond blanc (sous la carte identité)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.trust.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  value: activeListings.toString(),
                  label: 'Annonces',
                  icon: Icons.directions_car_outlined,
                ),
                const _StatDivider(),
                _StatItem(
                  value: favoritesCount.toString(),
                  label: 'Favoris',
                  icon: LucideIcons.heart,
                ),
                const _StatDivider(),
                _StatItem(
                  value: upcomingBookings.toString(),
                  label: 'RDV',
                  icon: LucideIcons.calendar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets utilitaires ───────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: context.textStyles.titleLarge?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            color: AppColors.neutral,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.outline);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.trust,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
