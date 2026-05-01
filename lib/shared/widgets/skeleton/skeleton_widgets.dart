import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

/// Widget skeleton shimmer générique — réutilisable partout.
/// Usage : [SkeletonBox] pour une boîte, [SkeletonListingCard] pour les annonces.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmer = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment(-1.5 + _shimmer.value * 3, 0),
            end: Alignment(-0.5 + _shimmer.value * 3, 0),
            colors: const [
              Color(0xFFE8E8E8),
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte d'annonce en mode skeleton.
class SkeletonListingCard extends StatelessWidget {
  const SkeletonListingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.rCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.trust.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.card),
              bottomLeft: Radius.circular(AppRadius.card),
            ),
            child: SkeletonBox(width: 120, height: 110),
          ),
          // Infos
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 14),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonBox(width: 100, height: 18),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      SkeletonBox(
                        width: 40,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      SizedBox(width: 6),
                      SkeletonBox(
                        width: 32,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonBox(width: 110, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero banner skeleton
class SkeletonBanner extends StatelessWidget {
  const SkeletonBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: const SkeletonBox(
        width: double.infinity,
        height: 180,
        borderRadius: AppRadius.rCard,
      ),
    );
  }
}

/// Filter chips skeleton
class SkeletonFilterChips extends StatelessWidget {
  const SkeletonFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: const [
          SkeletonBox(
            width: 60,
            height: 36,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          SizedBox(width: 8),
          SkeletonBox(
            width: 90,
            height: 36,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          SizedBox(width: 8),
          SkeletonBox(
            width: 72,
            height: 36,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          SizedBox(width: 8),
          SkeletonBox(
            width: 64,
            height: 36,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
        ],
      ),
    );
  }
}
