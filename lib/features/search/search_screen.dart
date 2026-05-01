import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/fixtures/mock_garages.dart';
import 'package:liko_auto/core/fixtures/mock_vehicles.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/search/models/search_filters.dart';
import 'package:liko_auto/features/search/tabs/garages_tab.dart';
import 'package:liko_auto/features/search/tabs/vehicles_tab.dart';
import 'package:liko_auto/features/search/widgets/garage_filter_sheet.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';
import 'package:liko_auto/features/search/widgets/search_top_bar.dart';
import 'package:liko_auto/features/search/widgets/vehicle_filter_sheet.dart';

/// Onglet 2 du shell — Rechercher (Voitures | Garages).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  VehicleFilters _vehicleFilters = VehicleFilters.empty;
  GarageFilters _garageFilters = GarageFilters.empty;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
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
      if (r != null && mounted) setState(() => _vehicleFilters = r);
    } else {
      final r = await GarageFilterSheet.show(context, initial: _garageFilters);
      if (r != null && mounted) setState(() => _garageFilters = r);
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
  List<ListingCardData> get _filteredVehicles {
    final q = _query.trim().toLowerCase();
    return MockVehicles.all.where((v) {
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

  List<GarageCardData> get _filteredGarages {
    final q = _query.trim().toLowerCase();
    return MockGarages.all.where((g) {
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
      if (f.openNowOnly && !g.isOpen) return false;
      return true;
    }).toList();
  }

  int get _activeFiltersCount => _tabController.index == 0
      ? _vehicleFilters.activeCount
      : _garageFilters.activeCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    'Rechercher',
                    style: context.textStyles.headlineLarge?.copyWith(
                      color: AppColors.trust,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  VehiclesTab(
                    results: _filteredVehicles,
                    filters: _vehicleFilters,
                    onResetFilters: _resetFilters,
                  ),
                  GaragesTab(
                    results: _filteredGarages,
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
        color: AppColors.primarySoft,
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
                Icon(Icons.directions_car_rounded, size: 17),
                SizedBox(width: 6),
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
                Icon(Icons.handyman_rounded, size: 17),
                SizedBox(width: 6),
                Text('Garages'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
