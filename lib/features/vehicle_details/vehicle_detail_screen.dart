import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/history/providers/view_history_provider.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

class VehicleDetailScreen extends ConsumerStatefulWidget {
  const VehicleDetailScreen({required this.data, super.key});

  final ListingCardData data;

  @override
  ConsumerState<VehicleDetailScreen> createState() =>
      _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(viewHistoryProvider.notifier).record(widget.data);
      }
    });
  }

  ListingCardData get data => widget.data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.gapLg,
                    _buildTags(),
                    AppSpacing.gapMd,
                    _buildTitleAndLocation(context),
                    AppSpacing.gapLg,
                    _buildPriceCard(context),
                    AppSpacing.gapLg,
                    _buildStatsRow(context),
                    AppSpacing.gapXl,
                    _buildSectionHeader(context, 'DESCRIPTION'),
                    _buildDescription(context),
                    AppSpacing.gapXl,
                    _buildSectionHeader(context, 'VÃ‰HICULE EN DÃ‰TAILS'),
                    _buildSpecsGrid(context),
                    AppSpacing.gapXl,
                    _buildSellerInfo(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: AppColors.trust,
      centerTitle: true,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed = constraints.biggest.height < 120;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isCollapsed ? 1.0 : 0.0,
            child: Text(
              '${data.title} â€¢ ${data.year}',
              style: const TextStyle(
                color: Colors.white,
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
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'car_image_${data.title}_${data.priceFcfa}',
              child: Image.asset(
                data.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: AppColors.primarySoft,
                  child: const Center(
                    child: Icon(Icons.directions_car_rounded, size: 64, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            // Photo counter overlay
            Positioned(
              bottom: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '1/${data.photoCount}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          if (data.isVinVerified)
            const _TagChip(
              icon: Icons.verified_rounded,
              label: 'VIN VÃ‰RIFIÃ‰',
              textColor: AppColors.success,
              bgColor: AppColors.successSoft,
            ),
          AppSpacing.gapSm,
          if (data.isPro)
            _TagChip(
              icon: Icons.verified_user_rounded,
              label: 'GARAGE CERTIFIÃ‰',
              textColor: Colors.blue[700]!,
              bgColor: Colors.blue[50]!,
            ),
          AppSpacing.gapSm,
          const _TagChip(
            label: 'DISPONIBLE',
            textColor: AppColors.primary,
            bgColor: AppColors.primarySoft,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndLocation(BuildContext context) {
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
              const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 4),
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

  Widget _buildPriceCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
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
            const SizedBox(height: 2),
            const Text(
              'Prix nÃ©gociable â€¢ Financement possible',
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

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: _StatBox(icon: Icons.speed_rounded, value: data.mileageKm.toGroupedString(), label: 'KM')),
          AppSpacing.gapSm,
          const Expanded(child: _StatBox(icon: Icons.local_gas_station_rounded, value: 'Diesel', label: 'CARB.')),
          AppSpacing.gapSm,
          const Expanded(child: _StatBox(icon: Icons.settings_rounded, value: 'Auto', label: 'BOÃŽTE')),
          AppSpacing.gapSm,
          Expanded(child: _StatBox(icon: Icons.calendar_month_rounded, value: data.year, label: 'ANNÃ‰E')),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        "VÃ©hicule en parfait Ã©tat, premiÃ¨re main au Cameroun. Entretien complet effectuÃ© chez le concessionnaire. Peinture d'origine, aucune rayure. IntÃ©rieur cuir noir comme neuf. Toutes options : CamÃ©ra 360Â°, toit ouvrant, climatisation bi-zone, GPS Afrique.\n\nIdÃ©al pour les longs trajets et une utilisation urbaine prestigieuse. Disponible pour essai immÃ©diat sur Douala.",
        style: context.textStyles.bodyLarge?.copyWith(
          color: AppColors.trust.withValues(alpha: 0.7),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSpecsGrid(BuildContext context) {
    final specs = [
      {'label': 'Marque', 'value': 'Toyota'},
      {'label': 'ModÃ¨le', 'value': data.title.split(' ').first},
      {'label': 'Version', 'value': 'Luxury Edition'},
      {'label': 'Portes', 'value': '5'},
      {'label': 'Places', 'value': '7'},
      {'label': 'Puissance', 'value': '12 CV'},
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
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

  Widget _buildSellerInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elite Garages Douala',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.trust),
                  ),
                  Text(
                    'Membre depuis 2022 â€¢ 48 annonces',
                    style: TextStyle(color: AppColors.neutral, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.neutral),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
              onPressed: () {},
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('APPELER LE VENDEUR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
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
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 10,
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
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: AppColors.trust, fontWeight: FontWeight.w900, fontSize: 13),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.neutral, fontSize: 9, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

