import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/shared/widgets/badges/app_badge.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/buttons/secondary_button.dart';
import 'package:liko_auto/shared/widgets/buttons/tertiary_button.dart';
import 'package:liko_auto/shared/widgets/cards/app_card.dart';

/// Écran temporaire pour visualiser le Design System Liko Auto.
/// Sera supprimé une fois les vrais écrans implémentés.
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System — Liko Auto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_rounded),
            tooltip: 'Aperçu thème système',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _SectionTitle('Typographie'),
          _TypographySection(),
          AppSpacing.gapXl,

          _SectionTitle('Couleurs'),
          _ColorsSection(),
          AppSpacing.gapXl,

          _SectionTitle('Boutons'),
          _ButtonsSection(),
          AppSpacing.gapXl,

          _SectionTitle('Badges'),
          _BadgesSection(),
          AppSpacing.gapXl,

          _SectionTitle('Carte annonce (exemple)'),
          _ListingCardExample(),
          AppSpacing.gapXl,

          _SectionTitle('Champs de saisie'),
          _InputsSection(),
          AppSpacing.gapXxl,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Vendre',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(text, style: context.textStyles.headlineMedium),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heading 1 — 28/Bold', style: t.headlineLarge),
        Text('Heading 2 — 22/Semi', style: t.headlineMedium),
        Text('Heading 3 — 18/Semi', style: t.headlineSmall),
        Text('Body — 16/Regular', style: t.bodyLarge),
        Text('Body Small — 14/Regular', style: t.bodyMedium),
        Text('Caption — 12/Regular', style: t.bodySmall),
      ],
    );
  }
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    const swatches = <(String, Color)>[
      ('Primary', AppColors.primary),
      ('Trust', AppColors.trust),
      ('Background', AppColors.background),
      ('Neutral', AppColors.neutral),
      ('Success', AppColors.success),
      ('Error', AppColors.error),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (name, color) in swatches) _Swatch(name: name, color: color),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: context.textStyles.labelSmall),
        Text(
          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          style: context.textStyles.bodySmall,
        ),
      ],
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryButton(label: 'Publier mon annonce', onPressed: () {}),
        AppSpacing.gapSm,
        PrimaryButton(
          label: 'Contacter via Chat',
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: () {},
        ),
        AppSpacing.gapSm,
        const PrimaryButton(label: 'Désactivé', onPressed: null),
        AppSpacing.gapSm,
        Row(
          children: [
            SecondaryButton(label: 'Voir tout', onPressed: () {}),
            AppSpacing.gapSm,
            SecondaryButton(
              label: 'Filtrer',
              icon: Icons.tune_rounded,
              onPressed: () {},
            ),
          ],
        ),
        AppSpacing.gapSm,
        Row(
          children: [
            TertiaryButton(label: 'Passer', onPressed: () {}),
            AppSpacing.gapSm,
            TertiaryButton(label: 'Annuler', onPressed: () {}),
          ],
        ),
      ],
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppBadge.vinVerified(),
        AppBadge.pro(),
        AppBadge.certified(),
        AppBadge.negotiable(),
        AppBadge(label: 'Toyota'),
        AppBadge(
          label: 'Ouvert',
          icon: Icons.circle,
          style: AppBadgeStyle.vinVerified,
        ),
      ],
    );
  }
}

class _ListingCardExample extends StatelessWidget {
  const _ListingCardExample();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      semanticLabel: 'Annonce Toyota Corolla 2018, 8 500 000 FCFA, Douala',
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.trust.withValues(alpha: 0.85),
                  AppColors.trust.withValues(alpha: 0.55),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_rounded,
                size: 80,
                color: Colors.white70,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    AppBadge.vinVerified(),
                    SizedBox(width: 8),
                    AppBadge.negotiable(),
                  ],
                ),
                AppSpacing.gapSm,
                Text(
                  'Toyota Corolla 2018',
                  style: context.textStyles.headlineSmall,
                ),
                Text(
                  8500000.toFcfa(),
                  style: context.textStyles.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.gapXs,
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Bonapriso, Douala',
                      style: context.textStyles.bodyMedium,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.photo_library_outlined,
                      size: 16,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text('14', style: context.textStyles.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputsSection extends StatelessWidget {
  const _InputsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher une voiture, un garage...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        AppSpacing.gapMd,
        const TextField(
          decoration: InputDecoration(
            labelText: 'Numéro de série (VIN)',
            helperText: '17 caractères — la CNI de votre voiture',
          ),
        ),
        AppSpacing.gapMd,
        const TextField(
          decoration: InputDecoration(
            labelText: 'VIN invalide',
            errorText: 'Ce numéro de série semble incorrect',
          ),
        ),
      ],
    );
  }
}
