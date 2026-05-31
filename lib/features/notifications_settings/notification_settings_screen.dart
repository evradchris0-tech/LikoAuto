import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/notifications_settings/providers/notification_prefs_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final n = ref.read(notificationPrefsProvider.notifier);
    final pushOn = prefs.pushEnabled;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.trust),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Notifications',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          const SizedBox(height: AppSpacing.lg),
          _MasterToggle(
            value: pushOn,
            onChanged: (v) => n.setPushEnabled(value: v),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(label: "TYPES D'ALERTES", dimmed: !pushOn),
          _Card(
            children: [
              _Toggle(
                icon: LucideIcons.messageSquare,
                label: 'Nouveaux messages',
                description: 'Quand un acheteur ou vendeur vous écrit.',
                enabled: pushOn,
                value: prefs.newMessages,
                onChanged: (v) => n.setNewMessages(value: v),
              ),
              _Toggle(
                icon: LucideIcons.trendingDown,
                label: 'Baisses de prix',
                description: 'Sur les annonces de votre liste de favoris.',
                enabled: pushOn,
                value: prefs.priceDrops,
                onChanged: (v) => n.setPriceDrops(value: v),
              ),
              _Toggle(
                icon: Icons.event_available_outlined,
                label: 'Rendez-vous garage',
                description: 'Confirmations, rappels et changements.',
                enabled: pushOn,
                value: prefs.appointments,
                onChanged: (v) => n.setAppointments(value: v),
              ),
              _Toggle(
                icon: LucideIcons.shield,
                label: 'Alertes système',
                description: 'Sécurité, vérification VIN, conformité.',
                enabled: pushOn,
                value: prefs.systemAlerts,
                onChanged: (v) => n.setSystemAlerts(value: v),
              ),
              _Toggle(
                icon: LucideIcons.tag,
                label: 'Promotions Liko Auto',
                description: 'Offres ponctuelles, jamais de spam.',
                enabled: pushOn,
                value: prefs.promotions,
                onChanged: (v) => n.setPromotions(value: v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(label: 'EMAIL'),
          _Card(
            children: [
              _Toggle(
                icon: Icons.mark_email_unread_outlined,
                label: 'Récap hebdomadaire',
                description:
                    'Résumé chaque lundi des annonces qui matchent votre profil.',
                enabled: true,
                value: prefs.emailDigest,
                onChanged: (v) => n.setEmailDigest(value: v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(label: 'NE PAS DÉRANGER', dimmed: !pushOn),
          _Card(
            children: [
              _Toggle(
                icon: Icons.bedtime_outlined,
                label: 'Heures de silence',
                description: prefs.quietHoursEnabled
                    ? 'De ${_fmt(prefs.quietStartHour)} à ${_fmt(prefs.quietEndHour)}'
                    : 'Coupe les notifications la nuit.',
                enabled: pushOn,
                value: prefs.quietHoursEnabled,
                onChanged: (v) => n.setQuietHoursEnabled(value: v),
              ),
              if (prefs.quietHoursEnabled) ...[
                _HourPickerTile(
                  label: 'Début',
                  hour: prefs.quietStartHour,
                  enabled: pushOn,
                  onPicked: n.setQuietStart,
                ),
                _HourPickerTile(
                  label: 'Fin',
                  hour: prefs.quietEndHour,
                  enabled: pushOn,
                  onPicked: n.setQuietEnd,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Vos préférences sont sauvegardées localement et seront '
              'synchronisées avec votre compte une fois connecté à Internet.',
              style: context.textStyles.labelSmall?.copyWith(
                color: AppColors.neutral,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int h) => '${h.toString().padLeft(2, '0')}:00';
}

class _MasterToggle extends StatelessWidget {
  const _MasterToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              value ? LucideIcons.bellRing : LucideIcons.bellOff,
              color: Colors.white,
              size: 26,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value ? 'Notifications activées' : 'Notifications coupées',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value
                      ? 'Vous recevrez les alertes ci-dessous.'
                      : 'Aucune notification ne sera envoyée.',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.dimmed = false});

  final String label;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            color: dimmed
                ? AppColors.neutral.withValues(alpha: 0.5)
                : AppColors.neutral,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

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

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.label,
    required this.description,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool enabled;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 4,
        ),
        secondary: Icon(icon, color: AppColors.neutral),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.trust,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            description,
            style: const TextStyle(
              color: AppColors.neutral,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

class _HourPickerTile extends StatelessWidget {
  const _HourPickerTile({
    required this.label,
    required this.hour,
    required this.enabled,
    required this.onPicked,
  });

  final String label;
  final int hour;
  final bool enabled;
  final ValueChanged<int> onPicked;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: 0),
    );
    if (picked != null) onPicked(picked.hour);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: enabled ? () => _pick(context) : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: const Icon(LucideIcons.clock, color: AppColors.neutral),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.trust,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${hour.toString().padLeft(2, '0')}:00',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
