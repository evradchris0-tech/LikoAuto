import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/city_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/home/providers/home_listings_provider.dart';
import 'package:liko_auto/features/home/widgets/city_picker_bottom_sheet.dart';
import 'package:liko_auto/features/home/widgets/home_app_bar.dart';
import 'package:liko_auto/features/home/widgets/home_skeleton.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/home/widgets/promo_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;
  int _unreadNotifs = 2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 8;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Column(
        children: [
          HomeAppBar(
            isScrolled: _isScrolled,
            city: city,
            unreadNotifs: _unreadNotifs,
            onCityTap: _showCityPicker,
            onNotifTap: () => setState(() => _unreadNotifs = 0),
          ),
          Expanded(
            child: listingsAsync.when(
              loading: () => const HomeSkeleton(),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
              data: (listings) => AnimationLimiter(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
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
                              onPressed: () => context.go(AppRoutes.search),
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
                    _buildResponsiveListings(context, listings),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveListings(BuildContext context, List<ListingCardData> listings) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    if (isTablet) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width > 1100 ? 3 : 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: 140, // Height of ListingCard
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: width > 1100 ? 3 : 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: ListingCard(
                      data: listings[index],
                      onTap: () => context.push(
                        AppRoutes.vehicleDetail,
                        extra: listings[index],
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount: listings.length,
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListingCard(
                    data: listings[index],
                    onTap: () => context.push(
                      AppRoutes.vehicleDetail,
                      extra: listings[index],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        childCount: listings.length,
      ),
    );
  }
}
