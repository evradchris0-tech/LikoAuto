import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/my_listings/domain/my_listing.dart';
import 'package:liko_auto/features/my_listings/providers/my_listings_provider.dart';
import 'package:liko_auto/features/my_listings/widgets/my_listing_card.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _filters = <_TabFilter>[
    _TabFilter('Toutes', null),
    _TabFilter('Actives', ListingStatus.active),
    _TabFilter('En attente', ListingStatus.pending),
    _TabFilter('Vendues', ListingStatus.sold),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(myListingsProvider);

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
          'Mes annonces',
          style: context.textStyles.headlineMedium?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ColoredBox(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.neutral,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: context.textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: context.textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: _filters
                  .map(
                    (f) => Tab(
                      text:
                          '${f.label} (${_countFor(listings, f.status)})',
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: _filters.map((f) {
          final filtered = f.status == null
              ? listings
              : listings.where((l) => l.status == f.status).toList();
          return _ListingsList(items: filtered);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.sell),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nouvelle annonce',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  int _countFor(List<MyListing> all, ListingStatus? s) {
    return s == null
        ? all.length
        : all.where((l) => l.status == s).length;
  }
}

class _TabFilter {
  const _TabFilter(this.label, this.status);
  final String label;
  final ListingStatus? status;
}

class _ListingsList extends ConsumerWidget {
  const _ListingsList({required this.items});

  final List<MyListing> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        96,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final l = items[index];
        return MyListingCard(
          listing: l,
          onTap: () => context.push(AppRoutes.vehicleDetail, extra: l.card),
          onAction: (action) => _handleAction(context, ref, l, action),
        );
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    MyListing l,
    MyListingAction a,
  ) async {
    final notifier = ref.read(myListingsProvider.notifier);
    switch (a) {
      case MyListingAction.edit:
        unawaited(context.push<void>(AppRoutes.sell));
        return;
      case MyListingAction.boost:
        _snack(context, 'Bientôt : booster « ${l.card.title} ».');
        return;
      case MyListingAction.pause:
        notifier.changeStatus(l.id, ListingStatus.paused);
        _snack(context, 'Annonce mise en pause.');
        return;
      case MyListingAction.resume:
        notifier.changeStatus(l.id, ListingStatus.active);
        _snack(context, 'Annonce réactivée.');
        return;
      case MyListingAction.markSold:
        notifier.changeStatus(l.id, ListingStatus.sold);
        _snack(context, 'Félicitations, annonce marquée vendue !');
        return;
      case MyListingAction.delete:
        final ok = await _confirmDelete(context, l);
        if (ok && context.mounted) {
          notifier.delete(l.id);
          _snack(context, 'Annonce supprimée.', destructive: true);
        }
        return;
    }
  }

  Future<bool> _confirmDelete(BuildContext context, MyListing l) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette annonce ?'),
        content: Text(
          '« ${l.card.title} » sera définitivement retirée. Cette action est irréversible.',
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
              'Supprimer',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  void _snack(BuildContext context, String msg, {bool destructive = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: destructive ? AppColors.error : AppColors.trust,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
                Icons.directions_car_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.gapLg,
            Text(
              'Aucune annonce ici.',
              style: context.textStyles.headlineSmall?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              'Déposez votre première annonce — minimum 5 photos et un VIN suffit.',
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
