import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState
    extends ConsumerState<AccountSettingsScreen> {
  File? _localAvatar;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.trust),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Paramètres du compte',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (user) => _Content(
          user: user,
          localAvatar: _localAvatar,
          onAvatarPicked: (file) => setState(() => _localAvatar = file),
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({
    required this.user,
    required this.localAvatar,
    required this.onAvatarPicked,
  });

  final User? user;
  final File? localAvatar;
  final ValueChanged<File> onAvatarPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.lg),
        _AvatarPicker(
          user: user,
          localFile: localAvatar,
          onPicked: onAvatarPicked,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionLabel(label: 'IDENTITÉ'),
        _SettingsCard(
          children: [
            _Tile(
              icon: Icons.person_outline_rounded,
              label: 'Nom affiché',
              value: user?.displayName?.trim().isNotEmpty ?? false
                  ? user!.displayName!
                  : 'Non renseigné',
              onTap: () => _editDisplayName(context, ref, user),
            ),
            const _Tile(
              icon: Icons.workspace_premium_outlined,
              label: 'Rôle',
              value: 'Vendeur Particulier',
              trailing: _ReadOnlyChip(),
              onTap: null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionLabel(label: 'COORDONNÉES'),
        _SettingsCard(
          children: [
            _Tile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user?.email ?? 'Aucun email',
              trailing: user?.emailVerified ?? false
                  ? const _VerifiedChip()
                  : null,
              onTap: () => _info(
                context,
                "Modifier l'email nécessite une re-authentification. À venir.",
              ),
            ),
            _Tile(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: user?.phoneNumber ?? 'Non lié',
              trailing: user?.phoneNumber != null
                  ? const _VerifiedChip()
                  : null,
              onTap: () => _info(
                context,
                'Lier ou changer le numéro nécessite une vérification SMS. À venir.',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionLabel(label: 'SÉCURITÉ'),
        _SettingsCard(
          children: [
            _Tile(
              icon: Icons.lock_outline_rounded,
              label: 'Changer le mot de passe',
              value: 'Recevoir un lien par email',
              onTap: () => _sendPasswordReset(context, ref, user),
            ),
            _Tile(
              icon: Icons.logout_rounded,
              label: 'Se déconnecter',
              value: 'Sur cet appareil',
              destructive: true,
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionLabel(label: 'PRÉFÉRENCES'),
        const _SettingsCard(
          children: [
            _Tile(
              icon: Icons.language_rounded,
              label: 'Langue',
              value: 'Français',
              trailing: _ReadOnlyChip(label: 'Bientôt'),
              onTap: null,
            ),
            _Tile(
              icon: Icons.brightness_6_rounded,
              label: 'Thème',
              value: 'Système',
              trailing: _ReadOnlyChip(label: 'Bientôt'),
              onTap: null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionLabel(label: 'ZONE DANGER', destructive: true),
        _SettingsCard(
          children: [
            _Tile(
              icon: Icons.delete_forever_outlined,
              label: 'Supprimer mon compte',
              value: 'Action irréversible',
              destructive: true,
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    User? user,
  ) async {
    final controller = TextEditingController(text: user?.displayName ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nom affiché'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Votre nom (ex : Cédric N.)',
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.neutral),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(
              'Enregistrer',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty) return;
    try {
      await user?.updateDisplayName(newName);
      await user?.reload();
      if (context.mounted) AppSnack.success(context, 'Nom mis à jour.');
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AppSnack.error(context, 'Erreur : ${e.message}');
      }
    }
  }

  Future<void> _sendPasswordReset(
    BuildContext context,
    WidgetRef ref,
    User? user,
  ) async {
    final email = user?.email;
    if (email == null) {
      AppSnack.error(context, 'Aucun email lié à ce compte.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        AppSnack.success(context, 'Email envoyé à $email.');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AppSnack.error(context, 'Erreur : ${e.message}');
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Vous serez redirigé vers la page de connexion.'),
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
    if (ok != true) return;
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(mockSignedInProvider.notifier).signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le compte ?'),
        content: const Text(
          'Cette action est irréversible. Toutes vos annonces, '
          'favoris et messages seront définitivement perdus.',
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
              'Supprimer définitivement',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (context.mounted) {
      AppSnack.warning(
        context,
        'Suppression côté serveur à venir (API NestJS).',
      );
    }
  }

  void _info(BuildContext context, String msg) => AppSnack.info(context, msg);
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.user,
    required this.localFile,
    required this.onPicked,
  });

  final User? user;
  final File? localFile;
  final ValueChanged<File> onPicked;

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Choisir dans la galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final url = user?.photoURL;
    final initials = _initials(
      user?.displayName ?? user?.email ?? user?.phoneNumber ?? '?',
    );
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                  image: localFile != null
                      ? DecorationImage(
                          image: FileImage(localFile!),
                          fit: BoxFit.cover,
                        )
                      : (url != null
                          ? DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                alignment: Alignment.center,
                child: localFile == null && url == null
                    ? Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 36,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    onTap: () => _pick(context),
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.photo_camera_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            'Touchez pour changer',
            style: context.textStyles.labelSmall?.copyWith(
              color: AppColors.neutral,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String src) {
    final parts = src.trim().split(RegExp(r'[\s@]+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.destructive = false});

  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: context.textStyles.labelSmall?.copyWith(
          color: destructive ? AppColors.error : AppColors.neutral,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, indent: 56, color: AppColors.outline),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.trust;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: Icon(icon, color: destructive ? color : AppColors.neutral),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.neutral,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outline,
            ),
          ],
        ],
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: AppColors.success, size: 12),
          SizedBox(width: 3),
          Text(
            'Vérifié',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyChip extends StatelessWidget {
  const _ReadOnlyChip({this.label = 'Verrouillé'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.outline,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.trust,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}
