import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/garages/domain/garage_entity.dart';
import 'package:liko_auto/features/garages/providers/garages_provider.dart';
import 'package:liko_auto/features/home/providers/home_listings_provider.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/notifications_inbox/providers/notifications_inbox_provider.dart';
import 'package:liko_auto/features/search/models/search_filters.dart';
import 'package:liko_auto/features/search/tabs/garages_tab.dart';
import 'package:liko_auto/features/search/tabs/vehicles_tab.dart';
import 'package:liko_auto/features/search/widgets/garage_filter_sheet.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';
import 'package:liko_auto/features/search/widgets/search_top_bar.dart';
import 'package:liko_auto/features/search/widgets/vehicle_filter_sheet.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Onglet 2 du shell — Rechercher (Voitures | Garages) avec toggle Liste/Carte.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({this.initialTab = 0, super.key});
  
  final int initialTab;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  VehicleFilters _vehicleFilters = VehicleFilters.empty;
  GarageFilters _garageFilters = GarageFilters.empty;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: widget.initialTab, length: 2, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _searchController.addListener(() {
      if (_query != _searchController.text) {
        setState(() => _query = _searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtres bottom sheet ────────────────────────────────────────────────
  Future<void> _openFilterSheet() async {
    if (_tabController.index == 0) {
      final r = await VehicleFilterSheet.show(
        context,
        initial: _vehicleFilters,
      );
      if (r != null && mounted) {
        setState(() => _vehicleFilters = r);
        AppSnack.success(context, 'Filtre appliqué');
      }
    } else {
      final r = await GarageFilterSheet.show(context, initial: _garageFilters);
      if (r != null && mounted) {
        setState(() => _garageFilters = r);
        AppSnack.success(context, 'Filtre appliqué');
      }
    }
  }

  void _resetFilters() {
    setState(() {
      if (_tabController.index == 0) {
        _vehicleFilters = VehicleFilters.empty;
      } else {
        _garageFilters = GarageFilters.empty;
      }
    });
  }

  // ── Filtrage en mémoire ─────────────────────────────────────────────────
  List<ListingCardData> _filteredVehicles(List<ListingCardData> all) {
    final q = _query.trim().toLowerCase();
    return all.where((v) {
      if (q.isNotEmpty &&
          !v.title.toLowerCase().contains(q) &&
          !v.location.toLowerCase().contains(q)) {
        return false;
      }
      final f = _vehicleFilters;
      if (f.priceRange != null) {
        if (v.priceFcfa < f.priceRange!.min ||
            v.priceFcfa > f.priceRange!.max) {
          return false;
        }
      }
      if (f.brand != null &&
          !v.title.toLowerCase().startsWith(f.brand!.toLowerCase())) {
        return false;
      }
      if (f.year != null && !v.title.contains('${f.year}')) return false;
      if (f.city != null &&
          !v.location.toLowerCase().contains(f.city!.toLowerCase())) {
        return false;
      }
      if (f.vinVerifiedOnly && !v.isVinVerified) return false;
      return true;
    }).toList();
  }

  List<GarageCardData> _filteredGarages(List<GarageEntity> garages) {
    final q = _query.trim().toLowerCase();
    return garages
        .where((g) {
          if (q.isNotEmpty &&
              !g.name.toLowerCase().contains(q) &&
              !g.location.toLowerCase().contains(q) &&
              !g.specialties.any((s) => s.toLowerCase().contains(q))) {
            return false;
          }
          final f = _garageFilters;
          if (f.specialty != null &&
              !g.specialties.any(
                (s) => s.toLowerCase() == f.specialty!.toLowerCase(),
              )) {
            return false;
          }
          if (f.city != null &&
              !g.location.toLowerCase().contains(f.city!.toLowerCase())) {
            return false;
          }
          if (f.minRating != null && g.rating < f.minRating!) return false;
          return true;
        })
        .map(
          (g) => GarageCardData(
            name: g.name,
            specialties: g.specialties,
            rating: g.rating,

            location: g.location,
            imageAsset: 'assets/images/car_rav4.png',
            isCertified: g.isCertified,
          ),
        )
        .toList();
  }

  int get _activeFiltersCount => _tabController.index == 0
      ? _vehicleFilters.activeCount
      : _garageFilters.activeCount;

  @override
  Widget build(BuildContext context) {
    final allGarages =
        ref.watch(garagesProvider).valueOrNull ?? const <GarageEntity>[];
    final allListings =
        ref.watch(homeListingsProvider).valueOrNull ??
        const <ListingCardData>[];
    final filteredGarages = _filteredGarages(allGarages);
    final filteredVehicles = _filteredVehicles(allListings);
    final currentResultCount = _tabController.index == 0
        ? filteredVehicles.length
        : filteredGarages.length;

    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header : burger + titre + ville + cloche
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.menu, color: AppColors.trust),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Rechercher',
                        style: context.textStyles.headlineSmall?.copyWith(
                          color: AppColors.trust,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  // Cloche notifs
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () =>
                            context.push(AppRoutes.notificationsInbox),
                        icon: const Icon(LucideIcons.bell),
                        color: AppColors.trust,
                        iconSize: 24,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SearchTopBar(
              controller: _searchController,
              onFilterTap: _openFilterSheet,
              activeFilters: _activeFiltersCount,
              hint: _tabController.index == 0
                  ? 'Toyota, Mercedes, Douala...'
                  : 'Spécialité, quartier...',
            ),
            _Tabs(controller: _tabController),
            _ResultsBar(
              count: currentResultCount,
              city: _vehicleFilters.city ?? 'Douala',
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  VehiclesTab(
                    results: filteredVehicles,
                    filters: _vehicleFilters,
                    onResetFilters: _resetFilters,
                    onTap: (data) =>
                        context.push(AppRoutes.vehicleDetail, extra: data),
                  ),
                  GaragesTab(
                    results: filteredGarages,
                    filters: _garageFilters,
                    onResetFilters: _resetFilters,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compteur résultats ──────────────────────────────────────────────────────

class _ResultsBar extends StatelessWidget {
  const _ResultsBar({required this.count, required this.city});

  final int count;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        0,
      ),
      child: Text(
        '$count résultat${count > 1 ? 's' : ''}',
        style: const TextStyle(
          color: AppColors.trust,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.trustSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.trust,
          borderRadius: BorderRadius.circular(999),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.trust,
        labelStyle: context.textStyles.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: context.textStyles.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            height: 44,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 17),
                SizedBox(width: AppSpacing.sm),
                Text('Voitures'),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.wrench, size: 17),
                SizedBox(width: AppSpacing.sm),
                Text('Garages'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
