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
import 'package:liko_auto/shared/widgets/skeleton/skeleton_widgets.dart';

/// Page d'accueil de Liko Auto — search + filtres + hero promo + annonces.
/// Inclut un skeleton de chargement (2s simulé) + animations d'apparition.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedFilter = 0;
  int _selectedTab = 0;
  bool _isLoading = true;

  late final AnimationController _contentController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

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
      title: 'Hyundai Tucson 2019',
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
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    // Simule un chargement réseau de 1,8s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _contentController.forward();
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

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
              // ── AppBar ────────────────────────────────────────────────
              const _HomeAppBar(),
              // ── Contenu ───────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const _SkeletonHome()
                    : SlideTransition(
                        position: _contentSlide,
                        child: FadeTransition(
                          opacity: _contentFade,
                          child: _HomeContent(
                            filterOptions: _filterOptions,
                            selectedFilter: _selectedFilter,
                            onFilterSelected: (i) =>
                                setState(() => _selectedFilter = i),
                            listings: _listings,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedTab,
          onTap: (i) => setState(() => _selectedTab = i),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Skeleton Home — s'affiche pendant 1,8s
// ────────────────────────────────────────────────────────────────────────────
class _SkeletonHome extends StatelessWidget {
  const _SkeletonHome();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // Search bar skeleton
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: SkeletonBox(
              width: double.infinity,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
        ),
        // Filter chips skeleton
        const SliverToBoxAdapter(child: SkeletonFilterChips()),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        // Banner skeleton
        const SliverToBoxAdapter(child: SkeletonBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        // Section header skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(width: 160, height: 20),
                const SkeletonBox(width: 56, height: 16),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        // Listing cards skeleton
        SliverList.separated(
          itemCount: 3,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, __) => const SkeletonListingCard(),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Contenu réel
// ────────────────────────────────────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.listings,
  });

  final List<HomeFilterOption> filterOptions;
  final int selectedFilter;
  final ValueChanged<int> onFilterSelected;
  final List<ListingCardData> listings;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
            options: filterOptions,
            selectedIndex: selectedFilter,
            onSelected: onFilterSelected,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        // Hero promo
        SliverToBoxAdapter(child: PromoBanner(onTap: () {})),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dernières annonces',
                  style: context.textStyles.headlineMedium?.copyWith(
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
        // Annonces avec animation staggerée
        SliverList.separated(
          itemCount: listings.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => _AnimatedCard(
            index: i,
            child: ListingCard(data: listings[i]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 90)),
      ],
    );
  }
}

/// Carte avec animation staggerée au chargement.
class _AnimatedCard extends StatefulWidget {
  const _AnimatedCard({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// AppBar
// ────────────────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

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
          // Badge de localisation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Douala',
                  style: context.textStyles.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
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
              selectedIcon:
                  Icon(Icons.search_rounded, color: AppColors.primary),
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
              selectedIcon:
                  Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
