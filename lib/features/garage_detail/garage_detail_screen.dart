import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/bookings/booking_flow_screen.dart';
import 'package:liko_auto/features/garage_detail/domain/garage_detail.dart';
import 'package:liko_auto/features/garage_detail/providers/garage_detail_provider.dart';
import 'package:liko_auto/features/reviews/domain/review.dart';
import 'package:liko_auto/features/reviews/providers/reviews_provider.dart';
import 'package:liko_auto/features/reviews/widgets/leave_review_sheet.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GarageDetailScreen extends ConsumerWidget {
  const GarageDetailScreen({required this.card, super.key});

  final GarageCardData card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(garageDetailProvider(card));
    final publishedReviews =
        ref
            .watch(
              reviewsForTargetProvider((
                type: ReviewTargetType.garage,
                id: card.name,
              )),
            )
            .valueOrNull ??
        const <Review>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _SliverHeader(detail: detail),
          SliverToBoxAdapter(child: _IdentityBlock(detail: detail)),
          const SliverToBoxAdapter(child: _SectionTitle(label: 'À propos')),
          SliverToBoxAdapter(child: _AboutBlock(detail: detail)),
          const SliverToBoxAdapter(child: _SectionTitle(label: 'Services')),
          SliverToBoxAdapter(child: _ServicesList(services: detail.services)),
          const SliverToBoxAdapter(child: _SectionTitle(label: 'Horaires')),
          SliverToBoxAdapter(child: _HoursBlock(hours: detail.hours)),
          SliverToBoxAdapter(
            child: _SectionTitle(
              label: 'Avis (${detail.reviewCount + publishedReviews.length})',
              trailing: _RatingPill(rating: detail.card.rating),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: OutlinedButton.icon(
                onPressed: () => showLeaveReviewSheet(
                  context,
                  targetType: ReviewTargetType.garage,
                  targetId: card.name,
                  targetName: card.name,
                  verified: false,
                ),
                icon: const Icon(
                  LucideIcons.star,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Laisser un avis',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: publishedReviews.length,
            itemBuilder: (_, i) =>
                _PublishedReviewTile(review: publishedReviews[i]),
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
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: PageView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return ColoredBox(
              color: AppColors.trust,
              child: Image.asset(
                detail.card.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            );
          },
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
              _RatingPill(rating: c.rating),
            ],
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 16,
                color: AppColors.neutral,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  detail.address,
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
                  icon: LucideIcons.shieldCheck,
                  label: 'Certifié',
                  fg: Colors.white,
                  bg: AppColors.primary,
                ),
              for (final s in c.specialties)
                _Tag(
                  label: s,
                  fg: AppColors.primary,
                  bg: AppColors.primarySoft,
                ),
            ],
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
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
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
          const Icon(LucideIcons.star, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
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
          const Icon(LucideIcons.wrench, size: 22, color: AppColors.primary),
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
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            LucideIcons.badgeCheck,
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
                      i < review.rating ? LucideIcons.star : LucideIcons.star,
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

// ── Published review tile (drift) ─────────────────────────────────────────

class _PublishedReviewTile extends StatelessWidget {
  const _PublishedReviewTile({required this.review});
  final Review review;

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
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  review.authorName.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
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
                          review.authorName,
                          style: const TextStyle(
                            color: AppColors.trust,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (review.verified) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            LucideIcons.badgeCheck,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _relativeTime(review.createdAt),
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
                      i < review.rating ? LucideIcons.star : LucideIcons.star,
                      size: 14,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ],
          ),
          if (review.body != null && review.body!.trim().isNotEmpty) ...[
            AppSpacing.gapSm,
            Text(
              review.body!,
              style: context.textStyles.bodySmall?.copyWith(
                color: AppColors.trust,
                height: 1.5,
              ),
            ),
          ],
          if (review.tags.isNotEmpty) ...[
            AppSpacing.gapSm,
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final t in review.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return '${t.day.toString().padLeft(2, '0')}/'
        '${t.month.toString().padLeft(2, '0')}';
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
                  onPressed: () => context.go(AppRoutes.chat),
                  icon: const Icon(LucideIcons.messageCircle, size: 18),
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
                  icon: LucideIcons.calendarCheck,
                  onPressed: () => context.push(
                    AppRoutes.bookingFlow,
                    extra: BookingFlowArgs(garage: detail.card),
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
