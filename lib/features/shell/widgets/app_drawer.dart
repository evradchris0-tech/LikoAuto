// ignore_for_file: cascade_invocations // Need to chain calls for UI logic
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/providers/user_role_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  void _navTo(BuildContext context, String route) {
    context
      ..pop() // ferme le drawer
      ..push<void>(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for reactivity (rebuild when role/user changes)
    ref.watch(userRoleProvider);
    ref.watch(authStateChangesProvider);

    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          _buildHeader(context, ref),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.md,
              ),
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DrawerMenuItem(
                      icon: LucideIcons.home,
                      label: 'Accueil',
                      onTap: () => _navTo(context, AppRoutes.home),
                    ),
                    DrawerMenuItem(
                      icon: LucideIcons.bookOpen,
                      label: 'Actualités & Blog',
                      onTap: () {
                        context.pop();
                        AppSnack.info(
                          context,
                          'Blog Liko Auto : Bientôt disponible.',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _SectionLabel("CENTRE D'AIDE"),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DrawerMenuItem(
                      icon: LucideIcons.helpCircle,
                      label: 'Aide & FAQ',
                      onTap: () => _navTo(context, AppRoutes.support),
                    ),
                    DrawerMenuItem(
                      icon: LucideIcons.phone,
                      label: 'Nous contacter',
                      onTap: () => _navTo(context, AppRoutes.support),
                    ),
                    DrawerMenuItem(
                      icon: LucideIcons.heart,
                      label: 'Donnez-nous votre avis',
                      onTap: () {
                        context.pop();
                        AppSnack.info(context, 'Bientôt disponible.');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _SectionLabel('INFORMATIONS LÉGALES'),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DrawerMenuItem(
                      icon: LucideIcons.scale,
                      label: 'Mentions légales',
                      onTap: () {
                        context.pop();
                        AppSnack.info(context, 'Bientôt disponible.');
                      },
                    ),
                    DrawerMenuItem(
                      icon: LucideIcons.gavel,
                      label: "Conditions d'utilisation",
                      onTap: () {
                        context.pop();
                        AppSnack.info(context, 'Bientôt disponible.');
                      },
                    ),
                    DrawerMenuItem(
                      icon: LucideIcons.shoppingBag,
                      label: 'Conditions de vente',
                      onTap: () {
                        context.pop();
                        AppSnack.info(context, 'Bientôt disponible.');
                      },
                    ),
                    DrawerMenuItem(
                      icon: LucideIcons.link,
                      label: 'Conditions partenaires',
                      onTap: () {
                        context.pop();
                        AppSnack.info(context, 'Bientôt disponible.');
                      },
                    ),
                    DrawerMenuItem(
                      icon: LucideIcons.fileText,
                      label: 'Prestations administratives',
                      onTap: () {
                        context.pop();
                        AppSnack.info(context, 'Bientôt disponible.');
                      },
                    ),
                    DrawerMenuItem(
                      icon: LucideIcons.shieldAlert,
                      label: 'Données personnelles',
                      onTap: () {
                        context.pop();
                        AppSnack.info(context, 'Bientôt disponible.');
                      },
                    ),
                  ],
                ),
                const Divider(indent: 20, endIndent: 20, height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'MODE DÉMO (CHANGER DE PROFIL)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _RoleSwitcher(ref: ref),
                const SizedBox(height: AppSpacing.xs),
                _OnboardingResetButton(ref: ref),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final role = ref.watch(userRoleProvider);

    var displayName = 'Invité';
    if (user != null) {
      if (user.displayName?.isNotEmpty ?? false) {
        displayName = user.displayName!;
      } else if (user.email?.isNotEmpty ?? false) {
        displayName = user.email!;
      } else if (user.phoneNumber?.isNotEmpty ?? false) {
        displayName = user.phoneNumber!;
      } else {
        displayName = 'Utilisateur';
      }
    }
    final avatarUrl = user?.photoURL;

    var roleLabel = 'Acheteur';
    if (role == UserRole.seller) roleLabel = 'Vendeur';
    if (role == UserRole.garage) roleLabel = 'Garage Pro';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        60, // Padding top pour la status bar
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.trust,
        // Pas d'arrondi (borderRadius) en bas comme demandé
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
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
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
                if (user != null && (user.email?.isNotEmpty ?? false))
                  Text(
                    user.email!,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (user != null && (user.phoneNumber?.isNotEmpty ?? false))
                  Text(
                    user.phoneNumber!,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  user == null
                      ? 'Mode Visiteur'
                      : '$roleLabel ${role == UserRole.buyer ? 'Particulier' : ''}',
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
              icon: const Icon(LucideIcons.logOut, size: 18),
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
    final currentRole = ref.watch(userRoleProvider);

    Widget buildRoleButton(UserRole role, IconData icon, String label) {
      final isActive = currentRole == role;
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.trust : AppColors.trustSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.trust : Colors.transparent,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => ref.read(userRoleProvider.notifier).role = role,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isActive ? Colors.white : AppColors.trust,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.trust,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildRoleButton(UserRole.buyer, LucideIcons.search, 'Acheteur'),
          buildRoleButton(UserRole.seller, LucideIcons.tag, 'Vendeur'),
          buildRoleButton(UserRole.garage, LucideIcons.building, 'Garage'),
        ],
      ),
    );
  }
}

class _OnboardingResetButton extends StatelessWidget {
  const _OnboardingResetButton({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton.icon(
        onPressed: () async {
          await ref.read(onboardingSeenProvider.notifier).reset();
          if (context.mounted) {
            context
              ..pop()
              ..go(AppRoutes.onboarding);
          }
        },
        icon: const Icon(LucideIcons.rotateCcw, size: 16),
        label: const Text("Revoir l'onboarding"),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neutral,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.neutral.withValues(alpha: 0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class DrawerMenuItem extends StatelessWidget {
  const DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.trust.withValues(alpha: 0.1),
          highlightColor: AppColors.trust.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 8,
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.trustSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 16, color: AppColors.trust),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: Color(0xFFCBD5E1),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
