import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/fixtures/mock_garages.dart';
import 'package:liko_auto/core/providers/city_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/features/home/providers/home_listings_provider.dart';
import 'package:liko_auto/features/home/widgets/city_picker_bottom_sheet.dart';
import 'package:liko_auto/features/home/widgets/home_skeleton.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/notifications_inbox/providers/notifications_inbox_provider.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';

// ── Catégories véhicules ───────────────────────────────────────────────────

class _VehicleCategory {
  const _VehicleCategory({
    required this.label,
    required this.icon,
    required this.count,
    required this.filter,
  });

  final String label;
  final IconData icon;
  final int count;
  final String filter;
}

const _kCategories = <_VehicleCategory>[
  _VehicleCategory(
    label: 'Pick-up',
    icon: Icons.local_shipping_rounded,
    count: 18,
    filter: 'hilux',
  ),
  _VehicleCategory(
    label: 'Berline',
    icon: Icons.directions_car_rounded,
    count: 13,
    filter: 'corolla',
  ),
  _VehicleCategory(
    label: 'SUV',
    icon: Icons.directions_car_filled_rounded,
    count: 17,
    filter: 'rav4',
  ),
  _VehicleCategory(
    label: 'À importer',
    icon: Icons.flight_land_rounded,
    count: 42,
    filter: 'bmw',
  ),
];

// ── Écran principal ────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollCtrl = ScrollController();
  bool _isScrolled = false;
  String? _activeCategory;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final scrolled = _scrollCtrl.offset > 4;
      if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showCityPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CityPickerBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    final listingsAsync = ref.watch(homeListingsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;

    final firstName = () {
      final name = user?.displayName?.trim() ?? '';
      if (name.isNotEmpty) return name.split(' ').first;
      return 'vous';
    }();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Column(
        children: [
          _HomeAppBar(
            isScrolled: _isScrolled,
            city: city,
            unreadCount: unreadCount,
            onCityTap: _showCityPicker,
            onNotifTap: () => context.push(AppRoutes.notificationsInbox),
            onMenuTap: () => Scaffold.of(context).openDrawer(),
          ),
          Expanded(
            child: listingsAsync.when(
              loading: () => const HomeSkeleton(),
              error: (err, _) => Center(child: Text('Erreur : $err')),
              data: (listings) {
                final filtered = _activeCategory == null
                    ? listings
                    : listings
                        .where(
                          (l) => l.title
                              .toLowerCase()
                              .contains(_activeCategory!.toLowerCase()),
                        )
                        .toList();

                return AnimationLimiter(
                  child: CustomScrollView(
                    controller: _scrollCtrl,
                    slivers: [
                      SliverToBoxAdapter(
                        child: _GreetingSection(
                          firstName: firstName,
                          onSearchTap: () => context.go(AppRoutes.search),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _CategoriesRow(
                          active: _activeCategory,
                          onSelect: (f) => setState(
                            () => _activeCategory =
                                _activeCategory == f ? null : f,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _EstimerCta(
                          onTap: () =>
                              AppSnackPlaceholder.showEstimer(context),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Dernières annonces',
                          onMore: () => context.go(AppRoutes.search),
                        ),
                      ),
                      if (filtered.isEmpty)
                        const SliverToBoxAdapter(child: _EmptyCategory())
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 320),
                                child: SlideAnimation(
                                  verticalOffset: 30,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.xs,
                                      ),
                                      child: ListingCard(
                                        data: filtered[index],
                                        onTap: () => context.push(
                                          AppRoutes.vehicleDetail,
                                          extra: filtered[index],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Garages près de vous',
                          onMore: () => context.go(AppRoutes.search),
                        ),
                      ),
                      const SliverToBoxAdapter(child: _GaragesRow()),
                      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl * 2)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper interne (à migrer vers AppSnack quand estimateur existera) ──────

abstract final class AppSnackPlaceholder {
  static void showEstimer(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Estimateur disponible au Sprint 6.',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: AppColors.trust,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

// ── App Bar ────────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({
    required this.isScrolled,
    required this.city,
    required this.unreadCount,
    required this.onCityTap,
    required this.onNotifTap,
    required this.onMenuTap,
  });

  final bool isScrolled;
  final String city;
  final int unreadCount;
  final VoidCallback onCityTap;
  final VoidCallback onNotifTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: isScrolled
              ? [
                  BoxShadow(
                    color: AppColors.trust.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu_rounded, color: AppColors.trust),
              ),
              const Spacer(),              GestureDetector(
                onTap: onCityTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(999),
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
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: onNotifTap,
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.trust,
                    ),
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
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Greeting + search bar ──────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({
    required this.firstName,
    required this.onSearchTap,
  });

  final String firstName;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour $firstName !',
            style: context.textStyles.headlineMedium?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Quelle voiture cherchez-vous ?',
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppColors.neutral,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.neutral,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Toyota, Mercedes, quartier...',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppColors.neutral,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Categories row ─────────────────────────────────────────────────────────

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({required this.active, required this.onSelect});

  final String? active;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: _kCategories.map((cat) {
            final isActive = active == cat.filter;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _CategoryChip(
                category: cat,
                isActive: isActive,
                onTap: () => onSelect(cat.filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isActive,
    required this.onTap,
  });

  final _VehicleCategory category;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.trust : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.trust : AppColors.outline,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 24,
              color: isActive ? Colors.white : AppColors.trust,
            ),
            const SizedBox(height: 4),
            Text(
              category.label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.trust,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${category.count} ann.',
              style: TextStyle(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.neutral,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Estimer ma voiture CTA ─────────────────────────────────────────────────

class _EstimerCta extends StatelessWidget {
  const _EstimerCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Material(
        color: AppColors.trust,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimer ma voiture',
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Prix de marché en quelques secondes',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onMore});

  final String title;
  final VoidCallback onMore;

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
              title,
              style: context.textStyles.titleLarge?.copyWith(
                color: AppColors.trust,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: onMore,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Voir tout →',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Garages carousel ───────────────────────────────────────────────────────

class _GaragesRow extends StatelessWidget {
  const _GaragesRow();

  @override
  Widget build(BuildContext context) {
    final garages = MockGarages.all.take(4).toList();
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: garages.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) => _GarageSmallCard(garage: garages[index]),
      ),
    );
  }
}

class _GarageSmallCard extends StatelessWidget {
  const _GarageSmallCard({required this.garage});

  final GarageCardData garage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              if (garage.isCertified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CERTIFIÉ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            garage.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.labelMedium?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 12,
                color: AppColors.primary,
              ),
              const SizedBox(width: 2),
              Text(
                garage.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: garage.isOpen ? AppColors.success : AppColors.neutral,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                garage.isOpen ? 'Ouvert' : 'Fermé',
                style: TextStyle(
                  color:
                      garage.isOpen ? AppColors.success : AppColors.neutral,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty category state ───────────────────────────────────────────────────

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.neutral,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucune annonce dans cette catégorie.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppColors.neutral,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
