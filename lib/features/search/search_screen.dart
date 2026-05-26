import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

/// Onglet 2 du shell — Rechercher (Voitures | Garages) avec toggle Liste/Carte.
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

  // Toggle Liste / Carte (wireframe 2.2)
  bool _isMapView = false;

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

  int get _currentResultCount => _tabController.index == 0
      ? _filteredVehicles.length
      : _filteredGarages.length;

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
                  const Spacer(),
                  // Toggle Liste / Carte (wireframe 2.2)
                  if (_tabController.index == 0)
                    _ListMapToggle(
                      isMapView: _isMapView,
                      onToggle: (v) => setState(() => _isMapView = v),
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
            // Compteur résultats avec ville (wireframe 2.2)
            _ResultsBar(
              count: _currentResultCount,
              city: _vehicleFilters.city ?? 'Douala',
            ),
            Expanded(
              child: _isMapView && _tabController.index == 0
                  ? _MapView(vehicles: _filteredVehicles)
                  : TabBarView(
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

// ── Toggle Liste / Carte (wireframe 2.2) ─────────────────────────────────────

class _ListMapToggle extends StatelessWidget {
  const _ListMapToggle({
    required this.isMapView,
    required this.onToggle,
  });

  final bool isMapView;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.view_list_rounded,
            label: 'Liste',
            selected: !isMapView,
            onTap: () => onToggle(false),
          ),
          _ToggleBtn(
            icon: Icons.map_rounded,
            label: 'Carte',
            selected: isMapView,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.trust : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : AppColors.trust,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.trust,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compteur résultats (wireframe 2.2) ───────────────────────────────────────

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
      child: Row(
        children: [
          Text(
            '$count résultat${count > 1 ? 's' : ''}',
            style: const TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const Text(
            ' à ',
            style: TextStyle(color: AppColors.neutral, fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 12,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 3),
                Text(
                  city,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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

// ── Vue carte OSM (wireframe 2.2) ────────────────────────────────────────────

class _MapView extends StatelessWidget {
  const _MapView({required this.vehicles});

  final List<ListingCardData> vehicles;

  // Positions mock autour de Douala
  static const _mockPositions = [
    LatLng(4.0511, 9.7085),
    LatLng(4.0638, 9.7238),
    LatLng(4.0420, 9.6950),
    LatLng(4.0750, 9.7300),
    LatLng(4.0330, 9.7150),
  ];

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(4.0511, 9.7085),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.likoauto.app',
        ),
        MarkerLayer(
          markers: [
            for (var i = 0; i < vehicles.length && i < _mockPositions.length; i++)
              Marker(
                point: _mockPositions[i],
                width: 120,
                height: 56,
                child: _VehicleMarker(vehicle: vehicles[i]),
              ),
          ],
        ),
      ],
    );
  }
}

class _VehicleMarker extends StatelessWidget {
  const _VehicleMarker({required this.vehicle});

  final ListingCardData vehicle;

  @override
  Widget build(BuildContext context) {
    final price =
        '${vehicle.priceFcfa ~/ 1000000}M FCFA';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.trust,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.trust.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const CustomPaint(
          size: Size(12, 6),
          painter: _TrianglePainter(color: AppColors.trust),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
