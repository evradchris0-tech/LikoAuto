import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/providers/user_role_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/onboarding_page_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Onboarding 4/5 — Quel est votre profil ?
class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  UserRole _selected = UserRole.buyer;

  void _onSelect(UserRole role) {
    setState(() => _selected = role);
    ref.read(userRoleProvider.notifier).role = role;
  }

  void _onContinue() {
    ref.read(userRoleProvider.notifier).role = _selected;
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      step: 4,
      totalSteps: 5,
      title: 'Quel est votre profil ?',
      body:
          'Choisissez votre rôle pour personnaliser votre expérience. Vous pourrez le modifier à tout moment dans votre profil.',
      primaryLabel: 'Continuer',
      onPrimary: _onContinue,
      visual: const _RoleVisual(),
      extra: _RoleCards(selected: _selected, onSelect: _onSelect),
    );
  }
}

// ── Visuel illustratif ────────────────────────────────────────────────────────

class _RoleVisual extends StatelessWidget {
  const _RoleVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2F50), Color(0xFF1A4878)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RoleIcon(icon: LucideIcons.search, label: 'Acheteur'),
                _RoleIcon(icon: LucideIcons.tag, label: 'Vendeur'),
                _RoleIcon(icon: LucideIcons.wrench, label: 'Garage'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleIcon extends StatelessWidget {
  const _RoleIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Cartes de sélection ───────────────────────────────────────────────────────

class _RoleCards extends StatelessWidget {
  const _RoleCards({required this.selected, required this.onSelect});

  final UserRole selected;
  final ValueChanged<UserRole> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoleCard(
          role: UserRole.buyer,
          icon: LucideIcons.search,
          title: 'Acheteur',
          subtitle: 'Je cherche un véhicule à acheter',
          selected: selected == UserRole.buyer,
          onTap: () => onSelect(UserRole.buyer),
        ),
        const SizedBox(height: AppSpacing.sm),
        _RoleCard(
          role: UserRole.seller,
          icon: LucideIcons.tag,
          title: 'Vendeur Particulier',
          subtitle: 'Je vends mon ou mes véhicules personnels',
          selected: selected == UserRole.seller,
          onTap: () => onSelect(UserRole.seller),
        ),
        const SizedBox(height: AppSpacing.sm),
        _RoleCard(
          role: UserRole.garage,
          icon: LucideIcons.wrench,
          title: 'Professionnel / Garage',
          subtitle: 'Je gère un garage ou vends en professionnel',
          selected: selected == UserRole.garage,
          onTap: () => onSelect(UserRole.garage),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : AppColors.outline;
    final bgColor = selected ? AppColors.primarySoft : Colors.white;
    final iconBg = selected ? AppColors.primary : AppColors.primarySoft;
    final iconColor = selected ? Colors.white : AppColors.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.trust,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.neutral,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  LucideIcons.checkCircle,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
