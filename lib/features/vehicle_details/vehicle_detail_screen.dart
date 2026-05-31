import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/history/providers/view_history_provider.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/listings/domain/api_listing.dart';
import 'package:liko_auto/features/listings/providers/listings_provider.dart';
import 'package:liko_auto/features/photo_gallery/photo_gallery_screen.dart';
import 'package:liko_auto/features/report/report_listing_sheet.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class VehicleDetailScreen extends ConsumerStatefulWidget {
  const VehicleDetailScreen({required this.data, super.key});

  final ListingCardData data;

  @override
  ConsumerState<VehicleDetailScreen> createState() =>
      _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(viewHistoryActionsProvider).record(widget.data);
      }
    });
  }

  ListingCardData get data => widget.data;


  void _openGallery(BuildContext context, {required int initialIndex}) {
    final detailAsync = ref.read(listingDetailProvider(data.id));
    final photos = detailAsync.valueOrNull?.photos ?? [];
    final List<String> assets;
    if (photos.isNotEmpty) {
      assets = photos.map((p) => p.photoUrl).toList();
    } else if (data.imageUrls.isNotEmpty) {
      assets = data.imageUrls;
    } else {
      assets = List<String>.filled(data.photoCount, data.imageAsset);
    }

    context.push(
      AppRoutes.photoGallery,
      extra: PhotoGalleryArgs(
        assets: assets,
        initialIndex: initialIndex,
        heroTagPrefix: 'car_image_${data.title}_${data.priceFcfa}',
        title: data.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(listingDetailProvider(data.id));
    final apiListing = detailAsync.valueOrNull;
    final photos = apiListing?.photos ?? [];
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Scrollbar(
        thumbVisibility: true,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, photos, apiListing),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.gapLg,
                      _buildTitleAndLocation(context, apiListing),
                      AppSpacing.gapLg,
                      _buildPriceCard(context, apiListing),
                      AppSpacing.gapMd,
                      _buildTags(),
                      AppSpacing.gapLg,
                      _buildStatsRow(context, apiListing),
                      AppSpacing.gapXl,
                      _buildSectionHeader(context, 'DESCRIPTION'),
                      _buildDescription(context, apiListing),
                      AppSpacing.gapXl,
                      _buildSectionHeader(context, 'VÉHICULE EN DÉTAILS'),
                      _buildSpecsGrid(context, apiListing),
                      AppSpacing.gapXl,
                      // Rapport Confiance (wireframe 4.1)
                      _buildRapportConfiance(context),
                      AppSpacing.gapXl,
                      _buildSectionHeader(context, 'VENDEUR'),
                      _buildSellerInfo(context, apiListing),  // Tabs Détails / Historique (wireframe 4.1)
                      _buildDetailsTabs(context),
                      AppSpacing.gapXl,
                      // Financement mensualités (wireframe 4.1)
                      _buildFinancementCard(context),
                      AppSpacing.gapXl,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, List<ApiPhoto> photos, ApiListing? apiListing) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed = constraints.biggest.height < 120;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isCollapsed ? 1.0 : 0.0,
            child: Text(
              '${data.title} • ${data.year}',
              style: const TextStyle(
                color: AppColors.trust,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        },
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(
              LucideIcons.arrowLeft,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => context.safePop(),
          ),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(LucideIcons.share2, color: Colors.white, size: 20),
            onPressed: _shareListing,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
            onPressed: () =>
                AppSnack.info(context, 'Ajout aux favoris (Sprint 4)'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: photos.isNotEmpty ? photos.length : (data.imageUrls.isNotEmpty ? data.imageUrls.length : data.photoCount),
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                final String imageUrl;
                if (photos.isNotEmpty) {
                  imageUrl = photos[index].photoUrl;
                } else if (data.imageUrls.isNotEmpty) {
                  imageUrl = data.imageUrls[index];
                } else {
                  imageUrl = data.imageAsset;
                }
                
                var resolvedUrl = imageUrl;
                if (imageUrl.startsWith('/')) {
                  resolvedUrl = '${AppConfig.baseUrl}$imageUrl';
                }
                final isNetwork = resolvedUrl.startsWith('http');
                
                return GestureDetector(
                  onTap: () => _openGallery(context, initialIndex: index),
                  child: Hero(
                    tag: index == 0
                        ? 'car_image_${data.title}_${data.priceFcfa}'
                        : 'car_image_${data.title}_${data.priceFcfa}_$index',
                    child: isNetwork
                        ? Image.network(
                            resolvedUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const ColoredBox(
                                  color: AppColors.primarySoft,
                                  child: Center(
                                    child: Icon(
                                      Icons.directions_car_outlined,
                                      size: 64,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                          )
                        : Image.asset(
                            resolvedUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const ColoredBox(
                                  color: AppColors.primarySoft,
                                  child: Center(
                                    child: Icon(
                                      Icons.directions_car_outlined,
                                      size: 64,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                          ),
                  ),
                );
              },
            ),
            // Photo counter overlay — tap = ouvre galerie
            Positioned(
              bottom: AppSpacing.md,
              right: AppSpacing.md,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.image,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${_currentImageIndex + 1}/${photos.isNotEmpty ? photos.length : (data.imageUrls.isNotEmpty ? data.imageUrls.length : data.photoCount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    final hasTags = data.isVinVerified || data.isPro;
    if (!hasTags) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: _TagChip(
          label: 'DISPONIBLE',
          textColor: AppColors.primary,
          bgColor: AppColors.primarySoft,
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          if (data.isVinVerified) ...[
            const _TagChip(
              icon: LucideIcons.badgeCheck,
              label: 'VIN VÉRIFIÉ',
              textColor: AppColors.success,
              bgColor: AppColors.successSoft,
            ),
            AppSpacing.gapSm,
          ],
          if (data.isPro) ...[
            _TagChip(
              icon: LucideIcons.shieldCheck,
              label: 'GARAGE CERTIFIÉ',
              textColor: Colors.blue[700]!,
              bgColor: Colors.blue[50]!,
            ),
            AppSpacing.gapSm,
          ],
          const _TagChip(
            label: 'DISPONIBLE',
            textColor: AppColors.primary,
            bgColor: AppColors.primarySoft,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndLocation(BuildContext context, ApiListing? apiListing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: context.textStyles.displaySmall?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              height: 1.1,
            ),
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                data.location,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: AppColors.neutral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, ApiListing? apiListing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: AppRadius.rCard,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.priceFcfa.toFcfa(),
              style: context.textStyles.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            const Text(
              'Prix négociable • Financement possible',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ApiListing? apiListing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              icon: LucideIcons.gauge,
              value: (apiListing?.vehicle.mileage ?? data.mileageKm).toGroupedString(),
              label: 'KM',
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            child: _StatBox(
              icon: LucideIcons.fuel,
              value: apiListing?.vehicle.fuelType ?? 'Essence',
              label: 'CARB.',
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            child: _StatBox(
              icon: LucideIcons.settings,
              value: apiListing?.vehicle.transmissionType ?? 'Auto',
              label: 'BOÎTE',
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            child: _StatBox(
              icon: LucideIcons.calendar,
              value: apiListing?.vehicle.year.toString() ?? data.year,
              label: 'ANNÉE',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Text(
        title,
        style: context.textStyles.labelLarge?.copyWith(
          color: AppColors.trust,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, ApiListing? apiListing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        apiListing?.description ??
            "Véhicule en parfait état, première main au Cameroun. Entretien complet effectué chez le concessionnaire. Peinture d'origine, aucune rayure. Intérieur cuir noir comme neuf. Toutes options : Caméra 360°, toit ouvrant, climatisation bi-zone, GPS Afrique.\n\nIdéal pour les longs trajets et une utilisation urbaine prestigieuse. Disponible pour essai immédiat sur Douala.",
        style: context.textStyles.bodyLarge?.copyWith(
          color: AppColors.trust.withValues(alpha: 0.7),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSpecsGrid(BuildContext context, ApiListing? apiListing) {
    final vehicle = apiListing?.vehicle;
    final specs = [
      {'label': 'Marque', 'value': vehicle?.brandName ?? 'Toyota'},
      {'label': 'Modèle', 'value': vehicle?.modelName ?? data.title.split(' ').first},
      {'label': 'Version', 'value': vehicle?.bodyType ?? 'Luxury Edition'},
      {'label': 'Condition', 'value': vehicle?.condition.label ?? 'Occasion'},
      {'label': 'Couleur', 'value': vehicle?.color ?? 'Noire'},
      {'label': 'Puissance', 'value': vehicle?.horsepower != null ? '${vehicle!.horsepower} CV' : '12 CV'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 64,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: specs.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      specs[index]['label']!,
                      style: const TextStyle(
                        color: AppColors.neutral,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      specs[index]['value']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.trust,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSellerInfo(BuildContext context, ApiListing? apiListing) {
    const mockGarage = GarageCardData(
      name: 'Elite Garages Douala',
      specialties: ['Toyota', 'Honda', 'Nissan'],
      rating: 4.8,
      location: 'Douala, Bonapriso',
      imageAsset: 'assets/images/car_rav4.png',
      isCertified: true,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: data.isPro
            ? () => context.push(AppRoutes.garageDetail, extra: mockGarage)
            : null,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/100?img=12',
                ),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Elite Garages Douala',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.trust,
                      ),
                    ),
                    const Text(
                      'Membre depuis 2022 • 48 annonces',
                      style: TextStyle(color: AppColors.neutral, fontSize: 12),
                    ),
                    if (data.isPro) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      const Text(
                        'Voir le profil du garage →',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: AppColors.neutral),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Menu 3 points — signaler
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: PopupMenuButton<String>(
              color: Colors.white,
              icon: const Icon(
                LucideIcons.moreHorizontal,
                color: AppColors.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'share') {
                  _shareListing();
                } else if (value == 'report') {
                  showReportListingSheet(context, listing: data);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(LucideIcons.share2, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text(
                        "Partager l'annonce",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(LucideIcons.flag, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text(
                        "Signaler l'annonce",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
          // Bouton Écrire au vendeur (placé à droite)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('${AppRoutes.chatDetail}?id=new'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(LucideIcons.messageCircle, size: 20),
              label: const Text(
                'Écrire au vendeur',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ── Rapport Confiance (wireframe 4.1) ──────────────────────────────────────
  Widget _buildRapportConfiance(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.shieldCheck, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'RAPPORT DE CONFIANCE',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Row(
              children: [
                    Expanded(
                      child: _ConfidenceItem(
                        icon: LucideIcons.history,
                        label: '1 propriétaire',
                        ok: true,
                      ),
                    ),
                    Expanded(
                      child: _ConfidenceItem(
                        icon: LucideIcons.wrench,
                        label: 'Entretien suivi',
                        ok: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }

  // ── Tabs Détails / Historique (wireframe 4.1) ──────────────────────────────
  Widget _buildDetailsTabs(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                labelColor: AppColors.trust,
                unselectedLabelColor: AppColors.neutral,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.trust.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Détails'),
                  Tab(text: 'Historique'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 160,
              child: TabBarView(
                children: [
                  // Onglet Détails
                  _buildDetailsContent(context),
                  // Onglet Historique
                  _buildHistoryContent(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    return const Column(
      children: [
        _DetailRow(label: 'Couleur extérieure', value: 'Blanc nacré'),
        Divider(height: 1, color: AppColors.outline),
        _DetailRow(label: 'Intérieur', value: 'Cuir noir'),
        Divider(height: 1, color: AppColors.outline),
        _DetailRow(label: 'Garantie', value: '6 mois'),
        Divider(height: 1, color: AppColors.outline),
        _DetailRow(label: 'Disponibilité', value: 'Immédiate'),
      ],
    );
  }

  Widget _buildHistoryContent(BuildContext context) {
    return const Column(
      children: [
        _DetailRow(label: 'Propriétaires', value: '1 seul'),
        Divider(height: 1, color: AppColors.outline),
        _DetailRow(label: 'Dernière vidange', value: 'Jan. 2025'),
        Divider(height: 1, color: AppColors.outline),
        _DetailRow(label: 'Dernier contrôle', value: 'Mar. 2025'),
        Divider(height: 1, color: AppColors.outline),
        _DetailRow(label: 'Accidents déclarés', value: 'Aucun'),
      ],
    );
  }

  // ── Financement mensualités (wireframe 4.1) ────────────────────────────────
  Widget _buildFinancementCard(BuildContext context) {
    // Estimation : 20% apport, 36 mois, taux 8%/an
    final principal = data.priceFcfa * 0.8;
    const monthlyRate = 0.08 / 12;
    const nMonths = 36;
    final monthly =
        (principal * monthlyRate) /
        (1 - (1 / math.pow(1 + monthlyRate, nMonths)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financement disponible',
                    style: TextStyle(
                      color: AppColors.trust,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '~${monthly.round().toGroupedString()} FCFA / mois',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const Text(
                    "sur 36 mois • 20% d'apport • 8% annuel",
                    style: TextStyle(color: AppColors.neutral, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _shareListing() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Découvrez cette annonce sur Liko Auto : ${data.title} à ${data.priceFcfa.toFcfa()}\n'
            'https://likoauto.cm/annonce/${Uri.encodeComponent(data.title)}',
        subject: data.title,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.textColor,
    required this.bgColor,
    this.icon,
  });

  final String label;
  final Color textColor;
  final Color bgColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confidence item (wireframe 4.1 — Rapport de confiance) ──────────────────

class _ConfidenceItem extends StatelessWidget {
  const _ConfidenceItem({
    required this.icon,
    required this.label,
    required this.ok,
  });

  final IconData icon;
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ok
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.errorSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: ok ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.trust,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Detail row (wireframe 4.1 — Tabs Détails/Historique) ────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}





