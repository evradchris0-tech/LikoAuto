import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/bookings/domain/booking.dart';
import 'package:liko_auto/features/bookings/providers/bookings_provider.dart';
import 'package:liko_auto/features/reviews/domain/review.dart';
import 'package:liko_auto/features/reviews/widgets/leave_review_sheet.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(bookingsProvider).valueOrNull ?? const [];
    final now = DateTime.now();
    final upcoming = all
        .where((b) =>
            b.status == BookingStatus.confirmed &&
            b.scheduledAt.isAfter(now))
        .toList();
    final past = all
        .where((b) =>
            b.status == BookingStatus.completed ||
            (b.status == BookingStatus.confirmed &&
                b.scheduledAt.isBefore(now)))
        .toList();
    final cancelled =
        all.where((b) => b.status == BookingStatus.cancelled).toList();

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
          'Mes rendez-vous',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ColoredBox(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.neutral,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: context.textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              tabs: [
                Tab(text: 'À venir (${upcoming.length})'),
                Tab(text: 'Passés (${past.length})'),
                Tab(text: 'Annulés (${cancelled.length})'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _BookingsList(items: upcoming, kind: _Kind.upcoming),
          _BookingsList(items: past, kind: _Kind.past),
          _BookingsList(items: cancelled, kind: _Kind.cancelled),
        ],
      ),
    );
  }
}

enum _Kind { upcoming, past, cancelled }

class _BookingsList extends ConsumerWidget {
  const _BookingsList({required this.items, required this.kind});

  final List<Booking> items;
  final _Kind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return _EmptyState(kind: kind);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final b = items[i];
        return _BookingCard(
          booking: b,
          onCancel: kind == _Kind.upcoming
              ? () => _cancel(context, ref, b)
              : null,
          onReview: kind == _Kind.past
              ? () => showLeaveReviewSheet(
                    context,
                    targetType: ReviewTargetType.garage,
                    targetId: b.garageName,
                    targetName: b.garageName,
                    verified: true,
                  )
              : null,
        );
      },
    );
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    Booking b,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler ce RDV ?'),
        content: Text(
          'Le rendez-vous chez ${b.garageName} sera annulé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Garder',
              style: TextStyle(color: AppColors.neutral),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Annuler le RDV',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref
          .read(bookingsActionsProvider)
          .changeStatus(b.id, BookingStatus.cancelled);
      if (context.mounted) {
        AppSnack.info(context, 'Rendez-vous annulé.');
      }
    }
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, this.onCancel, this.onReview});

  final Booking booking;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final fmt = DateFormat("EEE d MMM · HH'h'mm", 'fr_FR');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: ColoredBox(
                      color: AppColors.primarySoft,
                      child: Image.asset(b.garageImageAsset, fit: BoxFit.cover),
                    ),
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.garageName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.trust,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        b.service.label,
                        style: const TextStyle(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: b.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppColors.neutral,
                ),
                const SizedBox(width: 6),
                Text(
                  fmt.format(b.scheduledAt),
                  style: const TextStyle(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.payments_outlined,
                  size: 14,
                  color: AppColors.neutral,
                ),
                const SizedBox(width: 4),
                Text(
                  'dès ${b.service.priceFromFcfa.toFcfa()}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (b.note != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '« ${b.note} »',
                  style: const TextStyle(
                    color: AppColors.neutral,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Annuler le RDV',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            if (onReview != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReview,
                  icon: const Icon(
                    Icons.star_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Noter le garage',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _style(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
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

  static (Color, Color, IconData) _style(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return (
          AppColors.primarySoft,
          AppColors.primary,
          Icons.schedule_rounded,
        );
      case BookingStatus.confirmed:
        return (
          AppColors.successSoft,
          AppColors.success,
          Icons.check_circle_rounded,
        );
      case BookingStatus.completed:
        return (
          const Color(0xFFE3EAF3),
          AppColors.trust,
          Icons.verified_rounded,
        );
      case BookingStatus.cancelled:
        return (
          AppColors.errorSoft,
          AppColors.error,
          Icons.cancel_rounded,
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.kind});
  final _Kind kind;

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (kind) {
      _Kind.upcoming => (
          'Aucun rendez-vous à venir.',
          'Réservez chez un garage partenaire depuis la fiche garage.',
        ),
      _Kind.past => (
          'Aucun RDV passé.',
          'Votre historique de rendez-vous apparaîtra ici.',
        ),
      _Kind.cancelled => (
          'Aucun RDV annulé.',
          'Tant mieux !',
        ),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.gapLg,
            Text(
              title,
              style: context.textStyles.headlineSmall?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,
            Text(
              body,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppColors.neutral,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
