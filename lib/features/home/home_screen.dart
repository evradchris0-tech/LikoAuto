// ignore_for_file: unused_element, document_ignores

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/providers/user_role_provider.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/auth/providers/auth_repository.dart';
import 'package:liko_auto/features/garages/domain/garage_entity.dart';
import 'package:liko_auto/features/garages/providers/garages_provider.dart';
import 'package:liko_auto/features/home/providers/home_listings_provider.dart';
import 'package:liko_auto/features/home/widgets/home_skeleton.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/home/widgets/promo_banner.dart';
import 'package:liko_auto/features/notifications_inbox/providers/notifications_inbox_provider.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';
import 'package:liko_auto/shared/widgets/feedback/error_state_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    label: 'Toyota',
    icon: LucideIcons.car,
    count: 45,
    filter: 'toyota',
  ),
  _VehicleCategory(
    label: 'Mercedes',
    icon: LucideIcons.car,
    count: 12,
    filter: 'mercedes',
  ),
  _VehicleCategory(
    label: 'Hyundai',
    icon: LucideIcons.car,
    count: 28,
    filter: 'hyundai',
  ),
  _VehicleCategory(
    label: 'Ford',
    icon: LucideIcons.car,
    count: 15,
    filter: 'ford',
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

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(homeListingsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final authState = ref.watch(authStateChangesProvider);
    final role = ref.watch(userRoleProvider);
    final user = authState.valueOrNull;

    final firstName = () {
      final dn = user?.displayName?.trim() ?? '';
      if (dn.isNotEmpty) return dn.split(' ').first;
      final email = user?.email?.trim() ?? '';
      if (email.isNotEmpty) return email.split('@').first;
      return 'vous';
    }();

    final greetingSubtitle = switch (role) {
      UserRole.buyer => 'Quelle voiture cherchez-vous ?',
      UserRole.seller => 'Gérez et publiez vos annonces',
      UserRole.garage => 'Votre espace professionnel',
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Column(
        children: [
          _HomeAppBar(
            isScrolled: _isScrolled,
            unreadCount: unreadCount,
            onNotifTap: () => context.push(AppRoutes.notificationsInbox),
            onMenuTap: () => Scaffold.of(context).openDrawer(),
            firstName: firstName,
            subtitle: greetingSubtitle,
          ),
          Expanded(
            child: listingsAsync.when(
              loading: () => const HomeSkeleton(),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () => ref.invalidate(homeListingsProvider),
              ),
              data: (listings) {
                final filtered = _activeCategory == null
                    ? listings
                    : listings
                          .where(
                            (l) => l.title.toLowerCase().contains(
                              _activeCategory!.toLowerCase(),
                            ),
                          )
                          .toList();

                return AnimationLimiter(
                  child: Scrollbar(
                    controller: _scrollCtrl,
                    thumbVisibility: true,
                    child: CustomScrollView(
                      controller: _scrollCtrl,
                      slivers: [
                        // Greeting section was moved to app bar
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: AppSpacing.lg,
                              right: AppSpacing.lg,
                              top: AppSpacing.xl,
                            ),
                            child: PromoBanner(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: role == UserRole.buyer
                              ? _EstimerCta(
                                  onTap: () =>
                                      AppSnackPlaceholder.showEstimer(context),
                                )
                              : _PublishCta(
                                  onTap: () => context.push(AppRoutes.sell),
                                  isGarage: role == UserRole.garage,
                                ),
                        ),
                        SliverToBoxAdapter(
                          child: _SectionHeader(
                            title: 'Catégories',
                            onMore: () => context.go(AppRoutes.search),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _CategoriesRow(
                            active: _activeCategory,
                            onSelect: (cat) {
                              setState(() {
                                _activeCategory = _activeCategory == cat
                                    ? null
                                    : cat;
                              });
                            },
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _SectionHeader(
                            title: 'Dernières annonces',
                            onMore: () => context.go(AppRoutes.search),
                          ),
                        ),
                        if (filtered.isEmpty)
                          SliverToBoxAdapter(
                            child: _EmptyCategory(
                              hasFilter: _activeCategory != null,
                            ),
                          )
                        else
                          SliverToBoxAdapter(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: filtered.length > 3
                                  ? 3
                                  : filtered.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 320),
                                  child: SlideAnimation(
                                    verticalOffset: 30,
                                    child: FadeInAnimation(
                                      child: ListingCard(
                                        data: filtered[index],
                                        onTap: () => context.push(
                                          AppRoutes.vehicleDetail,
                                          extra: filtered[index],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: _SectionHeader(
                            title: 'Garages près de vous',
                            onMore: () => context.go('${AppRoutes.search}?tab=garages'),
                          ),
                        ),
                        const SliverToBoxAdapter(child: _GaragesRow()),
                        const SliverToBoxAdapter(child: SizedBox(height: 140)),
                      ],
                    ),
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
    required this.unreadCount,
    required this.onNotifTap,
    required this.onMenuTap,
    required this.firstName,
    required this.subtitle,
  });

  final bool isScrolled;
  final int unreadCount;
  final VoidCallback onNotifTap;
  final VoidCallback onMenuTap;
  final String firstName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: AppColors.surface,
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
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.menu, color: AppColors.trust),
                    onPressed: onMenuTap,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bonjour $firstName !',
                          style: context.textStyles.titleMedium?.copyWith(
                            color: AppColors.trust,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: onNotifTap,
                            icon: const Icon(
                              LucideIcons.bell,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Greeting ───────────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.firstName, required this.subtitle});

  final String firstName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppColors.neutral,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? AppColors.trust : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.trust : AppColors.outline,
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.trust.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: AppColors.neutral.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 18,
                color: isActive ? Colors.white : AppColors.trust,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                category.label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.trust,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.trustSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.count}',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.trust,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        color: AppColors.trustSoft,
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
                    color: AppColors.trust.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.calculator,
                    color: AppColors.trust,
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
                          color: AppColors.trust,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Prix de marché en quelques secondes',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: AppColors.trust.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.arrowRight,
                  color: AppColors.trust,
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

// ── Publier CTA (seller / garage) ──────────────────────────────────────────

class _PublishCta extends StatelessWidget {
  const _PublishCta({required this.onTap, required this.isGarage});

  final VoidCallback onTap;
  final bool isGarage;

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
        color: AppColors.primary,
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
                  child: Icon(
                    isGarage ? LucideIcons.store : LucideIcons.plus,
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
                        isGarage
                            ? 'Publier une annonce garage'
                            : 'Publier une nouvelle annonce',
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "Touchez des milliers d'acheteurs",
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.arrowRight,
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

class _GaragesRow extends ConsumerWidget {
  const _GaragesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(garagesProvider)
        .when(
          loading: () => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (garages) {
            if (garages.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: garages.length.clamp(0, 4),
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, index) {
                  final g = garages[index];
                  return _GarageSmallCard(
                    garage: g,
                    onTap: () {
                      final cardData = GarageCardData(
                        name: g.name,
                        specialties: g.specialties.isNotEmpty ? g.specialties : ['Général'],
                        rating: g.rating,
                        location: g.location,
                        imageAsset: 'assets/images/car_rav4.png',
                        isCertified: g.isCertified,
                      );
                      context.push(AppRoutes.garageDetail, extra: cardData);
                    },
                  );
                },
              ),
            );
          },
        );
  }
}

class _GarageSmallCard extends StatelessWidget {
  const _GarageSmallCard({required this.garage, required this.onTap});

  final GarageEntity garage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
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
                  LucideIcons.wrench,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
              const Icon(LucideIcons.star, size: 12, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                garage.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.trust,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
      ),
      ),
    );
  }
}

// ── Empty category state ───────────────────────────────────────────────────

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({this.hasFilter = false});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.searchX, size: 48, color: AppColors.neutral),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasFilter
                ? 'Aucune annonce dans cette catégorie.'
                : 'Aucune annonce disponible pour le moment.',
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
