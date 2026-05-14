import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/garage_detail/domain/garage_detail.dart';
import 'package:liko_auto/features/garage_detail/providers/garage_detail_provider.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

class GarageDetailScreen extends ConsumerWidget {
  const GarageDetailScreen({required this.card, super.key});

  final GarageCardData card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(garageDetailProvider(card));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _SliverHeader(detail: detail),
          SliverToBoxAdapter(child: _IdentityBlock(detail: detail)),
          SliverToBoxAdapter(child: _QuickActions(detail: detail)),
          const SliverToBoxAdapter(child: _SectionTitle(label: 'À propos')),
          SliverToBoxAdapter(child: _AboutBlock(detail: detail)),
          const SliverToBoxAdapter(child: _SectionTitle(label: 'Services')),
          SliverToBoxAdapter(child: _ServicesList(services: detail.services)),
          const SliverToBoxAdapter(child: _SectionTitle(label: 'Horaires')),
          SliverToBoxAdapter(child: _HoursBlock(hours: detail.hours)),
          SliverToBoxAdapter(
            child: _SectionTitle(
              label: 'Avis (${detail.reviewCount})',
              trailing: _RatingPill(rating: detail.card.rating),
            ),
          ),
          SliverList.builder(
            itemCount: detail.reviews.length,
            itemBuilder: (_, i) => _ReviewTile(review: detail.reviews[i]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: _BottomBar(detail: detail),
    );
  }
}

// ── Sliver header ──────────────────────────────────────────────────────────

class _SliverHeader extends StatelessWidget {
  const _SliverHeader({required this.detail});
  final GarageDetail detail;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.trust,
      foregroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.3),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: () =>
                  AppSnack.info(context, 'Partage : bientôt disponible.'),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          detail.card.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: AppColors.trust,
              child: Image.asset(
                detail.card.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.trust.withValues(alpha: 0.85),
                  ],
                  stops: const [0.4, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Identité (nom + localisation + badges) ────────────────────────────────

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({required this.detail});
  final GarageDetail detail;

  @override
  Widget build(BuildContext context) {
    final c = detail.card;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.name,
                  style: context.textStyles.headlineMedium?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _OpenChip(isOpen: c.isOpen),
            ],
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.neutral,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${detail.address} · ${c.distanceKm.toStringAsFixed(1)} km',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: AppColors.neutral,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (c.isCertified)
                const _Tag(
                  icon: Icons.verified_user_rounded,
                  label: 'Certifié',
                  fg: Colors.white,
                  bg: AppColors.primary,
                ),
              for (final s in c.specialties)
                _Tag(label: s, fg: AppColors.primary, bg: AppColors.primarySoft),
            ],
          ),
        ],
      ),
    );
  }
}

class _OpenChip extends StatelessWidget {
  const _OpenChip({required this.isOpen});
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.success : AppColors.neutral;
    final bg = isOpen ? AppColors.successSoft : AppColors.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen
                ? Icons.bolt_rounded
                : Icons.do_not_disturb_on_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Ouvert' : 'Fermé',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.fg,
    required this.bg,
    this.icon,
  });

  final String label;
  final Color fg;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick actions (Appeler / Itinéraire / Partager) ───────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.detail});
  final GarageDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.phone_rounded,
            label: 'Appeler',
            onTap: () => AppSnack.info(context, detail.phone),
          ),
          const _Divider(),
          _QuickActionButton(
            icon: Icons.directions_rounded,
            label: 'Itinéraire',
            onTap: () =>
                AppSnack.info(context, 'Itinéraire : bientôt disponible.'),
          ),
          const _Divider(),
          _QuickActionButton(
            icon: Icons.share_rounded,
            label: 'Partager',
            onTap: () =>
                AppSnack.info(context, 'Partage : bientôt disponible.'),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.outline);
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.textStyles.titleMedium?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1).replaceAll('.', ','),
            style: const TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── About ──────────────────────────────────────────────────────────────────

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.detail});
  final GarageDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        detail.about,
        style: context.textStyles.bodyMedium?.copyWith(
          color: AppColors.trust,
          height: 1.55,
        ),
      ),
    );
  }
}

// ── Services ───────────────────────────────────────────────────────────────

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.services});
  final List<GarageService> services;

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
          for (var i = 0; i < services.length; i++) ...[
            _ServiceTile(service: services[i]),
            if (i < services.length - 1)
              const Divider(height: 1, indent: 16, color: AppColors.outline),
          ],
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});
  final GarageService service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.build_circle_outlined,
            size: 22,
            color: AppColors.primary,
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.label,
                  style: const TextStyle(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '~ ${service.durationMin} min',
                  style: const TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'dès ${service.priceFromFcfa.toFcfa()}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hours ──────────────────────────────────────────────────────────────────

class _HoursBlock extends StatelessWidget {
  const _HoursBlock({required this.hours});
  final List<GarageHours> hours;

  @override
  Widget build(BuildContext context) {
    final todayIndex = (DateTime.now().weekday + 6) % 7; // 0 = Lundi
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < hours.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      hours[i].day,
                      style: TextStyle(
                        color: i == todayIndex
                            ? AppColors.primary
                            : AppColors.trust,
                        fontWeight: i == todayIndex
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      hours[i].range,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: hours[i].range == 'Fermé'
                            ? AppColors.neutral
                            : AppColors.trust,
                        fontWeight: i == todayIndex
                            ? FontWeight.w800
                            : FontWeight.w500,
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

// ── Reviews ────────────────────────────────────────────────────────────────

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final GarageReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  review.author[0],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.author,
                          style: const TextStyle(
                            color: AppColors.trust,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (review.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'il y a ${review.daysAgo} j',
                      style: const TextStyle(
                        color: AppColors.neutral,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < 5; i++)
                    Icon(
                      i < review.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            review.body,
            style: context.textStyles.bodySmall?.copyWith(
              color: AppColors.trust,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar (Contacter + Prendre RDV) ──────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.detail});
  final GarageDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.chat),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                  ),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.trust,
                    side: const BorderSide(color: AppColors.outline),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Prendre RDV',
                  icon: Icons.event_available_rounded,
                  onPressed: () => AppSnack.info(
                    context,
                    'Prise de RDV : disponible au Sprint 5.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
