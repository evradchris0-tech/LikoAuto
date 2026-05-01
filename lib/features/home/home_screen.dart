import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liko_auto/core/constants/app_assets.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/home/widgets/filter_chips_row.dart';
import 'package:liko_auto/features/home/widgets/home_search_bar.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/home/widgets/promo_banner.dart';
import 'package:liko_auto/shared/widgets/branding/liko_logo.dart';

/// Page d'accueil de Liko Auto — search + filtres + hero promo + annonces.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilter = 0;
  int _selectedTab = 0;

  static const _filterOptions = [
    HomeFilterOption('Tous'),
    HomeFilterOption('VIN vérifié'),
    HomeFilterOption('Moins 10M'),
    HomeFilterOption('Toyota'),
    HomeFilterOption('SUV'),
    HomeFilterOption('Douala'),
  ];

  static const _listings = [
    ListingCardData(
      title: 'Toyota RAV4 2020',
      priceFcfa: 14500000,
      location: 'Akwa, Douala',
      mileageKm: 42000,
      imageAsset: AppAssets.carRav4,
      photoCount: 8,
      isVinVerified: true,
      isPro: true,
    ),
    ListingCardData(
      title: 'Hyundai Tucson...',
      priceFcfa: 11200000,
      location: 'Bonanjo, Douala',
      mileageKm: 65000,
      imageAsset: AppAssets.carTucson,
      photoCount: 5,
      isVinVerified: true,
    ),
    ListingCardData(
      title: 'Mercedes GLC 300',
      priceFcfa: 28000000,
      location: 'Bastos, Yaoundé',
      mileageKm: 31000,
      imageAsset: AppAssets.logo,
      photoCount: 12,
      isVinVerified: true,
      isPro: true,
    ),
    ListingCardData(
      title: 'Honda CR-V 2019',
      priceFcfa: 9800000,
      location: 'Ngousso, Yaoundé',
      mileageKm: 78000,
      imageAsset: AppAssets.logo,
      photoCount: 6,
      isVinVerified: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── AppBar custom ──────────────────────────────────────────
              _HomeAppBar(),
              // ── Contenu scrollable ────────────────────────────────────
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Search bar
                    SliverToBoxAdapter(
                      child: HomeSearchBar(
                        unreadNotifications: 2,
                        onMenu: () {},
                        onSearch: () {},
                        onNotifications: () {},
                      ),
                    ),
                    // Filter chips
                    SliverToBoxAdapter(
                      child: FilterChipsRow(
                        options: _filterOptions,
                        selectedIndex: _selectedFilter,
                        onSelected: (i) =>
                            setState(() => _selectedFilter = i),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
                    // Hero promo banner
                    SliverToBoxAdapter(child: PromoBanner(onTap: () {})),
                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                    // Section header "Dernières annonces"
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dernières annonces',
                              style:
                                  context.textStyles.headlineMedium?.copyWith(
                                color: AppColors.trust,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Voir tout',
                                style: context.textStyles.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                    // Liste des annonces
                    SliverList.separated(
                      itemCount: _listings.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) =>
                          ListingCard(data: _listings[i]),
                    ),
                    // Bottom padding (nav bar)
                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Bottom Navigation ──────────────────────────────────────────
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedTab,
          onTap: (i) => setState(() => _selectedTab = i),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// AppBar personnalisée
// ────────────────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          const LikoLogo.app(),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Liko Auto',
            style: context.textStyles.headlineSmall?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline_rounded),
            color: AppColors.trust,
            tooltip: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Bar
// ────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.primarySoft,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search_rounded, color: AppColors.primary),
              label: 'Recherche',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(
                Icons.add_circle_rounded,
                color: AppColors.primary,
              ),
              label: 'Publier',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primary,
              ),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
