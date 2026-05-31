import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/feature_pill.dart';
import 'package:liko_auto/features/onboarding/widgets/onboarding_page_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Onboarding 3/5 — Trouvez le bon garage en un clic.
class GaragesPage extends StatelessWidget {
  const GaragesPage({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      step: 3,
      totalSteps: 5,
      title: 'Trouvez le bon garage en un clic.',
      body:
          "Accédez directement aux meilleurs spécialistes de votre quartier pour l'entretien et la réparation.",
      primaryLabel: 'Continuer',
      onPrimary: onContinue,
      visual: const _GaragesVisual(),
      extra: const Column(
        children: [
          FeaturePill(
            icon: LucideIcons.badgeCheck,
            label: 'Garages certifiés & notés',
          ),
          AppSpacing.gapMd,
          FeaturePill(
            icon: LucideIcons.navigation,
            label: 'Géolocalisation en temps réel',
          ),
          AppSpacing.gapMd,
          FeaturePill(
            icon: LucideIcons.calendarDays,
            label: 'Réservation de RDV intégrée',
          ),
        ],
      ),
    );
  }
}

class _GaragesVisual extends StatelessWidget {
  const _GaragesVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // Fond carte simplifié
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: CustomPaint(painter: _SimpleMapPainter()),
            ),
          ),

          // Pins statiques
          const Positioned(top: 60, left: 90, child: _Pin(active: false)),
          const Positioned(top: 95, left: 190, child: _Pin(active: true)),
          const Positioned(top: 145, left: 125, child: _Pin(active: false)),
          const Positioned(top: 55, left: 265, child: _Pin(active: false)),

          // Badge ville
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.trust,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.building, size: 12, color: Colors.white),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'DOUALA · YAOUNDÉ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Carte garage sélectionné
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.rButton,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      LucideIcons.wrench,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Garage Elite Akwa',
                          style: TextStyle(
                            color: AppColors.trust,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Toyota · Honda',
                          style: TextStyle(
                            color: AppColors.neutral,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.star,
                            size: 14,
                            color: AppColors.rating,
                          ),
                          SizedBox(width: AppSpacing.xxs),
                          Text(
                            '4,9',
                            style: TextStyle(
                              color: AppColors.trust,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _Pin extends StatelessWidget {
  const _Pin({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Icon(
      LucideIcons.mapPin,
      color: active
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.45),
      size: active ? 32 : 24,
      shadows: const [
        Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 2)),
      ],
    );
  }
}

class _SimpleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFE8EEF2),
    );

    final road = Paint()..color = const Color(0xFFF0F4F7);
    final block = Paint()..color = const Color(0xFFD4DCE4);
    final park = Paint()..color = const Color(0xFFCFE8CF);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.35, w * 0.22, h * 0.30),
        const Radius.circular(6),
      ),
      park,
    );

    for (final r in [
      Rect.fromLTWH(w * 0.04, h * 0.05, w * 0.18, h * 0.24),
      Rect.fromLTWH(w * 0.26, h * 0.05, w * 0.14, h * 0.18),
      Rect.fromLTWH(w * 0.44, h * 0.05, w * 0.20, h * 0.20),
      Rect.fromLTWH(w * 0.26, h * 0.26, w * 0.14, h * 0.20),
      Rect.fromLTWH(w * 0.44, h * 0.28, w * 0.20, h * 0.18),
      Rect.fromLTWH(w * 0.68, h * 0.05, w * 0.26, h * 0.30),
      Rect.fromLTWH(w * 0.62, h * 0.38, w * 0.32, h * 0.25),
      Rect.fromLTWH(w * 0.04, h * 0.70, w * 0.88, h * 0.20),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        block,
      );
    }

    canvas
      ..drawRect(Rect.fromLTWH(0, h * 0.29, w, h * 0.05), road)
      ..drawRect(Rect.fromLTWH(0, h * 0.65, w, h * 0.04), road)
      ..drawRect(Rect.fromLTWH(w * 0.22, 0, w * 0.04, h), road)
      ..drawRect(Rect.fromLTWH(w * 0.60, 0, w * 0.04, h), road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
