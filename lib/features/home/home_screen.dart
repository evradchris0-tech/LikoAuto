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

/// Page d'accueil de Liko Auto.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedFilter = 0;
  int _selectedTab = 0;
  bool _isLoading = true;

  // Scroll scroll-aware AppBar
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  late final AnimationController _contentController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  static const _filterOptions = [
    HomeFilterOption('Tous'),
    HomeFilterOption('VIN vérifié'),
    HomeFilterOption('< 10M FCFA'),
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
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
        );

    // Scroll listener → AppBar ombre
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 24;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });

    // Simule 1,8s chargement
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
    _scrollController.dispose();
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
        body: Column(
          children: [
            // ── AppBar scroll-aware ───────────────────────────────────────
            _ScrollAwareAppBar(isScrolled: _isScrolled),
            // ── Contenu ───────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const _SkeletonHome()
                  : SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: _HomeContent(
                          scrollController: _scrollController,
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
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedTab,
          onTap: (i) => setState(() => _selectedTab = i),
          isScrolled: _isScrolled,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// AppBar scroll-aware — shadow + dégradé quand scrollé
// ────────────────────────────────────────────────────────────────────────────
class _ScrollAwareAppBar extends StatelessWidget {
  const _ScrollAwareAppBar({required this.isScrolled});
  final bool isScrolled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: isScrolled
              ? [
                  BoxShadow(
                    color: AppColors.trust.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            // Logo + titre + localisation + profil
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  const LikoLogo.app(),
                  const SizedBox(width: AppSpacing.sm),
                  Builder(
                    builder: (context) => Text(
                      'Liko Auto',
                      style: context.textStyles.headlineSmall?.copyWith(
                        color: AppColors.trust,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Badge localisation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isScrolled
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Douala',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: AppColors.trust,
                  ),
                ],
              ),
            ),
            // Liseré dégradé bas quand scrollé
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: isScrolled ? 3 : 0,
              decoration: BoxDecoration(
                gradient: isScrolled
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Skeleton
// ────────────────────────────────────────────────────────────────────────────
class _SkeletonHome extends StatelessWidget {
  const _SkeletonHome();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
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
        const SliverToBoxAdapter(child: SkeletonFilterChips()),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        const SliverToBoxAdapter(child: SkeletonBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 160, height: 20),
                SkeletonBox(width: 56, height: 16),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverList.separated(
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
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
    required this.scrollController,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.listings,
  });

  final ScrollController scrollController;
  final List<HomeFilterOption> filterOptions;
  final int selectedFilter;
  final ValueChanged<int> onFilterSelected;
  final List<ListingCardData> listings;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: HomeSearchBar(
            unreadNotifications: 2,
            onMenu: () {},
            onSearch: () {},
            onNotifications: () {},
          ),
        ),
        SliverToBoxAdapter(
          child: FilterChipsRow(
            options: filterOptions,
            selectedIndex: selectedFilter,
            onSelected: onFilterSelected,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(child: PromoBanner(onTap: () {})),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
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
                    'Voir tout →',
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

/// Carte avec stagger d'apparition.
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
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 90), () {
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
// Bottom Navigation
// ────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.isScrolled,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isScrolled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: isScrolled ? 0.14 : 0.07),
            blurRadius: isScrolled ? 28 : 16,
            offset: const Offset(0, -4),
          ),
        ],
        // Liseré dégradé orange en haut de la nav quand scrollé
        border: isScrolled
            ? Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              )
            : const Border(),
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
              selectedIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
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
