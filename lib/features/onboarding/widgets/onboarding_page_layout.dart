import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/onboarding/widgets/step_indicator.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/buttons/tertiary_button.dart';

/// Layout animé commun aux 4 pages onboarding.
/// Chaque élément entre séquentiellement avec un stagger :
///   visuel → step → titre → body → extra → CTA
class OnboardingPageLayout extends StatefulWidget {
  const OnboardingPageLayout({
    required this.visual,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.tertiaryLabel,
    this.onTertiary,
    this.extra,
    super.key,
  });

  final Widget visual;
  final int step;
  final int totalSteps;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? tertiaryLabel;
  final VoidCallback? onTertiary;
  final Widget? extra;

  @override
  State<OnboardingPageLayout> createState() => _OnboardingPageLayoutState();
}

class _OnboardingPageLayoutState extends State<OnboardingPageLayout>
    with TickerProviderStateMixin {
  late final AnimationController _masterCtrl;

  // ── 6 animations staggerées ───────────────────────────────────────────────
  late final Animation<double> _visualFade;
  late final Animation<Offset> _visualSlide;

  late final Animation<double> _stepFade;
  late final Animation<Offset> _stepSlide;

  late final Animation<double> _titleFade;
  late final Animation<double> _titleScale;

  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  late final Animation<double> _extraFade;
  late final Animation<Offset> _extraSlide;

  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;

  // Breathing sur le visuel
  late final AnimationController _breathCtrl;
  late final Animation<double> _breathScale;

  @override
  void initState() {
    super.initState();

    // ── Contrôleur principal (800ms total) ───────────────────────────────
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Helper — crée un interval normalisé
    CurvedAnimation interval(
      double begin,
      double end, {
      Curve curve = Curves.easeOut,
    }) => CurvedAnimation(
      parent: _masterCtrl,
      curve: Interval(begin, end, curve: curve),
    );

    // Visuel — t 0..35%
    final v = interval(0, 0.35);
    _visualFade = v;
    _visualSlide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(v);

    // Step indicator — t 10..40%
    final s = interval(0.10, 0.42);
    _stepFade = s;
    _stepSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(s);

    // Titre — t 20..55% avec easeOutBack pour le scale
    final t = interval(0.20, 0.55, curve: Curves.easeOutBack);
    _titleFade = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.20, 0.55, curve: Curves.easeOut),
    );
    _titleScale = Tween<double>(begin: 0.88, end: 1).animate(t);

    // Body — t 32..62%
    final b = interval(0.32, 0.62);
    _bodyFade = b;
    _bodySlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(b);

    // Extra — t 45..75%
    final e = interval(0.45, 0.75);
    _extraFade = e;
    _extraSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(e);

    // CTA bouton — t 58..88%
    final c = interval(0.58, 0.88);
    _ctaFade = c;
    _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _masterCtrl,
            curve: const Interval(0.58, 0.88, curve: Curves.easeOutBack),
          ),
        );

    // ── Breathing du visuel ──────────────────────────────────────────────
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _breathScale = Tween<double>(
      begin: 1,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));

    // Lancer
    _masterCtrl.forward();
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Visuel haut ───────────────────────────────────────────────────
        FadeTransition(
          opacity: _visualFade,
          child: SlideTransition(
            position: _visualSlide,
            child: ScaleTransition(scale: _breathScale, child: widget.visual),
          ),
        ),

        // ── Contenu scrollable ────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  // Step indicator
                  FadeTransition(
                    opacity: _stepFade,
                    child: SlideTransition(
                      position: _stepSlide,
                      child: StepIndicator(
                        current: widget.step,
                        total: widget.totalSteps,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Titre
                  FadeTransition(
                    opacity: _titleFade,
                    child: ScaleTransition(
                      scale: _titleScale,
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: context.textStyles.headlineLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.18,
                          color: AppColors.trust,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Body
                  FadeTransition(
                    opacity: _bodyFade,
                    child: SlideTransition(
                      position: _bodySlide,
                      child: Text(
                        widget.body,
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  // Extra bloc (features, stats…)
                  if (widget.extra != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    FadeTransition(
                      opacity: _extraFade,
                      child: SlideTransition(
                        position: _extraSlide,
                        child: widget.extra,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // ── CTA ───────────────────────────────────────────────────────────
        FadeTransition(
          opacity: _ctaFade,
          child: SlideTransition(
            position: _ctaSlide,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xs,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: widget.primaryLabel,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: widget.onPrimary,
                  ),
                  if (widget.tertiaryLabel != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TertiaryButton(
                      label: widget.tertiaryLabel!,
                      onPressed: widget.onTertiary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
